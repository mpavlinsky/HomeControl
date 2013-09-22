//
//  HCLightGroupButton.h
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/22/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import <UIKit/UIKit.h>

@class HCLightGroupButton;

@protocol HCLightGroupButtonDelegate <NSObject>

- (void)activatedLightGroupButton:(HCLightGroupButton*)button;
- (void)deactivatedLightGroupButton:(HCLightGroupButton*)button;

@end

@interface HCLightGroupButton : UIControl

@property (weak, nonatomic) id<HCLightGroupButtonDelegate> delegate;

@property (nonatomic) BOOL activated;
@property (nonatomic, readonly) BOOL beingTouched;

@property (strong, nonatomic, readonly) UILabel* label;

@property (strong, nonatomic) NSArray* associatedLights;

@end
