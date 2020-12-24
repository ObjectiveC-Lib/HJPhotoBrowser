//
//  HJPhotoBrowserProtocol.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPBConstants.h"

#define HJPhoto_LOADING_DID_END_NOTIFICATION @"HJPhoto_LOADING_DID_END_NOTIFICATION"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - HJPhoto

@protocol HJPhoto <NSObject>
@required
- (UIImage *)underlyingImage;
- (void)loadUnderlyingImageAndNotify;
- (void)unloadUnderlyingImage;

@optional
- (NSString *)caption;
- (UIImage *)placeholderImage;
@end

#pragma mark - HJAccessory

@protocol HJAccessory <NSObject>
@optional
@property (nonatomic, strong) NSString *userPic;
@property (nonatomic, strong) NSString *userNick;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@end

#pragma mark - HJCaptionView

@protocol HJCaptionViewDelegate <NSObject>
@optional
- (void)captionViewHeightChanged:(CGFloat)height;
@end

@protocol HJCaptionView <NSObject>
@required

@optional
- (void)setCaptionViewOpen:(BOOL)open;

@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, assign) CGFloat minHeight; // also default height
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat bottomToolHeight;
@property (nonatomic, weak) id <HJPhoto> photo;
@property (nonatomic, weak) id <HJCaptionViewDelegate> captionDelegate;
@end

#pragma mark - HJNavigationView

@protocol HJNavigationViewDelegate <NSObject>
@optional
- (void)navigationViewHeightChanged:(CGFloat)height;
@end

@protocol HJNavigationView <NSObject>
@required

@optional
- (void)setNavigationViewOpen:(BOOL)open;

@property (nonatomic, assign, readonly) BOOL isOpen;
@property (nonatomic, assign) CGFloat minHeight; // also default height
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, weak) id <HJAccessory> accessory;
@property (nonatomic, weak) id <HJNavigationViewDelegate> navigationDelegate;
@end

NS_ASSUME_NONNULL_END
