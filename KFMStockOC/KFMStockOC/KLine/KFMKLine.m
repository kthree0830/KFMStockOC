//
//  KFMKLine.m
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLine.h"
#import "KFMCAShapeLayer.h"
@interface KFMKLine ()
@property (nonatomic, strong)NSMutableArray <KFMKLineModel *>*klineModels;
@property (nonatomic, assign)CGFloat kLineViewTotalWidth;
@property (nonatomic, assign)CGFloat showContentWidth;
@property (nonatomic, assign)CGFloat highLightIndex;

@property (nonatomic, assign)CGFloat maxMA;
@property (nonatomic, assign)CGFloat minMA;
@property (nonatomic, assign)CGFloat maxMACD;

@property (nonatomic, assign)CGFloat priceUnit;
@property (nonatomic, assign)CGFloat volumeUnit;

@property (nonatomic, assign)CGRect renderRect;

@property (nonatomic, strong)KFMCAShapeLayer *candleChartLayer;
@property (nonatomic, strong)KFMCAShapeLayer *volumeLayer;
@property (nonatomic, strong)KFMCAShapeLayer *ma5LineLayer;
@property (nonatomic, strong)KFMCAShapeLayer *ma10LineLayer;
@property (nonatomic, strong)KFMCAShapeLayer *ma20LineLayer;
@property (nonatomic, strong)KFMCAShapeLayer *xAxisTimeMarkLayer;

@property (nonatomic, assign, readonly)CGFloat uperChartHeight;
@property (nonatomic, assign, readonly)CGFloat lowerChartHeight;

@property (nonatomic, assign, readonly)int countOfshowCandle;



@end
@implementation KFMKLine
#pragma mark - init
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = kColorClear;
    }
    return self;
}
#pragma mark - function
- (void)drawKLineView {
    [self calcMaxAndMinData];
    [self convertToPositionModelWithData:self.dataK];
    [self clearLayer];
    [self drawxAxisTimeMarkLayer];
    [self drawCandleChartLayerWithArray:self.positionModels];
    [self drawVolumeLayerWithArray:self.positionModels];
    [self drawMALayerWithArray:self.positionModels];
}
//计算当前显示区域的最大最小值
- (void)calcMaxAndMinData {
    if (self.dataK.count > 0) {
        self.maxPrice = CGFLOAT_MIN;
        self.minPrice = CGFLOAT_MAX;
        self.maxVolume = CGFLOAT_MIN;
        self.maxMA = CGFLOAT_MIN;
        self.minMA = CGFLOAT_MAX;
        self.maxMACD = CGFLOAT_MIN;
        NSInteger startIndex = self.startIndex;
        // 比计算出来的多加一个，是为了避免计算结果的取整导致少画
        NSInteger count = (startIndex + self.countOfshowCandle + 1) > self.dataK.count ? self.dataK.count : (startIndex + self.countOfshowCandle + 1);
        
        if (startIndex < count) {
            for (NSInteger i = startIndex; i < count; i++) {
                KFMKLineModel *obj = self.dataK[i];
                self.maxPrice = self.maxPrice > obj.high ? self.maxPrice : obj.high;
                self.minPrice = self.minPrice < obj.low ? self.minPrice : obj.low;
                
                self.maxVolume = self.maxVolume > obj.volume ? self.maxVolume : obj.volume;
                
                CGFloat tempMAMax = kMAX(obj.ma5, obj.ma10, obj.ma20);
                self.maxMA = self.maxMA > tempMAMax ? self.maxMA : tempMAMax;
                NSLog(@"%f",self.maxMA);
                
                CGFloat tempMAMin = kMIX(obj.ma5, obj.ma10, obj.ma20);
                self.minMA = self.minMA < tempMAMin ? self.minMA : tempMAMin;
                
                CGFloat tempMax = kMAX(fabs(obj.diff), fabs(obj.dea), fabs(obj.macd));
                self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD;

            }
//            [self.dataK enumerateObjectsUsingBlock:^(KFMKLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                if (idx >= startIndex) {
//                    self.maxPrice = self.maxPrice > obj.high ? self.maxPrice : obj.high;
//                    self.minPrice = self.minPrice < obj.low ? self.minPrice : obj.low;
//                    
//                    self.maxVolume = self.maxVolume > obj.volume ? self.maxVolume : obj.volume;
//                    
//                    CGFloat tempMAMax = kMAX(obj.ma5, obj.ma10, obj.ma20);
//                    self.maxMA = self.maxMA > tempMAMax ? self.maxMA : tempMAMax;
//                    
//                    CGFloat tempMAMin = kMIX(obj.ma5, obj.ma10, obj.ma20);
//                    self.minMA = self.minMA < tempMAMin ? self.minMA : tempMAMin;
//                    
//                    CGFloat tempMax = kMAX(fabs(obj.diff), fabs(obj.dea), fabs(obj.macd));
//                    self.maxMACD = tempMax > self.maxMACD ? tempMax : self.maxMACD;
//                }
//            }];
            
        }
//        NSLog(@"%f",self.self.maxPrice);
        // 当均线数据缺失时候，注意注释这段，不然 minPrice 为 0，导致整体绘画比例不对
        self.maxPrice = self.maxPrice > self.maxMA ? self.maxPrice : self.maxMA;
        self.minPrice = self.minPrice < self.minMA ? self.minPrice : self.minMA;
        
    }
}

