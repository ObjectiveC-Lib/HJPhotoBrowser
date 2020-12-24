//
//  HJPhoto.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJPhoto.h"
#import "HJPhotoBrowser.h"
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/UIImage+ForceDecode.h>

@interface HJPhoto () {
}

@property (nonatomic, strong) NSString *photoPath;
@property (nonatomic, strong) UIImage *underlyingImage;
@property (nonatomic, assign) BOOL loadingInProgress;
@property (nonatomic, strong) NSURL *photoURL;
@end


@implementation HJPhoto

@synthesize underlyingImage = _underlyingImage;

#pragma mark - Class Methods

+ (HJPhoto *)photoWithImage:(UIImage *)image {
    return [[HJPhoto alloc] initWithImage:image];
}

+ (HJPhoto *)photoWithFilePath:(NSString *)path {
    return [[HJPhoto alloc] initWithFilePath:path];
}

+ (HJPhoto *)photoWithURL:(NSURL *)url {
    return [[HJPhoto alloc] initWithURL:url];
}

+ (NSArray <HJPhoto*> *)photosWithImages:(NSArray *)imagesArray {
    NSUInteger count = imagesArray.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        UIImage *image = imagesArray[i];
        if ([image isKindOfClass:[UIImage class]]) {
            HJPhoto *photo = [HJPhoto photoWithImage:image];
            photo.index = i+1;
            photo.count = count;
            [photos addObject:photo];
        }
    }
    
    return photos;
}

+ (NSArray <HJPhoto*> *)photosWithFilePaths:(NSArray *)pathsArray {
    NSUInteger count = pathsArray.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        NSString *path = pathsArray[i];
        if ([path isKindOfClass:[NSString class]]) {
            HJPhoto *photo = [HJPhoto photoWithFilePath:path];
            photo.index = i+1;
            photo.count = count;
            [photos addObject:photo];
        }
    }
    
    return photos;
}

+ (NSArray <HJPhoto*> *)photosWithURLs:(NSArray *)urlsArray {
    NSUInteger count = urlsArray.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (NSUInteger i = 0; i < count; i++) {
        id url = urlsArray[i];
        if ([url isKindOfClass:[NSURL class]]) {
            HJPhoto *photo = [HJPhoto photoWithURL:url];
            photo.index = i+1;
            photo.count = count;
            [photos addObject:photo];
        } else if ([url isKindOfClass:[NSString class]]) {
            HJPhoto *photo = [HJPhoto photoWithURL:[NSURL URLWithString:url]];
            photo.index = i+1;
            photo.count = count;
            [photos addObject:photo];
        }
    }
    
    return photos;
}

+ (NSArray <HJPhoto*> *)photosWithPhotos:(NSArray <HJPhoto*> *)photosArray {
    NSUInteger count = photosArray.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    
    for (NSUInteger i = 0; i < count; i++) {
        HJPhoto *photo = photosArray[i];
        photo.index = i+1;
        photo.count = count;
        [photos addObject:photo];
    }
    return photos;
}

#pragma mark - Init

- (id)initWithImage:(UIImage *)image {
    if ((self = [super init])) {
        self.underlyingImage = image;
    }
    return self;
}

- (id)initWithFilePath:(NSString *)path {
    if ((self = [super init])) {
        self.photoPath = [path copy];
    }
    return self;
}

- (id)initWithURL:(NSURL *)url {
    if ((self = [super init])) {
        self.photoURL = [url copy];
    }
    return self;
}


#pragma mark - HJPhoto Protocol

- (UIImage *)underlyingImage {
    return _underlyingImage;
}

- (void)loadUnderlyingImageAndNotify {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    self.loadingInProgress = YES;
    if (self.underlyingImage) {
        [self imageLoadingComplete];
    } else {
        if (self.photoPath) {
            [self performSelectorInBackground:@selector(loadImageFromFileAsync) withObject:nil];
        } else if (self.photoURL) {
            [[SDWebImageManager sharedManager] loadImageWithURL:self.photoURL options:SDWebImageRetryFailed progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    CGFloat progress = ((CGFloat)receivedSize)/((CGFloat)expectedSize);
                    if (self.progressUpdateBlock) {
                        self.progressUpdateBlock(progress);
                    }
                });
            } completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (image) {
                    self.underlyingImage = image;
                }
                [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
            }];
        } else {
            self.underlyingImage = nil;
            [self imageLoadingComplete];
        }
    }
}

- (void)unloadUnderlyingImage {
    self.loadingInProgress = NO;
    
    if (self.underlyingImage && (self.photoPath || self.photoURL)) {
        self.underlyingImage = nil;
    }
}

#pragma mark - Private

- (void)loadImageFromFileAsync {
    @autoreleasepool {
        @try {
            self.underlyingImage = [UIImage imageWithContentsOfFile:self.photoPath];
            if (!self.underlyingImage) {
            }
        } @finally {
            self.underlyingImage = [UIImage decodedImageWithImage:self.underlyingImage];
//            self.underlyingImage = [self decodedImageWithImage:self.underlyingImage];
            [self performSelectorOnMainThread:@selector(imageLoadingComplete) withObject:nil waitUntilDone:NO];
        }
    }
}

- (void)imageLoadingComplete {
    NSAssert([[NSThread currentThread] isMainThread], @"This method must be called on the main thread.");
    self.loadingInProgress = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:HJPhoto_LOADING_DID_END_NOTIFICATION
                                                        object:self];
}

- (UIImage *)decodedImageWithImage:(UIImage *)image {
    if (image.images) {
        // Do not decode animated images
        return image;
    }
    
    CGImageRef imageRef = image.CGImage;
    CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef), CGImageGetHeight(imageRef));
    CGRect imageRect = (CGRect){.origin = CGPointZero, .size = imageSize};
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    
    int infoMask = (bitmapInfo & kCGBitmapAlphaInfoMask);
    BOOL anyNonAlpha = (infoMask == kCGImageAlphaNone ||
                        infoMask == kCGImageAlphaNoneSkipFirst ||
                        infoMask == kCGImageAlphaNoneSkipLast);
    
    // CGBitmapContextCreate doesn't support kCGImageAlphaNone with RGB.
    // https://developer.apple.com/library/mac/#qa/qa1037/_index.html
    if (infoMask == kCGImageAlphaNone && CGColorSpaceGetNumberOfComponents(colorSpace) > 1)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        
        // Set noneSkipFirst.
        bitmapInfo |= kCGImageAlphaNoneSkipFirst;
    }
    // Some PNGs tell us they have alpha but only 3 components. Odd.
    else if (!anyNonAlpha && CGColorSpaceGetNumberOfComponents(colorSpace) == 3)
    {
        // Unset the old alpha info.
        bitmapInfo &= ~kCGBitmapAlphaInfoMask;
        bitmapInfo |= kCGImageAlphaPremultipliedFirst;
    }
    
    // It calculates the bytes-per-row based on the bitsPerComponent and width arguments.
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 imageSize.width,
                                                 imageSize.height,
                                                 CGImageGetBitsPerComponent(imageRef),
                                                 0,
                                                 colorSpace,
                                                 bitmapInfo);
    CGColorSpaceRelease(colorSpace);
    
    // If failed, return undecompressed image
    if (!context) return image;
    
    CGContextDrawImage(context, imageRect, imageRef);
    CGImageRef decompressedImageRef = CGBitmapContextCreateImage(context);
    
    CGContextRelease(context);
    
    UIImage *decompressedImage = [UIImage imageWithCGImage:decompressedImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(decompressedImageRef);
    return decompressedImage;
}

@end
