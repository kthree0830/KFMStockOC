//
//  KFMTimeLineCoordModel.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMTimeLineCoordModel.h"

@implementation KFMTimeLineCoordModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _pricePoint = CGPointZero;
        _avgPoint = CGPointZero;
        _volumeHeight = 0;
        _volumeStartPoint = CGPointZero;
        _volumeEndPoint = CGPointZero;
    }
    return self;
}

@end