/**
 转换为坐标 model

 @param data [HSKLineModel]
 */
- (void)convertToPositionModelWithData:(NSArray <KFMKLineModel *>*)data {
    [self.positionModels removeAllObjects];
    [self.klineModels removeAllObjects];
    
    NSInteger axisGap = self.countOfshowCandle / 3;
    CGFloat gap = KFMTheme.viewMinYGap;
    CGFloat minY = gap;
    CGFloat maxDiff = self.maxPrice - self.minPrice;
    if (maxDiff > 0 && self.maxVolume > 0) {
        self.priceUnit = (self.uperChartHeight - 2 * minY) / maxDiff;
        self.volumeUnit = (self.lowerChartHeight - KFMTheme.volumeGap) / self.maxVolume;
    }
    NSInteger count = (self.startIndex + self.countOfshowCandle + 1) > data.count ? data.count : (self.startIndex + self.countOfshowCandle + 1);
    if (self.startIndex < count) {
        for (NSInteger i = self.startIndex; i < count; i++) {
            KFMKLineModel *obj = data[i];
            CGFloat leftPosition = self.startX + (i - self.startIndex) * (self.theme.rCandleWidth + KFMTheme.candleGap);
            CGFloat xPosition = leftPosition + self.theme.rCandleWidth / 2;
            
            CGPoint highPoint = CGPointMake(xPosition, (self.maxPrice - obj.high) * self.priceUnit + minY);
            CGPoint lowPoint = CGPointMake(xPosition, (self.maxPrice - obj.low) * self.priceUnit + minY);
            
            CGPoint ma5Point = CGPointMake(xPosition, (self.maxPrice - obj.ma5) * self.priceUnit + minY);
            CGPoint ma10Point = CGPointMake(xPosition, (self.maxPrice - obj.ma10) * self.priceUnit + minY);
            CGPoint ma20Point = CGPointMake(xPosition, (self.maxPrice - obj.ma20) * self.priceUnit + minY);
            
            CGFloat openPointY = (self.maxPrice - obj.open) * self.priceUnit + minY;
            CGFloat closePointY = (self.maxPrice - obj.close) * self.priceUnit + minY;
            UIColor *fillCandleColor = [UIColor blackColor];
            CGRect candleRect = CGRectZero;
            
            CGFloat volume = (obj.volume - 0) * self.volumeUnit;
            CGPoint volumeStarPoint = CGPointMake(xPosition, self.height - volume);
            CGPoint volumeEndPoint = CGPointMake(xPosition, self.height);
            
            if (openPointY > closePointY) {
                fillCandleColor = [KFMTheme riseColor];
                candleRect = CGRectMake(leftPosition, closePointY, self.theme.rCandleWidth, openPointY - closePointY);
            } else if (openPointY < closePointY) {
                fillCandleColor = [KFMTheme fallColor];
                candleRect = CGRectMake(leftPosition, openPointY, self.theme.rCandleWidth, closePointY - openPointY);
            } else {
                candleRect = CGRectMake(leftPosition, closePointY, self.theme.rCandleWidth, [KFMTheme candleMinHeight]);
                if (i > 0) {
                    KFMKLineModel *frontModel = data[i - 1];
                    if (obj.open > frontModel.close) {
                        fillCandleColor = [KFMTheme riseColor];
                    } else {
                        fillCandleColor = [KFMTheme fallColor];
                    }
                }
            }
            
            KFMKLineCoordModel * positionModel = [[KFMKLineCoordModel alloc]init];
            positionModel.highPoint = highPoint;
            positionModel.lowPoint = lowPoint;
            positionModel.closeY = closePointY;
            positionModel.ma5Point = ma5Point;
            positionModel.ma10Point = ma10Point;
            positionModel.ma20Point = ma20Point;
            positionModel.volumeStartPoint = volumeStarPoint;
            positionModel.volumeEndPoint = volumeEndPoint;
            positionModel.candleFillColor = fillCandleColor;
            positionModel.candleRect = candleRect;
            if (i % axisGap == 0) {
                positionModel.isDrawAxis = YES;
            }
            [self.positionModels addObject:positionModel];
            [self.klineModels addObject:obj];
            
        }
//        [data enumerateObjectsUsingBlock:^(KFMKLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if (idx >= self.startIndex) {
//                CGFloat leftPosition = self.startX + (idx - self.startIndex) * (self.theme.rCandleWidth + KFMTheme.candleGap);
//                CGFloat xPosition = leftPosition + self.theme.rCandleWidth / 2;
//                
//                CGPoint highPoint = CGPointMake(xPosition, (self.maxPrice - obj.high) * self.priceUnit + minY);
//                CGPoint lowPoint = CGPointMake(xPosition, (self.maxPrice - obj.low) * self.priceUnit + minY);
//                
//                CGPoint ma5Point = CGPointMake(xPosition, (self.maxPrice - obj.ma5) * self.priceUnit + minY);
//                CGPoint ma10Point = CGPointMake(xPosition, (self.maxPrice - obj.ma10) * self.priceUnit + minY);
//                CGPoint ma20Point = CGPointMake(xPosition, (self.maxPrice - obj.ma20) * self.priceUnit + minY);
//                
//                CGFloat openPointY = (self.maxPrice - obj.open) * self.priceUnit + minY;
//                CGFloat closePointY = (self.maxPrice - obj.close) * self.priceUnit + minY;
//                UIColor *fillCandleColor = [UIColor blackColor];
//                CGRect candleRect = CGRectZero;
//                
//                CGFloat volume = (obj.volume - 0) * self.volumeUnit;
//                CGPoint volumeStarPoint = CGPointMake(xPosition, self.height - volume);
//                CGPoint volumeEndPoint = CGPointMake(xPosition, self.height);
//                
//                if (openPointY > closePointY) {
//                    fillCandleColor = [KFMTheme riseColor];
//                    candleRect = CGRectMake(leftPosition, closePointY, self.theme.rCandleWidth, openPointY - closePointY);
//                } else if (openPointY < closePointY) {
//                    fillCandleColor = [KFMTheme fallColor];
//                    candleRect = CGRectMake(leftPosition, openPointY, self.theme.rCandleWidth, closePointY - openPointY);
//                } else {
//                    candleRect = CGRectMake(leftPosition, closePointY, self.theme.rCandleWidth, [KFMTheme candleMinHeight]);
//                    if (idx > 0) {
//                        KFMKLineModel *frontModel = data[idx - 1];
//                        if (obj.open > frontModel.close) {
//                            fillCandleColor = [KFMTheme riseColor];
//                        } else {
//                            fillCandleColor = [KFMTheme fallColor];
//                        }
//                    }
//                }
//                
//                KFMKLineCoordModel * positionModel = [[KFMKLineCoordModel alloc]init];
//                positionModel.highPoint = highPoint;
//                positionModel.lowPoint = lowPoint;
//                positionModel.closeY = closePointY;
//                positionModel.ma5Point = ma5Point;
//                positionModel.ma10Point = ma10Point;
//                positionModel.ma20Point = ma20Point;
//                positionModel.volumeStartPoint = volumeStarPoint;
//                positionModel.volumeEndPoint = volumeEndPoint;
//                positionModel.candleFillColor = fillCandleColor;
//                positionModel.candleRect = candleRect;
//                if (idx % axisGap == 0) {
//                    positionModel.isDrawAxis = YES;
//                }
//                [self.positionModels addObject:positionModel];
//                [self.klineModels addObject:obj];
//            }
//
//        }];
    }
    
    
}
/// 清除图层
- (void)clearLayer {
    [self.ma5LineLayer removeFromSuperlayer];
    [self.ma10LineLayer removeFromSuperlayer];
    [self.ma20LineLayer removeFromSuperlayer];
    [self.candleChartLayer removeFromSuperlayer];
    [self.volumeLayer removeFromSuperlayer];
    [self.xAxisTimeMarkLayer removeFromSuperlayer];
}

