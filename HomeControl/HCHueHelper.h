//
//  HCHueHelper.h
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DPHue.h"
#import "DPHueLight.h"

@interface HCHueHelper : NSObject

+ (HCHueHelper*)sharedInstance;
- (void)start;

@property (strong, nonatomic, readonly) DPHue* hue;

// Set me to start manipulating a light.
@property (strong, nonatomic) NSSet* workingLights;

- (void)setWorkingLightsToColor:(UIColor*)color;

- (DPHueLight*)lightWithName:(NSString*)name;

@end
