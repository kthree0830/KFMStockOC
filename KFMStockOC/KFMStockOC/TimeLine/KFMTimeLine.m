//
//  KFMTimeLine.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#define kCountOfTimes 240
#define kFiveDayCount 120

#import "KFMTimeLine.h"
#import "KFMTimeLineCoordModel.h"


@interface KFMTimeLine ()
@property (nonatomic, strong)CAShapeLayer *timeLineLayer;
@property (nonatomic, strong)CAShapeLayer *volumeLayer;
@property (nonatomic, strong)CAShapeLayer *maLineLayer;
@property (nonatomic, strong)CAShapeLayer *frameLayer;
@property (nonatomic, strong)CAShapeLayer *fillColorLayer;
@property (nonatomic, strong)CAShapeLayer *yAxisLayer;
@property (nonatomic, strong)CAShapeLayer *crossLineLayer;

@property (nonatomic, assign)CGFloat maxPrice;
@property (nonatomic, assign)CGFloat minPrice;
@property (nonatomic, assign)CGFloat maxRatio;
@property (nonatomic, assign)CGFloat minRatio;
@property (nonatomic, assign)CGFloat maxVolume;
@property (nonatomic, assign)CGFloat priceMaxOffset;
@property (nonatomic, assign)CGFloat priceUnit;
@property (nonatomic, assign)CGFloat volumeUnit;

@property (nonatomic, assign)NSInteger highLightIndex;

@property (nonatomic, assign)BOOL isFiveDayTime;


@property (nonatomic, assign)CGFloat volumeStep;
@property (nonatomic, assign)CGFloat volumeWidth;

@property (nonatomic, strong)NSMutableArray <KFMTimeLineCoordModel *>*positionModels;

@property (nonatomic, strong)NSMutableArray <KFMTimeLineModel *>*dataT;

@end

