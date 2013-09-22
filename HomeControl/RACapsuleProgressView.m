//
//  RACapsuleProgressView.m
//  RipplingAbs
//
//  Created by Matthew Pavlinsky on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "RACapsuleProgressView.h"

#pragma mark -
#pragma mark Globals
// The amount the capsule content is inset from the edges of the view. So if we draw outlines after words they don't clip with the sides of the view.
#define kCapsuleHInset 2.0f
#define kCapsuleVInset 0.0f

#define kLineWidth 3.0f
#define kLineSpacing 8.0f
#define kLineBreadthToHeightRatio 1.0f

// The masks we have already created, so we don't make a bunch that are the same size.
static NSMutableArray* capsuleMasks = nil;

// Fill colors for different statuses
static CGColorRef goodStatusBarColor = nil;
static CGColorRef cautionStatusBarColor = nil;
static CGColorRef emergencyStatusBarColor = nil;

// And backgrounds
static CGColorRef goodStatusBGColor = nil;
static CGColorRef cautionStatusBGColor = nil;
static CGColorRef emergencyStatusBGColor = nil;

// Crosshatch
static CGColorRef crosshatchLineColor = nil;

// Outline
static CGColorRef outlineBorderColor = nil;
static CGColorRef outlineInsideColor = nil;

@interface RACapsuleProgressView () {
    CGLayerRef _capsuleLayer;
    UIImage* _capsuleMask;
    
    float _progress;
    QueryProgressState _queryProgressState;
    ProgressState _progressState;
}

@end

@implementation RACapsuleProgressView

@synthesize progressState;

#pragma mark -
#pragma mark Class Methods and Mask Generation

+ (void)initialize {
    // Initialize our globals here.
    capsuleMasks = [NSMutableArray array];
    
    // Colors
    goodStatusBarColor = CGColorRetain([UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:1.0f].CGColor);//CGColorRetain([UIColor colorWithRed:0.4f green:1.0f blue:0.4f alpha:1.0f].CGColor);
    cautionStatusBarColor = CGColorRetain([UIColor colorWithRed:1.0f green:1.0f blue:0.5f alpha:1.0f].CGColor);
    emergencyStatusBarColor = CGColorRetain([UIColor colorWithRed:1.0f green:0.4f blue:0.4f alpha:1.0f].CGColor);

    goodStatusBGColor = CGColorRetain([UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f].CGColor);
    cautionStatusBGColor = CGColorRetain([UIColor colorWithRed:1.0f green:1.0f blue:0.95f alpha:1.0f].CGColor);
    emergencyStatusBGColor = CGColorRetain([UIColor colorWithRed:1.0f green:0.95f blue:0.95f alpha:1.0f].CGColor);
    
    crosshatchLineColor = CGColorRetain([UIColor colorWithWhite:0.9f alpha:1.0f].CGColor);

    outlineInsideColor = CGColorRetain([UIColor colorWithWhite:0.2f alpha:1.0f].CGColor);

     outlineBorderColor = CGColorRetain([UIColor colorWithWhite:0.75f alpha:1.0f].CGColor);
}



+ (UIImage*)getCapsuleMaskWithSize:(CGSize)size {
    for (UIImage* mask in capsuleMasks) {
        if (CGSizeEqualToSize(mask.size, size)) {
            return mask;
        }
    }
    
    UIImage* newMask = [self makeCapsuleMaskForSize:size];
    [capsuleMasks addObject:newMask];
    return newMask;
}

+ (UIImage*)makeCapsuleMaskForSize:(CGSize)size {
    
    const float hMaskInset = kCapsuleHInset + 1.0f;
    const float vMaskInset = kCapsuleVInset + 1.0f;
    float capsuleWidth = size.width - hMaskInset * 2;
    float capsuleHeight = size.height - vMaskInset * 2;
    float arcRadius = capsuleHeight/2.0f;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
    
    CGContextRef bmpCtx = CGBitmapContextCreate(NULL,
                                                size.width,
                                                size.height,
                                                8,
                                                size.width,
                                                colorSpace,
                                                0);
    
    // Method Two
    {
        CGContextSetGrayStrokeColor(bmpCtx, 1, 1);// 13
        CGContextSetLineCap(bmpCtx, kCGLineCapRound);
        CGContextSetLineWidth(bmpCtx, capsuleHeight);
        
        CGContextBeginPath(bmpCtx);
        CGContextMoveToPoint(bmpCtx, arcRadius + hMaskInset, arcRadius + vMaskInset);
        CGContextAddLineToPoint(bmpCtx, capsuleWidth - arcRadius + hMaskInset, arcRadius + vMaskInset);
        
        CGContextStrokePath(bmpCtx);
    }  
    
    UIImage* capsuleMask = [UIImage imageWithCGImage:CGBitmapContextCreateImage(bmpCtx)];
    
    CGContextRelease(bmpCtx);
    CGColorSpaceRelease(colorSpace);
    
    return capsuleMask;
}



