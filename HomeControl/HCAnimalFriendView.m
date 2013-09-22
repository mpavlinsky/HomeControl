//
//  HCAnimalFriendView.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCAnimalFriendView.h"


#pragma mark -
#pragma mark Eye Class
@interface HCAnimalFriendEyeView : UIView

@property (strong, nonatomic) UIView* targetView;

@property (nonatomic) CGFloat maxTargetDistance;

@property (nonatomic) CGFloat eyeRadius;
@property (nonatomic) CGFloat maxEyeRadius;
@property (nonatomic) CGFloat minEyeRadius;
@end

@implementation HCAnimalFriendEyeView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.maxTargetDistance = 200.0f;
        self.maxEyeRadius = 8.0f;
        self.minEyeRadius = 2.0f;
        self.eyeRadius = 0.5f;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    UIColor* white = [UIColor whiteColor];
    [white set];
    
    CGFloat fixedEyeRadius = (self.maxEyeRadius - self.minEyeRadius) * self.eyeRadius + self.minEyeRadius;
    CGPoint selfMidPoint = CGPointMake(self.frameMidX, self.frameMidY);
    CGPoint fixedTargetPoint = [self.targetView.superview convertPoint:CGPointMake(self.targetView.frameMidX, self.targetView.frameMidY) toView:self];
    
    CGPoint vecToTarget = CGPointMake(fixedTargetPoint.x - selfMidPoint.x, fixedTargetPoint.y - selfMidPoint.y);
    
    float distance = sqrtf(vecToTarget.x * vecToTarget.x + vecToTarget.y * vecToTarget.y);
    vecToTarget = CGPointMake(vecToTarget.x / distance, vecToTarget.y / distance);
    distance = MIN(distance, self.maxTargetDistance);
    float normalDistance = distance / self.maxTargetDistance;

    
    CGSize maxDrift = CGSizeMake(rect.size.width * 0.5f - fixedEyeRadius, rect.size.height * 0.5f - fixedEyeRadius);
    
    CGRect eyeRect = CGRectMake(rect.origin.x + (rect.size.width * 0.5f) - fixedEyeRadius + (vecToTarget.x * (normalDistance * maxDrift.width)), rect.origin.y + (rect.size.height * 0.5f) - fixedEyeRadius + (vecToTarget.y * (normalDistance * maxDrift.height)), fixedEyeRadius*2.0f, fixedEyeRadius*2.0f);
    

//    CGRect eyeRectOne = CGRectMake(self.frameWidth * 0.3f, self.frameHeight * 0.4f, 80.0f, 80.0f);
    CGContextFillEllipseInRect(context, eyeRect);
}

@end

#pragma mark -
#pragma mark Private

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HCAnimalFriendView ()

@property (strong, nonatomic) UIImageView* face;

@property (strong, nonatomic) HCAnimalFriendEyeView* leftEye;
@property (strong, nonatomic) HCAnimalFriendEyeView* rightEye;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HCAnimalFriendView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.autoresizesSubviews = NO;
        self.backgroundColor = [UIColor clearColor];
        {   // Face
            UIImage* faceImage = [UIImage imageNamed:@"pig"];
//            faceImage.resizingMode = UIImageResizingModeStretch;
            self.face = [[UIImageView alloc] initWithImage:faceImage];
            self.face.backgroundColor = [UIColor clearColor];
            [self addSubview:self.face];
        }
        
        {   // Eyes
            self.leftEye = [[HCAnimalFriendEyeView alloc] init];
            [self addSubview:self.leftEye];
            
            self.rightEye = [[HCAnimalFriendEyeView alloc] init];
            [self addSubview:self.rightEye];
        }
    }
    return self;
}

- (void)layoutSubviews {
    {   // Face
        self.face.frameSize = self.boundsSize;
        self.face.frameMidX = self.boundsMidX;
        self.face.frameMidY = self.boundsMidY;
    }
    
    {   // Eyes
        self.leftEye.frameWidth = self.boundsWidth * 0.08f;
        self.leftEye.frameHeight = self.boundsHeight * 0.1f;
        self.leftEye.frameMidX = self.boundsWidth * 0.3775f;
        self.leftEye.frameMidY = self.boundsHeight * 0.4575f;
        
        self.rightEye.frame = self.leftEye.frame;
        self.rightEye.frameMidX = self.boundsWidth * (1.0f - 0.3775f);
    }
}

- (void)setNeedsDisplay {
    [super setNeedsDisplay];
    
    [self.leftEye setNeedsDisplay];
    [self.rightEye setNeedsDisplay];
}

- (void)startAnimating {
    [self rotateHeadLeft];
}

- (void)rotateHeadLeft {
    [UIView animateWithDuration:2.0f animations:^{
        self.transform = CGAffineTransformMakeRotation(M_PI / 16);
    } completion:^(BOOL finished) {
        [self rotateHeadRight];
    }];
}

- (void)rotateHeadRight {
    [UIView animateWithDuration:2.0f animations:^{
        self.transform = CGAffineTransformMakeRotation(-M_PI / 16);
    } completion:^(BOOL finished) {
        [self rotateHeadLeft];
    }];
}

#pragma mark -
#pragma mark Properties

- (void)setEyeTargetView:(UIView *)eyeTargetView {
    self.leftEye.targetView = eyeTargetView;
    self.rightEye.targetView = eyeTargetView;
}

- (UIView*)eyeTargetView {
    return self.leftEye.targetView;
}

- (void)setEyeRadius:(CGFloat)eyeRadius {
    self.leftEye.eyeRadius = eyeRadius;
    self.rightEye.eyeRadius = eyeRadius;
}

- (CGFloat)eyeRadius {
    return self.leftEye.eyeRadius;
}

@end
