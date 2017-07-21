//
//  UIColor+Category.m
//  OCExtension
//
//  Created by mac on 2017/3/31.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIColor+Category.h"

@implementation UIColor (Category)

+ (instancetype)kfm_colorWithHex:(u_int32_t)hex {
    u_int32_t red = (hex & 0xFF0000) >> 16;
    u_int32_t green = (hex & 0x00FF00) >> 8;
    u_int32_t blue = hex & 0x0000FF;

    return [UIColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:1.0];
}


+ (instancetype)kfm_colorRandom {
    return [UIColor colorWithRed:arc4random_uniform(256)/255.0 green:arc4random_uniform(256)/255.0 blue:arc4random_uniform(256)/255.0 alpha:1.0];
}
@end
