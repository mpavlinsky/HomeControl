//
//  HCBrightnessSlider.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCBrightnessSlider.h"

#import "RACapsuleProgressView.h"

typedef struct
{
    unsigned char r;
    unsigned char g;
    unsigned char b;
    
} PixelRGB;

#pragma mark -
#pragma mark Private

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HCBrightnessSlider ()

@property (strong, nonatomic) RACapsuleProgressView* backgroundView2;

// Background Drawing.
@property (strong, nonatomic) UIImageView* backgroundImageView;
@property (nonatomic) CGImageRef backgroundImage;
@property (strong, nonatomic) NSMutableData* backgroundImageData;


// Knob
@property (strong, nonatomic) UILabel* knobView;
@property (strong, nonatomic) NSArray* phasesOfTheKnob;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HCBrightnessSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        {   // Background
            self.backgroundImageView = [[UIImageView alloc] init];
            [self addSubview:self.backgroundImageView];
            
            [self updateImage];
        }
        
        self.backgroundView2 = [[RACapsuleProgressView alloc] init];
        self.backgroundView2.userInteractionEnabled = NO;
        self.backgroundView2.progress = 1.0f;
        [self addSubview:self.backgroundView2];
        
        {   // Knob
            self.phasesOfTheKnob = @[@"🌚",@"🌒",@"🌓",@"🌔",@"🌝"];
            
            self.knobView = [[UILabel alloc] init];
            self.knobView.font = [UIFont systemFontOfSize:96.0f];
            self.knobView.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.knobView];
        }
        
        self.value = 0.0f;
        
//        [self addTarget:self action:@selector(touchedView:) forControlEvents:UIControlEventTouchDown];
    }
    return self;
}

- (void)layoutSubviews {
    self.backgroundImageView.frame = self.bounds;
    
    
    self.backgroundView2.frame = CGRectMake(0, self.boundsMidY, self.boundsWidth, 25);
    {   // Knob
        self.knobView.frameSize = CGSizeMake(self.frameHeight, self.frameHeight);
    }
}

- (void)touchedView:(id)sender {
    NSLog(@"Touched view.");
}

#pragma mark -
#pragma mark Properties

- (void)setValue:(CGFloat)value {
    _value = MIN(value, 1.0f);
    _value = MAX(value, 0.0f);
    
    self.knobView.frameMidX = self.boundsWidth * _value;
    
    NSUInteger knobPhase = MIN(self.phasesOfTheKnob.count * _value, self.phasesOfTheKnob.count - 1);
    self.knobView.text = self.phasesOfTheKnob[knobPhase];
    
    if (self.delegate) {
        [self.delegate brightnessSliderValueChanged:_value];
    }
}

#pragma mark -
#pragma mark Knob handling: lol

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    return YES;
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    [self handleTouch:touch];
    return YES;
}

- (void)handleTouch:(UITouch*)touch {
    CGFloat touchX = [touch locationInView:self].x;
    touchX = MIN(touchX, self.boundsMaxX);
    touchX = MAX(touchX, self.boundsMinX);
    
    self.value = touchX / self.boundsWidth;
}

- (void)updateImage
{
    NSLog(@"...Building image....");
    if (self.backgroundImage) {
        CGImageRelease(self.backgroundImage);
        self.backgroundImage = nil;
    }
    
    int width = 1024;//_radius * 2.0;
    int height = 1;//_radius * 2.0;
    
    int dataLength = sizeof(PixelRGB) * width * height;
    
    if (dataLength != self.backgroundImageData.length)
    {
        self.backgroundImageData = [NSMutableData dataWithCapacity:dataLength];
    }
    
    PixelRGB* _imageData = (PixelRGB*)self.backgroundImageData.bytes;
    for (int x = 0; x < width; x++)
    {
        CGFloat lerp = (CGFloat)x/width;
        PixelRGB color;
        color.r = color.g = color.b = (unsigned char)(lerp * 255);
        for (int y = 0; y < height; y++)
        {
            _imageData[x + y * width] = color;
        }
    }
    
    CGBitmapInfo bitInfo = kCGBitmapByteOrderDefault;
    
	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, _imageData, dataLength, NULL);
	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
    
	self.backgroundImage = CGImageCreate(width,
                                height,
                                8,
                                24,
                                width * 3,
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
