//
//  HCHueHelper.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCHueHelper.h"

#define HUE_USERNAME @"72412CF2BF2CB0F90D4577611BD9DA86"

#define LIGHT_MAX_HUE 65280
#define LIGHT_MAX_BRIGHTNESS 255
#define LIGHT_MAX_SATURATION 255


#pragma mark -
#pragma mark Private

////////////////////////////////////////////////////////////////////////////////////////////////////
@interface HCHueHelper ()

@property (strong, nonatomic) DPHue* hue;
@property (strong, nonatomic) NSTimer* hueAuthTimer;

@property (strong, nonatomic) NSTimer* hueUpdateTimer;
@end



////////////////////////////////////////////////////////////////////////////////////////////////////
@implementation HCHueHelper

#pragma mark -
#pragma mark Singleton Implementation

static HCHueHelper *sharedInstance;

+ (HCHueHelper*)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[HCHueHelper alloc] init];
    });
    
    return sharedInstance;
}


- (void)start {
    if (!self.hue) {
        self.hue = [[DPHue alloc] initWithHueHost:@"10.0.0.253" username:HUE_USERNAME];
        [self readHue];
    }
}

- (void)readHue {
    self.hueAuthTimer = [NSTimer scheduledTimerWithTimeInterval:0.5f target:self selector:@selector(obtainAuthorization:) userInfo:nil repeats:YES];
    [self.hueAuthTimer fire];
}

- (void)obtainAuthorization:(NSTimer*)timer {
    [self.hue readWithCompletion:^(DPHue *hue, NSError *err) {
        if (hue.authenticated) {
            NSLog(@"Authenticated!");
            [self.hueAuthTimer invalidate];
            self.hueAuthTimer = nil;
            
            self.hueUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(updateHue:) userInfo:Nil repeats:YES];
        } else {
            NSLog(@"Press hue button!");
            [hue registerUsername];
        }
    }];
}

- (void)setWorkingLightsToColor:(UIColor*)color {
    CGFloat h = 1.0f,s = 0.0f,b = 1.0f,a = 1.0f;
    NSUInteger ih, is, ib;
    [color getHue:&h saturation:&s brightness:&b alpha:&a];
    
    ih = h * LIGHT_MAX_HUE;
    is = s * LIGHT_MAX_SATURATION;
    ib = b * LIGHT_MAX_BRIGHTNESS;
    
    for (DPHueLight* light in self.workingLights) {
        light.hue = @(ih);
        light.saturation = @(is);
        light.brightness = @(ib);
//        [light write];
    }
}

- (void)updateHue:(NSTimer*)timer {
    for (DPHueLight *light in self.hue.lights) {
        [light write];
    }
}

- (DPHueLight*)lightWithName:(NSString*)name {
    for (DPHueLight *light in self.hue.lights) {
        if ([light.name isEqualToString:name]) {
            return light;
        }
    }
    
    return nil;
}

@end
