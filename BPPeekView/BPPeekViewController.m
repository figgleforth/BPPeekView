//
//  BPPeekViewController.m
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import "BPPeekViewController.h"
#import "BPPeekView.h"

@interface BPPeekViewController () <BPPeekViewDelegate>
{
    NSArray *_viewControllers;
}

@property BPPeekView *peekView;

@end

@implementation BPPeekViewController

- (id)initWithViewControllers:(NSArray *)viewControllers
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewControllers = [NSArray arrayWithArray:viewControllers];
        self.peekView = [[BPPeekView alloc] initWithFrame:self.view.bounds];
        self.peekView.viewControllers = self.viewControllers;
        self.peekView.showActionRow = YES;
        self.peekView.delegate = self;
        [self.view addSubview:self.peekView];
    }
    return self;
}

- (NSString *)titleForViewControllerAtIndex:(NSInteger)index inPeekView:(BPPeekView *)peekView
{
    return [NSString stringWithFormat:@"title yay %i", index];
}

- (CGFloat)heightForRowsInPeekView:(BPPeekView *)peekView
{
    return 44.f;
}

- (void)didSelectActionRowInPeekView:(BPPeekView *)peekView
{
    NSLog(@"action row!");
}

@end
