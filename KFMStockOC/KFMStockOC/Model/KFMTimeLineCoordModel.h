//
//  KFMTimeLineCoordModel.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  分时坐标model

#import <UIKit/UIKit.h>

@interface KFMTimeLineCoordModel : NSObject

@property (nonatomic, assign)CGPoint pricePoint;
@property (nonatomic, assign)CGPoint avgPoint;
@property (nonatomic, assign)CGFloat volumeHeight;
@property (nonatomic, assign)CGPoint volumeStartPoint;
@property (nonatomic, assign)CGPoint volumeEndPoint;


@end

