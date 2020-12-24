//
//  HJIndexView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/18.
//

#import <UIKit/UIKit.h>
#import "HJPhoto.h"

NS_ASSUME_NONNULL_BEGIN

@interface HJIndexView : UIView
- (void)setPhoto:(id<HJPhoto>)photo;
@end

NS_ASSUME_NONNULL_END
