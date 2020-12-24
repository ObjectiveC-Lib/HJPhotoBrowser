//
//  HJZoomingScrollView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPhotoBrowserProtocol.h"
#import "HJTapDetectingView.h"
#import "HJTapDetectingImageView.h"
#import "HJBluuurView.h"

NS_ASSUME_NONNULL_BEGIN

@class HJPhotoBrowser, HJPhoto;

@interface HJZoomingScrollView : UIScrollView <UIScrollViewDelegate, UIDragInteractionDelegate, HJTapDetectingViewDelegate, HJTapDetectingImageViewDelegate>
@property (nonatomic, strong) HJBluuurView *effectView;
@property (nonatomic, strong) HJTapDetectingView *tapView;
@property (nonatomic, strong) HJTapDetectingImageView *photoImageView;
@property (nonatomic, strong, nullable) id<HJPhoto> photo;

- (id)initWithPhotoBrowser:(HJPhotoBrowser *)browser;
- (void)displayImage;
- (void)displayImageFailure;
- (void)setProgress:(CGFloat)progress forPhoto:(HJPhoto*)photo;
- (void)setMaxMinZoomScalesForCurrentBounds;
- (void)resetScrollEffectForReuse;
- (void)prepareForReuse;
@end

NS_ASSUME_NONNULL_END
