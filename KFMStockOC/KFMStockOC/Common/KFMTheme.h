//
//  KFMTheme.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  通用方法

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSUInteger, KFMChartType) {
    KFMTimeLineForDay,
    KFMTimeLineForFiveDay,
    KFMKLineForDay,
    KFMKLineForWeek,
    KFMKLineForMonth
};
@interface KFMTheme : NSObject
@property (nonatomic, assign, readonly, class)CGFloat uperChartHeightScale;// 70% 的空间是上部分的走势图
@property (nonatomic, assign, readonly, class)CGFloat lineWidth;
@property (nonatomic, assign, readonly, class)CGFloat frameWidth;

@property (nonatomic, assign, readonly, class)CGFloat xAxisHeitht;
@property (nonatomic, assign, readonly, class)CGFloat viewMinYGap;
@property (nonatomic, assign, readonly, class)CGFloat volumeGap;

@property (nonatomic, assign, readonly, class)CGFloat candleWidth;
@property (nonatomic, assign, readonly, class)CGFloat candleGap;
@property (nonatomic, assign, readonly, class)CGFloat candleMinHeight;
@property (nonatomic, assign, readonly, class)CGFloat candleMaxWidth;
@property (nonatomic, assign, readonly, class)CGFloat candleMinWidth;

@property (nonatomic, strong, readonly, class)UIColor *ma5Color;
@property (nonatomic, strong, readonly, class)UIColor *ma10Color;
@property (nonatomic, strong, readonly, class)UIColor *ma20Color;
@property (nonatomic, strong, readonly, class)UIColor *borderColor;
@property (nonatomic, strong, readonly, class)UIColor *crossLineColor;
@property (nonatomic, strong, readonly, class)UIColor *textColor;
@property (nonatomic, strong, readonly, class)UIColor *riseColor;// 涨 red
@property (nonatomic, strong, readonly, class)UIColor *fallColor;// 跌 green
@property (nonatomic, strong, readonly, class)UIColor *priceLineCorlor;
@property (nonatomic, strong, readonly, class)UIColor *avgLineCorlor;
@property (nonatomic, strong, readonly, class)UIColor *fillColor;

@property (nonatomic, strong, readonly, class)UIFont *baseFont;

@property (nonatomic, assign)CGFloat rCandleWidth;

+ (CGSize)getTextSizeWithText:(NSString *)text;

/**
 获取字符图层
 */
+ (CATextLayer *)getTextLayer:(NSString *)text foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame;

/**
 获取纵轴的标签图层
 */
+ (CATextLayer *)getYAxisMarkLayer:(CGRect)frame text:(NSString *)text y:(CGFloat)y isLeft:(BOOL)isLeft;

/**
 获取长按显示的十字线及其标签图层
 */
+ (CAShapeLayer *)getCrossLineLayer:(CGRect)frame pricePoint:(CGPoint)pricePoint volumePoint:(CGPoint)volumePoint model:(id)model;
@end
