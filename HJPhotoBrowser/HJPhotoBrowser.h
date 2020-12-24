//
//  HJPhotoBrowser.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPhoto.h"
#import "HJPhotoBrowserProtocol.h"
#import "HJTapDetectingImageView.h"

NS_ASSUME_NONNULL_BEGIN

@class HJPhotoBrowser;
@protocol HJPhotoBrowserDelegate <NSObject>
@optional
- (void)willAppearPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (void)willDisappearPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (void)photoBrowser:(HJPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)index;
- (void)photoBrowser:(HJPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(HJPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)index;
- (void)photoBrowser:(HJPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex
          photoIndex:(NSUInteger)photoIndex;
- (nullable id<HJCaptionView>)captionViewForPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (nullable id<HJNavigationView>)navigationViewForPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (UIView *)bottomToolViewForPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (UIView *)loadingViewForPhotoBrowser:(HJPhotoBrowser *)photoBrowser;
- (void)photoBrowser:(HJPhotoBrowser *)photoBrowser imageFailed:(NSUInteger)index
           imageView:(HJTapDetectingImageView *)imageView;
@end


@interface HJPhotoBrowser : UIViewController <UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic, weak) UIImage *scaleImage;
@property (nonatomic, assign) id <HJPhotoBrowserDelegate> delegate;
@property (nonatomic, strong) id <HJAccessory> accessory;

@property (nonatomic) BOOL dismissOnTouch;
@property (nonatomic) BOOL usePopAnimation;
@property (nonatomic) BOOL forceHideStatusBar;
@property (nonatomic) BOOL disableVerticalSwipe;
@property (nonatomic) BOOL disablePhotoAnimation;
@property (nonatomic) BOOL useWhiteBackgroundColor;

@property (nonatomic) BOOL displayBottomToolView; // bottom view
@property (nonatomic) BOOL displayAccessoryView; // nav and caption
@property (nonatomic) CGFloat navigationHeight;
@property (nonatomic) CGFloat captionHeight;

@property (nonatomic) float animationDuration; // default .28
@property (nonatomic) float backgroundScaleFactor; // default 1.0

- (id)initWithPhotos:(NSArray <HJPhoto*> *)photosArray;
- (id)initWithPhotos:(NSArray <HJPhoto*> *)photosArray animatedFromView:(UIView*)view;
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray;
- (id)initWithPhotoURLs:(NSArray *)photoURLsArray animatedFromView:(UIView*)view;

- (void)closeBrowser;
- (void)reloadData;
- (void)setPhotos:(NSArray <HJPhoto*> *)photos;
- (void)setInitialPageIndex:(NSUInteger)index;
- (id<HJPhoto>)photoAtIndex:(NSUInteger)index;
- (void)savePhoto;
- (void)resetBottomToolView;
- (void)showTip:(NSString *)tip;
@end

NS_ASSUME_NONNULL_END
