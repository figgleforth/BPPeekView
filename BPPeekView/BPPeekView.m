//
//  BPPeekView.m
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import "BPPeekView.h"
#import <CoreGraphics/CoreGraphics.h>

#define PEEK_HEIGHT 44.f
#define SHELF_HEIGHT 33.f
#define SHELVES_BOUNDS CGRectMake(0, 0, self.bounds.size.width, SHELF_HEIGHT * self.controller.viewControllers.count)
#define SHELVES_FRAME CGRectMake(0, -(SHELF_HEIGHT * self.controller.viewControllers.count), self.bounds.size.width, SHELF_HEIGHT * self.controller.viewControllers.count)
#define HANDLE_FRAME CGRectMake(0, 0, self.bounds.size.width, 44.f)
#define TITLE_SHELF_HEIGHT (SHELF_HEIGHT * self.controller.viewControllers.count)


@interface BPPeekView ()
{
    BOOL _animating;
    UIViewController *_topViewController;
}

@property BPPeekViewController *controller;

@property CGRect bodyFrame;
@property NSMutableArray *labels;
@property UIView *labelShelf;
@property UIPanGestureRecognizer *panGesture;
@property CGRect peekFrame;

@property UILabel *toolbarTitleLabel;
@property UIViewController *topViewController;

// new
@property UITableView *controllersTableView;
@property UIToolbar *toolbar;

@end

@implementation BPPeekView

- (id)initWithPeekViewController:(BPPeekViewController *)controller
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        self.controller = controller;
        for (int i=0; i<self.controller.viewControllers.count; i++) {
            UIViewController *vc = self.controller.viewControllers[i];
            [self addSubview:vc.view];
            if (i == (self.controller.viewControllers.count-1)) self.topViewController = vc;
        }
            
        self.labelShelf = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.labelShelf];
        
        self.labels = @[].mutableCopy;
        for (int i=0; i<self.controller.viewControllers.count; i++) {
            UIViewController *vc = self.controller.viewControllers[i];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
            label.textAlignment = NSTextAlignmentCenter;
            label.tag = i;
            label.text = vc.title;
            [self.labelShelf addSubview:label];
            [self.labels addObject:label];
        }
        
        self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectZero];
        [self addSubview:self.toolbar];
        
        self.toolbarTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.toolbarTitleLabel.backgroundColor = [UIColor clearColor];
        self.toolbarTitleLabel.text = self.topViewController.title;
        self.toolbarTitleLabel.textAlignment = NSTextAlignmentCenter;
        
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        UIBarButtonItem *titleButton = [[UIBarButtonItem alloc] initWithCustomView:self.toolbarTitleLabel];
        UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        [self.toolbar setItems:@[spacer, titleButton, spacer2] animated:YES];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(dragHandle:)];
        self.panGesture.minimumNumberOfTouches = 1;
        self.panGesture.maximumNumberOfTouches = 1;
        [self.toolbar addGestureRecognizer:self.panGesture];
        
        _animating = NO;
    }
    return self;
}

- (void)layoutSubviews
{
    CGRect peek;
    CGRect body;
    CGRectDivide(self.bounds, &peek, &body, PEEK_HEIGHT, CGRectMinYEdge);
    self.peekFrame = peek;
    self.bodyFrame = CGRectMake(0, body.origin.y, body.size.width, body.size.height);
    
    self.toolbarTitleLabel.frame = HANDLE_FRAME;

    if (!CGRectEqualToRect(self.labelShelf.bounds, SHELVES_BOUNDS)) {
        self.labelShelf.frame = SHELVES_FRAME;
    }    
    
    if (!CGRectEqualToRect(self.toolbar.bounds, HANDLE_FRAME)) {
        self.toolbar.frame = HANDLE_FRAME;
    }
    
    for (int i=0; i<self.labels.count; i++) {
        UILabel *title = self.labels[i];
        title.frame = CGRectMake(0, i * SHELF_HEIGHT, self.bounds.size.width, SHELF_HEIGHT);
    }
    
    if (!_animating) {
        for (int i=0; i<self.controller.viewControllers.count; i++) {
            UIViewController *vc = self.controller.viewControllers[i];
            if (!CGRectEqualToRect(vc.view.bounds, self.bodyFrame)) {
                vc.view.frame = self.bodyFrame;
            }
        }
    }
}

