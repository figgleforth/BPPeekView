//
//  BPPeekView.m
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import "BPPeekView.h"
#import <CoreGraphics/CoreGraphics.h>
#import <QuartzCore/QuartzCore.h>

#define PEEK_HEIGHT 44.f
#define SHELF_HEIGHT (( [self.delegate respondsToSelector:@selector(heightForRowsInPeekView:)] ) ? [self.delegate heightForRowsInPeekView:self] : 44.f )
#define SHELVES_BOUNDS CGRectMake(0, 0, self.bounds.size.width, SHELF_HEIGHT * self.viewControllers.count)
#define SHELVES_FRAME CGRectMake(0, -(SHELF_HEIGHT * self.viewControllers.count), self.bounds.size.width, SHELF_HEIGHT * self.viewControllers.count)
#define HANDLE_FRAME CGRectMake(0, 0, self.bounds.size.width, 44.f)
#define TITLE_SHELF_HEIGHT (SHELF_HEIGHT * self.viewControllers.count)


@interface BPPeekView () <UITableViewDataSource, UITableViewDelegate>
{
    BOOL _animating;
    __weak id<BPPeekViewDelegate> _delegate;
    BOOL _showActionRow;
    UIViewController *_topViewController;
    NSArray *_viewControllers;
}

@property CGRect bodyFrame;
@property UIPanGestureRecognizer *panGesture;
@property CGRect peekFrame;

@property UILabel *toolbarTitleLabel;
@property UIViewController *topViewController;

// new
@property UITableView *viewControllersTableView;
@property UIToolbar *toolbar;

@end

