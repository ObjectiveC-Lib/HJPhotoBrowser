//
//  HJPBUtils.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJPBUtils.h"

@implementation HJPBUtils

// Adjust a rect to be moved into a safe area specified by `insets`
+ (CGRect)adjustRect:(CGRect)rect forSafeAreaInsets:(UIEdgeInsets)insets forBounds:(CGRect)bounds adjustForStatusBar:(BOOL)adjust statusBarHeight:(int)statusBarHeight {
    BOOL isLeft = rect.origin.x <= insets.left;
    CGFloat insetTop = insets.top > 0 ? insets.top : statusBarHeight;
    BOOL isAtTop = (rect.origin.y <= insetTop);
    BOOL isRight = rect.origin.x + rect.size.width >= bounds.size.width - insets.right;
    BOOL isAtBottom = rect.origin.y + rect.size.height >= bounds.size.height - insets.bottom;
    if ((isLeft) && (isRight)) {
        rect.origin.x += insets.left;
        rect.size.width -= insets.right + insets.left;
    } else if (isLeft) {
        rect.origin.x += insets.left;
    } else if (isRight) {
        rect.origin.x -= insets.right;
    }
    if ((adjust) && (isAtTop) && (isAtBottom)) {
        rect.origin.y += insetTop;
        rect.size.height -= insets.bottom + insetTop;
    } else if ((adjust) && (isAtTop)) {
        rect.origin.y += insetTop;
    } else if ((isAtTop) && (isAtBottom)) {
        rect.size.height -= insets.bottom;
    } else if (isAtBottom) {
        rect.origin.y -= insets.bottom;
    }
    return rect;
}

@end
