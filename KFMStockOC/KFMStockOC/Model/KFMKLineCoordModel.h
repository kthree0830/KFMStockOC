//
//  KFMKLineCoordModel.h
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//  K线坐标model

#import <Foundation/Foundation.h>

@interface KFMKLineCoordModel : NSObject
@property (nonatomic, assign)CGPoint openPoint;
@property (nonatomic, assign)CGPoint closePoint;
@property (nonatomic, assign)CGPoint highPoint;
@property (nonatomic, assign)CGPoint lowPoint;
@property (nonatomic, assign)CGPoint ma5Point;
@property (nonatomic, assign)CGPoint ma10Point;
@property (nonatomic, assign)CGPoint ma20Point;
@property (nonatomic, assign)CGPoint volumeStartPoint;
@property (nonatomic, assign)CGPoint volumeEndPoint;
@property (nonatomic, strong)UIColor *candleFillColor;
@property (nonatomic, assign)CGRect candleRect;
@property (nonatomic, assign)CGFloat closeY;
@property (nonatomic, assign)BOOL isDrawAxis;

@end