/**
 画蜡烛图
 */
- (void)drawCandleChartLayerWithArray:(NSArray <KFMKLineCoordModel *>*)array {
    
    self.candleChartLayer.sublayers = nil;
    [array enumerateObjectsUsingBlock:^(KFMKLineCoordModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KFMCAShapeLayer *candleLayer = [self getCandleLayerWithModel:obj];
        [self.candleChartLayer addSublayer:candleLayer];
    }];
    [self.layer addSublayer:self.candleChartLayer];
}

/**
 画交易量图
 */
- (void)drawVolumeLayerWithArray:(NSArray <KFMKLineCoordModel *>*)array {
    //element
    self.volumeLayer.sublayers = nil;
    [array enumerateObjectsUsingBlock:^(KFMKLineCoordModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        KFMCAShapeLayer *volLayer = [self getVolumeLayerWithModel:obj];
        [self.volumeLayer addSublayer:volLayer];
    }];
    [self.layer addSublayer:self.volumeLayer];
}

/**
 画交均线图
 */
- (void)drawMALayerWithArray:(NSArray <KFMKLineCoordModel *>*)array {
    UIBezierPath *ma5LinePath = [UIBezierPath bezierPath];
    UIBezierPath *ma10LinePath = [UIBezierPath bezierPath];
    UIBezierPath *ma20LinePath = [UIBezierPath bezierPath];
    for (NSInteger i = 0; i < array.count; i++) {
        NSInteger idx = i;
        KFMKLineCoordModel *obj = array[idx];
        if (idx >= 1) {
            CGPoint perMa5Point = array[idx - 1].ma5Point;
            CGPoint ma5Point = obj.ma5Point;
            [ma5LinePath moveToPoint:perMa5Point];
            [ma5LinePath addLineToPoint:ma5Point];
            
            CGPoint perMa10Point = array[idx - 1].ma10Point;
            CGPoint ma10Point = obj.ma10Point;
            [ma10LinePath moveToPoint:perMa10Point];
            [ma10LinePath addLineToPoint:ma10Point];
            
            CGPoint perMa20Point = array[idx - 1].ma20Point;
            CGPoint ma20Point = obj.ma20Point;
            [ma20LinePath moveToPoint:perMa20Point];
            [ma20LinePath addLineToPoint:ma20Point];
        }

    }
//    [array enumerateObjectsUsingBlock:^(KFMKLineCoordModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        if (idx >= 1) {
//            CGPoint perMa5Point = array[idx - 1].ma5Point;
//            CGPoint ma5Point = obj.ma5Point;
//            [ma5LinePath moveToPoint:perMa5Point];
//            [ma5LinePath addLineToPoint:ma5Point];
//            
//            CGPoint perMa10Point = array[idx - 1].ma10Point;
//            CGPoint ma10Point = obj.ma10Point;
//            [ma10LinePath moveToPoint:perMa10Point];
//            [ma10LinePath addLineToPoint:ma10Point];
//
//            CGPoint perMa20Point = array[idx - 1].ma20Point;
//            CGPoint ma20Point = obj.ma20Point;
//            [ma20LinePath moveToPoint:perMa20Point];
//            [ma20LinePath addLineToPoint:ma20Point];
//        }
//    }];
    
    self.ma5LineLayer = [KFMCAShapeLayer layer];
    self.ma5LineLayer.path = ma5LinePath.CGPath;
    self.ma5LineLayer.strokeColor = [KFMTheme ma5Color].CGColor;
    self.ma5LineLayer.fillColor = kColorClear.CGColor;
    
    self.ma10LineLayer = [KFMCAShapeLayer layer];
    self.ma10LineLayer.path = ma10LinePath.CGPath;
    self.ma10LineLayer.strokeColor = [KFMTheme ma10Color].CGColor;
    self.ma10LineLayer.fillColor = kColorClear.CGColor;
    
    self.ma20LineLayer = [KFMCAShapeLayer layer];
    self.ma20LineLayer.path = ma20LinePath.CGPath;
    self.ma20LineLayer.strokeColor = [KFMTheme ma20Color].CGColor;
    self.ma20LineLayer.fillColor = kColorClear.CGColor;
    
    [self.layer addSublayer:self.ma5LineLayer];
    [self.layer addSublayer:self.ma10LineLayer];
    [self.layer addSublayer:self.ma20LineLayer];
    
}
- (void)drawxAxisTimeMarkLayer {
    __block NSDate *lastDate = nil;
    
    self.xAxisTimeMarkLayer.sublayers = nil;
    for (NSInteger i = 0; i < self.positionModels.count ; i++) {
        NSInteger idx = i;
        KFMKLineCoordModel *obj = self.positionModels[i];
        NSDate *date = [self.klineModels[idx].date toDateWithFormat:@"yyyyMMddHHmmss"];
        if (lastDate == nil) {
            lastDate = date;
        }
        if (obj.isDrawAxis) {
            switch (self.kLineType) {
                case KFMKLineForDay:
                case KFMKLineForWeek:
                case KFMKLineForMonth:
                    [self.xAxisTimeMarkLayer addSublayer:[self drawXaxisTimeMarkxPosition:obj.highPoint.x dateString:[date toSringWithFormat:@"yyyy-MM"]]];
                    break;
                    
                default:
                    [self.xAxisTimeMarkLayer addSublayer:[self drawXaxisTimeMarkxPosition:obj.highPoint.x dateString:[date toSringWithFormat:@"MM-dd"]]];
                    break;
            }
            lastDate = date;
        }

    }
    
//    [self.positionModels enumerateObjectsUsingBlock:^(KFMKLineCoordModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        NSDate *date = [self.klineModels[idx].date toDateWithFormat:@"yyyyMMddHHmmss"];
//        if (lastDate == nil) {
//            lastDate = date;
//        }
//        if (obj.isDrawAxis) {
//            switch (self.kLineType) {
//                case KFMKLineForDay:
//                case KFMKLineForWeek:
//                case KFMKLineForMonth:
//                    [self.xAxisTimeMarkLayer addSublayer:[self drawXaxisTimeMarkxPosition:obj.highPoint.x dateString:[date toSringWithFormat:@"yyyy-MM"]]];
//                    break;
//                    
//                default:
//                    [self.xAxisTimeMarkLayer addSublayer:[self drawXaxisTimeMarkxPosition:obj.highPoint.x dateString:[date toSringWithFormat:@"MM-dd"]]];
//                    break;
//            }
//            lastDate = date;
//        }
//        
//    }];
    [self.layer addSublayer:self.xAxisTimeMarkLayer];
}
#pragma mark - solo

