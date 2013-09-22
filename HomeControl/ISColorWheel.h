/*
 Copyright (c) 2012 Inline Studios
 Licensed under the MIT license: http://www.opensource.org/licenses/mit-license.php
*/

#import <UIKit/UIKit.h>

@class ISColorWheel;

@protocol ISColorWheelDelegate <NSObject>
@required
- (void)colorWheelDidChangeColor:(ISColorWheel*)colorWhee;
@end


@interface ISColorWheel : UIView

@property(nonatomic, assign)CGPoint touchPoint;
@property(nonatomic, retain)UIView* knobView;
@property(nonatomic, assign)CGSize knobSize;
@property(nonatomic, assign)float brightness;
@property(nonatomic, assign)bool continuous;
@property(nonatomic, assign)id <ISColorWheelDelegate> delegate;

- (void)updateImage;

- (void)setCurrentColor:(UIColor*)color;
- (UIColor*)currentColor;


@end
