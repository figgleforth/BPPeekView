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
        self.peekView.actionRowEnabled = YES;
        self.peekView.delegate = self;
        self.peekView.peekHighlighedViewController = YES;
        self.peekView.rowHighlightAnimated = NO;
        [self.view addSubview:self.peekView];
    }
    return self;
}

- (NSString *)titleForViewControllerAtIndex:(NSInteger)index inPeekView:(BPPeekView *)peekView
{
    NSString *stringToReturn = @"";
    if (index == 0) stringToReturn = @"ACTION ROW";
    else stringToReturn = ((UIViewController*)self.peekView.viewControllers[index]).title;
    return stringToReturn;
}

- (CGFloat)heightForRowsInPeekView:(BPPeekView *)peekView
{
    return 44.f;
}

- (void)didSelectActionRowInPeekView:(BPPeekView *)peekView
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"Action Fired" delegate:nil cancelButtonTitle:@"CANCEL" otherButtonTitles:@"OK", nil];
    [alertView show];
}

- (UITableViewCell *)cellForRowAtIndex:(NSInteger)index inPeekView:(BPPeekView *)peekView
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:PEEKCELLIDENTIFIER];
    cell.backgroundColor = [UIColor orangeColor];
    return cell;
}

@end
