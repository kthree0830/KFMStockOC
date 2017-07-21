//
//  KFMKLineCoordModel.m
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLineCoordModel.h"

@implementation KFMKLineCoordModel
- (instancetype)init
{
    self = [super init];
    if (self) {
        _openPoint = CGPointZero;
        _closePoint = CGPointZero;
        _highPoint = CGPointZero;
        _lowPoint = CGPointZero;
        _ma5Point = CGPointZero;
        _ma10Point = CGPointZero;
        _ma20Point = CGPointZero;
        _volumeStartPoint = CGPointZero;
        _volumeEndPoint = CGPointZero;
        _candleFillColor = [UIColor blackColor];
        _candleRect = CGRectZero;
        _closeY = 0;
        _isDrawAxis = NO;
    }
    return self;
}
@end
