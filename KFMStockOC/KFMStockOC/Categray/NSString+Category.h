//
//  NSString+Category.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (Category)

/**
 输出格式化的String

 @param format eg: ".2" 保留两位小数
 @return NSString
 */
+ (NSString *)toStringWithFormat:(NSString *)format cfloat:(CGFloat)cfloat;

/**
 输出为百分数
 @return 以%结尾的 百分数输出
 */
+ (NSString *)toPercentFormatCfloat:(CGFloat)cfloat;

- (NSDate *)toDateWithFormat:(NSString *)format;
@end
