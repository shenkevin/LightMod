//
//  ViewController.m
//  LightMod
//
//  Created by Guanshan Liu on 12/01/2013.
//  Copyright (c) 2013 Guanshan Liu. All rights reserved.
//

#import "ViewController.h"
#import "ThemedView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    UITapGestureRecognizer *doubleTapsRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.view action:@selector(toggleTheme)];
    doubleTapsRecognizer.numberOfTapsRequired = 2;
    doubleTapsRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:doubleTapsRecognizer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
