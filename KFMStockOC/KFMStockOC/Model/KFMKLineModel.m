//
//  KFMKLineModel.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLineModel.h"

@implementation KFMKLineModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _date = @"";
        _open = 0;
        _close = 0;
        _high = 0;
        _low = 0;
        _volume = 0;
        _ma5 = 0;
        _ma10 = 0;
        _ma20 = 0;
        _ma30 = 0;
        _diff = 0;
        _dea = 0;
        _macd = 0;
        _rate = 0;
    }
    return self;
}
- (void)setValue:(id)value forKey:(NSString *)key {
    if ([key isEqualToString: @"time"]) {
        self.date = [[NSDate toDateWithDateString:value format:@"EEE MMM d HH:mm:ss z yyyy"] toSringWithFormat:@"yyyyMMddHHmmss"];
    } else if ([key isEqualToString:@"percent"]) {
        self.rate = [value floatValue];
    } else if ([key isEqualToString:@"dif"]) {
        self.diff = [value floatValue];
    } else {
        [super setValue:value forKey:key];
    }
}
- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {

}
+ (NSArray <KFMKLineModel *>*)getKLineModelArrayWithDic:(NSDictionary *)dic {
    NSMutableArray <KFMKLineModel *>*models = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in dic[@"chartlist"]) {
        KFMKLineModel *model = [[KFMKLineModel alloc]init];
        [model setValuesForKeysWithDictionary:dict];
        [models addObject:model];
    }
    return models;
}
@end
