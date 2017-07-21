//
//  KFMStockBasicInfoModel.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  数据基础model

#import <Foundation/Foundation.h>

@interface KFMStockBasicInfoModel : NSObject
@property (nonatomic, copy)NSString *stockName;
@property (nonatomic, assign)CGFloat preClosePrice;
+ (KFMStockBasicInfoModel *)getStockBasicInfoModel:(NSDictionary *)jsonDic;
@end
