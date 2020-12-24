//
//  HJTapDetectingView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJTapDetectingView.h"

@interface HJTapDetectingView() <UIGestureRecognizerDelegate>
@end


@implementation HJTapDetectingView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
}

- (id)init {
    if ((self = [super init])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
//        UISwipeGestureRecognizer *swipe =[[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(viewSwipe:)];
//        swipe.direction = UISwipeGestureRecognizerDirectionDown | UISwipeGestureRecognizerDirectionUp;
//        swipe.delegate = self;
//        [self addGestureRecognizer:swipe];
    }
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    NSUInteger tapCount = touch.tapCount;
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    switch (tapCount) {
        case 1:
            [self performSelector:@selector(handleSingleTap:) withObject:touch afterDelay:0.3];
            break;
        case 2:
            [self handleDoubleTap:touch];
            break;
        case 3:
            [self handleTripleTap:touch];
            break;
        default:
            break;
    }
    [[self nextResponder] touchesEnded:touches withEvent:event];
}

- (void)handleSingleTap:(UITouch *)touch {
    if ([self.tapDelegate respondsToSelector:@selector(view:singleTapDetected:)])
        [self.tapDelegate view:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([self.tapDelegate respondsToSelector:@selector(view:doubleTapDetected:)])
        [self.tapDelegate view:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([self.tapDelegate respondsToSelector:@selector(view:tripleTapDetected:)])
        [self.tapDelegate view:self tripleTapDetected:touch];
}

#pragma mark - UIGestureRecognizerDelegate

-(void)viewSwipe:(UISwipeGestureRecognizer*)gesture {
    if(gesture.state == UIGestureRecognizerStateEnded) {
        if ([self.tapDelegate respondsToSelector:@selector(view:swipeGestureDetected:)])
            [self.tapDelegate view:self swipeGestureDetected:gesture];
    }
}

//- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
//    return YES;
//}
//
//- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
//    return YES;
//}
//
//-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
//    return YES;
//}

@end
