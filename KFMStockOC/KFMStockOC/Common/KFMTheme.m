//
//  KFMTheme.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMTheme.h"

@implementation KFMTheme
#pragma mark - init
- (instancetype)init {
    if (self = [super init]) {
        self.rCandleWidth = 5;
    }
    return self;
}
#pragma mark - class
+ (CGFloat)uperChartHeightScale {
    return 0.7;
}
+ (CGFloat)lineWidth {
    return 1;
}
+ (CGFloat)frameWidth {
    return 0.25;
}
+ (CGFloat)xAxisHeitht {
    return 30;
}
+ (CGFloat)viewMinYGap {
    return 15;
}
+ (CGFloat)volumeGap {
    return 10;
}
+ (CGFloat)candleWidth {
    return 5;
}
+ (CGFloat)candleGap {
    return 2;
}
+ (CGFloat)candleMinHeight {
    return 0.5;
}
+ (CGFloat)candleMaxWidth {
    return 30;
}
+ (CGFloat)candleMinWidth {
    return 2;
}
+ (UIColor *)ma5Color {
    return [UIColor kfm_colorWithHex:0xe8de85];
}
+ (UIColor *)ma10Color {
    return [UIColor kfm_colorWithHex:0x6fa8bb];
}
+ (UIColor *)ma20Color {
    return [UIColor kfm_colorWithHex:0xdf8fc6];
}
+ (UIColor *)borderColor {//
    return [UIColor kfm_colorWithHex:0xe4e4e4];
}
+ (UIColor *)crossLineColor {
    return [UIColor kfm_colorWithHex:0x546679];
}
+ (UIColor *)textColor {
    return [UIColor kfm_colorWithHex:0x8695a6];
}
+ (UIColor *)riseColor {
    return [UIColor kfm_colorWithHex:0xf24957];
}
+ (UIColor *)fallColor {
    return [UIColor kfm_colorWithHex:0x1dbf60];
}
+ (UIColor *)priceLineCorlor {
    return [UIColor kfm_colorWithHex:0x0095ff];
}
+ (UIColor *)avgLineCorlor {
    return [UIColor kfm_colorWithHex:0xffc004];
}
+ (UIColor *)fillColor {
    return [UIColor kfm_colorWithHex:0xe3efff];
}
+ (UIFont *)baseFont {
//    return Font(10);
    return [UIFont systemFontOfSize:10];
}