/// 获取单个蜡烛图的layer
- (KFMCAShapeLayer *)getCandleLayerWithModel:(KFMKLineCoordModel *)model {
    // K线
    UIBezierPath *linePath = [UIBezierPath bezierPathWithRect:model.candleRect];
    // 影线
    [linePath moveToPoint:model.lowPoint];
    [linePath addLineToPoint:model.highPoint];
    
    KFMCAShapeLayer *klayer = [KFMCAShapeLayer layer];
    klayer.path = linePath.CGPath;
    klayer.strokeColor = model.candleFillColor.CGColor;
    klayer.fillColor = model.candleFillColor.CGColor;
    
    return klayer;
    
}
/// 获取单个交易量图的layer
- (KFMCAShapeLayer *)getVolumeLayerWithModel:(KFMKLineCoordModel *)model {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:model.volumeStartPoint];
    [linePath addLineToPoint:model.volumeEndPoint];
    
    KFMCAShapeLayer * vLayer = [KFMCAShapeLayer layer];
    vLayer.path = linePath.CGPath;
    vLayer.lineWidth = self.theme.rCandleWidth;
    vLayer.strokeColor = model.candleFillColor.CGColor;
    vLayer.fillColor = model.candleFillColor.CGColor;
    
    return vLayer;
}

