//
//  HJAccessory.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/12/3.
//  Copyright © 2018 navy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <HJPhotoBrowser.h>

NS_ASSUME_NONNULL_BEGIN

@interface HJAccessory : NSObject <HJAccessory>
@property (nonatomic, strong) NSString *userPic;
@property (nonatomic, strong) NSString *userNick;
@property (nonatomic, strong) NSString *time;
@property (nonatomic, strong) NSString *title;
@end

NS_ASSUME_NONNULL_END
