//
//  HJPhotoBrowser.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJPhotoBrowser.h"
#import "HJPBUtils.h"

#import "HJPhotoBrowserPrivate.h"
#import "HJZoomingScrollView.h"
#import "HJPagingScrollView.h"

#import <AssetsLibrary/ALAssetsLibrary.h>
#import <MobileCoreServices/UTCoreTypes.h>

#import <pop/POP.h>
#import <SDWebImage/SDImageCache.h>


@implementation HJPhotoBrowser

#pragma mark - Init

- (id)init {
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        
        _initalPageIndex = 0;
        _currentPageIndex = 0;
        _beforePageIndex = _currentPageIndex - 1;
        
        _photos = [NSMutableArray new];
        _visiblePages = [NSMutableSet new];
        _recycledPages = [NSMutableSet new];
        
        _scrolling = NO;
        _viewIsActive = NO;
        _forwardXScroll = NO;
        _dismissOnTouch = NO;
        _isdraggingPhoto = NO;
        _accessoryIsHide = NO;
        _usePopAnimation = NO;
        _performingLayout = NO;
        _forceHideStatusBar = NO;
        _displayBottomToolView = NO;
        _displayAccessoryView = NO;
        _disableVerticalSwipe = NO;
        _disablePhotoAnimation = NO;
        _useWhiteBackgroundColor = NO;
        
        _statusBarHeight = 20.f;
        _animationDuration = 0.28;
        _backgroundScaleFactor = 1.0;
        
        _scaleImage = nil;
        _senderViewForAnimation = nil;
        
        _applicationWindow = [[[UIApplication sharedApplication] delegate] window];

        if ([self respondsToSelector:@selector(automaticallyAdjustsScrollViewInsets)]) {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
        
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalPresentationCapturesStatusBarAppearance = YES;
        self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
        
        // Listen for HJPhoto notifications
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleHJPhotoLoadingDidEndNotification:)
                                                     name:HJPhoto_LOADING_DID_END_NOTIFICATION
                                                   object:nil];
    }
    
    return self;
}

- (id)initWithPhotos:(NSArray <HJPhoto*> *)photosArray {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:[HJPhoto photosWithPhotos:photosArray]];
    }
    return self;
}

- (id)initWithPhotos:(NSArray <HJPhoto*> *)photosArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:[HJPhoto photosWithPhotos:photosArray]];
        _senderViewForAnimation = view;
    }
    return self;
}

- (id)initWithPhotoURLs:(NSArray *)photoURLsArray {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:[HJPhoto photosWithURLs:photoURLsArray]];
    }
    return self;
}

- (id)initWithPhotoURLs:(NSArray *)photoURLsArray animatedFromView:(UIView*)view {
    if ((self = [self init])) {
        _photos = [[NSMutableArray alloc] initWithArray:[HJPhoto photosWithURLs:photoURLsArray]];
        _senderViewForAnimation = view;
    }
    return self;
}

- (void)dealloc {
    _pagingScrollView.delegate = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseAllUnderlyingPhotos];
}

- (void)releaseAllUnderlyingPhotos {
    for (id p in _photos) {
        if (p != [NSNull null])
            [p unloadUnderlyingImage];
    }
}

- (void)didReceiveMemoryWarning {
    [self releaseAllUnderlyingPhotos];
    [_recycledPages removeAllObjects];
    
    [super didReceiveMemoryWarning];
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1];
    self.view.clipsToBounds = YES;
    _navigationHeight = HJPB_Navigation_Height;
    _captionHeight = HJPB_Caption_Height + (_displayBottomToolView?HJPB_Bottom_Tool_Height:0);
    
    _pagingScrollView = [self pagingScrollView];
    [self.view addSubview:_pagingScrollView];
    
    if (_displayAccessoryView) {
        _browserNavView = [self browserNavView];
        [self.view addSubview:_browserNavView];
        _browserCapView = [self browserCapView];
        [self.view addSubview:_browserCapView];

        _navigationView = [self navigationViewForBrowser];
        [_browserNavView addSubview:(HJNavigationView *)_navigationView];
        _captionView = [self captionViewForBrowser];
        [_browserCapView addSubview:(HJCaptionView *)_captionView];
    }
    
    [self performPresentAnimation];

    if(!_disableVerticalSwipe) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [_panGesture setMinimumNumberOfTouches:1];
        [_panGesture setMaximumNumberOfTouches:1];
        [self.view addGestureRecognizer:_panGesture];
    }
    
    _doneButton = [self doneButton];
    _doneButton.hidden = YES;
    [self.view addSubview:_doneButton];
    
    _browserLoadingView = [self browserLoadingView];
    _browserLoadingView.hidden = YES;
    [self.view addSubview:_browserLoadingView];

    _tipView = [self browserTipView];
    [self.view addSubview:_tipView];
    [self.view sendSubviewToBack:_tipView];

    _indexView = [self browserIndexView];
    _indexView.hidden = _displayAccessoryView;
    [self.view addSubview:_indexView];
    [self.view bringSubviewToFront:_indexView];

    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    if ([self numberOfPhotos]) {
        [self reloadData];
    }
    
    if (_delegate && [_delegate respondsToSelector:@selector(willAppearPhotoBrowser:)]) {
        [_delegate willAppearPhotoBrowser:self];
    }
    
    [super viewWillAppear:animated];
    
    _statusBarOriginallyHidden = [UIApplication sharedApplication].statusBarHidden;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _viewIsActive = YES;
}

#pragma mark - Status Bar

