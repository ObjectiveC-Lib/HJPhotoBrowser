//
//  HJPBUtils.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJPBUtils : NSObject

+ (CGRect)adjustRect:(CGRect)rect
   forSafeAreaInsets:(UIEdgeInsets)insets
           forBounds:(CGRect)bounds
  adjustForStatusBar:(BOOL)adjust
     statusBarHeight:(int)statusBarHeight;

@end

NS_ASSUME_NONNULL_END
