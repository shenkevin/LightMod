//
//  ThemedView.m
//  LightMod
//
//  Created by Guanshan Liu on 13/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

#import "ThemedView.h"

@implementation ThemedView

NSString *kCurrentTheme = @".currentTheme";

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _currentTheme = [defaults integerForKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:kCurrentTheme]];
        switch (_currentTheme) {
            case LightModThemeDark:
                [self darkTheme];
                break;
            case LightModThemeLight:
            default:
                [self lightTheme];
                break;
        }
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        _currentTheme = [defaults boolForKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:kCurrentTheme]];
        switch (_currentTheme) {
            case LightModThemeDark:
                [self darkTheme];
                break;
            case LightModThemeLight:
            default:
                [self lightTheme];
                break;
        }
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    /*
     *  Current graphics context
     */
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    /*
     *  Create base shape with rounded corners from bounds
     */
    
    CGRect activeBounds = self.bounds;
    
    //////////////DRAW GRADIENT
    /*
     *  Draw grafient from gradientLocations
     */
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    size_t count = [self.gradientLocations count];
    
    CGFloat *locations = malloc(count * sizeof(CGFloat));
    [self.gradientLocations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        locations[idx] = [((NSNumber *)obj) floatValue];
    }];
    
    CGFloat *components = malloc([self.gradientColors count] * 4 * sizeof(CGFloat));
    
    [self.gradientColors enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        UIColor *color = (UIColor *)obj;
        
        NSInteger startIndex = (idx * 4);
        
        if ([color respondsToSelector:@selector(getRed:green:blue:alpha:)]) {
            [color getRed:&components[startIndex]
                    green:&components[startIndex+1]
                     blue:&components[startIndex+2]
                    alpha:&components[startIndex+3]];
        } else {
            const CGFloat *colorComponent = CGColorGetComponents(color.CGColor);
            
            components[startIndex]   = colorComponent[0];
            components[startIndex+1] = colorComponent[1];
            components[startIndex+2] = colorComponent[2];
            components[startIndex+3] = colorComponent[3];
        }
    }];
    
    CGGradientRef gradient = CGGradientCreateWithColorComponents(colorSpace, components, locations, count);
    
    CGPoint startPoint = CGPointMake(activeBounds.size.width * 0.5f, 0.0f);
    CGPoint endPoint = CGPointMake(activeBounds.size.width * 0.5f, activeBounds.size.height);
    
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGColorSpaceRelease(colorSpace);
    CGGradientRelease(gradient);
    free(locations);
    free(components);
}

#pragma mark - Action Responder

- (void)toggleTheme {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if (self.currentTheme == LightModThemeLight) {
        self.currentTheme = LightModThemeDark;
        [self darkTheme];
    }
    else if (self.currentTheme == LightModThemeDark) {
        self.currentTheme = LightModThemeLight;
        [self lightTheme];
    }
    [defaults setInteger:self.currentTheme forKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:kCurrentTheme]];
    [defaults synchronize];
    
    [self setNeedsDisplay];
}

#pragma mark - LightModThemeLight

- (void)lightTheme {
    UIColor *topGradient = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *middleGradient = [UIColor colorWithRed:0.93f green:0.94f blue:0.96f alpha:1.0f];
    UIColor *bottomGradient = [UIColor colorWithRed:0.89f green:0.89f blue:0.92f alpha:1.00f];
    self.gradientColors = @[topGradient,middleGradient,bottomGradient];
    self.gradientLocations = @[ @0.0f, @0.57f, @1.0f];
}

#pragma mark - LightModThemeDark

- (void)darkTheme {
    UIColor *topGradient = [UIColor colorWithRed:0.27f green:0.27f blue:0.27f alpha:1.0f];
    UIColor *middleGradient = [UIColor colorWithRed:0.21f green:0.21f blue:0.21f alpha:1.0f];
    UIColor *bottomGradient = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.00f];
    self.gradientColors = @[topGradient,middleGradient,bottomGradient];
    self.gradientLocations = @[ @0.0f, @0.57f, @1.0f];
}

@end