- (UIStatusBarStyle)preferredStatusBarStyle {
    return _useWhiteBackgroundColor ? UIStatusBarStyleDefault : UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden {
    if (_forceHideStatusBar) return YES;
    if (_isdraggingPhoto) {
        return _statusBarOriginallyHidden;
    }
    return NO;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return UIStatusBarAnimationFade;
}

#pragma mark - Layout

- (void)viewWillLayoutSubviews {
    if ([self numberOfPhotos]) {
        _doneButton.hidden = YES;
        _browserLoadingView.hidden = YES;
        [(HJCaptionView *)_captionView setUserInteractionEnabled:YES];
    } else {
        _doneButton.hidden = NO;
        _browserLoadingView.hidden = NO;
        [(HJCaptionView *)_captionView setUserInteractionEnabled:NO];
        [super viewWillLayoutSubviews];
        return;
    }

    _performingLayout = YES;
    
    NSUInteger indexPriorToLayout = _currentPageIndex;
    
    // Get paging scroll view frame to determine if anything needs changing
    CGRect pagingScrollViewFrame = [self frameForPagingScrollView];
    _pagingScrollView.frame = pagingScrollViewFrame;
    _pagingScrollView.contentSize = [self contentSizeForPagingScrollView];
    
    for (HJZoomingScrollView *page in _visiblePages) {
        NSUInteger index = HJPB_Page_Index(page);
        page.frame = [self frameForPageAtIndex:index];
        [page setMaxMinZoomScalesForCurrentBounds];
    }
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:indexPriorToLayout];
    [self didStartViewingPageAtIndex:_currentPageIndex];
    [self didStartViewingAccessoryAtIndex:_currentPageIndex];

    _currentPageIndex = indexPriorToLayout;
    _performingLayout = NO;
    
    [super viewWillLayoutSubviews];
}

- (void)performLayout {
    _performingLayout = YES;

    [_visiblePages removeAllObjects];
    [_recycledPages removeAllObjects];
    
    _pagingScrollView.contentOffset = [self contentOffsetForPageAtIndex:_currentPageIndex];
    [self tilePages];
    _performingLayout = NO;
}

#pragma mark - Data

- (void)setPhotos:(NSArray <HJPhoto*> *)photos {
    if (![self numberOfPhotos]) {
        _photos = [[NSMutableArray alloc] initWithArray:[HJPhoto photosWithPhotos:photos]];
    }
}

- (void)reloadData {
    [self releaseAllUnderlyingPhotos];
    [self performLayout];
    
    [self.view setNeedsLayout];
}

- (NSUInteger)numberOfPhotos {
    return _photos.count;
}

- (id<HJPhoto>)photoAtIndex:(NSUInteger)index {
    return _photos[index];
}

- (UIImage *)imageForPhoto:(id<HJPhoto>)photo {
    if (photo) {
        if ([photo underlyingImage]) {
            return [photo underlyingImage];
        } else {
            [photo loadUnderlyingImageAndNotify];
            if ([photo respondsToSelector:@selector(placeholderImage)]) {
                return [photo placeholderImage];
            }
        }
    }
    
    return nil;
}

- (void)setInitialPageIndex:(NSUInteger)index {
    if (index >= [self numberOfPhotos]) index = [self numberOfPhotos]-1;
    _initalPageIndex = index;
    _currentPageIndex = index;
    if ([self isViewLoaded]) {
        [self jumpToPageAtIndex:index];
        if (!_viewIsActive) [self tilePages]; // Force tiling if view is not visible
    }
}

- (void)loadAdjacentPhotosIfNecessary:(id<HJPhoto>)photo {
    HJZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        // If page is current page then initiate loading of previous and next pages
        NSUInteger pageIndex = HJPB_Page_Index(page);
        if (_currentPageIndex == pageIndex) {
            if (pageIndex > 0) {
                id <HJPhoto> photo = [self photoAtIndex:pageIndex-1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    HJPB_Log(@"Pre-loading image at index %lu", pageIndex-1);
                }
            }
            if (pageIndex < [self numberOfPhotos] - 1) {
                id <HJPhoto> photo = [self photoAtIndex:pageIndex+1];
                if (![photo underlyingImage]) {
                    [photo loadUnderlyingImageAndNotify];
//                    HJPB_Log(@"Pre-loading image at index %lu", pageIndex+1);
                }
            }
        }
    }
}

#pragma mark - Pan Gesture

- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture {
    if (![self numberOfPhotos]) return;
    HJZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    static float firstX, firstY;
    static BOOL accessoryIsHide;
    
    CGPoint translation = [gesture translationInView:self.view];
    CGPoint velocity = [gesture velocityInView:self.view];
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        accessoryIsHide = _accessoryIsHide;
        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
    }
    
    if ((fabs(translation.x)/MAX(fabs(translation.y), 0.0001) <= 0.5) && (fabs(velocity.y) > fabs(velocity.x)) && translation.y>0) { // ->down
        translation = CGPointMake(firstX, firstY+translation.y);
        [scrollView setCenter:translation];

        if (scrollView.center.y > firstY) {
            _isdraggingPhoto = YES;

            [self setNeedsStatusBarAppearanceUpdate];
            if (!_accessoryIsHide) {
                [self setAccessoryHidden:YES animated:YES];
            }
            _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        }
        float newY = scrollView.center.y - viewHalfHeight;
        float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
        self.view.opaque = YES;
        self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:newAlpha];
        
        if ([gesture state] == UIGestureRecognizerStateEnded) {
            if (scrollView.center.y > firstY + 60) {
                CGFloat finalX = firstX;
                CGFloat finalY = viewHeight*2;
                [UIView animateWithDuration:0.35 animations:^{
                    [scrollView setCenter:CGPointMake(finalX, finalY)];
                    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
                } completion:^(BOOL finished) {
                    [self doneButtonPressed:nil];
                }];
            } else {
                _isdraggingPhoto = NO;
                
                CGFloat finalX = firstX;
                CGFloat finalY = viewHalfHeight;
                
                CGFloat velocityY = (.35*[gesture velocityInView:self.view].y);
                CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
                
                [UIView animateWithDuration:animationDuration animations:^{
                    [self setNeedsStatusBarAppearanceUpdate];
                    self.view.backgroundColor = [UIColor colorWithWhite:(self->_useWhiteBackgroundColor ? 1 : 0) alpha:1];
                    if (!accessoryIsHide) {
                        [self setAccessoryHidden:NO animated:YES];
                    }
                    [scrollView setCenter:CGPointMake(finalX, finalY)];
                }];
            }
        }
    } else {

        if ([gesture state] == UIGestureRecognizerStateEnded) {
            if (_isdraggingPhoto == NO) {
                if (!_captionView.isOpen) {
                    [_captionView setCaptionViewOpen:YES];
                }
            }
            
            _isdraggingPhoto = NO;
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            CGFloat velocityY = (.35*[gesture velocityInView:self.view].y);
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            [UIView animateWithDuration:animationDuration animations:^{
                [self setNeedsStatusBarAppearanceUpdate];
                self.view.backgroundColor = [UIColor colorWithWhite:(self->_useWhiteBackgroundColor ? 1 : 0) alpha:1];
                if (!accessoryIsHide) {
                    [self setAccessoryHidden:NO animated:YES];
                }
                [scrollView setCenter:CGPointMake(finalX, finalY)];
            }];
        }
    }
}

