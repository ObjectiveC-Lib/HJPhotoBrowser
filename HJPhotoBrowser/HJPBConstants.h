//
//  HJPBConstants.h
//  HJPhotoBrowser
//
//  Created by navy on 2018/11/26.
//  Copyright © 2018 navy. All rights reserved.
//

#ifndef HJPBConstants_h
#define HJPBConstants_h

#ifdef DEBUG
    #define HJPB_Log(x, ...) NSLog(x, ## __VA_ARGS__);
#else
    #define HJPB_Log(x, ...);
#endif

#define HJPB_Check_Valid_String(__string)   (__string && [__string isKindOfClass:[NSString class]] && [__string length])

#define HJPB_RGB_Alpha(rgbValue,a)   [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:(a)]

#define HJPB_Screen_Width        MIN([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)
#define HJPB_Screen_Height       MAX([UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height)

#define HJPB_Page_Padding            0
#define HJPB_Page_Index_Tag_Offset   1000
#define HJPB_Page_Index(page)        ([(page) tag] - HJPB_Page_Index_Tag_Offset)

#define HJPB_Navigation_Height   140.0f
#define HJPB_Caption_Height    125.0f
#define HJPB_Bottom_Tool_Height 58.0f

#endif /* HJPBConstants_h */