#pragma mark -
#pragma mark Initialization

- (void)initialize {
    _progress = 0.0f;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initialize];
    }
    return self;
}

- (void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    if (!_capsuleMask && self.frameHeight != 0 && self.frameWidth != 0) {
        _capsuleMask = [RACapsuleProgressView getCapsuleMaskWithSize:self.frame.size];
    }
}

#pragma mark -
#pragma mark Helper Methods

- (void)changedProgress {
    if (_queryProgressState) {
        _progressState = _queryProgressState(_progress);
    }
    
    _capsuleLayer = NULL;
    [self setNeedsDisplay];
}

- (CGColorRef)barColor {
    return goodStatusBarColor;

    switch (_progressState) {
        case eProgressStateGood:
            return goodStatusBarColor;
        case eProgressStateCaution:
            return cautionStatusBarColor;
        default:
            return emergencyStatusBarColor;
    }
}


- (CGColorRef)bgColor {
    return goodStatusBGColor;

    switch (_progressState) {
        case eProgressStateGood:
            return goodStatusBGColor;
        case eProgressStateCaution:
            return cautionStatusBGColor;
        default:
            return emergencyStatusBGColor;
    }
}



#pragma mark -
#pragma mark Outfacing Methods

- (float)progress {
    return _progress;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    [self changedProgress];
}

- (void)setProgress:(float)progress animated:(BOOL)animated {
    // TODO: Implement animation.
    _progress = progress;
    [self changedProgress];
}

- (void)setProgressStateQueryBlock:(QueryProgressState)queryBlock {
    _queryProgressState = queryBlock;
}

#pragma mark -
#pragma mark Drawing

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if (!_capsuleLayer) {
        [self createCapsuleLayerInContext:ctx rect:rect];
    }
    
    CGContextDrawLayerInRect(ctx, rect, _capsuleLayer);
}