#pragma mark - Pan Gesture
- (void)dragHandle:(UIPanGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        _animating = YES;
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        translation.x = 0;
        
        [self applyTransformPoint:translation toView:self.labelShelf];
        [self applyTransformPoint:translation toView:self.toolbar];
        for (UIViewController *vc in self.controller.viewControllers) {
            [self applyTransformPoint:translation toView:vc.view];
        }
        
        if (self.toolbar.frame.origin.y < 0) {
            self.toolbar.frame = CGRectMake(0, 0, self.toolbar.bounds.size.width, self.toolbar.bounds.size.height);
        }
        if (self.toolbar.frame.origin.y > TITLE_SHELF_HEIGHT) {
            self.toolbar.frame = CGRectMake(0, TITLE_SHELF_HEIGHT, self.toolbar.bounds.size.width, self.toolbar.bounds.size.height);
        }
        
        if (self.labelShelf.frame.origin.y > 0) {
            self.labelShelf.frame = CGRectMake(0, 0, self.labelShelf.bounds.size.width, self.labelShelf.bounds.size.height);
        }
        if (self.labelShelf.frame.origin.y < -TITLE_SHELF_HEIGHT) {
            self.labelShelf.frame = CGRectMake(0, -TITLE_SHELF_HEIGHT, self.labelShelf.bounds.size.width, self.labelShelf.bounds.size.height);
        }

        for (UIViewController *vc in self.controller.viewControllers) {
            if (vc.view.frame.origin.y < PEEK_HEIGHT) {
                vc.view.frame = CGRectMake(0, PEEK_HEIGHT, vc.view.bounds.size.width, vc.view.bounds.size.height);
            }
            if (vc.view.frame.origin.y > (TITLE_SHELF_HEIGHT + PEEK_HEIGHT)) {
                vc.view.frame = CGRectMake(0, (TITLE_SHELF_HEIGHT + PEEK_HEIGHT), vc.view.bounds.size.width, vc.view.bounds.size.height);
            }
        }

        int index = [self indexForOffset:self.toolbar.frame.origin.y];
        
        for (UILabel *label in self.labels) label.backgroundColor = [UIColor clearColor];
        UILabel *selectedLabel = self.labels[index];
        selectedLabel.backgroundColor = [UIColor yellowColor];
        
        UIViewController *newTopViewController = self.controller.viewControllers[index];
        if (![self.topViewController isEqual:newTopViewController]) {
            self.topViewController = newTopViewController;
        }

        [recognizer setTranslation:CGPointZero inView:self];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        int index = [self indexForOffset:self.toolbar.frame.origin.y];
        self.topViewController = self.controller.viewControllers[index];
    
        for (UIViewController *vc in self.controller.viewControllers) {
            CGRect handleFrame = self.toolbar.frame;
            handleFrame.origin.y = 0;
            [UIView animateWithDuration:0.3f animations:^{
                self.toolbar.frame = handleFrame;
                vc.view.frame = self.bodyFrame;
            }];
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            self.labelShelf.frame = SHELVES_FRAME;
        }];
        
        _animating = NO;
    }
}

- (int)indexForOffset:(CGFloat)offset
{
    int index;
    index = self.controller.viewControllers.count - roundf(offset / SHELF_HEIGHT);
    if (index < 0) index = 0;
    else if (index > (self.controller.viewControllers.count - 1)) index = (self.controller.viewControllers.count - 1);
    return index;
}

#pragma mark - Translation Helper
- (void)applyTransformPoint:(CGPoint)point toView:(UIView *)view
{
    view.transform = CGAffineTransformTranslate(view.transform, point.x, point.y);
}

#pragma mark - Mutators
- (UIViewController *)topViewController
{
    return _topViewController;
}

- (void)setTopViewController:(UIViewController *)topViewController
{
    _topViewController = topViewController;
    self.toolbarTitleLabel.text = _topViewController.title;
    for (UIViewController *vc in self.controller.viewControllers) {
        [UIView animateWithDuration:0.3f animations:^{
            vc.view.alpha = 0.f;
            _topViewController.view.alpha = 1.f;
        }];
    }
}

@end
