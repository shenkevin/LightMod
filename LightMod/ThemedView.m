//
//  ThemedView.m
//  LightMod
//
//  Created by Guanshan Liu on 13/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

#import "ThemedView.h"
#import "TorchObject.h"

@implementation ThemedView

#define SLIDER_FINAL_FRAME      CGRectMake(20.0f, [UIScreen mainScreen].bounds.size.height - 60.0f, [UIScreen mainScreen].bounds.size.width - 84.0f, 23.0f)
#define SLIDER_START_FRAME      CGRectMake(40.0f - [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height - 60.0f, [UIScreen mainScreen].bounds.size.width - 84.0f, 23.0f)

NSString *kCurrentTheme = @".currentTheme";

UITapGestureRecognizer *doubleTapsRecognizer = nil;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    // Theme
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
    
    // Torch Button
    _torchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _torchButton.frame = CGRectMake(0.0f, 0.0f, 120.0f, 130.0f);
    _torchButton.center = [[UIApplication sharedApplication].delegate window].center;
    [self addSubview:_torchButton];
    //[self updateTorchButtonDisplay];
    UITapGestureRecognizer *doubleTapsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleTheme:)];
    doubleTapsRecognizer.numberOfTapsRequired = 2;
    doubleTapsRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:doubleTapsRecognizer];
    
    // Brightness Slider
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0f) {
        self.brightnessSlider = [[UISlider alloc] init];
        self.brightnessSlider.minimumValue = 0.1f;
        self.brightnessSlider.maximumValue = 1.0f;
        self.brightnessSlider.minimumValueImage = [UIImage imageNamed:@"icon_brightness-sm"];
        //self.brightnessSlider.maximumValueImage = [UIImage imageNamed:@"icon_brightness-lg"];
        self.brightnessSlider.minimumTrackTintColor = self.minimumTrackTintColor;
        self.brightnessSlider.maximumTrackTintColor = self.maximumTrackTintColor;
        self.brightnessSlider.thumbTintColor = self.thumbTintColor;
        [self.brightnessSlider addTarget:self action:@selector(brightnessValueChanged:) forControlEvents:UIControlEventValueChanged];
        self.brightnessSlider.hidden = YES;
        
        CGRect screenRect = [UIScreen mainScreen].bounds;
        self.brightnessToggleButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.brightnessToggleButton.frame = CGRectMake(screenRect.size.width - 64.0f, screenRect.size.height - 70.0f, 44.0f, 44.0f);
        [self.brightnessToggleButton setImage:[UIImage imageNamed:@"icon_brightness-lg"] forState:UIControlStateNormal];
        [self.brightnessToggleButton addTarget:self action:@selector(toggleBrightnessSliderDisplay:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.brightnessToggleButton];
    }
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
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

#pragma mark - IBActions

- (BOOL)shouldResponseToGesture:(UIGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.torchButton];
    if ([self.torchButton.layer containsPoint:location]) {
        return NO;
    }
    
    if (self.brightnessToggleButton) {
        location = [recognizer locationInView:self.brightnessToggleButton];
        if ([self.brightnessToggleButton.layer containsPoint:location]) {
            return NO;
        }
    }
    
    if (self.brightnessSlider && self.brightnessSlider.hidden == NO) {
        location = [recognizer locationInView:self.brightnessSlider];
        if ([self.brightnessSlider.layer containsPoint:location]) {
            return NO;
        }
    }
    
    return YES;
}

- (void)toggleTheme:(UITapGestureRecognizer *)recognizer {
    
    if ([self shouldResponseToGesture:recognizer] == NO) {
        return;
    }
    
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
    [self updateTorchButtonDisplay];
    
    self.brightnessSlider.minimumTrackTintColor = self.minimumTrackTintColor;
    self.brightnessSlider.maximumTrackTintColor = self.maximumTrackTintColor;
    self.brightnessSlider.thumbTintColor = self.thumbTintColor;
}

