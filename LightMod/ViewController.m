//
//  ViewController.m
//  LightMod
//
//  Created by Guanshan Liu on 12/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

#import "ViewController.h"
#import "ThemedView.h"
#import "TorchObject.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [[(ThemedView *)self.view torchButton] addTarget:self action:@selector(toggleTorch) forControlEvents:UIControlEventTouchUpInside];
    [[NSNotificationCenter defaultCenter] addObserver:(ThemedView *)self.view selector:@selector(updateTorchButtonDisplay) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)toggleTorch {
    [[TorchObject sharedInstance] toggleTorch];
    [(ThemedView *)self.view updateTorchButtonDisplay];
}

@end
