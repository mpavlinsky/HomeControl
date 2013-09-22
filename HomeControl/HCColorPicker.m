//
//  HCColorPicker.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCColorPicker.h"

typedef struct
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    unsigned char a;
    
} PixelRGBA;

typedef struct
{
    float h;
    float s;
    float v;
    
} PixelHSV;

float ISColorWheel_PointDistance (CGPoint p1, CGPoint p2)
{
    return sqrtf((p1.x - p2.x) * (p1.x - p2.x) + (p1.y - p2.y) * (p1.y - p2.y));
}

PixelRGBA ISColorWheel_HSBToRGB (PixelHSV hsv) {
    float h = hsv.h, s = hsv.s, v = hsv.v;
    
    if (v < 0.0001f) {
        PixelRGBA pixel;
        pixel.a = 0;
        return pixel;
    }
    
    h *= 6.0f;
    int i = floorf(h);
    float f = h - (float)i;
    float p = v *  (1.0f - s);
    float q = v * (1.0f - s * f);
    float t = v * (1.0f - s * (1.0f - f));
    
    float r;
    float g;
    float b;
    
    switch (i)
    {
        case 0:
            r = v;
            g = t;
            b = p;
            break;
        case 1:
            r = q;
            g = v;
            b = p;
            break;
        case 2:
            r = p;
            g = v;
            b = t;
            break;
        case 3:
            r = p;
            g = q;
            b = v;
            break;
        case 4:
            r = t;
            g = p;
            b = v;
            break;
        default:        // case 5:
            r = v;
            g = p;
            b = q;
            break;
    }
    
    PixelRGBA pixel;
    pixel.r = r * 255.0f;
    pixel.g = g * 255.0f;
    pixel.b = b * 255.0f;
    pixel.a = 255.0f;
    
    return pixel;
}

PixelRGBA clearRGBAPixel = {0.0f, 0.0f, 0.0f, 0.0f};
PixelHSV clearHSVPixel = {0.0f, 0.0f, 0.0f};

@interface HCColorSelectorView : UIView

@property (strong, nonatomic) UILabel* iconView;
@property (strong, nonatomic) UIColor* selectedColor;

@end

@implementation HCColorSelectorView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.iconView = [[UILabel alloc] init];
        self.iconView.font = [UIFont systemFontOfSize:96.0f];
        self.iconView.textAlignment = NSTextAlignmentCenter;
        self.iconView.text = @"🔎";
        [self addSubview:self.iconView];
        
        self.userInteractionEnabled = NO;
        self.backgroundColor = [UIColor clearColor];
        _selectedColor = [UIColor clearColor];
    }
    
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.iconView.frame = self.bounds;
    self.iconView.frameMidX = self.boundsMidX - 12.0f;
    self.iconView.frameMidY = self.boundsMidY + 12.0f;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGSize colorFillSize = CGSizeMake(58.0f, 58.0f);
    CGRect colorFillRect = CGRectMake(self.boundsMidX - colorFillSize.width * 0.5f, self.boundsMidY - colorFillSize.height * 0.5f, colorFillSize.width, colorFillSize.height);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    [self.selectedColor set];

    CGContextFillEllipseInRect(context, colorFillRect);
}

- (void)setSelectedColor:(UIColor *)selectedColor {
    _selectedColor = selectedColor;
    [self setNeedsDisplay];
}

@end
#pragma mark -
#pragma mark Private

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HCColorPicker ()

// Background Drawing.
@property (strong, nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) CGImageRef backgroundImage;
@property (strong, nonatomic) NSMutableData* backgroundImageData;

@property (nonatomic) CGFloat imageRadius;
@property (nonatomic) CGFloat rainbowRadius;
@property (nonatomic) CGFloat innerRainbowRadius;
@property (nonatomic) CGPoint centerPoint;

@property (strong, nonatomic) HCColorSelectorView* colorSelectorView;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HCColorPicker

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];

        self.imageRadius = 512.0f;
        self.rainbowRadius = 1.0f;
        self.innerRainbowRadius = 0.4f;
        self.centerPoint = CGPointMake(_imageRadius, _imageRadius);

        {   // Background
            self.backgroundImageView = [[UIImageView alloc] init];
            self.backgroundImageView.backgroundColor = [UIColor clearColor];
            [self addSubview:self.backgroundImageView];
            
            [self updateImage];
        }
        
        {   // Selector
            self.colorSelectorView = [[HCColorSelectorView alloc] init];
            [self addSubview:self.colorSelectorView];
        }
    }
    return self;
}

