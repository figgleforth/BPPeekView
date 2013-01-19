//
//  BPPeekViewController.m
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import "BPPeekViewController.h"
#import "BPPeekView.h"

@interface BPPeekViewController ()
{
    NSArray *_viewControllers;
}

@end

@implementation BPPeekViewController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllers = [NSArray arrayWithArray:viewControllers];
    }
    return self;
}

- (void)loadView
{
    self.view = [[BPPeekView alloc] initWithPeekViewController:self];
}

#pragma mark - Mutators
- (NSArray *)viewControllers
{
    if (!_viewControllers) _viewControllers = @[];
    return _viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = viewControllers;
    self.view = [[BPPeekView alloc] initWithPeekViewController:self];
}


@end
