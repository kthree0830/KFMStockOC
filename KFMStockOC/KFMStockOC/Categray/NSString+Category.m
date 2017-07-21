//
//  NSString+Category.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSString+Category.h"

@implementation NSString (Category)

+ (NSString *)toStringWithFormat:(NSString *)format cfloat:(CGFloat)cfloat {
    NSString *temp = [@"%" stringByAppendingString:format];
    NSString *t = [temp stringByAppendingString:@"f"];
    return [NSString stringWithFormat:t,cfloat];
}

+ (NSString *)toPercentFormatCfloat:(CGFloat)cfloat {
    return [NSString stringWithFormat:@"%.2f%%",cfloat];
}
- (NSDate *)toDateWithFormat:(NSString *)format {
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.timeZone = [NSTimeZone defaultTimeZone];
    formatter.dateFormat = format;
    return [formatter dateFromString:self];
}
@end