/*
- (void)panGestureRecognized:(UIPanGestureRecognizer *)gesture {
    if (![self numberOfPhotos]) return;
    HJZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
    
    static float firstX, firstY;
    
    float viewHeight = scrollView.frame.size.height;
    float viewHalfHeight = viewHeight/2;
    
    CGPoint translatedPoint = [gesture translationInView:self.view];
    
    // Gesture Began
    if ([gesture state] == UIGestureRecognizerStateBegan) {
        [self setAccessoryHidden:YES animated:YES];

        firstX = [scrollView center].x;
        firstY = [scrollView center].y;
        
        _senderViewForAnimation.hidden = (_currentPageIndex == _initalPageIndex);
        
        _isdraggingPhoto = YES;
        [self setNeedsStatusBarAppearanceUpdate];
    }
    
    translatedPoint = CGPointMake(firstX, firstY+translatedPoint.y);
    [scrollView setCenter:translatedPoint];
    
    float newY = scrollView.center.y - viewHalfHeight;
    float newAlpha = 1 - fabsf(newY)/viewHeight; //abs(newY)/viewHeight * 1.8;
    
    self.view.opaque = YES;
    
    self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:newAlpha];
    
    // Gesture Ended
    if ([gesture state] == UIGestureRecognizerStateEnded) {
        
        if(scrollView.center.y > viewHalfHeight+40 || scrollView.center.y < viewHalfHeight-40) { // Automatic Dismiss View
            
            if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
                [self performCloseAnimationWithScrollView:scrollView];
                return;
            }
            
            CGFloat finalX = firstX, finalY;
            
            CGFloat windowsHeigt = [_applicationWindow frame].size.height;
            
            if(scrollView.center.y > viewHalfHeight+30) // swipe down
                finalY = windowsHeigt*2;
            else // swipe up
                finalY = -viewHalfHeight;
            
            CGFloat animationDuration = 0.35;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:0];
            [UIView commitAnimations];
            
            [self performSelector:@selector(doneButtonPressed:) withObject:self afterDelay:animationDuration];
        } else { // Continue Showing View
            _isdraggingPhoto = NO;
            [self setNeedsStatusBarAppearanceUpdate];
            
            self.view.backgroundColor = [UIColor colorWithWhite:(_useWhiteBackgroundColor ? 1 : 0) alpha:1];
            
            CGFloat velocityY = (.35*[gesture velocityInView:self.view].y);
            
            CGFloat finalX = firstX;
            CGFloat finalY = viewHalfHeight;
            
            CGFloat animationDuration = (ABS(velocityY)*.0002)+.2;
            
            [UIView beginAnimations:nil context:NULL];
            [UIView setAnimationDuration:animationDuration];
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDelegate:self];
            [scrollView setCenter:CGPointMake(finalX, finalY)];
            [UIView commitAnimations];
        }
    }
}
*/

//#pragma mark - HJPagingScrollViewDelegate
//
//- (void)pagingScrollView:(HJPagingScrollView *)pagingScrollView swipeGesture:(UIGestureRecognizer *)swipeGesture {
//
//}
//
//- (void)pagingScrollView:(HJPagingScrollView *)pagingScrollView panGesture:(UIGestureRecognizer *)panGesture {
//    if(_disableVerticalSwipe || _scrolling) return;
//}

#pragma mark - Animation

