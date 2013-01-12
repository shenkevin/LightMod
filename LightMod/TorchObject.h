//
//  TorchObject.h
//  FlashlightHero
//
//  Created by Guanshan Liu on 08/01/2012.
//  Copyright (c) 2012 Guanshan Liu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface TorchObject : NSObject

#if !TARGET_IPHONE_SIMULATOR
@property (nonatomic, retain) AVCaptureDevice *torchDevice;
#endif

+ (id)sharedInstance;

- (void)setTorchOn:(BOOL)torchOn;
- (BOOL)isTorchOn;
- (void)toggleTorch;
- (void)setTorchLevel:(float)torchLevel;
- (float)torchLevel;

@end
