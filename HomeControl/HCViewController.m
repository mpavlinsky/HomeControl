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
#import "HCLightGroupButton.h"
#import "HCBrightnessSlider.h"
#import "HCColorPicker.h"
#import "HCAnimalFriendView.h"

@interface HCViewController () <
HCBrightnessSliderDelegate,
HCColorPickerDelegate,
HCLightGroupButtonDelegate
>


//- (IBAction)selectedKitchen:(id)sender;
//- (IBAction)selectedBar:(id)sender;
//- (IBAction)selectedLivingArea:(id)sender;

@property (strong, nonatomic) UIImageView* backgroundImage;

@property (strong, nonatomic) NSMutableArray* lightGroupButtons;
@property (strong, nonatomic) HCLightGroupButton* kitchenButton;
@property (strong, nonatomic) HCLightGroupButton* barButton;
@property (strong, nonatomic) HCLightGroupButton* livingAreaButton;

@property (strong, nonatomic) HCBrightnessSlider* brightnessSlider;

@property (strong, nonatomic) HCColorPicker* colorPicker;

@property (strong, nonatomic) HCAnimalFriendView* animalFriendView;

@end


@implementation HCViewController

- (void)loadView {
    [super loadView];
    
    {   // Background
        self.backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"grassbackground"]];
        [self.view addSubview:self.backgroundImage];
    }
    //@"🍲"
    {   // Buttons
        self.lightGroupButtons = [NSMutableArray array];
        {   // Kitchen
            self.kitchenButton = [[HCLightGroupButton alloc] init];// [UIButton buttonWithType:UIButtonTypeSystem];
            self.kitchenButton.label.text = @"🔪";
            self.kitchenButton.delegate = self;
            self.kitchenButton.associatedLights = @[@"Kitchen 1", @"Kitchen 2"];
            [self.view addSubview:self.kitchenButton];
            
            [self.lightGroupButtons addObject:self.kitchenButton];
        }
        
        {   // Bar
            self.barButton = [[HCLightGroupButton alloc] init];// [UIButton buttonWithType:UIButtonTypeSystem];
            self.barButton.label.text = @"🍶";
            self.barButton.delegate = self;
            self.barButton.associatedLights = @[@"Bar 1", @"Wall 1"];
            [self.view addSubview:self.barButton];
            
            [self.lightGroupButtons addObject:self.barButton];
        }
        
        {   // Living Area
            self.livingAreaButton = [[HCLightGroupButton alloc] init];// [UIButton buttonWithType:UIButtonTypeSystem];
            self.livingAreaButton.label.text = @"🎎";
            self.livingAreaButton.delegate = self;
            self.livingAreaButton.associatedLights = @[@"Fan 1", @"Fan 2", @"Fan 3"];
            [self.view addSubview:self.livingAreaButton];
            
            [self.lightGroupButtons addObject:self.livingAreaButton];
        }
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
    
    {   // Animal Friend
        self.animalFriendView = [[HCAnimalFriendView alloc] init];
        [self.view addSubview:self.animalFriendView];
    }
    
    {   // Color Picker
        self.colorPicker = [[HCColorPicker alloc] init];
        self.colorPicker.delegate = self;
        [self.view addSubview:self.colorPicker];
    }
    
    self.animalFriendView.eyeTargetView = self.colorPicker.selectorView;

}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    {   // Background
        self.backgroundImage.frame = self.view.bounds;
    }
    
    CGSize buttonSize = CGSizeMake(150, 150);
    CGFloat buttonPadding = 40.0f;
    
    self.barButton.frameSize = buttonSize;
    self.barButton.frameMidX = self.view.boundsMidX;
    self.barButton.frameMinY = self.view.boundsMinY + 60.0f;
    
    self.kitchenButton.frameSize = buttonSize;
    self.kitchenButton.frameMidX = self.barButton.frameMidX - buttonSize.width - buttonPadding;
    self.kitchenButton.frameMinY = self.barButton.frameMinY + buttonPadding;

    self.livingAreaButton.frameSize = buttonSize;
    self.livingAreaButton.frameMidX = self.barButton.frameMidX + buttonSize.width + buttonPadding;
    self.livingAreaButton.frameMinY = self.barButton.frameMinY + buttonPadding;
//    self.kitchenButton.frame = self.view.bounds;
    
//    self.brightnessSlider.frame = self.view.bounds;
//    self.brightnessSlider.frameHeight = self.view.boundsHeight * 0.5f;
//    self.brightnessSlider.frameWidth = self.view.boundsWidth * 0.5f;
//    self.brightnessSlider.frameMidX = self.view.boundsMidX;
//    self.brightnessSlider.frameMidY = self.view.boundsMidY;
//    

    self.colorPicker.frameSize = CGSizeMake(600, 300);
    self.colorPicker.frameMidX = self.view.boundsMidX;
    self.colorPicker.frameMaxY = self.view.boundsMaxY - 70.0f;
    
//    self.colorPicker.frame = CGRectMake(self.view.boundsMidX, self.view.boundsMidY, 400, 200);
    self.brightnessSlider.frameSize = CGSizeMake(600.f, 100.0f);
    self.brightnessSlider.frameMaxY = self.colorPicker.frameMinY;
    self.brightnessSlider.frameMidX = self.colorPicker.frameMidX;
    
    self.animalFriendView.frameSize = CGSizeMake(250.0f, 250.0f);
    self.animalFriendView.frameMidX = self.colorPicker.frameMidX;
    self.animalFriendView.frameMidY = self.colorPicker.frameMaxY - 20.0f;
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
    NSMutableSet* workingLights = [NSMutableSet set];
    for (HCLightGroupButton* lightGroupButton in self.lightGroupButtons) {
        if (lightGroupButton.activated) {
            for (NSString* lightName in lightGroupButton.associatedLights) {
                DPHueLight* foundLight = [[HCHueHelper sharedInstance] lightWithName:lightName];
                if (foundLight) {
                    [workingLights addObject:foundLight];
                }
            }
        }
    }
    
    self.animalFriendView.eyeRadius = 1.0f - self.brightnessSlider.value;
    [self.animalFriendView setNeedsDisplay];
    [HCHueHelper sharedInstance].workingLights = workingLights;
    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor colorWithHue:self.colorPicker.hue saturation:self.colorPicker.saturation brightness:self.brightnessSlider.value alpha:1.0f]];
}
//
//#pragma mark -
//#pragma mark Interface Actions
//
//- (void)pressedKitchen:(id)sender {
//    [HCHueHelper sharedInstance].workingLights = [HCHueHelper sharedInstance].hue.lights;
//    [[HCHueHelper sharedInstance] setWorkingLightsToColor:[UIColor redColor]];
//}
//

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

#pragma mark -
#pragma mark HCLightGroupButtonDelegate
- (void)deactivatedLightGroupButton:(HCLightGroupButton*)button {
    BOOL anyWasActivated = NO;
    for (HCLightGroupButton* lightGroupButton in self.lightGroupButtons) {
        if (lightGroupButton.activated) {
            anyWasActivated = YES;
            break;
        }
    }
    
    if (!anyWasActivated) {
        button.activated = YES;
    }
}

- (void)activatedLightGroupButton:(HCLightGroupButton*)button {
    for (HCLightGroupButton* lightGroupButton in self.lightGroupButtons) {
        if (!lightGroupButton.beingTouched) {
            lightGroupButton.activated = NO;
        }
    }
}

@end
