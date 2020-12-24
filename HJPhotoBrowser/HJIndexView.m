//
//  HJIndexView.m
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/18.
//

#import "HJIndexView.h"

@interface HJIndexView ()
@property (nonatomic, strong) id <HJPhoto> photo;

@property (nonatomic, strong) UILabel *label;
@end


@implementation HJIndexView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubview:self.label];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
}

- (void)setPhoto:(id<HJPhoto>)photo {
    _photo = photo;
    self.label.attributedText = [self indexString:photo];
    self.label.frame = CGRectMake(0, 0, 100, 32);
    
    [self setNeedsLayout];
}

- (NSAttributedString *)indexString:(id<HJPhoto>)photo {
    HJPhoto *ph = (HJPhoto *)photo;
    if (!photo) return nil;
    
    NSString *indexStr = [NSString stringWithFormat:@"%lu", (unsigned long)ph.index];
    NSString *str = [NSString stringWithFormat:@"%@/%lu", indexStr, (unsigned long)ph.count];
    
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    style.alignment = NSTextAlignmentRight;
    [attrStr addAttribute:NSParagraphStyleAttributeName
                    value:style
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:16]
                    range:NSMakeRange(0 , str.length)];

    [attrStr addAttribute:NSForegroundColorAttributeName
                    value:[UIColor whiteColor]
                    range:NSMakeRange(0, str.length)];
    
    [attrStr addAttribute:NSFontAttributeName
                    value:[UIFont systemFontOfSize:18]
                    range:NSMakeRange(0 , indexStr.length)];
    
    return attrStr;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        _label.textAlignment = NSTextAlignmentRight;
        _label.lineBreakMode = NSLineBreakByTruncatingTail;
        _label.numberOfLines = 0;
        _label.textColor = HJPB_RGB_Alpha(0xC2C2C2, 1);
        _label.font = [UIFont systemFontOfSize:16];
//        _label.backgroundColor = [UIColor redColor];
    }
    return _label;
}

@end