- (void)toggleBrightnessSliderDisplay:(UIButton *)button {
    
    if (self.brightnessSlider.hidden == YES) {
        self.brightnessSlider.value = [[TorchObject sharedInstance] torchLevel];
        
        self.brightnessSlider.hidden = NO;
        self.brightnessSlider.alpha = 0.0f;
        self.brightnessSlider.frame = SLIDER_START_FRAME;
        [self addSubview:self.brightnessSlider];
        
        button.enabled = NO;
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^(void){
                             self.brightnessSlider.alpha = 1.0f;
                             self.brightnessSlider.frame = SLIDER_FINAL_FRAME;
                             
                             button.transform = CGAffineTransformScale(button.transform, 1.5f, 1.5f);
                             button.transform = CGAffineTransformRotate(button.transform, 360.0f);
                         }
                         completion:^(BOOL finished) {
                             button.transform = CGAffineTransformIdentity;
                             button.enabled = YES;
                         }];
    }
    else {
        button.enabled = NO;
        
        [UIView animateWithDuration:0.5f
                              delay:0.0f
                            options:UIViewAnimationCurveEaseOut
                         animations:^(void){
                             self.brightnessSlider.alpha = 0.0f;
                             self.brightnessSlider.frame = SLIDER_START_FRAME;
                             
                             button.transform = CGAffineTransformScale(button.transform, 1.5f, 1.5f);
                             button.transform = CGAffineTransformRotate(button.transform, -360.0f);
                         }
                         completion:^(BOOL finished) {
                             self.brightnessSlider.hidden = YES;
                             [self.brightnessSlider removeFromSuperview];
                             
                             button.transform = CGAffineTransformIdentity;
                             button.enabled = YES;
                         }];
    }
}

- (void)brightnessValueChanged:(UISlider *)slider {
    [[TorchObject sharedInstance] setTorchLevel:slider.value];
}

#pragma mark - Torch Button

