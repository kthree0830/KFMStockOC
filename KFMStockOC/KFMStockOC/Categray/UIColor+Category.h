//
//  UIColor+Category.h
//  OCExtension
//
//  Created by mac on 2017/3/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kColorWhite [UIColor whiteColor]
#define kColorClear [UIColor clearColor]
@interface UIColor (Category)

/**
 32位色
 */
+ (instancetype)kfm_colorWithHex:(u_int32_t)hex;


+ (instancetype)kfm_colorRandom;

@end
