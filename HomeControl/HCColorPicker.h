//
//  HCColorPicker.h
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HCColorPickerDelegate

@required
- (void)colorPickerValueChanged;

@end

@interface HCColorPicker : UIControl

@property (weak, nonatomic) id<HCColorPickerDelegate> delegate;
@property (nonatomic) CGFloat hue;
@property (nonatomic) CGFloat saturation;

@property (strong, nonatomic, readonly) UILabel* selectorView;

@end