- (UIImage*)imageForSelector:(SEL)selector {
    UIGraphicsBeginImageContextWithOptions(self.torchButton.bounds.size, NO, 0.0f);
	
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector];
#pragma clang diagnostic pop
	
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (void)drawButtonWithState:(BOOL)isON {
    //// General Declarations
	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = UIGraphicsGetCurrentContext();
	
	//// Color Declarations
	UIColor* baseColor = self.buttonBaseColor;//[UIColor colorWithRed: 0.335 green: 0.641 blue: 1 alpha: 1];
	CGFloat baseColorRGBA[4];
	[baseColor getRed: &baseColorRGBA[0] green: &baseColorRGBA[1] blue: &baseColorRGBA[2] alpha: &baseColorRGBA[3]];
	
	CGFloat baseColorHSBA[4];
	[baseColor getHue: &baseColorHSBA[0] saturation: &baseColorHSBA[1] brightness: &baseColorHSBA[2] alpha: &baseColorHSBA[3]];
	
	UIColor* topColor = self.buttonTopColor;//[UIColor colorWithRed: (baseColorRGBA[0] * 0.2 + 0.8) green: (baseColorRGBA[1] * 0.2 + 0.8) blue: (baseColorRGBA[2] * 0.2 + 0.8) alpha: (baseColorRGBA[3] * 0.2 + 0.8)];
	CGFloat topColorRGBA[4];
	[topColor getRed: &topColorRGBA[0] green: &topColorRGBA[1] blue: &topColorRGBA[2] alpha: &topColorRGBA[3]];
	
	UIColor* topOutColor = [UIColor colorWithRed: (topColorRGBA[0] * 0 + 1) green: (topColorRGBA[1] * 0 + 1) blue: (topColorRGBA[2] * 0 + 1) alpha: (topColorRGBA[3] * 0 + 1)];
	UIColor* bottomColor = self.buttonBottomColor;//[UIColor colorWithHue: baseColorHSBA[0] saturation: baseColorHSBA[1] brightness: 0.8 alpha: baseColorHSBA[3]];
	CGFloat bottomColorRGBA[4];
	[bottomColor getRed: &bottomColorRGBA[0] green: &bottomColorRGBA[1] blue: &bottomColorRGBA[2] alpha: &bottomColorRGBA[3]];
	
	UIColor* bottomOutColor = [UIColor colorWithRed: (bottomColorRGBA[0] * 0.9) green: (bottomColorRGBA[1] * 0.9) blue: (bottomColorRGBA[2] * 0.9) alpha: (bottomColorRGBA[3] * 0.9 + 0.1)];
	UIColor* symbolShadow = [UIColor colorWithRed: 0.496 green: 0.496 blue: 0.496 alpha: 1];
	UIColor* symbolONColor = self.buttonONColor;//[UIColor colorWithRed: 0.798 green: 0.949 blue: 1 alpha: 1];
    
	UIColor* smallShadowColor = [UIColor colorWithRed: 0.296 green: 0.296 blue: 0.296 alpha: 1];
	UIColor* symbolOffShadowColor = [UIColor colorWithRed: 0 green: 0 blue: 0 alpha: 1];
	UIColor* symbolOnHighColor = self.buttonONColor;//[UIColor colorWithRed: 1 green: 1 blue: 1 alpha: 1];
    
	//// Gradient Declarations
	NSArray* buttonOutGradientColors = [NSArray arrayWithObjects:
										(id)bottomOutColor.CGColor,
										(id)[UIColor colorWithRed: 0.727 green: 0.82 blue: 0.86 alpha: 1].CGColor,
										(id)topOutColor.CGColor, nil];
	CGFloat buttonOutGradientLocations[] = {0, 0.69, 1};
	CGGradientRef buttonOutGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonOutGradientColors, buttonOutGradientLocations);
	NSArray* buttonGradientColors = [NSArray arrayWithObjects:
									 (id)bottomColor.CGColor,
									 (id)topColor.CGColor, nil];
	CGFloat buttonGradientLocations[] = {0, 1};
	CGGradientRef buttonGradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef)buttonGradientColors, buttonGradientLocations);
	
	//// Shadow Declarations
	UIColor* shadow = symbolShadow;
	CGSize shadowOffset = CGSizeMake(0.1, 210.1);
	CGFloat shadowBlurRadius = 15;
	UIColor* glow = symbolONColor;
	CGSize glowOffset = CGSizeMake(0.1, -0.1);
	CGFloat glowBlurRadius = 7.5;
	UIColor* smallShadow = smallShadowColor;
	CGSize smallShadowOffset = CGSizeMake(0.1, 3.1);
	CGFloat smallShadowBlurRadius = 5.5;
	UIColor* symbolOffShadow = symbolOffShadowColor;
	CGSize symbolOffShadowOffset = CGSizeMake(0.1, 2.1);
	CGFloat symbolOffShadowBlurRadius = 7;
	
	//// Frames
	CGRect frame = CGRectMake(0, -0, 120, 130);
	
	//// Subframes
	CGRect symbol = CGRectMake(CGRectGetMinX(frame) + 39, CGRectGetMinY(frame) + 35, CGRectGetWidth(frame) - 77, CGRectGetHeight(frame) - 85);
	
    
	//// GroupShadow
	if (isON)
	{
		CGContextSaveGState(context);
		CGContextSetAlpha(context, 0.75);
		CGContextSetBlendMode(context, kCGBlendModeMultiply);
		CGContextBeginTransparencyLayer(context, NULL);
		
		
		//// LongShadow Drawing
		UIBezierPath* longShadowPath = [UIBezierPath bezierPath];
		[longShadowPath moveToPoint: CGPointMake(58.79, -91.94)];
		[longShadowPath addCurveToPoint: CGPointMake(94.83, -171.47) controlPoint1: CGPointMake(105.69, -91.51) controlPoint2: CGPointMake(108.82, -151.54)];
		[longShadowPath addCurveToPoint: CGPointMake(58.79, -191.24) controlPoint1: CGPointMake(91.21, -176.63) controlPoint2: CGPointMake(83.49, -191.41)];
		[longShadowPath addCurveToPoint: CGPointMake(23.82, -171.47) controlPoint1: CGPointMake(34.73, -191.08) controlPoint2: CGPointMake(26.78, -176.84)];
		[longShadowPath addCurveToPoint: CGPointMake(58.79, -91.94) controlPoint1: CGPointMake(11.99, -149.99) controlPoint2: CGPointMake(15.59, -92.33)];
		[longShadowPath closePath];
		CGContextSaveGState(context);
		CGContextSetShadowWithColor(context, shadowOffset, shadowBlurRadius, shadow.CGColor);
		[baseColor setFill];
		[longShadowPath fill];
		CGContextRestoreGState(context);
		
		
		
		CGContextEndTransparencyLayer(context);
		CGContextRestoreGState(context);
	}
	
	
	//// outerRing Drawing
	CGRect outerRingRect = CGRectMake(CGRectGetMinX(frame) + 15.5, CGRectGetMinY(frame) + 13.5, CGRectGetWidth(frame) - 31, CGRectGetHeight(frame) - 41);
	UIBezierPath* outerRingPath = [UIBezierPath bezierPathWithOvalInRect: outerRingRect];
	CGContextSaveGState(context);
	CGContextSetShadowWithColor(context, smallShadowOffset, smallShadowBlurRadius, smallShadow.CGColor);
	CGContextBeginTransparencyLayer(context, NULL);
	[outerRingPath addClip];
	CGContextDrawLinearGradient(context, buttonOutGradient,
								CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMaxY(outerRingRect)),
								CGPointMake(CGRectGetMidX(outerRingRect), CGRectGetMinY(outerRingRect)),
								0);
	CGContextEndTransparencyLayer(context);
	CGContextRestoreGState(context);
	
	
	
	//// innerRing Drawing
	CGRect innerRingRect = CGRectMake(CGRectGetMinX(frame) + 18.5, CGRectGetMinY(frame) + 16.5, CGRectGetWidth(frame) - 37, CGRectGetHeight(frame) - 47);
	UIBezierPath* innerRingPath = [UIBezierPath bezierPathWithOvalInRect: innerRingRect];
	CGContextSaveGState(context);
	[innerRingPath addClip];
	CGContextDrawLinearGradient(context, buttonGradient,
								CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMaxY(innerRingRect)),
								CGPointMake(CGRectGetMidX(innerRingRect), CGRectGetMinY(innerRingRect)),
								0);
	CGContextRestoreGState(context);
	
	
	//// Symbol
	{
		//// symbolOFF Drawing
		UIBezierPath* symbolPath = [UIBezierPath bezierPath];
		[symbolPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50194 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04446 * CGRectGetHeight(symbol))];
		[symbolPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.49855 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04445 * CGRectGetHeight(symbol))];
		[symbolPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50194 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.04446 * CGRectGetHeight(symbol))];
		[symbolPath closePath];
		[symbolPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.86006 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 1.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.37097 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 1.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.67348 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.14645 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.86006 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.65829 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 1.04665 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.34171 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 1.04665 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.14645 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + -0.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.67348 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + -0.04882 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.37097 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.25581 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18889 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.17353 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.16157 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.22375 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.16086 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.26156 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.29438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.28788 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.21692 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.28490 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.27238 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.26156 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.75007 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.12987 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.42021 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.12987 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.62423 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.75007 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.39325 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.87590 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.60675 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.87590 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.29438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.87013 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.62423 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.87013 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.42021 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.73844 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.70569 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.26272 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.70967 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.21188 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.85355 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.18438 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.76722 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.15688 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.83173 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.15986 * CGRectGetHeight(symbol))];
		[symbolPath closePath];
		[symbolPath moveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50000 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.56518 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.45505 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.54495 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.60000 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.56518 * CGRectGetHeight(symbol))];
		[symbolPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.07778 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.50000 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.58140 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.03482 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.54495 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol))];
		[symbolPath addCurveToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.07778 * CGRectGetHeight(symbol)) controlPoint1: CGPointMake(CGRectGetMinX(symbol) + 0.45505 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.00000 * CGRectGetHeight(symbol)) controlPoint2: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.03482 * CGRectGetHeight(symbol))];
		[symbolPath addLineToPoint: CGPointMake(CGRectGetMinX(symbol) + 0.41860 * CGRectGetWidth(symbol), CGRectGetMinY(symbol) + 0.52222 * CGRectGetHeight(symbol))];
		[symbolPath closePath];
		
		if (isON)
		{
			CGContextSaveGState(context);
			CGContextSetShadowWithColor(context, glowOffset, glowBlurRadius, glow.CGColor);
			[symbolOnHighColor setFill];
			[symbolPath fill];
			CGContextRestoreGState(context);
		}
		else
		{
			CGContextSaveGState(context);
			[symbolPath addClip];
			CGRect symbolOFFBounds = symbolPath.bounds;
			CGContextDrawLinearGradient(context, buttonGradient,
										CGPointMake(CGRectGetMidX(symbolOFFBounds) + 0.13 * CGRectGetWidth(symbolOFFBounds) / 43, CGRectGetMidY(symbolOFFBounds) + 41.12 * CGRectGetHeight(symbolOFFBounds) / 45),
										CGPointMake(CGRectGetMidX(symbolOFFBounds) + 1.05 * CGRectGetWidth(symbolOFFBounds) / 43, CGRectGetMidY(symbolOFFBounds) + -40.14 * CGRectGetHeight(symbolOFFBounds) / 45),
										kCGGradientDrawsBeforeStartLocation | kCGGradientDrawsAfterEndLocation);
			CGContextRestoreGState(context);
			
			////// symbolOFF Inner Shadow
			CGRect symbolOFFBorderRect = CGRectInset([symbolPath bounds], -symbolOffShadowBlurRadius, -symbolOffShadowBlurRadius);
			symbolOFFBorderRect = CGRectOffset(symbolOFFBorderRect, -symbolOffShadowOffset.width, -symbolOffShadowOffset.height);
			symbolOFFBorderRect = CGRectInset(CGRectUnion(symbolOFFBorderRect, [symbolPath bounds]), -1, -1);
			
			UIBezierPath* symbolOFFNegativePath = [UIBezierPath bezierPathWithRect: symbolOFFBorderRect];
			[symbolOFFNegativePath appendPath: symbolPath];
			symbolOFFNegativePath.usesEvenOddFillRule = YES;
			
			CGContextSaveGState(context);
			{
				CGFloat xOffset = symbolOffShadowOffset.width + round(symbolOFFBorderRect.size.width);
				CGFloat yOffset = symbolOffShadowOffset.height;
				CGContextSetShadowWithColor(context,
											CGSizeMake(xOffset + copysign(0.1, xOffset), yOffset + copysign(0.1, yOffset)),
											symbolOffShadowBlurRadius,
											symbolOffShadow.CGColor);
				
				[symbolPath addClip];
				CGAffineTransform transform = CGAffineTransformMakeTranslation(-round(symbolOFFBorderRect.size.width), 0);
				[symbolOFFNegativePath applyTransform: transform];
				[[UIColor grayColor] setFill];
				[symbolOFFNegativePath fill];
			}
			CGContextRestoreGState(context);
            
            
		}
        
	}
	
	
	//// Cleanup
	CGGradientRelease(buttonOutGradient);
	CGGradientRelease(buttonGradient);
	CGColorSpaceRelease(colorSpace);
}

