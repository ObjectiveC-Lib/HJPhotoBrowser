//
//  HJLoadingView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/13.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJLoadingView.h"
#import "HJPBConstants.h"

@interface HJLoadingView () {
    SEL retryAction;
}
@property (nonatomic, weak) id actObject;
@property (nonatomic, readwrite, strong) UIActivityIndicatorView *indicator;
@property (nonatomic, readwrite, strong) UIButton                *retryButton;
@end


@implementation HJLoadingView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        _retryButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _retryButton.frame = CGRectMake((frame.size.width-100)/2, (frame.size.height-100)/2, 100, 100);
        [_retryButton setTitle:@"重新加载" forState:UIControlStateNormal];
//        [_retryButton setImage:[UIImage imageNamed:@"empty_article_reload_nomal_night.png"] forState:UIControlStateNormal];
//        [_retryButton setImage:[UIImage imageNamed:@"empty_article_reload_pressed_night.png"] forState:UIControlStateHighlighted];
        [_retryButton addTarget:self action:@selector(tapped) forControlEvents:UIControlEventTouchUpInside];
        _retryButton.hidden = YES;
        _retryButton.backgroundColor = [UIColor clearColor];
        [self addSubview:_retryButton];
        
        _indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake((frame.size.width-44)/2, (frame.size.height-44)/2, 44, 44)];
        _indicator.hidesWhenStopped = YES;
        _indicator.backgroundColor = [UIColor clearColor];
        _indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
        _indicator.alpha = 0.5;
        [self addSubview:_indicator];

        self.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)startAnimating {
    _retryButton.hidden = YES;
    [_indicator startAnimating];
    self.hidden = NO;
}

- (void)stopAnimating {
    [_indicator stopAnimating];
    self.hidden = YES;
}

- (void)stopAnimationWithRetryAction:(SEL)aRetryAction withActObject:(id)object {
    self.hidden = NO;
    [_indicator stopAnimating];
    _retryButton.hidden = NO;
    retryAction = aRetryAction;
    self.actObject = object;
}

- (void)tapped {
    [self startAnimating];
    if ([self.actObject respondsToSelector:retryAction]) {
        if (nil != retryAction) {
            IMP imp = [self.actObject methodForSelector:retryAction];
            void (*func)(id, SEL) = (void *)imp;
            func(self.actObject, retryAction);
        }
    }
}

@end
