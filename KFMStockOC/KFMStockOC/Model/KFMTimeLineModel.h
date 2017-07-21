//
//  KFMTimeLineModel.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  分时model

#import <Foundation/Foundation.h>
@interface KFMTimeLineModel : NSObject
@property (nonatomic, copy)NSString *time;
@property (nonatomic, assign)CGFloat price;
@property (nonatomic, assign)CGFloat volume;
@property (nonatomic, assign)CGFloat preClosePx;
@property (nonatomic, assign)CGFloat avgPirce;
@property (nonatomic, assign)CGFloat totalVolume;
@property (nonatomic, assign)CGFloat trade;
@property (nonatomic, assign)CGFloat rate;
@property (nonatomic, strong)NSMutableArray <NSString *>*days;

+ (NSArray <KFMTimeLineModel *>*)getTimeLineModelArrayWithDic:(NSDictionary *)dic;
+ (NSArray <KFMTimeLineModel *>*)getTimeLineModelArrayWithDic:(NSDictionary *)dic type:(KFMChartType)type basicInfo:(KFMStockBasicInfoModel *)basicInfo;
@end
