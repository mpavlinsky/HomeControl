//
//  RACapsuleProgressView.h
//  RipplingAbs
//
//  Created by Matthew Pavlinsky on 7/8/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RACapsuleProgressView : UIView


typedef enum {
    eProgressStateGood = 0,
    eProgressStateCaution,
    eProgressStateEmergency,
    eProgressStateCount
} ProgressState;

typedef int (^QueryProgressState)(float progress);


@property (nonatomic) float progress;
@property (nonatomic) ProgressState progressState;

- (void)setProgress:(float)progress animated:(BOOL)animated;
- (void)setProgressStateQueryBlock:(QueryProgressState)queryBlock;

- (CGColorRef)barColor;
- (CGColorRef)bgColor;

@end
