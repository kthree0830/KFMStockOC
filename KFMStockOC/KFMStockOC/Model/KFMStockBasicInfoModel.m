//
//  KFMStockBasicInfoModel.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMStockBasicInfoModel.h"

@implementation KFMStockBasicInfoModel

+ (KFMStockBasicInfoModel *)getStockBasicInfoModel:(NSDictionary *)jsonDic {
    KFMStockBasicInfoModel *model = [[KFMStockBasicInfoModel alloc]init];
    model.stockName = jsonDic[@"SZ300033"][@"name"];
    model.preClosePrice = [jsonDic[@"SZ300033"][@"last_close"] floatValue];
    return model;
}

@end
