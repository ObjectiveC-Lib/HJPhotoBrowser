//
//  HJZoomingScrollView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJZoomingScrollView.h"
#import "HJPhoto.h"
#import "HJCaptionView.h"
#import "HJPhotoBrowser.h"
#import <DACircularProgress/DACircularProgressView.h>

@interface HJPhotoBrowser ()
- (UIImage *)imageForPhoto:(id<HJPhoto>)photo;
- (void)handleSingleTap;
- (void)doneButtonPressed:(id)sender;
- (void)savePhoto;
@end


@interface HJZoomingScrollView ()
@property (nonatomic) CGFloat maximumDoubleTapZoomScale;
@property (nonatomic, weak) HJPhotoBrowser *photoBrowser;
@property (nonatomic, strong) DACircularProgressView *progressView;

- (void)handleSingleTap:(CGPoint)touchPoint;
- (void)handleDoubleTap:(CGPoint)touchPoint;
@end


@implementation HJZoomingScrollView
@synthesize photo = _photo;

- (id)initWithPhotoBrowser:(HJPhotoBrowser *)browser {
    if ((self = [super init])) {
        self.photoBrowser = browser;
        
        _tapView = [[HJTapDetectingView alloc] initWithFrame:self.bounds];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor clearColor];
        [self addSubview:_tapView];
        
        _photoImageView = [[HJTapDetectingImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.tapDelegate = self;
        _photoImageView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _photoImageView.accessibilityIgnoresInvertColors = YES;
            UIDragInteraction *drag = [[UIDragInteraction alloc] initWithDelegate: self];
            [_photoImageView addInteraction:drag];
        } else {
            // Fallback on earlier versions
        }
        [self addSubview:_photoImageView];
        
        if (@available(iOS 9.0, *)) {
            // iOS 9.0+, because of subclassing from UIVisualEffectsView.
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            self.effectView = [[HJBluuurView alloc] initWithEffect:effect];
            self.effectView.blurRadius = 0;
            self.effectView.userInteractionEnabled = NO;
            [self addSubview:self.effectView];
        }
        
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenBound.size.width;
        CGFloat screenHeight = screenBound.size.height;
        
        if ([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
            screenWidth = screenBound.size.height;
            screenHeight = screenBound.size.width;
        }
        
        _progressView = [[DACircularProgressView alloc] initWithFrame:CGRectMake((screenWidth-35.)/2., (screenHeight-35.)/2, 35.0f, 35.0f)];
        [_progressView setProgress:0.0f];
        _progressView.tag = 101;
        _progressView.thicknessRatio = 0.1;
        _progressView.roundedCorners = NO;
        [self addSubview:_progressView];
        
        self.backgroundColor = [UIColor clearColor];
        self.delegate = self;
        self.showsHorizontalScrollIndicator = NO;
        self.showsVerticalScrollIndicator = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    
    return self;
}

- (void)setPhoto:(id<HJPhoto>)photo {
    _photoImageView.image = nil;
    if (_photo != photo) {
        _photo = photo;
    }
    [self displayImage];
}

- (void)prepareForReuse {
    self.photo = nil;
    [self resetScrollEffectForReuse];
}

- (void)resetScrollEffectForReuse {
    self.alpha = 1;
    self.transform = CGAffineTransformMakeScale(1, 1);
    self.effectView.blurRadius = 0;
}

#pragma mark - Drag & Drop

- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session NS_AVAILABLE_IOS(11.0) {
    return @[[[UIDragItem alloc] initWithItemProvider:[[NSItemProvider alloc] initWithObject:_photoImageView.image]]];
}

#pragma mark - Image

- (void)displayImage {
    if (_photo) {
        self.maximumZoomScale = 1;
        self.minimumZoomScale = 1;
        self.zoomScale = 1;
        self.contentSize = CGSizeMake(0, 0);
        
        UIImage *img = [self.photoBrowser imageForPhoto:_photo];
        if (img) {
            _progressView.alpha = 0.0f;
            [_progressView removeFromSuperview];
            
            _photoImageView.image = img;
            _photoImageView.hidden = NO;
            
            CGRect photoImageViewFrame;
            photoImageViewFrame.origin = CGPointZero;
            photoImageViewFrame.size = img.size;
            _photoImageView.frame = photoImageViewFrame;
            self.effectView.frame = photoImageViewFrame;
            self.contentSize = photoImageViewFrame.size;

            [self setMaxMinZoomScalesForCurrentBounds];
        } else {
            _photoImageView.hidden = YES;
            _progressView.alpha = 1.0f;
        }
        
        [self setNeedsLayout];
    }
}

- (void)setProgress:(CGFloat)progress forPhoto:(HJPhoto*)photo {
    HJPhoto *p = (HJPhoto*)self.photo;
    
    if ([photo.photoURL.absoluteString isEqualToString:p.photoURL.absoluteString]) {
        if (_progressView.progress < progress) {
            [_progressView setProgress:progress animated:YES];
        }
    }
}

- (void)displayImageFailure {
    [_progressView removeFromSuperview];
}

#pragma mark - Setup

- (void)setMaxMinZoomScalesForCurrentBounds {
    self.maximumZoomScale = 1;
    self.minimumZoomScale = 1;
    self.zoomScale = 1;
    
    if (_photoImageView.image == nil) return;
    
    CGSize boundsSize = self.bounds.size;
    boundsSize.width -= 0.1;
    boundsSize.height -= 0.1;
    
    CGSize imageSize = _photoImageView.frame.size;
    
    CGFloat xScale = boundsSize.width / imageSize.width;
    CGFloat yScale = boundsSize.height / imageSize.height;
    CGFloat minScale = MIN(xScale, yScale);
    
    // If image is smaller than the screen then ensure we show it at
    // min scale of xScale
    if (xScale > 1 && yScale > 1) {
//        minScale = 1.0;
        minScale = xScale;
    }
    
    // If image height is bigger than the screen height then ensure we show it at
    // min scale of xScale
    if (xScale < 1 && yScale < 1) {
        minScale = xScale;
    }
    
    CGFloat maxScale = 4.0;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxScale = maxScale / [[UIScreen mainScreen] scale];
        if (maxScale < minScale) {
            maxScale = minScale * 2;
        }
    }
    
    CGFloat maxDoubleTapZoomScale = 4.0 * minScale;
    if ([UIScreen instancesRespondToSelector:@selector(scale)]) {
        maxDoubleTapZoomScale = maxDoubleTapZoomScale / [[UIScreen mainScreen] scale];
        if (maxDoubleTapZoomScale < minScale) {
            maxDoubleTapZoomScale = minScale * 2;
        }
    }
    
    maxDoubleTapZoomScale = MIN(maxDoubleTapZoomScale, maxScale);
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
    self.zoomScale = minScale;
    self.maximumDoubleTapZoomScale = maxDoubleTapZoomScale;

    _photoImageView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    self.effectView.frame = CGRectMake(0, 0, _photoImageView.frame.size.width, _photoImageView.frame.size.height);
    [self setNeedsLayout];
}

#pragma mark - Layout

- (void)layoutSubviews {
    _tapView.frame = self.bounds;
    
    [super layoutSubviews];
    
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _photoImageView.frame;
    
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
    } else {
        frameToCenter.origin.x = 0;
    }
    
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
    } else {
        frameToCenter.origin.y = 0;
    }
    
    if (!CGRectEqualToRect(_photoImageView.frame, frameToCenter)) {
        _photoImageView.frame = frameToCenter;
        self.effectView.frame = frameToCenter;
    }
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _photoImageView;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {

}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    float contentHeight = scrollView.contentSize.height;
    float viewHeight = scrollView.frame.size.height;
    if (self.zoomScale > self.minimumZoomScale) return;
        
    if(scrollView.contentOffset.y < -100 || scrollView.contentOffset.y > contentHeight-viewHeight+100) {
        [_photoBrowser doneButtonPressed:nil];
    }
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    [self setNeedsLayout];
    [self layoutIfNeeded];
}