- (void)performPresentAnimation {
    self.view.alpha = 0.0f;
    _pagingScrollView.alpha = 0.0f;
    _browserNavView.alpha = 0.0f;
    _browserCapView.alpha = 0.0f;
    
    UIImage *imageFromView = _scaleImage ? _scaleImage : [self getImageFromView:_senderViewForAnimation];
    
    _senderViewOriginalFrame = [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil];
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = [UIColor clearColor];
    [_applicationWindow addSubview:fadeView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = _senderViewOriginalFrame;
    resizableImageView.clipsToBounds = YES;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    if (@available(iOS 11.0, *)) {
        resizableImageView.accessibilityIgnoresInvertColors = YES;
    } else {
        // Fallback on earlier versions
    }
    [_applicationWindow addSubview:resizableImageView];
    _senderViewForAnimation.hidden = YES;
    
    void (^completion)(void) = ^() {
        self.view.alpha = 1.0f;
        self->_pagingScrollView.alpha = 1.0f;
        self->_browserNavView.alpha = 1.0f;
        self->_browserCapView.alpha = 1.0f;
        resizableImageView.backgroundColor = [UIColor colorWithWhite:(self->_useWhiteBackgroundColor) ? 1 : 0 alpha:1];
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.backgroundColor = self.useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    } completion:nil];
    
    CGRect finalImageViewFrame = [self animationFrameForImage:imageFromView presenting:YES scrollView:nil];
    
    if(_usePopAnimation) {
        [self animateView:resizableImageView toFrame:finalImageViewFrame completion:completion];
    } else {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = finalImageViewFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (void)performCloseAnimationWithScrollView:(HJZoomingScrollView*)scrollView {
    if (_delegate && [_delegate respondsToSelector:@selector(willDisappearPhotoBrowser:)]) {
        [_delegate willDisappearPhotoBrowser:self];
    }
    
    float fadeAlpha = 1 - fabs(scrollView.frame.origin.y)/scrollView.frame.size.height;
    
    UIImage *imageFromView = [scrollView.photo underlyingImage];
    if (!imageFromView && [scrollView.photo respondsToSelector:@selector(placeholderImage)]) {
        imageFromView = [scrollView.photo placeholderImage];
    }
    
    UIView *fadeView = [[UIView alloc] initWithFrame:_applicationWindow.bounds];
    fadeView.backgroundColor = self.useWhiteBackgroundColor ? [UIColor whiteColor] : [UIColor blackColor];
    fadeView.alpha = fadeAlpha;
    [_applicationWindow addSubview:fadeView];
    
    CGRect imageViewFrame = [self animationFrameForImage:imageFromView presenting:NO scrollView:scrollView];
    
    UIImageView *resizableImageView = [[UIImageView alloc] initWithImage:imageFromView];
    resizableImageView.frame = imageViewFrame;
    resizableImageView.contentMode = _senderViewForAnimation ? _senderViewForAnimation.contentMode : UIViewContentModeScaleAspectFill;
    resizableImageView.backgroundColor = [UIColor clearColor];
    resizableImageView.clipsToBounds = YES;
    if (@available(iOS 11.0, *)) {
        resizableImageView.accessibilityIgnoresInvertColors = YES;
    } else {
        // Fallback on earlier versions
    }
    [_applicationWindow addSubview:resizableImageView];
    self.view.hidden = YES;
    
    void (^completion)(void) = ^() {
        self->_senderViewForAnimation.hidden = NO;
        self->_senderViewForAnimation = nil;
        self->_scaleImage = nil;
        
        [fadeView removeFromSuperview];
        [resizableImageView removeFromSuperview];
        
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:NO];
    };
    
    [UIView animateWithDuration:_animationDuration animations:^{
        fadeView.alpha = 0;
        self.view.backgroundColor = [UIColor clearColor];
    } completion:nil];
    
    CGRect senderViewOriginalFrame = _senderViewForAnimation.superview ? [_senderViewForAnimation.superview convertRect:_senderViewForAnimation.frame toView:nil] : _senderViewOriginalFrame;
    
    if(_usePopAnimation) {
        [self animateView:resizableImageView toFrame:senderViewOriginalFrame completion:completion];
    } else {
        [UIView animateWithDuration:_animationDuration animations:^{
            resizableImageView.layer.frame = senderViewOriginalFrame;
        } completion:^(BOOL finished) {
            completion();
        }];
    }
}

- (CGRect)animationFrameForImage:(UIImage *)image presenting:(BOOL)presenting scrollView:(UIScrollView *)scrollView {
    if (!image) return CGRectZero;
    
    CGSize imageSize = image.size;
    CGRect bounds = _applicationWindow.bounds;
    
    if (@available(iOS 11.0, *)) {
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        UIEdgeInsets insets = UIEdgeInsetsMake(_statusBarHeight, 0, 0, 0);
        if (window != NULL) {
            insets = window.safeAreaInsets;
        }
        bounds = [self adjustForSafeArea:bounds adjustForStatusBar:NO forInsets:insets];
    }
    CGFloat maxWidth = CGRectGetWidth(bounds);
    CGFloat maxHeight = CGRectGetHeight(bounds);
    
    CGRect animationFrame = CGRectZero;
    
    CGFloat aspect = imageSize.width / imageSize.height;
    if (maxWidth / aspect <= maxHeight) {
        animationFrame.size = CGSizeMake(maxWidth, maxWidth / aspect);
    } else {
        animationFrame.size = CGSizeMake(maxHeight * aspect, maxHeight);
    }
    
    animationFrame.origin.x = roundf((maxWidth - animationFrame.size.width) / 2.0f);
    animationFrame.origin.y = roundf((maxHeight - animationFrame.size.height) / 2.0f);
    
    if (!presenting) {
        animationFrame.origin.y += scrollView.frame.origin.y;
    }
    return animationFrame;
}

- (void)performPhotoAnimationWithPreviousCurrentPage:(NSInteger)previousCurrentPage {
    CGRect visibleBounds = _pagingScrollView.bounds;
    float index = (CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    int intIndex = index;
    float c = index/intIndex;
    if (c == 1 || index <= 0 || index > ([self numberOfPhotos]-1)) return;
    
    HJZoomingScrollView * zoomingScrollView = nil;
    float scrollPercent = 0;
    if (_forwardXScroll) { //正向滑动
        scrollPercent = index - floorf(index);
        //        zoomingScrollView = [self pageDisplayedAtIndex:(scrollPercent<0.5?_currentPageIndex:(_currentPageIndex - 1))];
        zoomingScrollView = [self pageDisplayedAtIndex:_currentPageIndex];
        if (zoomingScrollView.layer.anchorPoint.x == 0.5) { // 0.5 -> 1
            zoomingScrollView.layer.anchorPoint = CGPointMake(1, 0.5);
            zoomingScrollView.layer.position = CGPointMake(zoomingScrollView.layer.position.x + HJPB_Screen_Width/2, zoomingScrollView.layer.position.y);
        } else if (zoomingScrollView.layer.anchorPoint.x == 0) { // 0 -> 1
            zoomingScrollView.layer.anchorPoint = CGPointMake(1, 0.5);
            zoomingScrollView.layer.position = CGPointMake(zoomingScrollView.layer.position.x + HJPB_Screen_Width, zoomingScrollView.layer.position.y);
        }
    } else { //反向滑动
        if (_beforePageIndex == 0) return;
        scrollPercent = 1 - (index - floorf(index));
        //        zoomingScrollView = [self pageDisplayedAtIndex:(scrollPercent<0.5?(_currentPageIndex+1):_currentPageIndex)];
        zoomingScrollView = [self pageDisplayedAtIndex:(_currentPageIndex+1)];
        if (zoomingScrollView.layer.anchorPoint.x == 1) {
            zoomingScrollView.layer.anchorPoint = CGPointMake(0, 0.5);
            zoomingScrollView.layer.position = CGPointMake(zoomingScrollView.layer.position.x - HJPB_Screen_Width, zoomingScrollView.layer.position.y);
        } else if (zoomingScrollView.layer.anchorPoint.x == 0.5) {
            zoomingScrollView.layer.anchorPoint = CGPointMake(0, 0.5);
            zoomingScrollView.layer.position = CGPointMake(zoomingScrollView.layer.position.x - HJPB_Screen_Width/2, zoomingScrollView.layer.position.y);
        }
    }
    
    if (zoomingScrollView) {
        CGFloat alpha = 1 - scrollPercent * 0.4;
        zoomingScrollView.alpha = alpha;
        
        float scale = 1 - scrollPercent * 0.3;
        zoomingScrollView.transform = CGAffineTransformMakeScale(scale, scale);
        
        zoomingScrollView.effectView.blurRadius = scrollPercent*10;
    }
}

#pragma mark - Genaral

- (void)prepareForClosePhotoBrowser {
    [_applicationWindow removeGestureRecognizer:_panGesture];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self]; // Cancel any pending toggles from taps
}

- (void)dismissPhotoBrowserAnimated:(BOOL)animated {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:willDismissAtPageIndex:)])
        [_delegate photoBrowser:self willDismissAtPageIndex:_currentPageIndex];
    
    [self dismissViewControllerAnimated:animated completion:^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(photoBrowser:didDismissAtPageIndex:)])
            [self.delegate photoBrowser:self didDismissAtPageIndex:self->_currentPageIndex];
    }];
}

