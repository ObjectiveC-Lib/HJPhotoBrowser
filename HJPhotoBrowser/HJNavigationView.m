//
//  HJNavigationView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/27.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJNavigationView.h"
#import "HJPhoto.h"
#import "HJTapDetectingView.h"
#import <YYCategories/YYCategories.h>
#import "UIImageView+WebCache.h"

static const CGFloat paddingLeft = 20;
static const CGFloat paddingTop = 40;
static const CGFloat paddingBottom = 15;


@interface HJNavigationView()<HJTapDetectingViewDelegate>
@property (nonatomic, strong) HJTapDetectingView *tapView;
@property (nonatomic, assign) CGFloat titleHeight;
@property (nonatomic, assign) CGFloat trueHeight;

@property (nonatomic, strong) UIImageView *userHeadImageView;
@property (nonatomic, strong) UILabel *userNickLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, assign) BOOL isOpen;
@end


@implementation HJNavigationView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
//        self.opaque = NO;
//        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        [self.layer addSublayer:self.gradientLayer];
        [self addSubview:self.tapView];
        [self addSubview:self.userHeadImageView];
        [self addSubview:self.userNickLabel];
        [self addSubview:self.dateLabel];
        [self addSubview:self.titleLabel];
    }
    return self;
}

- (void)setNavigationViewOpen:(BOOL)open {
    CGFloat totalHeight = _trueHeight+paddingBottom*2+_userHeadImageView.bottom;
    if (totalHeight > _minHeight) {
        self.isOpen = open;
        CGFloat height = self.minHeight;
        if (self.isOpen) {
            height = totalHeight;
            if (height > _maxHeight) height = _maxHeight;
        }
        self.frame = CGRectMake(0, 0, self.frame.size.width, height);
    }
    
    [self setNeedsLayout];
}

- (void)setAccessory:(id<HJAccessory>)accessory {
    _accessory = accessory;
//    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:_accessory.userPic]
//                              placeholderImage:[UIImage imageNamed:@"user_head_default"]
//                                       options:SDWebImageRetryFailed];
    [self.userHeadImageView sd_setImageWithURL:[NSURL URLWithString:_accessory.userPic]];
    self.userNickLabel.text = _accessory.userNick;
    self.dateLabel.text = _accessory.time;
    self.titleLabel.text = _accessory.title;
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tapView.frame = self.bounds;
    self.gradientLayer.frame = self.bounds;
    
    self.userHeadImageView.frame = CGRectMake(paddingLeft, paddingTop, 32, 32);
    self.userNickLabel.frame = CGRectMake(_userHeadImageView.right+8, paddingTop, self.width-_userHeadImageView.right-paddingLeft-8, 16);
    self.dateLabel.frame = CGRectMake(_userHeadImageView.right+8, _userNickLabel.bottom+4, _userNickLabel.width, 12);
    
    CGSize size = [self sizeThatFits:self.bounds.size];
    self.titleLabel.frame = CGRectMake(paddingLeft, _userHeadImageView.bottom+paddingBottom,
                                       size.width,
                                       size.height);
}

- (CGSize)sizeThatFits:(CGSize)size {
    if (self.titleLabel.text.length == 0) return CGSizeZero;
    
    self.titleLabel.numberOfLines = 0;
    CGFloat width = size.width - paddingLeft * 2;
    _trueHeight = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    CGFloat height = _trueHeight;
    if (self.isOpen) {
        self.titleLabel.numberOfLines = 0;
        CGFloat total = height+_userHeadImageView.bottom+paddingBottom*2;
        if (total > _maxHeight) height = _maxHeight-_userHeadImageView.bottom-paddingBottom*2;
    } else {
        self.titleLabel.numberOfLines = 2;
        height = [self.titleLabel sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)].height;
    }
    return CGSizeMake(width, height);
}

#pragma mark - HJTapDetectingViewDelegate

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    CGFloat totalHeight = _trueHeight+paddingBottom*2+_userHeadImageView.bottom;
    if ((int)(totalHeight) > _minHeight) {
        self.isOpen = !self.isOpen;
        CGFloat height = self.minHeight;
        if (self.isOpen) {
            height = totalHeight;
            if (height > _maxHeight) height = _maxHeight;
        }
        self.frame = CGRectMake(0, 0, self.frame.size.width, height);
        if ([self.navigationDelegate respondsToSelector:@selector(navigationViewHeightChanged:)]) {
            [self.navigationDelegate navigationViewHeightChanged:height];
        }
    }
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
//    HJPB_Log(@"HJNavigationView_doubleTapDetected");
    
}

- (void)view:(UIView *)view swipeGestureDetected:(UISwipeGestureRecognizer *)gesture {
//    HJPB_Log(@"HJNavigationView_swipeGestureDetected");
    
}

#pragma mark - LazyLoad

- (HJTapDetectingView *)tapView {
    if (!_tapView) {
        _tapView = [HJTapDetectingView new];
        _tapView.tapDelegate = self;
        _tapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _tapView.backgroundColor = [UIColor clearColor];
    }
    return _tapView;
}

- (UIImageView *)userHeadImageView {
    if (!_userHeadImageView) {
        _userHeadImageView = [UIImageView new];
        _userHeadImageView.clipsToBounds = YES;
        _userHeadImageView.layer.cornerRadius = 16;
        _userHeadImageView.layer.masksToBounds = YES;
        _userHeadImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _userHeadImageView;
}

- (UILabel *)userNickLabel {
    if (!_userNickLabel) {
        _userNickLabel = [UILabel new];
        _userNickLabel.textColor = HJPB_RGB_Alpha(0xFFFFFF, 1);
        _userNickLabel.font = [UIFont systemFontOfSize:16];
    }
    return _userNickLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.numberOfLines = 2;
        _titleLabel.textColor = HJPB_RGB_Alpha(0xFFFFFF, 1);
        _titleLabel.font = [UIFont systemFontOfSize:20];
    }
    return _titleLabel;
}

- (UILabel *)dateLabel {
    if (!_dateLabel) {
        _dateLabel = [UILabel new];
        _dateLabel.textColor = HJPB_RGB_Alpha(0xFFFFFF, 1);
        _dateLabel.font = [UIFont systemFontOfSize:10];
    }
    return _dateLabel;
}

- (CAGradientLayer *)gradientLayer {
    if (!_gradientLayer) {
        _gradientLayer = [CAGradientLayer layer];
        _gradientLayer.frame = self.bounds;
        _gradientLayer.colors = @[(id)[[UIColor colorWithWhite:0 alpha:1] CGColor], (id)[[UIColor colorWithWhite:0 alpha:0] CGColor]];
        _gradientLayer.startPoint = CGPointMake(0.5, 0);
        _gradientLayer.endPoint = CGPointMake(0.5, 1);
        _gradientLayer.locations = @[@0,@1];
    }
    return _gradientLayer;
}

@end