- (void)createCapsuleLayerInContext:(CGContextRef)ctx rect:(CGRect)rect {
    
    CGFloat scale = [[UIScreen mainScreen] scale]; 
    rect.size.width *= scale;
    rect.size.height *= scale;

    const float lineWidth = kLineWidth * scale;
    const float lineSpacing = kLineSpacing * scale;
    const float lineBreadth = rect.size.height;
    CGRect progressAreaRect = rect;
    progressAreaRect.size.width *= self.progress;
    
    // Make the layer.
    _capsuleLayer = CGLayerCreateWithContext(ctx, rect.size, NULL);
    CGContextRef layerCtx = CGLayerGetContext(_capsuleLayer);
    
    // Save our current state (clean)
    CGContextSaveGState(layerCtx);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    
    // Clip to capsule and fill 'background.
    CGContextClipToMask(layerCtx, rect, _capsuleMask.CGImage);
    CGContextSetFillColorWithColor(layerCtx, [self bgColor]);
    CGContextFillRect(layerCtx,rect);
    
    

    
    // Clip to our current progress and fill the current progress.
    CGContextClipToRect(layerCtx, progressAreaRect);
    CGContextSetFillColorWithColor(layerCtx, [self barColor]);
    CGContextFillRect(layerCtx,rect);
    
    // Gradient test.
    
    NSArray *colors = [NSArray arrayWithObjects:(id)[self barColor], [self bgColor], nil];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)colors, NULL);
    CGPoint startPoint = CGPointMake(CGRectGetMinX(rect), CGRectGetMidY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMaxX(rect), CGRectGetMidY(rect));
    
    CGContextSaveGState(layerCtx);
    //CGContextAddRect(layerCtx, rect);
    //CGContextClip(layerCtx);
    CGContextDrawLinearGradient(layerCtx, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(layerCtx);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
    
    CGContextSetShouldAntialias(layerCtx, YES);
    
    // Draw shine
    UIColor *temp2 = [UIColor colorWithWhite:1.0f alpha:0.6f];
    CGContextSetLineWidth(layerCtx, 2.0f * scale);
    CGContextSetStrokeColorWithColor(layerCtx, temp2.CGColor);
    CGContextSetLineCap(layerCtx, kCGLineCapRound);

    CGContextBeginPath(layerCtx);
    CGContextMoveToPoint(layerCtx, rect.size.width, rect.size.height * 0.45f);
    CGContextAddLineToPoint(layerCtx, rect.size.height * 0.4f, rect.size.height * 0.3f);
    CGContextStrokePath(layerCtx);

    
    UIColor *temp = [UIColor colorWithWhite:1.0f alpha:0.50f];
    // Draw all the cross-hatch style lines.
    CGContextSetStrokeColorWithColor(layerCtx, temp.CGColor);
    CGContextSetLineWidth(layerCtx, lineWidth);
    CGContextSetLineCap(layerCtx, kCGLineCapRound);
    for (float pos = -lineBreadth - 0.5f; pos < rect.size.width; pos += lineSpacing) {
        CGContextBeginPath(layerCtx);
        CGContextMoveToPoint(layerCtx, pos, rect.size.height);
        CGContextAddLineToPoint(layerCtx, pos + lineBreadth, 0);
        CGContextStrokePath(layerCtx);
    }
    
    // Restore our context to the non-clipped state.
    CGContextRestoreGState(layerCtx);
    
    CGRect insetRect = rect;
    insetRect.origin.x += kCapsuleHInset*scale;
    insetRect.origin.y += kCapsuleVInset*scale;
    insetRect.size.width -= kCapsuleHInset * 2*scale;
    insetRect.size.height -= kCapsuleVInset * 2*scale;

    // Draw the outline.
    //    [self drawCapsuleOutlineInContext:layerCtx rect:insetRect inset:2.0f thickness:4.0f color:outlineBorderColor];
    //    [self drawCapsuleOutlineInContext:layerCtx rect:insetRect inset:2.0f thickness:1.0f color:outlineInsideColor];
        [self drawCapsuleOutlineInContext:layerCtx rect:insetRect inset:0.5f*scale thickness:1.0f*scale color:outlineBorderColor];
        [self drawCapsuleOutlineInContext:layerCtx rect:insetRect inset:1.0f*scale thickness:1.0f*scale color:outlineInsideColor];
}

- (void)drawCapsuleOutlineInContext:(CGContextRef)ctx rect:(CGRect)rect inset:(float)inset thickness:(float)thickness color:(CGColorRef)color {
    
    CGRect capsuleRect = rect;
    capsuleRect.origin.x += inset;
    capsuleRect.origin.y += inset;
    capsuleRect.size.width -= inset * 2;
    capsuleRect.size.height -= inset * 2;

    const float minX = CGRectGetMinX(capsuleRect);
    const float minY = CGRectGetMinY(capsuleRect);

    const float maxX = CGRectGetMaxX(capsuleRect);
    const float maxY = CGRectGetMaxY(capsuleRect);
    
    float arcRadius = capsuleRect.size.height/2.0f;
    
    // Save the state.
    CGContextSaveGState(ctx);
    
    
    // Set up drawing parameters.
    CGContextSetStrokeColorWithColor(ctx, color);
    CGContextSetLineWidth(ctx, thickness);

    
    //CGContextSetShouldAntialias(layerCtx, YES);
    
    // Start drawing.
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, maxX - arcRadius, minY);
    
    // End cap one
    CGContextAddArcToPoint(ctx, maxX, minY, maxX, maxY, arcRadius);
    CGContextAddArcToPoint(ctx, maxX, maxY, maxX - arcRadius, maxY, arcRadius);
    
    // Draw the bottom line.
    CGContextAddLineToPoint(ctx, minX + arcRadius, maxY);
    
    // End cap two
    CGContextAddArcToPoint(ctx, minX, maxY, minX, minY, arcRadius);
    CGContextAddArcToPoint(ctx, minX, minY, minX + arcRadius, minY, arcRadius);
    
    // Draw the top line.
    CGContextClosePath(ctx); 
    CGContextStrokePath(ctx);
    
    // Restore the old state.
    CGContextRestoreGState(ctx);
}

@end

