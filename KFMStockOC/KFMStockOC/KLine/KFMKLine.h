//
//  KFMKLine.h
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFMKLine : UIView
@property (nonatomic, assign)KFMChartType kLineType;
@property (nonatomic, strong)NSMutableArray <KFMKLineModel *>*dataK;
@property (nonatomic, strong)NSMutableArray <KFMKLineCoordModel *>*positionModels;
@property (nonatomic, assign)CGFloat contentOffsetX;
@property (nonatomic, assign)CGFloat maxPrice;
@property (nonatomic, assign)CGFloat minPrice;
@property (nonatomic, assign)CGFloat maxVolume;
@property (nonatomic, assign)CGFloat renderWidth;

@property (nonatomic, strong)KFMTheme *theme;

@property (nonatomic, assign, readonly)NSInteger startIndex;
@property (nonatomic, assign, readonly)CGFloat startX;

- (void)drawKLineView;

@end
