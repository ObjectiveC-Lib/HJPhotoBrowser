//
//  HJTapDetectingView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HJTapDetectingViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface HJTapDetectingView : UIView
@property (nonatomic, weak) id <HJTapDetectingViewDelegate> tapDelegate;

- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol HJTapDetectingViewDelegate <NSObject>
@optional
- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view tripleTapDetected:(UITouch *)touch;
- (void)view:(UIView *)view swipeGestureDetected:(UISwipeGestureRecognizer *)gesture;
@end

NS_ASSUME_NONNULL_END
