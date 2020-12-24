//
//  HJPagingScrollView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/30.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJPagingScrollView.h"

@interface HJPagingScrollView()
@end


@implementation HJPagingScrollView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        /*
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognized:)];
        [panGesture setMinimumNumberOfTouches:1];
        [panGesture setMaximumNumberOfTouches:1];
        [self addGestureRecognizer:panGesture];
        
        UISwipeGestureRecognizer *swipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeGestureRecognized:)];
        swipe.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
        [self addGestureRecognizer:swipe];
        */
    }
    return self;
}

- (void)swipeGestureRecognized:(UISwipeGestureRecognizer *)gesture {
    if ([self.pagingScrollViewDelegate respondsToSelector:@selector(pagingScrollView:swipeGesture:)]) {
        [self.pagingScrollViewDelegate pagingScrollView:self swipeGesture:gesture];
    }
}

- (void)panGestureRecognized:(UIGestureRecognizer *)gesture {
    if (UIGestureRecognizerStateBegan == gesture.state) {
    }
    
    if (UIGestureRecognizerStateChanged == gesture.state) {
    }
    
    if (UIGestureRecognizerStateEnded == gesture.state) {
    }
    
    if ([self.pagingScrollViewDelegate respondsToSelector:@selector(pagingScrollView:panGesture:)]) {
        [self.pagingScrollViewDelegate pagingScrollView:self panGesture:gesture];
    }
}

@end

/*
@implementation HJPagingScrollView (Recognizer)
 
 - (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
 if ([touch.view isDescendantOfView:_captionView]) {
 return NO;
 }
 return YES;
 }

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    CGPoint transPoint = [gestureRecognizer translationInView:self];
    
//    NSLog(@"gestureRecognizer = %@", [gestureRecognizer class]);
    
//    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]
//        || [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]
//        || [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) {
//        return YES;
//    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    NSLog(@"gestureRecognizer = %@", [gestureRecognizer class]);

//    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]
//        || [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewDelayedTouchesBeganGestureRecognizer")]
//        || [gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPagingSwipeGestureRecognizer")]) {
//        return YES;
//    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    if ([gestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")]) {
//        CGPoint touchPoint = [gestureRecognizer locationInView:self];
//        touchPoint.x = 50;
//    }
    return YES;
}
 
@end
 
*/

