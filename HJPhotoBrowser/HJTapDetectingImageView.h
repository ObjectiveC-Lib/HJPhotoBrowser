//
//  HJTapDetectingImageView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol HJTapDetectingImageViewDelegate;

NS_ASSUME_NONNULL_BEGIN

@interface HJTapDetectingImageView : UIImageView
@property (nonatomic, weak) id <HJTapDetectingImageViewDelegate> tapDelegate;

- (void)handleSingleTap:(UITouch *)touch;
- (void)handleDoubleTap:(UITouch *)touch;
- (void)handleTripleTap:(UITouch *)touch;
@end

@protocol HJTapDetectingImageViewDelegate <NSObject>
@optional
- (void)imageView:(UIImageView *)imageView singleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView doubleTapDetected:(UITouch *)touch;
- (void)imageView:(UIImageView *)imageView tripleTapDetected:(UITouch *)touch;
- (void)longPressToSaveImage:(UIImageView *)imageView;
@end

NS_ASSUME_NONNULL_END
