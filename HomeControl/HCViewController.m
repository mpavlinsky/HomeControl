//
//  HCViewController.m
//  HomeControl
//
//  Created by Matthew Pavlinsky on 9/21/13.
//  Copyright (c) 2013 Matthew Pavlinsky. All rights reserved.
//

#import "HCViewController.h"
#import "HCHueHelper.h"

//#import "ISColorWheel.h"
#import "HCBrightnessSlider.h"
#import "HCColorPicker.h"

@interface HCViewController () <
HCBrightnessSliderDelegate,
HCColorPickerDelegate>


//- (IBAction)selectedKitchen:(id)sender;
//- (IBAction)selectedBar:(id)sender;
//- (IBAction)selectedLivingArea:(id)sender;

@property (strong, nonatomic) UIButton* kitchenButton;
@property (strong, nonatomic) UIButton* barButton;
@property (strong, nonatomic) UIButton* livingAreaButton;

@property (strong, nonatomic) HCBrightnessSlider* brightnessSlider;

@property (strong, nonatomic) HCColorPicker* colorPicker;

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
    
    {   // Color Picker
        self.colorPicker = [[HCColorPicker alloc] init];
        self.colorPicker.delegate = self;
        [self.view addSubview:self.colorPicker];
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
//    self.kitchenButton.frame = self.view.bounds;
    
//    self.brightnessSlider.frame = self.view.bounds;
//    self.brightnessSlider.frameHeight = self.view.boundsHeight * 0.5f;
//    self.brightnessSlider.frameWidth = self.view.boundsWidth * 0.5f;
//    self.brightnessSlider.frameMidX = self.view.boundsMidX;
//    self.brightnessSlider.frameMidY = self.view.boundsMidY;
//    

    self.colorPicker.frameSize = CGSizeMake(600, 300);
    self.colorPicker.frameMaxX = self.view.boundsMaxX - 20;
    self.colorPicker.frameMidY = self.view.boundsMidY;
    
//    self.colorPicker.frame = CGRectMake(self.view.boundsMidX, self.view.boundsMidY, 400, 200);
    self.brightnessSlider.frameSize = CGSizeMake(600.f, 100.0f);
    self.brightnessSlider.frameMaxY = self.colorPicker.frameMinY;
    self.brightnessSlider.frameMidX = self.colorPicker.frameMidX;
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


- (void)updateLights {
    [HCHueHelper sharedInstance].workingLights = [HCHueHelper sharedInstance].hue.lights;
    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor colorWithHue:self.colorPicker.hue saturation:self.colorPicker.saturation brightness:self.brightnessSlider.value alpha:1.0f]];
}

#pragma mark -
#pragma mark Interface Actions

- (void)pressedKitchen:(id)sender {
    [HCHueHelper sharedInstance].workingLights = [HCHueHelper sharedInstance].hue.lights;
    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor redColor]];
}


#pragma mark -
#pragma mark HCBrightnessSliderDelegate
- (void)brightnessSliderValueChanged {
    [self updateLights];
}


#pragma mark -
#pragma mark HCColorPickerDelegate
- (void)colorPickerValueChanged {
    [self updateLights];
}

@end
