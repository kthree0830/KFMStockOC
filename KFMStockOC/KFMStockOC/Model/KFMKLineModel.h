//
//  KFMKLineModel.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  K线model

#import <Foundation/Foundation.h>

@interface KFMKLineModel : NSObject

@property (nonatomic, copy)NSString * date;
@property (nonatomic, assign)CGFloat open;
@property (nonatomic, assign)CGFloat close;
@property (nonatomic, assign)CGFloat high;
@property (nonatomic, assign)CGFloat low;
@property (nonatomic, assign)CGFloat volume;
@property (nonatomic, assign)CGFloat ma5;
@property (nonatomic, assign)CGFloat ma10;
@property (nonatomic, assign)CGFloat ma20;
@property (nonatomic, assign)CGFloat ma30;
@property (nonatomic, assign)CGFloat diff;
@property (nonatomic, assign)CGFloat dea;
@property (nonatomic, assign)CGFloat macd;
@property (nonatomic, assign)CGFloat rate;

+ (NSArray <KFMKLineModel *>*)getKLineModelArrayWithDic:(NSDictionary *)dic;
@end
