//
//  KFMKLineView.m
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLineView.h"
#import "KFMKLine.h"
#import "KFMKLineUpFrontView.h"
@interface KFMKLineView ()<UIScrollViewDelegate>
@property (nonatomic, strong)UIScrollView *scrollView;
@property (nonatomic, strong)KFMKLine *kLine;
@property (nonatomic, strong)KFMKLineUpFrontView *upFrontView;
@property (nonatomic, assign)KFMChartType kLineType;

@property (nonatomic, strong)KFMTheme *theme;

@property (nonatomic, strong)NSMutableArray <KFMKLineModel *>*dataK;



@property (nonatomic, strong)NSMutableArray <KFMKLineModel *>*allDataK;
@property (nonatomic, assign)BOOL enableKVO;

@property (nonatomic, assign)CGFloat kLineViewWidth;
@property (nonatomic, assign)CGFloat oldRightOffset;
@property (nonatomic, assign, readonly)CGFloat uperChartHeight;
@property (nonatomic, assign, readonly)CGFloat lowerChartTop;
@end


@implementation KFMKLineView
- (instancetype)initWithFrame:(CGRect)frame kLineType:(KFMChartType)kLineType
{
    self = [super initWithFrame:frame];
    if (self) {
        self.enableKVO = YES;
        self.kLineViewWidth = 0;
        self.oldRightOffset = -1;
        self.theme = [[KFMTheme alloc]init];
        
        [self drawFrameLayer];
        
        self.backgroundColor = kColorWhite;
        self.scrollView = [[UIScrollView alloc]initWithFrame:self.bounds];
        self.scrollView.showsHorizontalScrollIndicator = YES;
        self.scrollView.showsVerticalScrollIndicator = NO;
        self.scrollView.alwaysBounceHorizontal = YES;
        self.scrollView.delegate = self;
        [self.scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
        [self addSubview:self.scrollView];
        
        self.kLine = [[KFMKLine alloc]init];
        self.kLine.kLineType = kLineType;
        [self.scrollView addSubview:self.kLine];
        
        self.upFrontView = [[KFMKLineUpFrontView alloc]initWithFrame:self.bounds];
        [self addSubview:self.upFrontView];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPressGestureAction:)];
        [self.kLine addGestureRecognizer:longPressGesture];
        UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGestureAction:)];
        [self.kLine addGestureRecognizer:pinGesture];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureAction:)];
        [self.kLine addGestureRecognizer:tapGesture];
        
        NSString *jsonFile = @"";
        switch (kLineType) {
            case KFMKLineForDay:
                jsonFile = @"kLineForDay";
                break;
            case KFMKLineForWeek:
                jsonFile = @"kLineForWeek";
                break;
            default:
                jsonFile = @"kLineForMonth";
                break;
        }
        self.allDataK = [KFMKLineModel getKLineModelArrayWithDic:[self getJsonDataFormFie:jsonFile]].mutableCopy;
        NSArray *tmpDataK = [self.allDataK subarrayWithRange:NSMakeRange(self.allDataK.count - 70, 70)];
        [self configureViewWithData:tmpDataK];
        
        
    }
    return self;
}
- (void)dealloc {
    [self.scrollView removeObserver:self forKeyPath:@"contentOffset"];
}
- (void)configureViewWithData:(NSArray <KFMKLineModel *>*)data {
    self.dataK = [[NSMutableArray alloc]initWithArray:data];
    self.kLine.dataK = [[NSMutableArray alloc]initWithArray:data];
    CGFloat count = data.count;
    
    // 总长度
    self.kLineViewWidth = count * self.theme.rCandleWidth + (count + 1) * KFMTheme.candleGap;
    if (self.kLineViewWidth < self.width) {
        self.kLineViewWidth = self.width;
    } else {
        self.kLineViewWidth = count * self.theme.rCandleWidth + (count + 1) * KFMTheme.candleGap;
    }
    
    // 更新view长度
    self.kLine.frame = CGRectMake(self.x, self.y, self.kLineViewWidth, self.scrollView.height);
    
    CGFloat contentOffsetX = 0;
    if (self.scrollView.contentSize.width > 0) {
        contentOffsetX = self.kLineViewWidth - self.scrollView.contentSize.width;
    } else {
        contentOffsetX = self.kLine.width - self.scrollView.width;
    }
    
    self.scrollView.contentSize = CGSizeMake(self.kLineViewWidth, self.height);
    self.scrollView.contentOffset = CGPointMake(contentOffsetX, 0);
    self.kLine.contentOffsetX = self.scrollView.contentOffset.x;
    
}
- (void)updateKlineViewWidth {
    CGFloat count = self.kLine.dataK.count;
    // 总长度
    self.kLineViewWidth = count * self.theme.rCandleWidth + (count + 1) * KFMTheme.candleGap;
    if (self.kLineViewWidth < self.width) {
        self.kLineViewWidth = self.width;
    } else {
        self.kLineViewWidth = count * self.theme.rCandleWidth + (count + 1) * KFMTheme.candleGap;
    }
    
    // 更新view长度
    self.kLine.frame = CGRectMake(self.x, self.y, self.kLineViewWidth, self.scrollView.height);
    self.scrollView.contentSize = CGSizeMake(self.kLineViewWidth, self.height);
}
// 画边框
- (void)drawFrameLayer {
    // K线图
    UIBezierPath *uperFramePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, self.width, self.uperChartHeight)];
    
    // K线图 内上边线 即最高价格线
    [uperFramePath moveToPoint:CGPointMake(0, KFMTheme.viewMinYGap)];
    [uperFramePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.frame), KFMTheme.viewMinYGap)];
    
    // K线图 内下边线 即最低价格线
    [uperFramePath moveToPoint:CGPointMake(0, self.uperChartHeight - KFMTheme.viewMinYGap)];
    [uperFramePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.frame), self.uperChartHeight - KFMTheme.viewMinYGap)];
    
    // K线图 中间的横线
    [uperFramePath moveToPoint:CGPointMake(0, self.uperChartHeight / 2)];
    [uperFramePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.frame), self.uperChartHeight / 2)];
    
    CAShapeLayer *uperFrameLayer = [CAShapeLayer layer];
    uperFrameLayer.path = uperFramePath.CGPath;
    uperFrameLayer.lineWidth = KFMTheme.frameWidth;
    uperFrameLayer.strokeColor = KFMTheme.borderColor.CGColor;
    uperFrameLayer.fillColor = kColorClear.CGColor;
    
    // 交易量图
    UIBezierPath *volFramePath = [UIBezierPath bezierPathWithRect:CGRectMake(0, self.uperChartHeight + KFMTheme.xAxisHeitht, self.width, self.height - self.uperChartHeight - KFMTheme.xAxisHeitht)];
    
    // 交易量图 内上边线 即最高交易量格线
    [volFramePath moveToPoint:CGPointMake(0, self.uperChartHeight + KFMTheme.xAxisHeitht + KFMTheme.volumeGap)];
    [volFramePath addLineToPoint:CGPointMake(CGRectGetMaxX(self.frame), self.uperChartHeight + KFMTheme.xAxisHeitht + KFMTheme.volumeGap)];
    
    CAShapeLayer *volFrameLayer = [CAShapeLayer layer];
    volFrameLayer.path = volFramePath.CGPath;
    volFrameLayer.lineWidth = KFMTheme.frameWidth;
    volFrameLayer.strokeColor = KFMTheme.borderColor.CGColor;
    volFrameLayer.fillColor = kColorClear.CGColor;
    
    [self.layer addSublayer:uperFrameLayer];
    [self.layer addSublayer:volFrameLayer];
}
#pragma mark - events
- (void)handleLongPressGestureAction:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint point = [recognizer locationInView:self.kLine];
        NSInteger highLightIndex = point.x / (self.theme.rCandleWidth + KFMTheme.candleGap);
        if (highLightIndex < self.kLine.dataK.count) {
            NSInteger index = highLightIndex - self.kLine.startIndex;
            KFMKLineModel *entity = self.kLine.dataK[highLightIndex];
            CGFloat left = self.kLine.startX + (highLightIndex - self.kLine.startIndex) * (self.theme.rCandleWidth + KFMTheme.candleGap) - self.scrollView.contentOffset.x;
            
            CGFloat centerX = left + self.theme.rCandleWidth / 2.0;
            CGFloat highLightVolume = self.kLine.positionModels[index].volumeStartPoint.y;
            CGFloat highLightClose = self.kLine.positionModels[index].closeY;
            
            [self.upFrontView drawCrossLinePricePoint:CGPointMake(centerX, highLightClose) volumePoint:CGPointMake(centerX, highLightVolume) model:entity];
            
            KFMKLineModel *lastData = highLightIndex > 0 ? self.dataK[highLightIndex - 1] : self.kLine.dataK.firstObject;
            NSDictionary *userInfo = @{
                                       @"preClose" : @(lastData.close),
                                       @"kLineEntity" : self.kLine.dataK[highLightIndex]
                                       };
            [NSNotificationCenter.defaultCenter postNotificationName:kKLineChartLongPress object:self userInfo:userInfo];
        }

    }
    
    if (recognizer.state == UIGestureRecognizerStateEnded) {
        [self.upFrontView removeCrossLine];
        [NSNotificationCenter.defaultCenter postNotificationName:kKLineChartUnLongPress object:self];
    }
}
// 捏合缩放扩大操作
- (void)handlePinGestureAction:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.numberOfTouches != 2) {
        return;
    }
    
    CGFloat scale = recognizer.scale;
    CGFloat originScale = 1.0;
    CGFloat kLineScaleFactor = 0.06;
    CGFloat kLineScaleBound = 0.03;
    CGFloat diffScale = scale - originScale;// 获取缩放倍数
    switch (recognizer.state) {
        case UIGestureRecognizerStateBegan:
        {
            self.enableKVO = NO;
            [self.scrollView setScrollEnabled:NO];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            self.enableKVO = YES;
            [self.scrollView setScrollEnabled:YES];
        }
            break;
            
        default:
            break;
    }
    
    if (fabs(diffScale) > kLineScaleBound) {
        CGPoint point1 = [recognizer locationOfTouch:0 inView:self];
        CGPoint point2 = [recognizer locationOfTouch:1 inView:self];
        
        CGFloat pinCenterX = (point1.x + point2.x) / 2;
        CGFloat scrollViewPinCenterX = pinCenterX + self.scrollView.contentOffset.x;
        
        // 中心点数据index
        CGFloat pinCenterLeftCount = scrollViewPinCenterX / (self.theme.rCandleWidth + KFMTheme.candleGap);
        
        // 缩放后的candle宽度
        CGFloat newCandleWidth = self.theme.rCandleWidth * (diffScale > 0 ? (1 + kLineScaleFactor) : (1 - kLineScaleFactor));
        if (newCandleWidth > KFMTheme.candleMaxWidth) {
            self.theme.rCandleWidth = KFMTheme.candleMaxWidth;
            self.kLine.theme.rCandleWidth = KFMTheme.candleMaxWidth;
        } else if (newCandleWidth < KFMTheme.candleMinWidth) {
            self.theme.rCandleWidth = KFMTheme.candleMinWidth;
            self.kLine.theme.rCandleWidth = KFMTheme.candleMinWidth;
        } else {
            self.theme.rCandleWidth = newCandleWidth;
            self.kLine.theme.rCandleWidth = newCandleWidth;
        }
        
        // 更新容纳的总长度
        [self updateKlineViewWidth];
        CGFloat newPinCenterX = pinCenterLeftCount * self.theme.rCandleWidth + (pinCenterLeftCount - 1) * KFMTheme.candleGap;
        CGFloat newOffsetX = newPinCenterX - pinCenterX;
        self.scrollView.contentOffset = CGPointMake(newOffsetX > 0 ? newOffsetX : 0, self.scrollView.contentOffset.y);
        
        self.kLine.contentOffsetX = self.scrollView.contentOffset.x;
        [self.kLine drawKLineView];
    }
}
/// 处理点击事件
- (void)handleTapGestureAction:(UITapGestureRecognizer *)recognizer {
    if (!self.isLandscapeMode) {
        CGPoint point = [recognizer locationInView:self.kLine];
        if (point.y < self.lowerChartTop) {
            [NSNotificationCenter.defaultCenter postNotificationName:kKLineUperChartDidTap object:@(self.tag)];
        }
    }
}
#pragma mark - observe
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"contentOffset"] && self.enableKVO) {
        // 拖动 ScrollView 时重绘当前显示的 klineview
        self.kLine.contentOffsetX = self.scrollView.contentOffset.x;
        self.kLine.renderWidth = self.scrollView.width;
        [self.kLine drawKLineView];
        
        [self.upFrontView configureAxisWithMax:self.kLine.maxPrice Min:self.kLine.minPrice maxVol:self.kLine.maxVolume];
    }
}
#pragma mark - scrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    //用于滑动加载更多 KLine 数据
    if (scrollView.contentOffset.x < 0 && self.dataK.count < self.allDataK.count) {
        self.oldRightOffset = scrollView.contentSize.width - scrollView.contentOffset.x;
        [self configureViewWithData:self.allDataK];
    } else {
    
    }
}
#pragma mark - lazy

- (CGFloat)uperChartHeight {
    return [KFMTheme uperChartHeightScale] * self.height;
}
- (CGFloat)lowerChartTop {
    return self.uperChartHeight + [KFMTheme xAxisHeitht];
}
- (NSMutableArray<KFMKLineModel *> *)dataK {
    if (!_dataK) {
        _dataK = [[NSMutableArray alloc]init];
    }
    return _dataK;
}
- (NSMutableArray<KFMKLineModel *> *)allDataK {
    if (!_allDataK) {
        _allDataK = [[NSMutableArray alloc]init];
    }
    return _allDataK;
}
#pragma mark - private
- (NSDictionary *)getJsonDataFormFie:(NSString *)fileName {
    NSString *pathForResource = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    NSString *content = [NSString stringWithContentsOfFile:pathForResource encoding:NSUTF8StringEncoding error:nil];
    NSData *jsonContent = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonContent options:NSJSONReadingMutableContainers error:nil];
    return dic;
}
@end
