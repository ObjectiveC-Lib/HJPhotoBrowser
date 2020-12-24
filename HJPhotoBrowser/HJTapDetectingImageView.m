//
//  HJTapDetectingImageView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJTapDetectingImageView.h"

@interface HJTapDetectingImageView() <UIActionSheetDelegate, UIGestureRecognizerDelegate>
@property (nonatomic, strong) UIActionSheet *actionSheet;
@end


@implementation HJTapDetectingImageView

- (void)dealloc {
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.userInteractionEnabled = YES;
        UILongPressGestureRecognizer *longTap =[[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(imageLongTapClick:)];
        longTap.delegate = self;
        [self addGestureRecognizer:longTap];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(dissmissActionSheet)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image {
    if ((self = [super initWithImage:image])) {
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (id)initWithImage:(UIImage *)image highlightedImage:(UIImage *)highlightedImage {
    if ((self = [super initWithImage:image highlightedImage:highlightedImage])) {
        self.userInteractionEnabled = YES;
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
    if ([self.tapDelegate respondsToSelector:@selector(imageView:singleTapDetected:)])
        [self.tapDelegate imageView:self singleTapDetected:touch];
}

- (void)handleDoubleTap:(UITouch *)touch {
    if ([self.tapDelegate respondsToSelector:@selector(imageView:doubleTapDetected:)])
        [self.tapDelegate imageView:self doubleTapDetected:touch];
}

- (void)handleTripleTap:(UITouch *)touch {
    if ([self.tapDelegate respondsToSelector:@selector(imageView:tripleTapDetected:)])
        [self.tapDelegate imageView:self tripleTapDetected:touch];
}

#pragma mark - Notification

- (void)dissmissActionSheet {
    [self.actionSheet dismissWithClickedButtonIndex:1 animated:NO];
}

#pragma mark - UIGestureRecognizerDelegate

-(void)imageLongTapClick:(UILongPressGestureRecognizer*)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan) {
        self.actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                       delegate:self
                                              cancelButtonTitle:@"取消"
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:@"保存图片",nil];
        self.actionSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
        [self.actionSheet showInView:self];
    }
}

#pragma mark - UIActionSheetDelegate

-(void)actionSheet:(UIActionSheet*)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if(buttonIndex == 0) {
        if ([self.tapDelegate respondsToSelector:@selector(longPressToSaveImage:)])
            [self.tapDelegate longPressToSaveImage:self];
    }
}

@end
