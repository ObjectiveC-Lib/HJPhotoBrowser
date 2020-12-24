//
//  HJPhotoBrowserPrivate.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/30.
//  Copyright © 2018 navy. All rights reserved.
//

#ifndef HJPhotoBrowserPrivate_h
#define HJPhotoBrowserPrivate_h

#import <UIKit/UIKit.h>
#import "HJPhotoBrowser.h"
#import "HJZoomingScrollView.h"
#import "HJPagingScrollView.h"
#import "HJCaptionView.h"
#import "HJNavigationView.h"
#import "HJLoadingView.h"
#import "HJTipView.h"
#import "HJIndexView.h"

@interface HJPhotoBrowser () <HJPagingScrollViewDelegate, HJCaptionViewDelegate, HJNavigationViewDelegate> {
    NSMutableArray *_photos;
    HJPagingScrollView *_pagingScrollView;
    UIView *_browserNavView;
    UIView *_browserCapView;
    
    UIView *_indexView;
    UIView *_tipView;
    UIView *_browserLoadingView;
    UIButton *_doneButton;
    
    UIPanGestureRecognizer *_panGesture;

    NSMutableSet *_visiblePages, *_recycledPages;
    NSUInteger _currentPageIndex;
    NSUInteger _beforePageIndex;
    
    BOOL _viewIsActive;
    BOOL _forwardXScroll;
    BOOL _scrolling;
    BOOL _performingLayout;
    BOOL _accessoryIsHide;
    BOOL _isdraggingPhoto;
    BOOL _statusBarOriginallyHidden;
    
    NSInteger _initalPageIndex;
    CGFloat _statusBarHeight;
    
    UIView *_senderViewForAnimation;
    CGRect _senderViewOriginalFrame;
    
    UIWindow *_applicationWindow;
}

@property (nonatomic, strong) id<HJNavigationView> navigationView;
@property (nonatomic, strong) id<HJCaptionView> captionView;
@end


#endif /* HJPhotoBrowserPrivate_h */
