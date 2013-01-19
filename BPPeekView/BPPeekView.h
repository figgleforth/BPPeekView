//
//  BPPeekView.h
//  BPPeekView
//
//  Created by Bojan Percevic on 1/19/13.
//  Copyright (c) 2013 Bojan Percevic. All rights reserved.
//

#import <UIKit/UIKit.h>

#define PEEKCELLIDENTIFIER @"peekCell"

@class BPPeekView;
@protocol BPPeekViewDelegate <NSObject>

@required
- (NSString *) titleForViewControllerAtIndex:(NSInteger)index inPeekView:(BPPeekView *)peekView;

@optional
- (CGFloat) heightForRowsInPeekView:(BPPeekView *)peekView;
- (void) didSelectActionRowInPeekView:(BPPeekView *)peekView;
- (UITableViewCell *) cellForRowAtIndex:(NSInteger)index inPeekView:(BPPeekView *)peekView;

@end

@interface BPPeekView : UIView

@property BOOL actionRowEnabled;
@property (weak) id<BPPeekViewDelegate> delegate;
@property BOOL peekHighlighedViewController;
@property BOOL rowHighlightAnimated;
@property NSArray *viewControllers;

@end