- (UIImage*)getImageFromView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, YES, 2);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - HJPhoto Loading Notification

- (void)handleHJPhotoLoadingDidEndNotification:(NSNotification *)notification {
    id <HJPhoto> photo = [notification object];
    HJZoomingScrollView *page = [self pageDisplayingPhoto:photo];
    if (page) {
        if ([photo underlyingImage]) {
            [page displayImage];
            [self loadAdjacentPhotosIfNecessary:photo];
        } else {
            [page displayImageFailure];
            if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:imageFailed:imageView:)]) {
                NSUInteger pageIndex = HJPB_Page_Index(page);
                [_delegate photoBrowser:self imageFailed:pageIndex imageView:page.photoImageView];
            }
            [page setNeedsLayout];
        }
    }
}

#pragma mark - Paging

- (void)tilePages {
    CGRect visibleBounds = _pagingScrollView.bounds;
    NSInteger iFirstIndex = (NSInteger) floorf((CGRectGetMinX(visibleBounds)+HJPB_Page_Padding*2) / CGRectGetWidth(visibleBounds));
    NSInteger iLastIndex  = (NSInteger) floorf((CGRectGetMaxX(visibleBounds)-HJPB_Page_Padding*2-1) / CGRectGetWidth(visibleBounds));
    if (iFirstIndex < 0) iFirstIndex = 0;
    if (iFirstIndex > [self numberOfPhotos] - 1) iFirstIndex = [self numberOfPhotos] - 1;
    if (iLastIndex < 0) iLastIndex = 0;
    if (iLastIndex > [self numberOfPhotos] - 1) iLastIndex = [self numberOfPhotos] - 1;
    
    // Recycle no longer needed pages
    NSInteger pageIndex;
    for (HJZoomingScrollView *page in _visiblePages) {
        pageIndex = HJPB_Page_Index(page);
        if (pageIndex < (NSUInteger)iFirstIndex || pageIndex > (NSUInteger)iLastIndex) {
            [_recycledPages addObject:page];
            [page prepareForReuse];
            [page removeFromSuperview];
//            HJPB_Log(@"Removed page at index %li", HJPB_Page_Index(page));
        }
    }
    [_visiblePages minusSet:_recycledPages];
    while (_recycledPages.count > 2) // Only keep 2 recycled pages
        [_recycledPages removeObject:[_recycledPages anyObject]];
    
    // Add missing pages
    for (NSUInteger index = (NSUInteger)iFirstIndex; index <= (NSUInteger)iLastIndex; index++) {
        if (![self isDisplayingPageForIndex:index]) {
            // Add new page
            HJZoomingScrollView *page;
            page = [[HJZoomingScrollView alloc] initWithPhotoBrowser:self];
            page.backgroundColor = [UIColor clearColor];
            page.opaque = YES;
            
            [self configurePage:page forIndex:index];
            [_visiblePages addObject:page];
            [_pagingScrollView addSubview:page];
//            HJPB_Log(@"Added page at index %lu", (unsigned long)index);
        }
    }
}

- (BOOL)isDisplayingPageForIndex:(NSUInteger)index {
    for (HJZoomingScrollView *page in _visiblePages)
        if (HJPB_Page_Index(page) == index) return YES;
    return NO;
}