@implementation KFMTimeLine
- (instancetype)initWithFrame:(CGRect)frame isFiveDay:(BOOL)isFiveDay
{
    self = [super initWithFrame:frame];
    if (self) {
        _maxPrice = 0;
        _minPrice = 0;
        _maxRatio = 0;
        _minRatio = 0;
        _maxVolume = 0;
        _priceMaxOffset = 0;
        _priceUnit = 0;
        _volumeUnit = 0;
        _volumeStep = 0;
        _volumeWidth = 0;
        _isLandscapeMode = NO;
        self.isFiveDayTime = isFiveDay;
        [self addGestures];
        [self drawFrameLayer];
        [self drawXAxisLabel];


    }
    return self;
}
#pragma mark - function
- (void)addGestures {
    UILongPressGestureRecognizer *longPressgesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureAction:)];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureAction:)];
    [self addGestureRecognizer:longPressgesture];
    [self addGestureRecognizer:tapGesture];
}
#pragma mark - events
- (void)configDataT:(NSMutableArray<KFMTimeLineModel *> *)dataT {
    [self.dataT removeAllObjects];
    self.dataT = [[NSMutableArray alloc]initWithArray:dataT];
    [self drawTimeLineChart];    
}
- (void)handleLongPressGestureAction:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self];
        if (point.x > 0 && point.x < self.width && point.y > 0 && point.y < self.height) {
            int index = point.x / self.volumeStep;
            if (index > self.dataT.count - 1) {
                self.highLightIndex = self.dataT.count - 1;
            } else {
                self.highLightIndex = index;
            }
            
            [self.crossLineLayer removeFromSuperlayer];
            self.crossLineLayer = [KFMTheme getCrossLineLayer:self.frame pricePoint:self.positionModels[self.highLightIndex].pricePoint volumePoint:self.positionModels[self.highLightIndex].volumeStartPoint model:self.dataT[self.highLightIndex]];
            [self.layer addSublayer:self.crossLineLayer];
        }
        if (self.highLightIndex < self.dataT.count) {
            [NSNotificationCenter.defaultCenter postNotificationName:kTimeLineLongpress object:self userInfo:@{ktimeLineEntity:self.dataT[self.highLightIndex]}];
        }
    }
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.crossLineLayer removeFromSuperlayer];
        [NSNotificationCenter.defaultCenter postNotificationName:kTimeLineUnLongpress object:self];
    }
    
}
- (void)handleTapGestureAction:(UITapGestureRecognizer *)recognizer {
    if (!_isLandscapeMode) {
        [NSNotificationCenter.defaultCenter postNotificationName:kTimeLineChartDidTap object:[NSNumber numberWithInteger:recognizer.view.tag]];
    }
}
#pragma mark - draw
//绘图
- (void)drawTimeLineChart {
    [self setMaxAndMinData];
    [self convertToPointsData:self.dataT];
    [self clearLayer];
    [self drawLineLayerArray:self.positionModels];
    [self drawVolumeLayerArray:self.positionModels];
    [self drawMALineLayerArray:self.positionModels];
    [self drawYAxisLabel];
    
}
//清除图层
- (void)clearLayer {
    [self.timeLineLayer removeFromSuperlayer];
    [self.fillColorLayer removeFromSuperlayer];
    [self.volumeLayer removeFromSuperlayer];
    [self.maLineLayer removeFromSuperlayer];
    [self.yAxisLayer removeFromSuperlayer];
}
//求极限值
- (void)setMaxAndMinData {
    if (self.dataT.count > 0) {
        self.maxPrice = self.dataT[0].price;
        self.minPrice = self.dataT[0].price;
        self.maxRatio = self.dataT[0].rate;
        self.minRatio = self.dataT[0].rate;
        self.maxVolume = self.dataT[0].volume;
        
        //分时线和五日线的比较基准
        CGFloat toComparePrice = _isFiveDayTime ? self.dataT[0].price : self.dataT[0].preClosePx;
        
        if (_isFiveDayTime) {
            for (KFMTimeLineModel *model in self.dataT) {
                self.maxVolume = _maxVolume > model.volume ? _maxVolume : model.volume;
                self.maxPrice = _maxPrice > model.price ? _maxPrice : model.price;
                self.minPrice = _minPrice < model.price ? _minPrice : model.price;
            }
            self.maxRatio = (_maxPrice - toComparePrice) / toComparePrice;
            self.minRatio = (_minPrice - toComparePrice) / toComparePrice;
        } else {
            for (KFMTimeLineModel *model in self.dataT) {
                self.priceMaxOffset = _priceMaxOffset > fabs(model.price - toComparePrice) ? _priceMaxOffset : fabs(model.price - toComparePrice);
                self.maxVolume = _maxVolume > model.volume ? _maxVolume : model.volume;
            }
            self.maxPrice = toComparePrice + self.priceMaxOffset;
            self.minPrice = toComparePrice - self.priceMaxOffset;
            self.maxRatio = self.priceMaxOffset / toComparePrice;
            self.minRatio = -self.maxRatio;
        }
        for (KFMTimeLineModel *model in self.dataT) {
            model.avgPirce = model.avgPirce < self.minPrice ? self.minPrice : model.avgPirce;
            model.avgPirce = model.avgPirce > self.maxPrice ? self.maxPrice : model.avgPirce;
        }
    }
}
//横坐标轴的标签
- (void)drawXAxisLabel {
    if (_isFiveDayTime) {
        
    } else {
        CGSize startTimeSize = [KFMTheme getTextSizeWithText:@"9:30"];
        CATextLayer *startTime = [KFMTheme getTextLayer:@"9:30" foregroundColor:KFMTheme.textColor backgroundColor:kColorClear frame:CGRectMake(0, self.uperChartHeight, startTimeSize.width, startTimeSize.height)];
        
        CGSize midTimeSize = [KFMTheme getTextSizeWithText:@"11:30/13:00"];
        CATextLayer *midTime = [KFMTheme getTextLayer:@"11:30/13:00" foregroundColor:KFMTheme.textColor backgroundColor:kColorClear frame:CGRectMake(self.width / 2 - midTimeSize.width / 2, self.uperChartHeight, midTimeSize.width, midTimeSize.height)];
        
        CGSize stopTimeSize = [KFMTheme getTextSizeWithText:@"15:00"];
        CATextLayer *stopTime = [KFMTheme getTextLayer:@"15:00" foregroundColor:KFMTheme.textColor backgroundColor:kColorClear frame:CGRectMake(self.width - stopTimeSize.width, self.uperChartHeight, stopTimeSize.width, stopTimeSize.height)];
        
        [self.layer addSublayer:startTime];
        [self.layer addSublayer:midTime];
        [self.layer addSublayer:stopTime];
    }
}
//纵坐标轴的标签
- (void)drawYAxisLabel {

    for (NSInteger i = 0; i< self.yAxisLayer.sublayers.count; i++) {
        CALayer *layer = self.yAxisLayer.sublayers[i];
        [layer removeFromSuperlayer];
    }
    //画纵坐标的最高和最低价格标签
    NSString *maxPriceStr = [NSString toStringWithFormat:@".2" cfloat:self.maxPrice];
    NSString *minPriceStr = [NSString toStringWithFormat:@".2" cfloat:self.minPrice];
    [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:maxPriceStr y:[KFMTheme viewMinYGap] isLeft:NO]];
    [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:minPriceStr y:[self uperChartDrawAreaBottom] isLeft:NO]];
    
    //最高成交量标签及其横线
    CGFloat y = self.height - self.maxVolume * self.volumeUnit;
    NSString *maxVolumeStr = [NSString toStringWithFormat:@".2" cfloat:self.maxVolume];
    [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:maxVolumeStr y:y isLeft:NO]];
    
    UIBezierPath *maxVolLine = [UIBezierPath bezierPath];
    [maxVolLine moveToPoint:CGPointMake(0, y)];
    [maxVolLine addLineToPoint:CGPointMake(self.width, y)];
    CAShapeLayer *maxVolLineLayer = [CAShapeLayer layer];
    maxVolLineLayer.path = maxVolLine.CGPath;
    maxVolLineLayer.lineWidth = 0.25;
    maxVolLineLayer.strokeColor = [KFMTheme borderColor].CGColor;
    maxVolLineLayer.fillColor = kColorClear.CGColor;
    [self.yAxisLayer addSublayer:maxVolLineLayer];
    
    //画比率标签
    NSString *maxRationStr = [NSString toPercentFormatCfloat:self.maxRatio * 100];
    NSString *minRationStr = [NSString toPercentFormatCfloat:self.minRatio * 100];
    [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:maxRationStr y:[self uperChartDrawAreaTop] isLeft:YES]];
    [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:minRationStr y:[self uperChartDrawAreaBottom] isLeft:YES]];
    
    //中间横虚线及其标签
    KFMTimeLineModel *model = self.dataT.firstObject;
    if (model) {
         // 日分时图中间区域线代表昨日的收盘价格，五日分时图的则代表五日内的第一天9点30分的价格
        CGFloat price = _isFiveDayTime ? model.price : model.preClosePx;
        CGFloat preClosePriceYaxis = (self.maxPrice - price) * self.priceUnit + self.uperChartDrawAreaTop;
        
        UIBezierPath *dashLinePath = [UIBezierPath bezierPath];
        [dashLinePath moveToPoint:CGPointMake(0, y)];
        [dashLinePath addLineToPoint:CGPointMake(self.width, y)];
        
        CAShapeLayer *dashLineLayer = [CAShapeLayer layer];
        dashLineLayer.lineWidth = [KFMTheme lineWidth] / 2;
        dashLineLayer.strokeColor = [KFMTheme borderColor].CGColor;
        dashLineLayer.fillColor = kColorClear.CGColor;
        dashLineLayer.path = dashLinePath.CGPath;
        dashLineLayer.lineDashPattern = @[@6,@3];//虚线
        [self.yAxisLayer addSublayer:dashLineLayer];
        
        [self.yAxisLayer addSublayer:[KFMTheme getYAxisMarkLayer:self.frame text:[NSString toPercentFormatCfloat:price] y:preClosePriceYaxis isLeft:NO]];
    }
    [self.layer addSublayer:self.yAxisLayer];
}
//转换为坐标数据
- (void)convertToPointsData:(NSArray <KFMTimeLineModel*>*)data {
    CGFloat maxDiff = self.maxPrice - self.minPrice;
    if (maxDiff > 0 && self.maxVolume > 0) {
        self.priceUnit = ([self uperChartHeight] - 2 * [KFMTheme viewMinYGap]) / maxDiff;
        self.volumeUnit = ([self lowerChartHeight] - [KFMTheme volumeGap]) / self.maxVolume;
    }
    
    if (_isFiveDayTime) {
        self.volumeStep = self.width / kFiveDayCount;
    } else {
        self.volumeStep = self.width / kCountOfTimes;
    }
    
    self.volumeWidth = self.volumeStep - self.volumeStep / 3;
    [self.positionModels removeAllObjects];
    
    for (NSInteger i = 0; i < data.count; i++) {
        NSInteger idx = i;
        KFMTimeLineModel *obj = data[i];
        CGFloat centerX = self.volumeStep * idx + self.volumeStep / 2;
        CGFloat xPosition = centerX;
        CGFloat yPosition = (self.maxPrice - obj.price) * self.priceUnit + [self uperChartDrawAreaTop];
        CGPoint pricePoint = CGPointMake(xPosition, yPosition);
        
        CGFloat avgYposition = (self.maxPrice - obj.avgPirce) * self.priceUnit + [self uperChartDrawAreaTop];
        CGPoint avgPoint = CGPointMake(xPosition, avgYposition);
        
        CGFloat volumeHeight = obj.volume * self.volumeUnit;
        CGPoint volumeStartPoiint = CGPointMake(centerX, self.height - volumeHeight);
        CGPoint volumeEndPoint = CGPointMake(centerX, self.height);
        
        KFMTimeLineCoordModel *positionModel = [[KFMTimeLineCoordModel alloc]init];
        positionModel.pricePoint = pricePoint;
        positionModel.avgPoint = avgPoint;
        positionModel.volumeHeight = volumeHeight;
        positionModel.volumeStartPoint = volumeStartPoiint;
        positionModel.volumeEndPoint = volumeEndPoint;
        
        [self.positionModels addObject:positionModel];

    }
    
//    [data enumerateObjectsUsingBlock:^(KFMTimeLineModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        CGFloat centerX = self.volumeStep * idx + self.volumeStep / 2;
//        CGFloat xPosition = centerX;
//        CGFloat yPosition = (self.maxPrice - obj.price) * self.priceUnit + [self uperChartDrawAreaTop];
//        CGPoint pricePoint = CGPointMake(xPosition, yPosition);
//        
//        CGFloat avgYposition = (self.maxPrice - obj.avgPirce) * self.priceUnit + [self uperChartDrawAreaTop];
//        CGPoint avgPoint = CGPointMake(xPosition, avgYposition);
//        
//        CGFloat volumeHeight = obj.volume * self.volumeUnit;
//        CGPoint volumeStartPoiint = CGPointMake(centerX, self.height - volumeHeight);
//        CGPoint volumeEndPoint = CGPointMake(centerX, self.height);
//        
//        KFMTimeLineCoordModel *positionModel = [[KFMTimeLineCoordModel alloc]init];
//        positionModel.pricePoint = pricePoint;
//        positionModel.avgPoint = avgPoint;
//        positionModel.volumeHeight = volumeHeight;
//        positionModel.volumeStartPoint = volumeStartPoiint;
//        positionModel.volumeEndPoint = volumeEndPoint;
//        
//        [self.positionModels addObject:positionModel];
//    }];
}
//边框
- (void)drawFrameLayer {
    // 分时线区域 frame
    UIBezierPath *framePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.width, self.uperChartHeight)];
    if (self.isFiveDayTime) {
        //五日分时图的四条竖线
        CGFloat width = self.width / 5;
        for (NSInteger i = 1; i < 5; i++) {
            CGFloat lineX = width * i;
            CGPoint startPoint = CGPointMake(lineX, self.uperChartHeight);
            CGPoint stopPoint = CGPointMake(lineX, 0);
            [framePath moveToPoint:startPoint];
            [framePath addLineToPoint:stopPoint];
        }
    } else {
        //分时线的中间竖线
        CGPoint startPoint = CGPointMake(self.width / 2, 0);
        CGPoint stopPoint = CGPointMake(self.width / 2, self.uperChartHeight);
        [framePath moveToPoint:startPoint];
        [framePath addLineToPoint:stopPoint];
    }
    CAShapeLayer *frameLayer = [CAShapeLayer layer];
    frameLayer.path = framePath.CGPath;
    frameLayer.lineWidth = KFMTheme.frameWidth;
    frameLayer.strokeColor = KFMTheme.borderColor.CGColor;
    frameLayer.fillColor = kColorClear.CGColor;
    
    // 交易量区域 frame
    UIBezierPath *volFramePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.lowerChartTop, self.width, self.lowerChartHeight)];
    CGFloat y = self.height - self.maxVolume * self.volumeUnit;
    [volFramePath moveToPoint:CGPointMake(0, y)];
    [volFramePath addLineToPoint:CGPointMake(self.width, y)];
    
    CAShapeLayer *volFrameLayer = [CAShapeLayer layer];
    volFrameLayer.path = volFramePath.CGPath;
    volFrameLayer.lineWidth = KFMTheme.frameWidth;
    volFrameLayer.strokeColor = KFMTheme.borderColor.CGColor;
    volFrameLayer.fillColor = kColorClear.CGColor;
    [self.layer addSublayer:frameLayer];
    [self.layer addSublayer:volFrameLayer];
}
//分时线
- (void)drawLineLayerArray:(NSArray <KFMTimeLineCoordModel *>*)array {
    if (array.count > 0) {
        UIBezierPath *timeLinePath = [UIBezierPath bezierPath];
        [timeLinePath moveToPoint:array.firstObject.pricePoint];

        [array enumerateObjectsUsingBlock:^(KFMTimeLineCoordModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx != 0) {
                [timeLinePath addLineToPoint:obj.pricePoint];
            }
        }];
        self.timeLineLayer.path = timeLinePath.CGPath;
        self.timeLineLayer.lineWidth = 1;
        self.timeLineLayer.strokeColor = [KFMTheme priceLineCorlor].CGColor;
        self.timeLineLayer.fillColor = kColorClear.CGColor;
        
        // 填充颜色
        [timeLinePath addLineToPoint:CGPointMake(array.lastObject.pricePoint.x, [KFMTheme uperChartHeightScale] * self.height)];
        [timeLinePath addLineToPoint:CGPointMake(array.firstObject.pricePoint.x, [KFMTheme uperChartHeightScale] * self.height)];
        self.fillColorLayer.path = timeLinePath.CGPath;
        self.fillColorLayer.fillColor = [KFMTheme fillColor].CGColor;
        self.fillColorLayer.strokeColor = kColorClear.CGColor;
        self.fillColorLayer.zPosition -= 1;// 将图层置于下一级，让底部的标记线显示出来
        
        [self.layer addSublayer:self.timeLineLayer];
        [self.layer addSublayer:self.fillColorLayer];
        [self animatePoint].frame = CGRectMake(array.lastObject.pricePoint.x - 3/2, array.lastObject.pricePoint.y - 3/2, 3, 3);
    }
    
}
///交易量图
- (void)drawVolumeLayerArray:(NSArray <KFMTimeLineCoordModel *>*)array {
    if (array.count > 0) {
        for (NSInteger i = 0; i< self.volumeLayer.sublayers.count; i++) {
            CALayer *layer = self.volumeLayer.sublayers[i];
            [layer removeFromSuperlayer];
        }
        UIColor *strokeColor = kColorClear;
        CGFloat preClosePx = self.dataT.firstObject.preClosePx >= 0 ? self.dataT.firstObject.preClosePx : 0;
        
        for (NSInteger i = 0; i < array.count; i++) {
            CGFloat comparePrice = (i == 0) ? preClosePx : self.dataT[i - 1].price;
            strokeColor = self.dataT[i].price < comparePrice ? [KFMTheme fallColor] :[KFMTheme riseColor];
            CAShapeLayer *volLayer = [self getVolumeLayerModel:array[i] fillColor:strokeColor];
            [self.volumeLayer addSublayer:volLayer];
        }
        [self.layer addSublayer:self.volumeLayer];

    }
    
}
//均线
- (void)drawMALineLayerArray:(NSArray <KFMTimeLineCoordModel *>*)array {
    if (array.count > 0) {
        UIBezierPath *maLinePath = [UIBezierPath bezierPath];
        for (NSInteger i = 1; i < array.count; i++) {
            CGPoint preMaPoint = array[i - 1].avgPoint;
            CGPoint maPoint = array[i].avgPoint;
            [maLinePath moveToPoint:preMaPoint];
            [maLinePath addLineToPoint:maPoint];
        }
        self.maLineLayer.path = maLinePath.CGPath;
        self.maLineLayer.strokeColor = [KFMTheme avgLineCorlor].CGColor;
        self.maLineLayer.fillColor = kColorClear.CGColor;
        [self.layer addSublayer:self.maLineLayer];
    }
    
    
}
//获取单个交易量图的layer
- (CAShapeLayer *)getVolumeLayerModel:(KFMTimeLineCoordModel *)model fillColor:(UIColor *)fillColor {
    UIBezierPath *linePath = [UIBezierPath bezierPath];
    [linePath moveToPoint:model.volumeStartPoint];
    [linePath addLineToPoint:model.volumeEndPoint];
    
    CAShapeLayer *vlayer = [CAShapeLayer layer];
    vlayer.path = linePath.CGPath;
    vlayer.lineWidth = self.volumeWidth;
    vlayer.strokeColor = fillColor.CGColor;
    vlayer.fillColor = fillColor.CGColor;
    
    return vlayer;
}
//呼吸灯动画
- (CAAnimationGroup *)breathingLightAnimateTime:(double)time {
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    scaleAnimation.fromValue = @1;
    scaleAnimation.toValue = @3.5;
    scaleAnimation.autoreverses = NO;
    [scaleAnimation setRemovedOnCompletion:YES];
    scaleAnimation.repeatCount = CGFLOAT_MAX;
    scaleAnimation.duration = time;
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.fromValue = @1.0;
    opacityAnimation.toValue = @0;
    opacityAnimation.autoreverses = NO;
    [opacityAnimation setRemovedOnCompletion:YES];
    opacityAnimation.repeatCount = CGFLOAT_MAX;
    opacityAnimation.duration = time;
    opacityAnimation.fillMode = kCAFillModeForwards;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.duration = time;
    group.autoreverses = NO;
    [group setRemovedOnCompletion:NO];// 设置为false 在各种走势图切换后，动画不会失效
    group.fillMode = kCAFillModeForwards;
    group.animations = @[scaleAnimation,opacityAnimation];
    group.repeatCount = CGFLOAT_MAX;
    
    return group;
}
#pragma mark - getter
- (CGFloat)uperChartHeight {
    return self.height * KFMTheme.uperChartHeightScale;
}
- (CGFloat)lowerChartHeight {
    return self.height * (1 - KFMTheme.uperChartHeightScale) - KFMTheme.xAxisHeitht;
}
- (CGFloat)uperChartDrawAreaTop {
    return KFMTheme.viewMinYGap;
}
- (CGFloat)uperChartDrawAreaBottom {
    return self.uperChartHeight - KFMTheme.viewMinYGap;
}
- (CGFloat)lowerChartTop {
    return self.uperChartHeight + KFMTheme.xAxisHeitht;

}
#pragma mark - lazy
- (CALayer *)animatePoint {
    CALayer *animatePoint = [CALayer layer];
    [self.layer addSublayer:animatePoint];
    animatePoint.backgroundColor = [UIColor kfm_colorWithHex:0x0095ff].CGColor;
    animatePoint.cornerRadius = 1.5;
    
    CALayer *layer = [CALayer layer];
    layer.frame = CGRectMake(0, 0, 3, 3);
    layer.backgroundColor = [UIColor kfm_colorWithHex:0x0095ff].CGColor;
    layer.cornerRadius = 1.5;
    [layer addAnimation:[self breathingLightAnimateTime:2] forKey:nil];
    
    [animatePoint addSublayer:layer];
    
    return animatePoint;
}
- (NSMutableArray<KFMTimeLineModel *> *)dataT {
    if (!_dataT) {
        _dataT = [[NSMutableArray alloc]init];
    }
    return _dataT;
}
- (NSMutableArray<KFMTimeLineCoordModel *> *)positionModels {
    if (!_positionModels) {
        _positionModels = [[NSMutableArray alloc]init];
    }
    return _positionModels;
}
- (CAShapeLayer *)timeLineLayer {
    if (!_timeLineLayer) {
        _timeLineLayer = [[CAShapeLayer alloc]init];
    }
    return _timeLineLayer;
}
- (CAShapeLayer *)volumeLayer {
    if (!_volumeLayer) {
        _volumeLayer = [[CAShapeLayer alloc]init];
    }
    return _volumeLayer;
}
- (CAShapeLayer *)maLineLayer {
    if (!_maLineLayer) {
        _maLineLayer = [[CAShapeLayer alloc]init];
    }
    return _maLineLayer;
}
- (CAShapeLayer *)frameLayer {
    if (!_frameLayer) {
        _frameLayer = [[CAShapeLayer alloc]init];
    }
    return _frameLayer;
}
- (CAShapeLayer *)fillColorLayer {
    if (!_fillColorLayer) {
        _fillColorLayer = [[CAShapeLayer alloc]init];
    }
    return _fillColorLayer;
}
- (CAShapeLayer *)yAxisLayer {
    if (!_yAxisLayer) {
        _yAxisLayer = [[CAShapeLayer alloc]init];
    }
    return _yAxisLayer;
}
- (CAShapeLayer *)crossLineLayer {
    if (!_crossLineLayer) {
        _crossLineLayer = [[CAShapeLayer alloc]init];
    }
    return _crossLineLayer;
}
@end