@implementation BPPeekView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        self.showActionRow = NO;
        self.animateRowHighlight = YES;
        
        self.viewControllersTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        self.viewControllersTableView.dataSource = self;
        self.viewControllersTableView.delegate = self;
        [self addSubview:self.viewControllersTableView];
        
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
    
    self.bounds = CGRectMake(0, 0, self.superview.bounds.size.width, self.superview.bounds.size.height);
    
    CGRect peek;
    CGRect body;
    CGRectDivide(self.bounds, &peek, &body, PEEK_HEIGHT, CGRectMinYEdge);
    self.peekFrame = peek;
    self.bodyFrame = CGRectMake(0, body.origin.y, body.size.width, body.size.height);
    
    self.toolbarTitleLabel.frame = HANDLE_FRAME;
    
    if (!CGRectEqualToRect(self.viewControllersTableView.bounds, SHELVES_BOUNDS)) {
        self.viewControllersTableView.frame = SHELVES_FRAME;
    }
    
    if (!CGRectEqualToRect(self.toolbar.bounds, HANDLE_FRAME)) {
        self.toolbar.frame = HANDLE_FRAME;
    }
    
    if (!_animating) {
        for (int i=0; i<self.viewControllers.count; i++) {
            UIViewController *vc = self.viewControllers[i];
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
        
        [self applyTransformPoint:translation toView:self.viewControllersTableView];
        [self applyTransformPoint:translation toView:self.toolbar];
        for (UIViewController *vc in self.viewControllers) {
            [self applyTransformPoint:translation toView:vc.view];
        }
        
        if (self.toolbar.frame.origin.y < 0) {
            self.toolbar.frame = CGRectMake(0, 0, self.toolbar.bounds.size.width, self.toolbar.bounds.size.height);
        }
        if (self.toolbar.frame.origin.y > TITLE_SHELF_HEIGHT) {
            self.toolbar.frame = CGRectMake(0, TITLE_SHELF_HEIGHT, self.toolbar.bounds.size.width, self.toolbar.bounds.size.height);
        }
        
        if (self.viewControllersTableView.frame.origin.y > 0) {
            self.viewControllersTableView.frame = CGRectMake(0, 0, self.viewControllersTableView.bounds.size.width, self.viewControllersTableView.bounds.size.height);
        }
        if (self.viewControllersTableView.frame.origin.y < -TITLE_SHELF_HEIGHT) {
            self.viewControllersTableView.frame = CGRectMake(0, -TITLE_SHELF_HEIGHT, self.viewControllersTableView.bounds.size.width, self.viewControllersTableView.bounds.size.height);
        }

        for (UIViewController *vc in self.viewControllers) {
            if (vc.view.frame.origin.y < PEEK_HEIGHT) {
                vc.view.frame = CGRectMake(0, PEEK_HEIGHT, vc.view.bounds.size.width, vc.view.bounds.size.height);
            }
            if (vc.view.frame.origin.y > (TITLE_SHELF_HEIGHT + PEEK_HEIGHT)) {
                vc.view.frame = CGRectMake(0, (TITLE_SHELF_HEIGHT + PEEK_HEIGHT), vc.view.bounds.size.width, vc.view.bounds.size.height);
            }
        }

        int index = [self indexForOffset:self.toolbar.frame.origin.y];
        
        UITableViewCell *selectedCell = [self.viewControllersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        [selectedCell setHighlighted:YES animated:self.animateRowHighlight];
        for (int i=0; i<self.viewControllers.count; i++) {
            UITableViewCell *deselectedCell = [self.viewControllersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (![deselectedCell isEqual:selectedCell]) [deselectedCell setHighlighted:NO animated:self.animateRowHighlight];
        }
        
        UIViewController *newTopViewController = self.viewControllers[index];
        if (![self.topViewController isEqual:newTopViewController]) {
            self.topViewController = newTopViewController;
        }

        [recognizer setTranslation:CGPointZero inView:self];
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
        int index = [self indexForOffset:self.toolbar.frame.origin.y];
        self.topViewController = self.viewControllers[index];
    
        for (UIViewController *vc in self.viewControllers) {
            CGRect handleFrame = self.toolbar.frame;
            handleFrame.origin.y = 0;
            [UIView animateWithDuration:0.3f animations:^{
                self.toolbar.frame = handleFrame;
                vc.view.frame = self.bodyFrame;
            }];
        }
        
        [UIView animateWithDuration:0.3f animations:^{
            self.viewControllersTableView.frame = SHELVES_FRAME;
        }];
        
        for (int i=0; i<self.viewControllers.count; i++) {
            UITableViewCell *deselectedCell = [self.viewControllersTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            [deselectedCell setHighlighted:NO animated:self.animateRowHighlight];
        }
        
        _animating = NO;
    }
}

- (int)indexForOffset:(CGFloat)offset
{
    int index;
    index = self.viewControllers.count - roundf(offset / SHELF_HEIGHT);
    if (index < 0) index = 0;
    else if (index > (self.viewControllers.count - 1)) index = (self.viewControllers.count - 1);
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
    if ([self.delegate respondsToSelector:@selector(titleForViewControllerAtIndex:inPeekView:)]) {
        self.toolbarTitleLabel.text = [self.delegate titleForViewControllerAtIndex:_topViewController.tabBarItem.tag inPeekView:self];
    }
    for (UIViewController *vc in self.viewControllers) {
        [UIView animateWithDuration:0.3f animations:^{
            vc.view.alpha = 0.f;
            _topViewController.view.alpha = 1.f;
        }];
    }
}

- (NSArray *)viewControllers
{
    return _viewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers
{
    _viewControllers = [NSArray arrayWithArray:viewControllers];
    int total = (self.showActionRow ? _viewControllers.count + 1 : _viewControllers.count);
    for (int i=0; i<total; i++) {
        UIViewController *vc = _viewControllers[i];
        vc.tabBarItem.tag = i;
        [self addSubview:vc.view];
        if (i == (_viewControllers.count-1)) self.topViewController = vc;
    }
}

- (id<BPPeekViewDelegate>)delegate
{
    return _delegate;
}

- (void)setDelegate:(id<BPPeekViewDelegate>)delegate
{
    _delegate = delegate;
    [self _setup];
}

- (BOOL)showActionRow
{
    return _showActionRow;
}

- (void)setShowActionRow:(BOOL)showActionRow
{
    _showActionRow = showActionRow;
    if (_showActionRow) {
        NSArray *viewControllers = [NSArray arrayWithArray:self.viewControllers];
        self.viewControllers = viewControllers;
    }
}

#pragma mark - Private Setup
- (void)_setup
{
    if (!self.delegate || !self.viewControllers.count) return;
    [self.viewControllersTableView reloadData];
}

#pragma mark - UITableViewDataSource & Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.viewControllers.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(heightForRowsInPeekView:)]) {
        return [self.delegate heightForRowsInPeekView:self];
    } else {
        return 44.f;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"peekCell"];
    if (!cell) {
        if ([self.delegate respondsToSelector:@selector(cellForRowAtIndex:inPeekView:)]) {
            cell = [self.delegate cellForRowAtIndex:indexPath.row inPeekView:self];
        } else {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"peekCell"];
        }
    }
    
    cell.textLabel.text = [self.delegate titleForViewControllerAtIndex:indexPath.row inPeekView:self];
    
    return cell;
}

@end
