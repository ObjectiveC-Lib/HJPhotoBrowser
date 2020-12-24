//
//  HJPagingScrollView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/30.
//  Copyright © 2018 navy. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HJPagingScrollView;

@protocol HJPagingScrollViewDelegate <NSObject>
@optional
- (void)pagingScrollView:(HJPagingScrollView *)pagingScrollView panGesture:(UIGestureRecognizer *)panGesture;
- (void)pagingScrollView:(HJPagingScrollView *)pagingScrollView swipeGesture:(UIGestureRecognizer *)swipeGesture;
@end


@interface HJPagingScrollView : UIScrollView
@property (nonatomic, weak) id<HJPagingScrollViewDelegate> pagingScrollViewDelegate;
@end


@interface HJPagingScrollView (Recognizer)
@end

NS_ASSUME_NONNULL_END
