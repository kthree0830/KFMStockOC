//
//  NSDate+Category.m
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "NSDate+Category.h"

@implementation NSDate (Category)
+ (NSDate *)toDateWithDateString:(NSString *)dateString format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = format;
    dateFormatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US"];
    NSDate *date = [dateFormatter dateFromString:dateString];
    if (!date) {
        date = [NSDate date];
    }
    return date;
}
- (NSString *)toSringWithFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.timeZone = [NSTimeZone localTimeZone];
    dateFormatter.dateFormat = format;
    if ([dateFormatter stringFromDate:self]) {
         return [dateFormatter stringFromDate:self];
    }else {
        return @"";
    }
    
}
@end