+ (CGSize)getTextSizeWithText:(NSString *)text {
    CGSize size = [text sizeWithAttributes:@{NSFontAttributeName:KFMTheme.baseFont}];
    CGFloat width = ceil(size.width) + 5;
    CGFloat height = ceil(size.height);
    return CGSizeMake(width, height);
}
+ (CATextLayer *)getTextLayer:(NSString *)text foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.frame = frame;
    textLayer.string = text;
    textLayer.fontSize = 10;
    textLayer.foregroundColor = foregroundColor.CGColor;
    textLayer.backgroundColor = backgroundColor.CGColor;
    textLayer.alignmentMode = kCAAlignmentCenter;
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
}
+ (CATextLayer *)getYAxisMarkLayer:(CGRect)frame text:(NSString *)text y:(CGFloat)y isLeft:(BOOL)isLeft {
    CGSize textSize = [KFMTheme getTextSizeWithText:text];
    CGFloat yAxisLabelEdgeInset = 5;
    CGFloat labelX = 0;
    if (isLeft) {
        labelX = yAxisLabelEdgeInset;
    } else {
        labelX = frame.size.width - textSize.width - yAxisLabelEdgeInset;
    }
    CGFloat labelY = y - textSize.height / 2;
    
    return [KFMTheme getTextLayer:text foregroundColor:KFMTheme.textColor backgroundColor:kColorClear frame:CGRectMake(labelX, labelY, textSize.width, textSize.height)];
}
+ (CAShapeLayer *)getCrossLineLayer:(CGRect)frame pricePoint:(CGPoint)pricePoint volumePoint:(CGPoint)volumePoint model:(id)model {
    CAShapeLayer *highlightLayer = [CAShapeLayer layer];
    CAShapeLayer *corssLineLayer = [CAShapeLayer layer];
    CATextLayer *volMarkLayer = [CATextLayer layer];
    CATextLayer *yAxisMarkLayer = [CATextLayer layer];
    CATextLayer *bottomMarkLayer = [CATextLayer layer];
    
    NSString *bottomMarkerString = @"";
    NSString *yAxisMarkString = @"";
    NSString *volumeMarkerString = @"";
    
    if (!model) {
        return highlightLayer;
    }
    if ([model isKindOfClass:[KFMKLineModel class]]) {
        KFMKLineModel *entity = (KFMKLineModel *)model;
        yAxisMarkString = [NSString toStringWithFormat:@".2" cfloat:entity.close];
        bottomMarkerString = [[entity.date toDateWithFormat:@"yyyyMMddHHmmss"] toSringWithFormat:@"MM-dd"];
        volumeMarkerString = [NSString toStringWithFormat:@".2" cfloat:entity.volume];
        
    } else if ([model isKindOfClass:[KFMTimeLineModel class]]) {
        KFMTimeLineModel *entity = (KFMTimeLineModel *)model;
        yAxisMarkString = [NSString toStringWithFormat:@".2" cfloat:entity.price];
        bottomMarkerString = entity.time;
        volumeMarkerString = [NSString toStringWithFormat:@".2" cfloat:entity.volume];
    } else {
        return highlightLayer;
    }
    
    UIBezierPath *linePath = [UIBezierPath bezierPath];
     // 竖线
    [linePath moveToPoint:CGPointMake(pricePoint.x, 0)];
    [linePath addLineToPoint:CGPointMake(pricePoint.x, frame.size.height)];
    // 横线
    [linePath moveToPoint:CGPointMake(CGRectGetMinX(frame), pricePoint.y)];
    [linePath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), pricePoint.y)];
    // 标记交易量的横线
    [linePath moveToPoint:CGPointMake(CGRectGetMinX(frame), volumePoint.y)];
    [linePath addLineToPoint:CGPointMake(CGRectGetMaxX(frame), volumePoint.y)];
    
    corssLineLayer.lineWidth = KFMTheme.lineWidth;
    corssLineLayer.strokeColor = KFMTheme.crossLineColor.CGColor;
    corssLineLayer.fillColor = KFMTheme.crossLineColor.CGColor;
    corssLineLayer.path = linePath.CGPath;
    
     // 标记标签大小
    CGSize yAxisMarkSize = [KFMTheme getTextSizeWithText:yAxisMarkString];
    CGSize volMarkSize = [KFMTheme getTextSizeWithText:volumeMarkerString];
    CGSize bottomMarkSize = [KFMTheme getTextSizeWithText:bottomMarkerString];
    
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    
    // 纵坐标标签
    if (pricePoint.x > frame.size.width / 2) {
        labelX = CGRectGetMinX(frame);
    } else {
        labelX = CGRectGetMaxX(frame) - yAxisMarkSize.width;
    }
    labelY = pricePoint.y - yAxisMarkSize.height / 2;
    yAxisMarkLayer = [KFMTheme getTextLayer:yAxisMarkString foregroundColor:kColorWhite backgroundColor:KFMTheme.textColor frame:CGRectMake(labelX, labelY, yAxisMarkSize.width, yAxisMarkSize.height)];
    
    // 底部时间标签
    CGFloat maxX = CGRectGetMaxX(frame) - bottomMarkSize.width;
    labelX = pricePoint.x - bottomMarkSize.width / 2;
    labelY = frame.size.height * KFMTheme.uperChartHeightScale;
    if (labelX > maxX) {
        labelX = CGRectGetMaxX(frame) - bottomMarkSize.width;
    } else {
        labelX = CGRectGetMinX(frame);
    }
    bottomMarkLayer = [KFMTheme getTextLayer:bottomMarkerString foregroundColor:kColorWhite backgroundColor:KFMTheme.textColor frame:CGRectMake(labelX, labelY, bottomMarkSize.width, bottomMarkSize.height)];
    
    // 交易量右标签
    if (pricePoint.x > frame.size.width / 2) {
        labelX = CGRectGetMinX(frame);
    } else {
        labelX = CGRectGetMaxX(frame) - volMarkSize.width;
    }
    CGFloat maxY = CGRectGetMaxY(frame) - volMarkSize.height;
    labelY = volumePoint.y - volMarkSize.height / 2;
    labelY = labelY > maxY ? maxY : labelY;
    volMarkLayer = [KFMTheme getTextLayer:volumeMarkerString foregroundColor:kColorWhite backgroundColor:KFMTheme.textColor frame:CGRectMake(labelX, labelY, volMarkSize.width, volMarkSize.height)];
    
    [highlightLayer addSublayer:corssLineLayer];
    [highlightLayer addSublayer:yAxisMarkLayer];
    [highlightLayer addSublayer:bottomMarkLayer];
    [highlightLayer addSublayer:volMarkLayer];
    
    return highlightLayer;
}
@end
