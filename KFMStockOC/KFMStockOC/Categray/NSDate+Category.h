//
//  NSDate+Category.h
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Category)
+ (NSDate *)toDateWithDateString:(NSString *)dateString format:(NSString *)format;
- (NSString *)toSringWithFormat:(NSString *)format;
@end
