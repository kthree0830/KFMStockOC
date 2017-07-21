//
//  KFMTimeLineModel.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMTimeLineModel.h"

@implementation KFMTimeLineModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _time = @"";
        _price = 0;
        _volume = 0;
        _days = [[NSMutableArray alloc]init];
        _preClosePx = 0;
        _avgPirce = 0;
        _totalVolume = 0;
        _trade = 0;
        _rate = 0;
    }
    return self;
}
+ (NSArray<KFMTimeLineModel *> *)getTimeLineModelArrayWithDic:(NSDictionary *)dic {
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    for (NSDictionary *dict in dic[@"chartlist"]) {
        KFMTimeLineModel *model = [[KFMTimeLineModel alloc]init];
        model.time = [[NSDate toDateWithDateString:[dict[@"time"] stringValue] format:@"EEE MMM d HH:mm:ss z yyyy"] toSringWithFormat:@"HH:mm"];
        model.avgPirce = [dict[@"avg_price"] doubleValue];
        model.price = [dict[@"current"] doubleValue];
        model.volume = [dict[@"volume"] doubleValue];
        if ([dict objectForKey:@"days"]) {
            model.days = [NSMutableArray arrayWithArray:dict[@"days"]];
        }else {
            model.days = [NSMutableArray arrayWithCapacity:0];
        }
        [modelArray addObject:model];
    }

    return modelArray;
}
+ (NSArray<KFMTimeLineModel *> *)getTimeLineModelArrayWithDic:(NSDictionary *)dic type:(KFMChartType)type basicInfo:(KFMStockBasicInfoModel *)basicInfo {
    NSMutableArray *modelArray = [[NSMutableArray alloc]init];
    CGFloat toComparePrice = 0;
    
    if (type == KFMTimeLineForFiveDay) {
        toComparePrice = [dic[@"chartlist"][0][@"current"] floatValue];
    } else {
        toComparePrice = basicInfo.preClosePrice;
    }
    
    for (NSDictionary *dict in dic[@"chartlist"]) {
        KFMTimeLineModel *model = [[KFMTimeLineModel alloc]init];
        model.time = [[NSDate toDateWithDateString:dict[@"time"] format:@"EEE MMM d HH:mm:ss z yyyy"] toSringWithFormat:@"HH:mm"];
        model.avgPirce = [dict[@"avg_price"] doubleValue];
        model.price = [dict[@"current"] doubleValue];
        model.volume = [dict[@"volume"] doubleValue];
        model.rate = (model.price - toComparePrice) / 2;
        model.preClosePx = basicInfo.preClosePrice;
        if ([dict objectForKey:@"days"]) {
            model.days = [NSMutableArray arrayWithArray:dict[@"days"]];
        }else {
            model.days = [NSMutableArray arrayWithCapacity:0];
        }
        [modelArray addObject:model];
    }
    
    return modelArray;

}
@end