- (void)layoutSubviews {
    self.backgroundImageView.frame = self.bounds;
    self.colorSelectorView.frame = self.bounds;
}

- (UIView*)selectorView {
    return self.colorSelectorView.iconView;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    return YES;
}

- (void)handleTouch:(UITouch*)touch {
    CGPoint touchLocation = [touch locationInView:self];
    
    if (touchLocation.x < 0.0f || touchLocation.x > self.boundsWidth ||
        touchLocation.y < 0.0f || touchLocation.y > self.boundsHeight) {
        return;
    }
    
    CGFloat fixedWidth = (_imageRadius*2) / self.boundsWidth * touchLocation.x;
    CGFloat fixedHeight = _imageRadius / self.boundsHeight * touchLocation.y;

    PixelHSV touchedPixel = [self hsvColorAtPoint:CGPointMake(fixedWidth, fixedHeight)];
    if (touchedPixel.v > 0.0001f) {
        self.colorSelectorView.frameMidX = touchLocation.x;
        self.colorSelectorView.frameMidY = touchLocation.y;
        
        self.colorSelectorView.selectedColor = [UIColor colorWithHue:touchedPixel.h saturation:touchedPixel.s brightness:1.0f alpha:1.0f];
    }
    
    self.hue = touchedPixel.h;
    self.saturation = touchedPixel.s;
    
    if (self.delegate) {
        [self.delegate colorPickerValueChanged];
    }
}

- (PixelHSV)hsvColorAtPoint:(CGPoint)point
{
    float angle = -atan2(point.x - _centerPoint.x, point.y - _centerPoint.y) - M_PI_2;
    if (angle < 0) {
        angle += M_PI * 2;
    }
    
    float dist = ISColorWheel_PointDistance(point, _centerPoint);
    
    // Black outside of the rainbow arc.
    if (dist > _imageRadius * _rainbowRadius || dist < _imageRadius * _innerRainbowRadius) {
        return clearHSVPixel;
    }
    
    float rainbowBreadth = _rainbowRadius - _innerRainbowRadius;
    dist = dist  / (_imageRadius * _rainbowRadius);
    dist = (dist - _innerRainbowRadius) / rainbowBreadth;
    float hue = dist;//  / (_imageRadius * _rainbowRadius);
    
    hue = MIN(hue, 1.0f - .0000001f);
    hue = MAX(hue, 0.0f);
    
    float sat = angle / M_PI;
    
    sat = MIN(sat, 1.0f);
    sat = MAX(sat, 0.0f);
    
    PixelHSV pixel = {hue, sat, 1.0f};
    return pixel;
}

- (PixelRGBA)rgbaColorAtPoint:(CGPoint)point
{
    return ISColorWheel_HSBToRGB([self hsvColorAtPoint:point]);
}

- (void)updateImage
{
    NSLog(@"...Building image....");
    if (self.backgroundImage) {
        CGImageRelease(self.backgroundImage);
        self.backgroundImage = nil;
    }

    int width = _imageRadius * 2.0;
    int height = _imageRadius;

    int dataLength = sizeof(PixelRGBA) * width * height;

    if (dataLength != self.backgroundImageData.length)
    {
        self.backgroundImageData = [NSMutableData dataWithCapacity:dataLength];
    }

    PixelRGBA* _imageData = (PixelRGBA*)self.backgroundImageData.bytes;
    for (int y = 0; y < height; y++)
    {
        for (int x = 0; x < width; x++)
        {
            _imageData[x + y * width] = [self rgbaColorAtPoint:CGPointMake(x, y)];
        }
    }

    CGBitmapInfo bitInfo = kCGBitmapByteOrderDefault | kCGImageAlphaLast;

	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, _imageData, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();

	self.backgroundImage = CGImageCreate(width,
                                height,
                                8,
                                32,
                                width * 4,
                                colorspace,
                                bitInfo,
                                ref,
                                NULL,
                                true,
                                kCGRenderingIntentDefault);


    CGColorSpaceRelease(colorspace);
    CGDataProviderRelease(ref);

    self.backgroundImageView.image = [UIImage imageWithCGImage:self.backgroundImage];
    NSLog(@"All done!");

//    [self setNeedsDisplay];
}



@end