- (HJZoomingScrollView *)pageDisplayedAtIndex:(NSUInteger)index {
    HJZoomingScrollView *thePage = nil;
    for (HJZoomingScrollView *page in _visiblePages) {
        if (HJPB_Page_Index(page) == index) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (HJZoomingScrollView *)pageDisplayingPhoto:(id<HJPhoto>)photo {
    HJZoomingScrollView *thePage = nil;
    for (HJZoomingScrollView *page in _visiblePages) {
        if (page.photo == photo) {
            thePage = page; break;
        }
    }
    return thePage;
}

- (void)configurePage:(HJZoomingScrollView *)page forIndex:(NSUInteger)index {
    page.frame = [self frameForPageAtIndex:index];
    page.tag = HJPB_Page_Index_Tag_Offset + index;
    page.photo = [self photoAtIndex:index];
    
    __block __weak HJPhoto *photo = (HJPhoto*)page.photo;
    __weak HJZoomingScrollView* weakPage = page;
    photo.progressUpdateBlock = ^(CGFloat progress){
        [weakPage setProgress:progress forPhoto:photo];
    };
}

- (HJZoomingScrollView *)dequeueRecycledPage {
    HJZoomingScrollView *page = [_recycledPages anyObject];
    if (page) {
        [_recycledPages removeObject:page];
    }
    return page;
}

- (void)didStartViewingPageAtIndex:(NSUInteger)index {
    id <HJPhoto> currentPhoto = [self photoAtIndex:index];
    if ([currentPhoto underlyingImage]) {
        [self loadAdjacentPhotosIfNecessary:currentPhoto];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(photoBrowser:didShowPhotoAtIndex:)]) {
        [_delegate photoBrowser:self didShowPhotoAtIndex:index];
    }
}

- (void)didStartViewingAccessoryAtIndex:(NSUInteger)index {
    id <HJPhoto> currentPhoto = [self photoAtIndex:index];
    _captionView.photo = currentPhoto;
    _navigationView.accessory = _accessory;
    [(HJIndexView *)_indexView setPhoto:currentPhoto];
}

#pragma mark - View

- (HJPagingScrollView *)pagingScrollView {
    HJPagingScrollView *view = [[HJPagingScrollView alloc] initWithFrame:[self frameForPagingScrollView]];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    view.pagingEnabled = YES;
    view.delegate = self;
//    view.pagingScrollViewDelegate = self;
    view.showsHorizontalScrollIndicator = NO;
    view.showsVerticalScrollIndicator = NO;
    view.backgroundColor = [UIColor clearColor];
    view.contentSize = [self contentSizeForPagingScrollView];
    return view;
}

- (UIView *)browserIndexView {
    HJIndexView *view = [[HJIndexView alloc] initWithFrame:CGRectMake(self.view.frame.size.width-100-16, self.view.frame.size.height-32-44, 100, 32)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)browserTipView {
    HJTipView *view = [[HJTipView alloc] initWithFrame:CGRectMake(0, (self.view.frame.size.height-300)/2, self.view.frame.size.width, 300)];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (UIView *)browserLoadingView {
    UIView *view = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(loadingViewForPhotoBrowser:)]) {
        view = [_delegate loadingViewForPhotoBrowser:self];
    }
    return view;
}

- (UIButton *)doneButton {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.frame = CGRectMake(_statusBarHeight, _statusBarHeight*2, 44, 44);
    [button setImage:[self convertToImageWithView:[self drawCloseView]] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(doneButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (UIView *)browserCapView {
    return [[UIView alloc] initWithFrame:[self frameForBrowserCaptionViewWithHeight:_captionHeight]];
}

- (UIView *)browserNavView {
    return [[UIView alloc] initWithFrame:[self frameForBrowserNavigationViewWithHeight:_navigationHeight]];
}

- (UIView *)bottomToolView {
    UIView *bottomToolView = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(bottomToolViewForPhotoBrowser:)]) {
        bottomToolView = [_delegate bottomToolViewForPhotoBrowser:self];
    }
    return bottomToolView;
}

- (HJNavigationView *)navigationViewForBrowser {
    HJNavigationView *navView = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(navigationViewForPhotoBrowser:)]) {
        navView = (HJNavigationView *)[_delegate navigationViewForPhotoBrowser:self];
    } else {
        navView = [[HJNavigationView alloc] init];
        navView.minHeight = _navigationHeight;
        navView.maxHeight = self.view.bounds.size.height - _captionHeight;
    }
    navView.navigationDelegate = self;
    navView.frame = CGRectMake(0, 0, _browserNavView.frame.size.width, _browserNavView.frame.size.height);
    navView.alpha = _accessoryIsHide ? 0 : 1;
    
    return navView;
}

- (HJCaptionView *)captionViewForBrowser {
    HJCaptionView *captionView = nil;
    if (_delegate && [_delegate respondsToSelector:@selector(captionViewForPhotoBrowser:)]) {
        captionView = (HJCaptionView *)[_delegate captionViewForPhotoBrowser:self];
    } else {
        captionView = [[HJCaptionView alloc] init];
        captionView.minHeight = _captionHeight;
        captionView.maxHeight = self.view.bounds.size.height - _navigationHeight;
    }
    captionView.captionDelegate = self;
    captionView.alpha = _accessoryIsHide ? 0 : 1;
    captionView.frame = CGRectMake(0, 0, _browserCapView.frame.size.width, _browserCapView.frame.size.height);
    UIView *bottomToolView = [self bottomToolView];
    if (bottomToolView) {
        bottomToolView.frame = CGRectMake(0, _browserCapView.frame.size.height - HJPB_Bottom_Tool_Height, _browserCapView.frame.size.width, HJPB_Bottom_Tool_Height);
        captionView.bottomToolHeight = HJPB_Bottom_Tool_Height;
        [captionView addSubview:bottomToolView];
    }

    return captionView;
}

//- (UIView *)fadeView:(CGRect)rect {
//    UIView *fadeView = [[UIView alloc] initWithFrame:rect];
//    fadeView.tag = 101;
//    CAGradientLayer *gradient = [CAGradientLayer layer];
//    gradient.frame = fadeView.bounds;
//    gradient.colors = [NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0.5] CGColor], nil];
//    [fadeView.layer insertSublayer:gradient atIndex:0];
//    fadeView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    return fadeView;
//}

-(UIImage*)convertToImageWithView:(UIView*)view {
    CGSize size = view.bounds.size;
    // 下面方法，第一个参数表示区域大小。第二个参数表示是否是非透明的。如果需要显示半透明效果，需要传NO，否则传YES。第三个参数就是屏幕密度了
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage*image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIView *)drawCloseView {
    UIView *logoView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 30, 30)];
//    UIBezierPath * path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(logoView.center.x, logoView.center.y)
//                                                         radius:logoView.frame.size.width/2
//                                                     startAngle:0
//                                                       endAngle:M_PI*2
//                                                      clockwise:YES];
    UIBezierPath * path = [UIBezierPath bezierPath];
    path.lineCapStyle=kCGLineCapRound;
    path.lineJoinStyle=kCGLineCapRound;
    
    [path moveToPoint:CGPointMake(logoView.frame.size.width/4, logoView.frame.size.width/4)];
    CGPoint pl = CGPointMake(logoView.frame.size.width/4*3, logoView.frame.size.width/4*3);
    [path addLineToPoint:pl];
    
    [path moveToPoint:CGPointMake(logoView.frame.size.width/4*3, logoView.frame.size.width/4)];
    CGPoint p2 = CGPointMake(logoView.frame.size.width/4.0, logoView.frame.size.width/4*3);
    [path addLineToPoint:p2];
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.fillColor = [UIColor clearColor].CGColor;
    layer.strokeColor = [UIColor grayColor].CGColor;
    layer.lineWidth = 2;
    layer.path = path.CGPath;
    //动画设置
//    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:NSStringFromSelector(@selector(strokeEnd))];
//    animation.fromValue = @0;
//    animation.toValue = @1;
//    animation.duration = 1;
//    [layer addAnimation:animation forKey:NSStringFromSelector(@selector(strokeEnd))];
    [logoView.layer addSublayer:layer];
    
    return logoView;
}

#pragma mark - Frame Calculations

