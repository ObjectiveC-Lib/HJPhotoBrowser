//
//  HJCaptionView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import "HJCaptionView.h"
#import "HJPhoto.h"
#import "HJTapDetectingView.h"

#import <QuartzCore/QuartzCore.h>

static const CGFloat labelPadding = 20;
static const CGFloat labelTop = 15;

@interface HJCaptionView () <HJTapDetectingViewDelegate>
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) HJTapDetectingView *tapView;

@property (nonatomic, assign) CGFloat captionHeight;
@property (nonatomic, assign) CGFloat trueHeight;

@property (nonatomic, assign) BOOL isOpen;
@end


@implementation HJCaptionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        self.isOpen = NO;
        
        self.tapView.frame = self.bounds;
        [self addSubview:self.tapView];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    self.tapView.frame = self.bounds;
    [super layoutSubviews];
    
    [self updateUI];
}

- (void)setCaptionViewOpen:(BOOL)open {
    CGFloat totalHeight = _trueHeight+labelTop*2+_bottomToolHeight;
    if (totalHeight > _minHeight) {
        self.isOpen = open;
        CGFloat height = self.minHeight;
        if (self.isOpen) {
            height = totalHeight;
            if (height > _maxHeight) height = _maxHeight;
        }
        self.frame = CGRectMake(0, 0, self.frame.size.width, height);
        if ([self.captionDelegate respondsToSelector:@selector(captionViewHeightChanged:)]) {
            [self.captionDelegate captionViewHeightChanged:height];
        }
    }
    
    [self setNeedsLayout];
}

- (CGFloat)getSelfFrame {
    CGFloat height = self.minHeight;
    if ((int)(_trueHeight+labelTop*2+_bottomToolHeight) > _minHeight) {
        if (self.isOpen) {
            height = _trueHeight+labelTop*2+_bottomToolHeight;
            if (height > _maxHeight) height = _maxHeight;
        }
    }
    //    self.isOpen = !self.isOpen;
    //    self.frame = CGRectMake(0, 0, self.frame.size.width, height);
    
    return height;
}

- (void)setPhoto:(id<HJPhoto>)photo {
    _photo = photo;
    
    [self updateUI];
    [self setNeedsLayout];
}

- (void)updateUI {
    self.label.attributedText = [self captionString:_photo];
    CGSize size = [self sizeThatFit:self.bounds.size];
    self.label.frame = CGRectMake(labelPadding, labelTop,
                                  size.width,
                                  size.height);
    if (self.isOpen) {
        self.label.numberOfLines = 0;
        self.label.lineBreakMode = NSLineBreakByWordWrapping;
    } else {
        self.label.numberOfLines = 4;
        self.label.lineBreakMode = NSLineBreakByTruncatingTail;
    }
}

- (CGSize)sizeThatFit:(CGSize)size {
    if (self.label.attributedText.length == 0) return CGSizeZero;
    
    CGFloat width = size.width - labelPadding * 2;
    _trueHeight = [self boundingRectWithString:[self captionString:_photo] size:size];
    
    CGFloat height = _trueHeight;
    if (self.isOpen) {
        if (_trueHeight+labelTop*2+_bottomToolHeight > _maxHeight) {
            height = _maxHeight-labelTop*2-_bottomToolHeight;
        }
    } else {
        if (_trueHeight+labelTop*2+_bottomToolHeight > _minHeight) {
            height = self.minHeight-labelTop*2-_bottomToolHeight;
        }
    }
    return CGSizeMake(width, height);
}

- (CGFloat)boundingRectWithString:(NSAttributedString *)string size:(CGSize)size {
    CGFloat width = size.width - labelPadding * 2;
    CGRect rect = [string boundingRectWithSize:CGSizeMake(width, HUGE)
                                       options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                       context:nil];
    return rect.size.height;
}

- (NSAttributedString *)captionString:(id<HJPhoto>)photo {
    HJPhoto *ph = (HJPhoto *)photo;
    if (!HJPB_Check_Valid_String(photo.caption)) return nil;
    
    NSString *indexStr = [NSString stringWithFormat:@"%lu", (unsigned long)ph.index];
    NSString *countStr = [NSString stringWithFormat:@"%@/%lu", indexStr, (unsigned long)ph.count];
    NSString *str = [NSString stringWithFormat:@"%@  %@", countStr, photo.caption];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 4;
    style.alignment = NSTextAlignmentLeft;
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:16]
                    range:NSMakeRange(0 , str.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:HJPB_RGB_Alpha(0xC2C2C2, 1)
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor whiteColor]
                    range:NSMakeRange(0, countStr.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:18]
                    range:NSMakeRange(0 , indexStr.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:16]
                    range:NSMakeRange(indexStr.length , countStr.length)];
    return attrStr;
}

#pragma mark - HJTapDetectingViewDelegate

- (void)view:(UIView *)view singleTapDetected:(UITouch *)touch {
    CGFloat totalHeight = _trueHeight+labelTop*2+_bottomToolHeight;
    if (totalHeight > _minHeight) {
        self.isOpen = !self.isOpen;
        CGFloat height = self.minHeight;
        if (self.isOpen) {
            height = totalHeight;
            if (height > _maxHeight) height = _maxHeight;
        }
        self.frame = CGRectMake(0, 0, self.frame.size.width, height);
        if ([self.captionDelegate respondsToSelector:@selector(captionViewHeightChanged:)]) {
            [self.captionDelegate captionViewHeightChanged:height];
        }
    }
}

- (void)view:(UIView *)view doubleTapDetected:(UITouch *)touch {
    HJPB_Log(@"HJCaptionView_doubleTapDetected");
    
}

- (void)view:(UIView *)view swipeGestureDetected:(UISwipeGestureRecognizer *)gesture {
    HJPB_Log(@"HJCaptionView_swipeGestureDetected");
    
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

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _label.opaque = NO;
        _label.textAlignment = NSTextAlignmentLeft;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.numberOfLines = 0;
        _label.textColor = HJPB_RGB_Alpha(0xC2C2C2, 1);
        _label.font = [UIFont systemFontOfSize:16];
//        _label.backgroundColor = [UIColor redColor];
    }
    return _label;
}

@end
