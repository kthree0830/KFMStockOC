//
//  KFMKLineUpFrontView.m
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLineUpFrontView.h"

@interface KFMKLineUpFrontView ()
@property (nonatomic, strong)CATextLayer *rrText;//左上
@property (nonatomic, strong)CATextLayer *volText;//成交量
@property (nonatomic, strong)CATextLayer *maxMark;//最大值
@property (nonatomic, strong)CATextLayer *minMark;//最小值
@property (nonatomic, strong)CATextLayer *midMark;//中间值
@property (nonatomic, strong)CATextLayer *maxVolMark;//最大成交量
//@property (nonatomic, strong)CAShapeLayer *yAxisLayer;
//
@property (nonatomic, strong)CAShapeLayer *corssLineLayer;
//@property (nonatomic, strong)CATextLayer *volMarkLayer;
//@property (nonatomic, strong)CATextLayer *leftMarkLayer;
//@property (nonatomic, strong)CATextLayer *bottomMarkLayer;
//@property (nonatomic, strong)CATextLayer *yAxisMarkLayer;

@property (nonatomic, assign, getter=uperCharheight, readonly)CGFloat uperCharheight;
@property (nonatomic, assign, getter=lowerChartTop, readonly)CGFloat lowerChartTop;
@end

@implementation KFMKLineUpFrontView
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self drawMarkLayerWithMax:nil Mid:nil Min:nil maxVol:nil];
    }
    return self;
}
- (void)drawMarkLayerWithMax:(NSString *)max Mid:(NSString *)mid Min:(NSString *)min maxVol:(NSString *)maxVol {
    
    NSString *tempMax = max.length ? max : @"0.00";
    self.maxMark = [KFMTheme getYAxisMarkLayer:self.frame text:tempMax y:KFMTheme.viewMinYGap isLeft:NO];
    
    NSString *tempMin = min.length ? min : @"0.00";
    self.minMark = [KFMTheme getYAxisMarkLayer:self.frame text:tempMin y:self.uperCharheight - KFMTheme.viewMinYGap isLeft:NO];
    
    NSString *tempMid = mid.length ? mid : @"0.00";
    self.midMark = [KFMTheme getYAxisMarkLayer:self.frame text:tempMid y:self.uperCharheight / 2 isLeft:NO];
    
    NSString *tempMaxVol = maxVol.length ? maxVol : @"0.00";
    self.maxVolMark = [KFMTheme getYAxisMarkLayer:self.frame text:tempMaxVol y:self.lowerChartTop + KFMTheme.volumeGap isLeft:NO];
    
    if (!max.length && !mid.length && !min.length && !maxVol.length) {
        self.rrText = [KFMTheme getYAxisMarkLayer:self.frame text:@"不复权" y:KFMTheme.viewMinYGap isLeft:YES];
        self.volText = [KFMTheme getYAxisMarkLayer:self.frame text:@"成交量" y:self.lowerChartTop + KFMTheme.volumeGap isLeft:YES];
        [self.layer addSublayer:_rrText];
        [self.layer addSublayer:_volText];
    }
    [self.layer addSublayer:_maxMark];
    [self.layer addSublayer:_minMark];
    [self.layer addSublayer:_midMark];
    [self.layer addSublayer:_maxVolMark];
    
}
- (void)removeMarkLayer {
    [self.maxMark removeFromSuperlayer];
    [self.midMark removeFromSuperlayer];
    [self.minMark removeFromSuperlayer];
    [self.maxVolMark removeFromSuperlayer];
}

#pragma mark - open
- (void)configureAxisWithMax:(CGFloat)max Min:(CGFloat)min maxVol:(CGFloat)maxVol {
    NSString *maxPriceStr = [NSString toStringWithFormat:@".2" cfloat:max];
    NSString *minPriceStr = [NSString toStringWithFormat:@".2" cfloat:min];
    NSString *midPriceStr = [NSString toStringWithFormat:@".2" cfloat:(max + min) / 2];
    NSString *maxVolStr = [NSString toStringWithFormat:@".2" cfloat:maxVol];
    
    self.maxMark.string = maxPriceStr;
    self.minMark.string = minPriceStr;
    self.midMark.string = midPriceStr;
    self.maxVolMark.string = maxVolStr;
    
    [self removeMarkLayer];
    [self drawMarkLayerWithMax:self.maxMark.string Mid:self.midMark.string Min:self.minMark.string maxVol:self.maxVolMark.string];
}
- (void)drawCrossLinePricePoint:(CGPoint)pricePoint volumePoint:(CGPoint)volumePoint model:(id)model {
    [self.corssLineLayer removeFromSuperlayer];
    self.corssLineLayer = [KFMTheme getCrossLineLayer:self.frame pricePoint:pricePoint volumePoint:volumePoint model:model];
    [self.layer addSublayer:self.corssLineLayer];
}
- (void)removeCrossLine {
    [self.corssLineLayer removeFromSuperlayer];
}
#pragma mark - override
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        // 交给下一层级的view响应事件（解决该 view 在 scrollView 上面到时scrollView无法滚动问题）
        return nil;
    }
    return view;
}
#pragma mark - 
- (CGFloat)uperCharheight {
    return [KFMTheme uperChartHeightScale] * self.height;
}
- (CGFloat)lowerChartTop {
    return self.uperCharheight + [KFMTheme xAxisHeitht];
}
@end
