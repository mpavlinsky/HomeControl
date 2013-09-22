//
//  HCLightGroupButton.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCLightGroupButton.h"

#pragma mark -
#pragma mark Private

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HCLightGroupButton ()

@property (nonatomic) BOOL beingTouched;

@property (strong, nonatomic) UILabel* label;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HCLightGroupButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        
        {   // Label
            self.label = [[UILabel alloc] init];
            self.label.font = [UIFont systemFontOfSize:96.0f];
            self.label.textAlignment = NSTextAlignmentCenter;
            self.label.text = @"🐣";
            [self addSubview:self.label];
        }
    }
    return self;
}

- (void)layoutSubviews {
    {   // Label
        self.label.frame = self.bounds;
    }
}
- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.beingTouched = YES;
    self.activated = !self.activated;
    return YES;
}
- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    return YES;
}
- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    self.beingTouched = NO;
}
- (void)cancelTrackingWithEvent:(UIEvent *)event {
    self.beingTouched = NO;
}

- (void)setActivated:(BOOL)activated {
    _activated = activated;
    
    if (self.delegate) {
        if (_activated) {
            [self.delegate activatedLightGroupButton:self];
        } else {
            [self.delegate deactivatedLightGroupButton:self];
        }
    }
    
    [self setNeedsDisplay];
}
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGFloat inset = 1.0f;
    
    CGRect capsuleRect = rect;
    capsuleRect.origin.x += inset;
    capsuleRect.origin.y += inset;
    capsuleRect.size.width -= inset * 2;
    capsuleRect.size.height -= inset * 2;
    
    const float minX = CGRectGetMinX(capsuleRect);
    const float minY = CGRectGetMinY(capsuleRect);
    
    const float maxX = CGRectGetMaxX(capsuleRect);
    const float maxY = CGRectGetMaxY(capsuleRect);
    
    float arcRadius = 10.0f;//capsuleRect.size.height/2.0f;
    
    UIColor* outlineColor = [UIColor blackColor];
    [outlineColor setStroke];
    
    UIColor* backgroundColor;
    if (!self.activated) {
        backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.2f];
    } else {
        backgroundColor = [UIColor colorWithWhite:0.0f alpha:0.4f];
    }
    [backgroundColor setFill];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // Save the state.
    CGContextSaveGState(ctx);
    
    // Set up drawing parameters.
    CGContextSetLineWidth(ctx, 1.0f);
    
    
    //CGContextSetShouldAntialias(layerCtx, YES);
    
    // Start drawing.
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, maxX - arcRadius, minY);
    
    // End cap one
    CGContextAddArcToPoint(ctx, maxX, minY, maxX, minY + arcRadius, arcRadius);
//    CGContextAddLineToPoint(ctx, maxX, maxY - arcRadius);
    CGContextAddArcToPoint(ctx, maxX, maxY, maxX - arcRadius, maxY, arcRadius);
    
    // Draw the bottom line.
    CGContextAddLineToPoint(ctx, minX + arcRadius, maxY);
    
    // End cap two
    CGContextAddArcToPoint(ctx, minX, maxY, minX, minY, arcRadius);
    CGContextAddArcToPoint(ctx, minX, minY, minX + arcRadius, minY, arcRadius);
    
    // Draw the top line.
    CGPathDrawingMode mode = kCGPathFillStroke;
    CGContextClosePath(ctx);
    
    CGContextDrawPath(ctx, mode);
    
    // Restore the old state.
    CGContextRestoreGState(ctx);
    // Drawing code
}

@end