#pragma mark - Tap Detection

- (void)handleSingleTap:(CGPoint)touchPoint {
    [_photoBrowser performSelector:@selector(handleSingleTap) withObject:nil afterDelay:0.2];
}

- (void)handleDoubleTap:(CGPoint)touchPoint {
    [NSObject cancelPreviousPerformRequestsWithTarget:_photoBrowser];
    
    if (self.zoomScale == self.maximumDoubleTapZoomScale) {
        [self setZoomScale:self.minimumZoomScale animated:YES];
    } else {
        CGSize targetSize = CGSizeMake(self.frame.size.width / self.maximumDoubleTapZoomScale, self.frame.size.height / self.maximumDoubleTapZoomScale);
        CGPoint targetPoint = CGPointMake(touchPoint.x - targetSize.width / 2, touchPoint.y - targetSize.height / 2);
        [self zoomToRect:CGRectMake(targetPoint.x, targetPoint.y, targetSize.width, targetSize.height) animated:YES];
    }
}

#pragma mark - HJTapDetectingImageViewDelegate

- (void)longPressToSaveImage:(UIImageView *)imageView {
    [_photoBrowser savePhoto];
}

- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:imageView]];
}
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:imageView]];
}

#pragma mark - HJTapDetectingViewDelegate

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    [self handleSingleTap:[touch locationInView:view]];
}
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    [self handleDoubleTap:[touch locationInView:view]];
}

@end
