//
//  ThemedView.h
//  LightMod
//
//  Created by Guanshan Liu on 13/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, LightModTheme) {
    LightModThemeLight  = 0,
    LightModThemeDark   = 1,
};

@interface ThemedView : UIView

#pragma mark - Theme

@property (nonatomic, assign) LightModTheme currentTheme;
- (void)toggleTheme:(UITapGestureRecognizer *)recognizer;

#pragma mark - Torch Button

@property (nonatomic, strong) UIButton *torchButton;
@property (nonatomic, copy) NSString *torchButtonImageNameSuffix;

- (void)updateTorchButtonDisplay;

/*
 *  Background gradient colors and locations
 */
@property (nonatomic, strong) NSArray *gradientLocations;
@property (nonatomic, strong) NSArray *gradientColors;

/*
 *  Torch button colors
 */
@property (nonatomic, strong) UIColor *buttonBaseColor;
@property (nonatomic, strong) UIColor *buttonTopColor;
@property (nonatomic, strong) UIColor *buttonBottomColor;
@property (nonatomic, strong) UIColor *buttonONColor;

#pragma mark - Brightness Slider

@property (nonatomic, strong)   UISlider *brightnessSlider;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;

- (void)toggleBrightnessSliderDisplay:(UIGestureRecognizer *)recognizer;
- (void)brightnessValueChanged:(UISlider *)slider;

@end
