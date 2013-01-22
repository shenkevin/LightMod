//
//  ViewController.m
//  LightMod
//
//  Created by Guanshan Liu on 12/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

/*
 Copyright (C) 2013 Guanshan Liu
 
 This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or any later version.
 
 This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License along with this program. If not, see http://www.gnu.org/licenses/
 */

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
