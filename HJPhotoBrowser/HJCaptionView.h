//
//  HJCaptionView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPhotoBrowserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HJCaptionView : UIView <HJCaptionView>
@property (nonatomic, weak) id <HJPhoto> photo;
@property (nonatomic, weak) id <HJCaptionViewDelegate> captionDelegate;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign) CGFloat bottomToolHeight;
@property (nonatomic, assign, readonly) BOOL isOpen;
@end

NS_ASSUME_NONNULL_END