- (CGRect)frameForBrowserNavigationViewWithHeight:(CGFloat)height {
    CGRect frame = self.view.bounds;
    return CGRectMake(0, 0, frame.size.width, height);
}

- (CGRect)frameForBrowserCaptionViewWithHeight:(CGFloat)height {
    CGRect frame = self.view.bounds;
    return CGRectMake(0, frame.size.height - height, frame.size.width, height);
}

- (CGRect)frameForPagingScrollView {
    CGRect frame = self.view.bounds;
    frame.origin.x -= HJPB_Page_Padding;
    frame.size.width += (2 * HJPB_Page_Padding);
    frame = [self adjustForSafeArea:frame adjustForStatusBar:false];
    return frame;
}

- (CGRect)frameForPageAtIndex:(NSUInteger)index {
    CGRect bounds = _pagingScrollView.bounds;
    CGRect pageFrame = bounds;
    pageFrame.size.width -= (2 * HJPB_Page_Padding);
    pageFrame.origin.x = (bounds.size.width * index) + HJPB_Page_Padding;
    return pageFrame;
}

- (CGSize)contentSizeForPagingScrollView {
    CGRect bounds = _pagingScrollView.bounds;
    return CGSizeMake(bounds.size.width * [self numberOfPhotos], bounds.size.height);
}

- (CGPoint)contentOffsetForPageAtIndex:(NSUInteger)index {
    CGFloat pageWidth = _pagingScrollView.bounds.size.width;
    CGFloat newOffset = index * pageWidth;
    return CGPointMake(newOffset, 0);
}

- (CGRect)adjustForSafeArea:(CGRect)rect adjustForStatusBar:(BOOL)adjust {
    if (@available(iOS 11.0, *)) {
        return [self adjustForSafeArea:rect adjustForStatusBar:adjust forInsets:self.view.safeAreaInsets];
    }
    UIEdgeInsets insets = UIEdgeInsetsMake(_statusBarHeight, 0, 0, 0);
    return [self adjustForSafeArea:rect adjustForStatusBar:adjust forInsets:insets];
}

- (CGRect)adjustForSafeArea:(CGRect)rect adjustForStatusBar:(BOOL)adjust forInsets:(UIEdgeInsets) insets {
    return [HJPBUtils adjustRect:rect forSafeAreaInsets:insets forBounds:self.view.bounds adjustForStatusBar:adjust statusBarHeight:_statusBarHeight];
}

- (void)changeFrameForBrowserNavigationViewWithHeight:(CGFloat)height {
    [UIView animateWithDuration:0.3 animations:^{
        self->_browserNavView.frame = [self frameForBrowserNavigationViewWithHeight:height];
    } completion:nil];
}

