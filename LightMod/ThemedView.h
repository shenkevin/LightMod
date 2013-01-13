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

@property (nonatomic, assign) LightModTheme currentTheme;
@property (nonatomic, weak) UIButton *torchButton;
@property (nonatomic, copy) NSString *torchButtonImageNameSuffix;

- (void)toggleTheme;
- (void)updateTorchButtonDisplay;

/*
 *  Background gradient colors and locations
 */
@property (nonatomic,strong) NSArray *gradientLocations;
@property (nonatomic,strong) NSArray *gradientColors;

/*
 *  Torch button colors
 */
@property (nonatomic, copy) UIColor *buttonBaseColor;
@property (nonatomic, copy) UIColor *buttonTopColor;
@property (nonatomic, copy) UIColor *buttonBottomColor;
@property (nonatomic, copy) UIColor *buttonONColor;

@end
