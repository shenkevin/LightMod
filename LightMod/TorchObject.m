//
//  TorchObject.m
//  FlashlightHero
//
//  Created by Guanshan Liu on 08/01/2012.
//  Copyright (c) 2012 Guanshan Liu. All rights reserved.
//

#import "TorchObject.h"

@implementation TorchObject

+ (id)sharedInstance {
    static TorchObject *torch = nil;
    if (torch == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            torch = [[TorchObject alloc] init];
        });
    }
    
    return torch;
}

- (id)init {
    if (self = [super init]) {
#if !TARGET_IPHONE_SIMULATOR 
        _torchDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
#endif
    }
    return self;
}

#pragma mark - Torch Methods

- (BOOL)isTorchOn{
#if !TARGET_IPHONE_SIMULATOR  
    return [self.torchDevice torchMode] == AVCaptureTorchModeOn;
#else
    return NO;
#endif
}

NSString *kTorchLevel = @".torchLevel";

- (void)setTorchOn:(BOOL)torchOn{
#if !TARGET_IPHONE_SIMULATOR    
    
    [self.torchDevice lockForConfiguration:nil];
    
    if (torchOn) {
        [self.torchDevice setFlashMode:AVCaptureFlashModeOn];
        
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
            float level = [[NSUserDefaults standardUserDefaults] floatForKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:kTorchLevel]];
            [self.torchDevice setTorchModeOnWithLevel:level error:nil];
            
        }
        else {
            [self.torchDevice setTorchMode:AVCaptureTorchModeOn];
        }
    }
    else {
        [self.torchDevice setFlashMode:AVCaptureFlashModeOff];
        
        [self.torchDevice setTorchMode:AVCaptureTorchModeOff];
    }
    
    [self.torchDevice unlockForConfiguration];
    
#endif
}

- (void)toggleTorch {
    [self setTorchOn:![self isTorchOn]];
}

- (float)torchLevel {
#if !TARGET_IPHONE_SIMULATOR 
    return self.torchDevice.torchLevel;
#else
    return 0.0f;
#endif
}

- (void)setTorchLevel:(float)torchLevel {
#if !TARGET_IPHONE_SIMULATOR 
    if ([[[UIDevice currentDevice] systemVersion] floatValue] < 6.0) {
        return;
    }
    
    torchLevel = fmaxf(fminf(torchLevel, 1.0f), 0.0);
    
    if ([self isTorchOn]) {
        [self.torchDevice lockForConfiguration:nil];
        [self.torchDevice setFlashMode:AVCaptureFlashModeOn];
        [self.torchDevice setTorchModeOnWithLevel:torchLevel error:nil];
        [self.torchDevice unlockForConfiguration];
    }
    else {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setFloat:torchLevel forKey:[[NSBundle mainBundle].bundleIdentifier stringByAppendingString:kTorchLevel]];
        [defaults synchronize];
    }
#endif
}

@end