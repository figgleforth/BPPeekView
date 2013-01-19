//
//  BPRedViewController.m
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import "BPRedViewController.h"

@interface BPRedViewController ()

@end

@implementation BPRedViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"Red";        
        self.view.backgroundColor = [UIColor redColor];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