/**
 横坐标单个时间标签
 */
- (KFMCAShapeLayer *)drawXaxisTimeMarkxPosition:(CGFloat)xPosition dateString:(NSString *)dateString {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:CGPointMake(xPosition, 0)];
    [linePath addLineToPoint:CGPointMake(xPosition, self.height * [KFMTheme uperChartHeightScale])];
    [linePath moveToPoint:CGPointMake(xPosition, self.height * [KFMTheme uperChartHeightScale] + [KFMTheme xAxisHeitht])];
    [linePath addLineToPoint:CGPointMake(xPosition, self.height)];
    
    KFMCAShapeLayer *lineLayer = [KFMCAShapeLayer layer];
    lineLayer.path = linePath.CGPath;
    lineLayer.lineWidth = 0.25;
    lineLayer.strokeColor = [KFMTheme borderColor].CGColor;
    lineLayer.fillColor = kColorClear.CGColor;
    
    CGSize textSize = [KFMTheme getTextSizeWithText:dateString];
    CGFloat labelX = 0;
    CGFloat labelY = 0;
    CGFloat maxX = CGRectGetMaxX(self.frame) - textSize.width;
    labelX = xPosition - textSize.width / 2;
    labelY = self.height * KFMTheme.uperChartHeightScale;
    if (labelX > maxX) {
        labelX = maxX;
    } else if (labelX < CGRectGetMinX(self.frame)) {
        labelX = CGRectGetMinX(self.frame);
    }
    
    CATextLayer *timeLayer = [self getTextLayerText:dateString foregroundColor:KFMTheme.textColor backgroundColor:kColorClear frame:CGRectMake(labelX, labelY, textSize.width, textSize.height)];
    
    KFMCAShapeLayer *shaperlayer = [KFMCAShapeLayer layer];
    [shaperlayer addSublayer:lineLayer];
    [shaperlayer addSublayer:timeLayer];
    
    return shaperlayer;
    
}
- (CATextLayer *)getTextLayerText:(NSString *)text foregroundColor:(UIColor *)foregroundColor backgroundColor:(UIColor *)backgroundColor frame:(CGRect)frame {
    CATextLayer *textLayer = [CATextLayer layer];
    textLayer.string = text;
    textLayer.foregroundColor = foregroundColor.CGColor;
    textLayer.backgroundColor = backgroundColor.CGColor;
    textLayer.frame = frame;
    textLayer.fontSize = 10;
    [textLayer setWrapped:YES];
    textLayer.contentsScale = [UIScreen mainScreen].scale;
    return textLayer;
    
}
#pragma mark - getter 
- (KFMCAShapeLayer *)xAxisTimeMarkLayer {
    if (!_xAxisTimeMarkLayer) {
        _xAxisTimeMarkLayer = [[KFMCAShapeLayer alloc]init];
    }
    return _xAxisTimeMarkLayer;
}
- (KFMCAShapeLayer *)candleChartLayer {
    if (!_candleChartLayer) {
        _candleChartLayer = [[KFMCAShapeLayer alloc]init];
    }
    return _candleChartLayer;
}
- (KFMCAShapeLayer *)volumeLayer {
    if (!_volumeLayer) {
        _volumeLayer = [[KFMCAShapeLayer alloc]init];
    }
    return _volumeLayer;
}
- (NSMutableArray<KFMKLineCoordModel *> *)positionModels {
    if (!_positionModels) {
        _positionModels = [[NSMutableArray alloc]init];
    }
    return _positionModels;
}
- (NSMutableArray<KFMKLineModel *> *)klineModels {
    if (!_klineModels) {
        _klineModels = [[NSMutableArray alloc]init];
    }
    return _klineModels;
}
- (KFMTheme *)theme {
    if (!_theme) {
        _theme = [[KFMTheme alloc]init];
    }
    return _theme;
}
- (CGFloat)uperChartHeight {
    return [KFMTheme uperChartHeightScale] * self.height;
}
- (CGFloat)lowerChartHeight {
    return  self.height * (1 - KFMTheme.uperChartHeightScale) - KFMTheme.xAxisHeitht;
}
- (NSInteger)startIndex {
    CGFloat scrollViewOffsetX = self.contentOffsetX < 0 ? 0 : self.contentOffsetX;
    NSInteger leftCandleCount = (NSInteger)fabs(scrollViewOffsetX) / (self.theme.rCandleWidth + KFMTheme.candleGap);
    
    if (leftCandleCount > self.dataK.count) {
        leftCandleCount = self.dataK.count - 1;
        return leftCandleCount;
    } else if (leftCandleCount == 0) {
        return leftCandleCount;
    } else {
        return leftCandleCount + 1;
    }
}
- (CGFloat)startX {
    return self.contentOffsetX < 0 ? 0 : self.contentOffsetX;
}
- (int)countOfshowCandle {
    return (int)(self.renderWidth - self.theme.rCandleWidth) / (self.theme.rCandleWidth + KFMTheme.candleGap);
}
@end