- (void)drawOnState {
    [self drawButtonWithState:YES];
}

- (void)drawOffState {
    [self drawButtonWithState:NO];
}

- (void)updateTorchButtonDisplay {
    if ([[TorchObject sharedInstance] isTorchOn]) {
        [self.torchButton setBackgroundImage:[self
                                              imageForSelector:@selector(drawOnState)] forState:UIControlStateNormal];
    }
    else {
        [self.torchButton setBackgroundImage:[self
                                              imageForSelector:@selector(drawOffState)] forState:UIControlStateNormal];
    }
}

#pragma mark - LightModThemeLight

- (void)lightTheme {
    UIColor *topGradient = [UIColor colorWithRed:1.0f green:1.0f blue:1.0f alpha:1.0f];
    UIColor *middleGradient = [UIColor colorWithRed:0.93f green:0.94f blue:0.96f alpha:1.0f];
    UIColor *bottomGradient = [UIColor colorWithRed:0.89f green:0.89f blue:0.92f alpha:1.00f];
    self.gradientColors = @[topGradient,middleGradient,bottomGradient];
    self.gradientLocations = @[ @0.0f, @0.57f, @1.0f];
    
    self.buttonBaseColor = middleGradient;
    self.buttonTopColor = topGradient;
    self.buttonBottomColor = bottomGradient;
    self.buttonONColor = [UIColor colorWithRed:0.086f green:0.706f blue:0.906f alpha:1.000f];
    
    self.minimumTrackTintColor = topGradient;
    self.thumbTintColor = middleGradient;
    self.maximumTrackTintColor = bottomGradient;
}

#pragma mark - LightModThemeDark

- (void)darkTheme {
    UIColor *topGradient = [UIColor colorWithRed:0.27f green:0.27f blue:0.27f alpha:1.0f];
    UIColor *middleGradient = [UIColor colorWithRed:0.21f green:0.21f blue:0.21f alpha:1.0f];
    UIColor *bottomGradient = [UIColor colorWithRed:0.15f green:0.15f blue:0.15f alpha:1.00f];
    self.gradientColors = @[topGradient,middleGradient,bottomGradient];
    self.gradientLocations = @[ @0.0f, @0.57f, @1.0f];
    
    self.buttonBaseColor = middleGradient;
    self.buttonTopColor = topGradient;
    self.buttonBottomColor = bottomGradient;
    self.buttonONColor = [UIColor colorWithRed:0.110f green:0.820f blue:0.106f alpha:1.000f];
    
    self.minimumTrackTintColor = topGradient;
    self.thumbTintColor = middleGradient;
    self.maximumTrackTintColor = bottomGradient;
}

@end
