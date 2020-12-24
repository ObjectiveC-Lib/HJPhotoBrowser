//
//  HJNavigationView.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/27.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "HJPhotoBrowserProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface HJNavigationView : UIView <HJNavigationView>
@property (nonatomic, weak) id <HJAccessory> accessory;
@property (nonatomic, weak) id <HJNavigationViewDelegate> navigationDelegate;
@property (nonatomic, assign) CGFloat minHeight;
@property (nonatomic, assign) CGFloat maxHeight;
@property (nonatomic, assign, readonly) BOOL isOpen;
@end

NS_ASSUME_NONNULL_END
