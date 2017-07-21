//
//  ViewController.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "ViewController.h"
#import "KFMSegmentMenu.h"
#import "KFMChartViewController.h"
#import "KFMLandscapeViewController.h"
#import "KFMStockBriefView.h"
#import "KFMKLineBriefView.h"
@interface ViewController ()<KFMSegmentMenuDelegate>
@property (nonatomic, strong)KFMSegmentMenu *segmentMenu;
@property (nonatomic, strong)KFMStockBriefView *stockBriefView;
@property (nonatomic, strong)KFMKLineBriefView *kLineBriefView;
@property (nonatomic, strong)NSMutableArray <UIViewController *>*controllerArray;
@property (nonatomic, strong)UIViewController *currentShowingChartVC;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUpView];
    [self addNoticficationObserve];
    [self addChartController];
    [self.segmentMenu setSelectedButtonWithIndex:0];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - noti 
// 长按分时线图，显示摘要信息
- (void)showLongPressView:(NSNotification *)notification {
    KFMTimeLineModel *model = notification.userInfo[ktimeLineEntity];
    self.stockBriefView.hidden = NO;
    [self.stockBriefView configureViewTimeLineEntity:model];
}
- (void)showUnLongPressView:(NSNotification *)notification {
    self.stockBriefView.hidden = YES;
}
- (void)showKLineChartLongPressView:(NSNotification *)notification {
    CGFloat perClose = [notification.userInfo[@"preClose"] floatValue];
    KFMKLineModel *klineModel = notification.userInfo[@"kLineEntity"];
    [self.kLineBriefView configureViewPreClose:perClose kLineModel:klineModel];
    self.kLineBriefView.hidden = NO;
}
- (void)showKLineChartUnLongPressView:(NSNotification *)notification {
    self.kLineBriefView.hidden = YES;
}
- (void)showLandScapeChartView:(NSNotification *)notification {
    KFMLandscapeViewController *vc = [[KFMLandscapeViewController alloc]init];
    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.viewindex = [notification.object integerValue];
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - KFMSegmentMenuDelegate
- (void)menuButtonDidClick:(NSInteger)index {
    if (_currentShowingChartVC) {
        [_currentShowingChartVC willMoveToParentViewController:nil];
        [_currentShowingChartVC.view removeFromSuperview];
        [_currentShowingChartVC removeFromParentViewController];
    }
    KFMChartViewController *selectedVC = (KFMChartViewController *)self.controllerArray[index];
    selectedVC.chartRect = CGRectMake(0, 0, XMGWidth, 300);
    selectedVC.view.frame = CGRectMake(0, CGRectGetMaxY(self.segmentMenu.frame), XMGWidth, 300);
    [self addChildViewController:selectedVC];
    if (selectedVC.view.superview == nil) {
        [self.view addSubview:selectedVC.view];
    }
    [selectedVC didMoveToParentViewController:self];
    _currentShowingChartVC = selectedVC;
    
}
#pragma mark - 
- (void)setUpView {
    _segmentMenu = [[KFMSegmentMenu alloc]initWithFrame:CGRectMake(0, 100, XMGWidth, 40)];
    _segmentMenu.menuTitleArray = @[@"分时", @"五日", @"日K", @"周K", @"月K"].mutableCopy;
    _segmentMenu.delegate = self;
    [self.view addSubview:_segmentMenu];
    
    _stockBriefView = [[KFMStockBriefView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_segmentMenu.frame), self.view.width, 40)];
    _stockBriefView.hidden = YES;
    [self.view addSubview:_stockBriefView];
    
    _kLineBriefView = [[KFMKLineBriefView alloc]initWithFrame:CGRectMake(0, CGRectGetMinY(_segmentMenu.frame), self.view.width, 40)];
    _kLineBriefView.hidden = YES;
    [self.view addSubview:_kLineBriefView];
}
- (void)addNoticficationObserve {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showLongPressView:) name:kTimeLineLongpress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showUnLongPressView:) name:kTimeLineUnLongpress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showKLineChartLongPressView:) name:kKLineChartLongPress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showKLineChartUnLongPressView:) name:kKLineChartUnLongPress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showLandScapeChartView:) name:kKLineUperChartDidTap object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showLandScapeChartView:) name:kTimeLineChartDidTap object:nil];
}
- (void)addChartController {
    // 分时线
    KFMChartViewController *timeViewcontroller = [[KFMChartViewController alloc]init];
    timeViewcontroller.chartType = KFMTimeLineForDay;
    [self.controllerArray addObject:timeViewcontroller];
    
    // 五日分时线
    KFMChartViewController *fiveDayTimeViewController = [[KFMChartViewController alloc]init];
    fiveDayTimeViewController.chartType = KFMTimeLineForFiveDay;
    [self.controllerArray addObject:fiveDayTimeViewController];
    
    // 日 K 线
    KFMChartViewController *kLineViewController = [[KFMChartViewController alloc]init];
    kLineViewController.chartType = KFMKLineForDay;
    [self.controllerArray addObject:kLineViewController];
    
    // 周 K 线
    KFMChartViewController *weeklyKLineViewController = [[KFMChartViewController alloc]init];
    weeklyKLineViewController.chartType = KFMKLineForWeek;
    [self.controllerArray addObject:weeklyKLineViewController];
    
    // 月 K 线
    KFMChartViewController *monthlyKLineViewController = [[KFMChartViewController alloc]init];
    monthlyKLineViewController.chartType = KFMKLineForMonth;
    [self.controllerArray addObject:monthlyKLineViewController];
}

#pragma mark - lazy
- (NSMutableArray<UIViewController *> *)controllerArray {
    if (!_controllerArray) {
        _controllerArray = [[NSMutableArray alloc]init];
    }
    return _controllerArray;
}
@end
