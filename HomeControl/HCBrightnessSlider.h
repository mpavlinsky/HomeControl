//
//  HCBrightnessSlider.h
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HCBrightnessSliderDelegate
@required
- (void)brightnessSliderValueChanged:(CGFloat)value;

@end

@interface HCBrightnessSlider : UIControl

@property (weak, nonatomic) id<HCBrightnessSliderDelegate> delegate;
@property (nonatomic) CGFloat value;

@end