- (void)changeFrameForBrowserCaptionViewWithHeight:(CGFloat)height {
    [UIView animateWithDuration:0.1 animations:^{
        self->_browserCapView.alpha = 0.4;
        self->_browserCapView.frame = [self frameForBrowserCaptionViewWithHeight:height];
        [self resetBottomToolView];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.3 animations:^{
            self->_browserCapView.alpha = 1;
        }];
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView  {
    if (!_viewIsActive || _performingLayout) return;
    
    [self tilePages];
    
    CGRect visibleBounds = _pagingScrollView.bounds;
    float exactIndex = (CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
    NSInteger index = (NSInteger)exactIndex;
    if (!_scrolling) { // Scrolling state and direction
        _scrolling = YES;
        _forwardXScroll = index >= _currentPageIndex ? YES : NO;
    }
    
    if (index < 0) index = 0;
    if (index > [self numberOfPhotos] - 1) index = [self numberOfPhotos] - 1;
    NSUInteger previousCurrentPage = _currentPageIndex;
    _currentPageIndex = index;
    if (_currentPageIndex != previousCurrentPage) {
        [self didStartViewingPageAtIndex:index];
    }
    
    if (!_disablePhotoAnimation) {
        [self performPhotoAnimationWithPreviousCurrentPage:previousCurrentPage];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    _beforePageIndex = _currentPageIndex;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (!_disablePhotoAnimation) {
        HJZoomingScrollView *zoomingScrollView = [self pageDisplayedAtIndex:_beforePageIndex];
        [zoomingScrollView resetScrollEffectForReuse];
    }
    _scrolling = NO;
    
    if (_beforePageIndex != _currentPageIndex) {
        if (!_accessoryIsHide) {
            [self resetNavigationView];
            [self resetCaptionView];
        } else {
            [_navigationView setNavigationViewOpen:NO];
            [_captionView setCaptionViewOpen:NO];
        }
        [self didStartViewingAccessoryAtIndex:_currentPageIndex];
    }
}

#pragma mark - HJNavigationViewDelegate

- (void)navigationViewHeightChanged:(CGFloat)height {
    [self resetCaptionView];
    [self changeFrameForBrowserNavigationViewWithHeight:height];
}

#pragma mark - HJCaptionViewDelegate

- (void)captionViewHeightChanged:(CGFloat)height {
    [self resetNavigationView];
    [self changeFrameForBrowserCaptionViewWithHeight:height];
}

#pragma mark - Accessory Hiding / Showing / Reset

- (void)resetNavigationView {
    if (_navigationView.isOpen) {
        [_navigationView setNavigationViewOpen:NO];
        [self changeFrameForBrowserNavigationViewWithHeight:_navigationHeight];
    }
}

- (void)resetCaptionView {
    if(_captionView.isOpen) {
        [_captionView setCaptionViewOpen:NO];
        [self changeFrameForBrowserCaptionViewWithHeight:_captionHeight];
    }
}

- (void)setAccessoryHidden:(BOOL)hidden animated:(BOOL)animated {
    if (_accessoryIsHide == hidden) return;
    _accessoryIsHide = hidden;
    
    CGRect navRect = _browserNavView.frame;
    CGRect newNavRect = CGRectMake(navRect.origin.x,
                                   hidden?-navRect.size.height:0,
                                   navRect.size.width, navRect.size.height);
    CGRect capRect = _browserCapView.frame;
    CGRect newCapRect = CGRectMake(capRect.origin.x,
                                   hidden?self.view.bounds.size.height:self.view.bounds.size.height-capRect.size.height,
                                   capRect.size.width, capRect.size.height);
    
    [UIView animateWithDuration:(animated ? 0.3 : 0) animations:^(void) {
        CGFloat alpha = hidden ? 0 : 1;
        [self.navigationController.navigationBar setAlpha:alpha];
        self->_browserNavView.alpha = alpha;
        self->_browserNavView.frame = newNavRect;
        self->_browserCapView.alpha = alpha;
        self->_browserCapView.frame = newCapRect;
    } completion:nil];
    
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)handleSingleTap {
    if (_dismissOnTouch) {
        [self doneButtonPressed:nil];
    } else {
        [self setAccessoryHidden:!_accessoryIsHide animated:YES];
    }
}

#pragma mark - Actions

- (void)jumpToPageAtIndex:(NSUInteger)index {
    if (index < [self numberOfPhotos]) {
        CGRect pageFrame = [self frameForPageAtIndex:index];
        [_pagingScrollView setContentOffset:CGPointMake(pageFrame.origin.x - HJPB_Page_Padding, 0) animated:YES];
    }
}

- (void)gotoPreviousPage { [self jumpToPageAtIndex:_currentPageIndex-1]; }
- (void)gotoNextPage     { [self jumpToPageAtIndex:_currentPageIndex+1]; }

- (void)doneButtonPressed:(id)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(willDisappearPhotoBrowser:)]) {
        [_delegate willDisappearPhotoBrowser:self];
    }
    
    if (_senderViewForAnimation && _currentPageIndex == _initalPageIndex) {
        HJZoomingScrollView *scrollView = [self pageDisplayedAtIndex:_currentPageIndex];
        [self performCloseAnimationWithScrollView:scrollView];
    } else {
        _senderViewForAnimation.hidden = NO;
        [self prepareForClosePhotoBrowser];
        [self dismissPhotoBrowserAnimated:YES];
    }
}

- (void)closeBrowser {
    [self doneButtonPressed:nil];
}

- (void)savePhoto {
    id <HJPhoto> photo = [self photoAtIndex:_currentPageIndex];
    UIImage *currentImage = [photo underlyingImage];
    if (currentImage) {
//        [self showProgressHUDWithMessage:[NSString stringWithFormat:NSLocalizedString(@"Saving...", nil)]];
        if (currentImage) {
            if (currentImage.images) { // GIF
                NSData *gifImageData = nil;
                if ([photo isKindOfClass:[HJPhoto class]]) {
                    NSString *picUrl = ((HJPhoto *)photo).photoURL.description;
                    if (HJPB_Check_Valid_String(picUrl)) {
                        NSString *cachedPath  = [[SDImageCache sharedImageCache] defaultCachePathForKey:picUrl];
                        gifImageData          = [NSData dataWithContentsOfFile:cachedPath];
                    }
                }
                //GIF保存到相册
                ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
                NSDictionary *metadata = @{@"UTI":(__bridge NSString *)kUTTypeGIF};
                [library writeImageDataToSavedPhotosAlbum:gifImageData metadata:metadata completionBlock:^(NSURL *assetURL, NSError *error) {
                    [self savePhotoFinishWithError:error];
                }];
            } else { //普通图片保存到相册
                UIImageWriteToSavedPhotosAlbum(currentImage, self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
            }
        }
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    [self savePhotoFinishWithError:error];
}

- (void)savePhotoFinishWithError:(NSError *)error {
    if (error) {
        if (-3310 == error.code) {
//            [self hideProgressHUD:NO];
            UIAlertController *alertCtrl = [UIAlertController alertControllerWithTitle:@"提示"
                                                                               message:@"相册权限被禁用，请到设置中授予新浪博客访问相册权限"
                                                                        preferredStyle:UIAlertControllerStyleAlert];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
            [alertCtrl addAction:[UIAlertAction actionWithTitle:@"去设置" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
                NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
                if ([[UIApplication sharedApplication] canOpenURL:url]) {
                    if (@available(iOS 10.0, *)) {
                        [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
                    } else {
                        [[UIApplication sharedApplication] openURL:url];
                    }
                }
            }]];
            [self presentViewController:alertCtrl animated:YES completion:nil];
        } else {
//            [self showProgressHUDCompleteMessage:NSLocalizedString(@"Save photo failed, please try later",nil) type:TipType_fail];
        }
    } else {
//        [self showProgressHUDCompleteMessage:NSLocalizedString(@"Save photo succeed", nil) type:TipType_success];
    }
}

- (void)resetBottomToolView {
    UIView *bottomToolView = [self bottomToolView];
    if (bottomToolView) {
        [bottomToolView removeFromSuperview];
        bottomToolView.frame = CGRectMake(0, _browserCapView.frame.size.height - HJPB_Bottom_Tool_Height, _browserCapView.frame.size.width, HJPB_Bottom_Tool_Height);
        _captionView.bottomToolHeight = HJPB_Bottom_Tool_Height;
        [(HJCaptionView *)_captionView addSubview:bottomToolView];
    }
}

- (void)showTip:(NSString *)tip {
    [(HJTipView *)_tipView showTip:tip];
}

/*
#pragma mark - Action Sheet Delegate
// TODO
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (actionSheet == _actionsSheet) {
        self.actionsSheet = nil;
        
        if (buttonIndex != actionSheet.cancelButtonIndex) {
            if ([_delegate respondsToSelector:@selector(photoBrowser:didDismissActionSheetWithButtonIndex:photoIndex:)]) {
                [_delegate photoBrowser:self didDismissActionSheetWithButtonIndex:buttonIndex photoIndex:_currentPageIndex];
                return;
            }
        }
    }
}
*/

#pragma mark - pop Animation

- (void)animateView:(UIView *)view toFrame:(CGRect)frame completion:(void (^)(void))completion {
    POPSpringAnimation *animation = [POPSpringAnimation animationWithPropertyNamed:kPOPViewFrame];
    [animation setSpringBounciness:6];
    [animation setDynamicsMass:1];
    [animation setToValue:[NSValue valueWithCGRect:frame]];
    [view pop_addAnimation:animation forKey:nil];
    
    if (completion) {
        [animation setCompletionBlock:^(POPAnimation *animation, BOOL finished) {
            completion();
        }];
    }
}

@end
