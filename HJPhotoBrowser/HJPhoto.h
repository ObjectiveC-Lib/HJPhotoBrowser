//
//  HJPhoto.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPhotoBrowserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^HJProgressUpdateBlock)(CGFloat progress);

@interface HJPhoto : NSObject <HJPhoto>
@property (nonatomic, strong, readonly) NSURL *photoURL;
@property (nonatomic, copy) HJProgressUpdateBlock progressUpdateBlock;

@property (nonatomic, strong) NSString *caption;
@property (nonatomic, strong) UIImage *placeholderImage;
@property (nonatomic, assign) NSUInteger index;
@property (nonatomic, assign) NSUInteger count;

+ (HJPhoto *)photoWithImage:(UIImage *)image;
+ (HJPhoto *)photoWithFilePath:(NSString *)path;
+ (HJPhoto *)photoWithURL:(NSURL *)url;

+ (NSArray <HJPhoto*> *)photosWithImages:(NSArray *)imagesArray;
+ (NSArray <HJPhoto*> *)photosWithFilePaths:(NSArray *)pathsArray;
+ (NSArray <HJPhoto*> *)photosWithURLs:(NSArray *)urlsArray;
+ (NSArray <HJPhoto*> *)photosWithPhotos:(NSArray <HJPhoto*> *)urlsArray;

- (id)initWithImage:(UIImage *)image;
- (id)initWithFilePath:(NSString *)path;
- (id)initWithURL:(NSURL *)url;
@end

NS_ASSUME_NONNULL_END
