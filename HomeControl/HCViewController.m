//
//  HCViewController.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCViewController.h"
#import "HCHueHelper.h"

#import "ISColorWheel.h"
#import "HCBrightnessSlider.h"

@interface HCViewController () <HCBrightnessSliderDelegate>


//- (IBAction)selectedKitchen:(id)sender;
//- (IBAction)selectedBar:(id)sender;
//- (IBAction)selectedLivingArea:(id)sender;

@property (strong, nonatomic) UIButton* kitchenButton;
@property (strong, nonatomic) UIButton* barButton;
@property (strong, nonatomic) UIButton* livingAreaButton;

@property (strong, nonatomic) ISColorWheel* colorWheel;

@property (strong, nonatomic) HCBrightnessSlider* brightnessSlider;

@end


@implementation HCViewController

- (void)loadView {
    [super loadView];
    //@"🍲"
    {   // Buttons
//        UIFont* buttonFont = [UIFont systemFontOfSize:192.0f];
//        {   // Kitchen
//            self.kitchenButton = [UIButton buttonWithType:UIButtonTypeSystem];
//            [self.kitchenButton setTitle:@"🔪" forState:UIControlStateNormal];
//            [self.kitchenButton.titleLabel setFont:buttonFont];
//            [self.kitchenButton addTarget:self action:@selector(pressedKitchen:) forControlEvents:UIControlEventTouchDown];
//            [self.view addSubview:self.kitchenButton];
//        }
    }
    
//    {   // Color Wheel
//        self.colorWheel = [[ISColorWheel alloc] init];
//        [self.view addSubview:self.colorWheel];
//    }
    
    {   // Brightness Slider
        self.brightnessSlider = [[HCBrightnessSlider alloc] init];
        self.brightnessSlider.delegate = self;
        [self.view addSubview:self.brightnessSlider];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    self.kitchenButton.frame = self.view.bounds;
    
    self.brightnessSlider.frame = self.view.bounds;
    self.brightnessSlider.frameHeight = self.view.boundsHeight * 0.5f;
    self.brightnessSlider.frameWidth = self.view.boundsWidth * 0.5f;
    self.brightnessSlider.frameMidX = self.view.boundsMidX;
    self.brightnessSlider.frameMidY = self.view.boundsMidY;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[HCHueHelper sharedInstance] start];
}



- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark -
#pragma mark Interface Actions

- (void)pressedKitchen:(id)sender {
    [HCHueHelper sharedInstance].workingLights = [HCHueHelper sharedInstance].hue.lights;
    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor redColor]];
}


#pragma mark -
#pragma mark HCBrightnessSliderDelegate
- (void)brightnessSliderValueChanged:(CGFloat)value {
    [HCHueHelper sharedInstance].workingLights = [HCHueHelper sharedInstance].hue.lights;
    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor colorWithHue:0.5f saturation:1.0f brightness:value alpha:1.0f]];
}


@end
