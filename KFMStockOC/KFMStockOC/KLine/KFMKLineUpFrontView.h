//
//  KFMKLineUpFrontView.h
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//  K线上层视图

#import <UIKit/UIKit.h>

@interface KFMKLineUpFrontView : UIView

/**
 K线上层视图各个赋值
 */
- (void)configureAxisWithMax:(CGFloat)max Min:(CGFloat)min maxVol:(CGFloat)maxVol;

/**
 K线上层视图画十字线
 */
- (void)drawCrossLinePricePoint:(CGPoint)pricePoint volumePoint:(CGPoint)volumePoint model:(id)model;
/**
 K线上层视图移除十字线
 */
- (void)removeCrossLine;
@end
