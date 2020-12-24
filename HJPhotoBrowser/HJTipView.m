//
//  HJTipView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/17.
//

#import "HJTipView.h"
#import "HJPBConstants.h"

@interface HJTipView()
@property (nonatomic, strong) UILabel *tipLabel;
@property (nonatomic, strong) UIView *tipView;
@end


@implementation HJTipView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _tipView = [UIView new];
        _tipView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.86];
        _tipView.layer.cornerRadius = 5;
        _tipView.alpha = 0.0;
        [self addSubview:_tipView];
        
        _tipLabel = [UILabel new];
        _tipLabel.frame = CGRectMake(14, 14, _tipView.frame.size.width-2*14, _tipView.frame.size.height-2*14);
        _tipLabel.font = [UIFont systemFontOfSize:16.0];
        _tipLabel.textColor = HJPB_RGB_Alpha(0xFFFFFF, 1);
        _tipLabel.numberOfLines = 0;
        [self.tipView addSubview:_tipLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)showTip:(NSString *)tip {
    if (!HJPB_Check_Valid_String(tip)) return;
    [self.superview bringSubviewToFront:self];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:tip];
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.lineSpacing = 6;
    style.lineBreakMode = NSLineBreakByTruncatingTail;
    style.alignment = NSTextAlignmentCenter;
    [attrStr addAttribute:NSParagraphStyleAttributeName value:style range:NSMakeRange(0, attrStr.length)];
    
    self.tipLabel.attributedText = attrStr;
    
    CGRect rect = [attrStr boundingRectWithSize:CGSizeMake([UIScreen mainScreen].bounds.size.width-100, 0)
                                        options:NSStringDrawingUsesLineFragmentOrigin
                                        context:nil];
    CGFloat width = rect.size.width + 60;
    CGFloat height = rect.size.height + 2*14;
    if (width > [UIScreen mainScreen].bounds.size.width-100) {
        width = [UIScreen mainScreen].bounds.size.width-100;
    }
    
    self.tipView.frame = CGRectMake((self.frame.size.width-width)/2, (self.frame.size.height-height)/2, width, height);
    self.tipLabel.frame = CGRectMake(14, 14, _tipView.frame.size.width-2*14, _tipView.frame.size.height-2*14);
    [self layoutIfNeeded];

    [UIView animateWithDuration:0.4 animations:^{
        self.tipView.alpha = 1.0;
    }];
    
    [self performSelector:@selector(hiddenTipView)
               withObject:nil
               afterDelay:1.5f
                  inModes:@[NSDefaultRunLoopMode, UITrackingRunLoopMode]];


}

- (void)hiddenTipView {
    [UIView animateWithDuration:0.4 animations:^{
        self.tipView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.superview sendSubviewToBack:self];
    }];
    
}

@end
