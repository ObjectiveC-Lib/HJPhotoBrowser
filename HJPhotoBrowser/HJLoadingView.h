//
//  HJLoadingView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/13.
//  Copyright © 2018 navy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJLoadingView : UIView
@property (nonatomic, readonly, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, readonly, strong) UIButton                *retryButton;

- (void)startAnimating;
- (void)stopAnimating;
- (void)stopAnimationWithRetryAction:(SEL)retryAction withActObject:(id)object;
@end

NS_ASSUME_NONNULL_END
