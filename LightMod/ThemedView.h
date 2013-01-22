//
//  ThemedView.h
//  LightMod
//
//  Created by Guanshan Liu on 13/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

/*
 Copyright (C) 2013 Guanshan Liu
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
 */

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

@property (nonatomic, strong) UIButton *brightnessToggleButton;

@property (nonatomic, strong) UISlider *brightnessSlider;
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
@property (nonatomic, strong) UIColor *thumbTintColor;

- (void)toggleBrightnessSliderDisplay:(UIButton *)button;
- (void)brightnessValueChanged:(UISlider *)slider;

@end
