//
//  KFMLandscapeViewController.m
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMLandscapeViewController.h"
#import "KFMSegmentMenu.h"
#import "KFMChartViewController.h"
#import "KFMStockBriefView.h"
#import "KFMKLineBriefView.h"
@interface KFMLandscapeViewController ()<KFMSegmentMenuDelegate>
@property (nonatomic, strong)KFMSegmentMenu *segmentMenu;
@property (nonatomic, strong)UIView *viewForChart;
@property (nonatomic, strong)KFMStockBriefView *stockBriefView;
@property (nonatomic, strong)KFMKLineBriefView *kLineBriefView;
@property (nonatomic, weak)UIViewController *currentShowingChartVC;
@property (nonatomic, strong)NSMutableArray <UIViewController *>*controllerArray;


@end

@implementation KFMLandscapeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = kColorWhite;
    [self addNotificationObserve];
    [self addChartViewController];
    [self setUpView];
    [self.segmentMenu setSelectedButtonWithIndex:self.viewindex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - KFMSegmentMenuDelegate
- (void)menuButtonDidClick:(NSInteger)index {
    if (_currentShowingChartVC) {
        [_currentShowingChartVC willMoveToParentViewController:nil];
        [_currentShowingChartVC.view removeFromSuperview];
        [_currentShowingChartVC removeFromParentViewController];
    }
    KFMChartViewController *selectedVC = (KFMChartViewController *)self.controllerArray[index];
    [self addChildViewController:selectedVC];
    selectedVC.chartRect = _viewForChart.bounds;
    selectedVC.view.frame = _viewForChart.bounds;
    
    if (selectedVC.view.superview == nil) {
        [self.viewForChart addSubview:selectedVC.view];
    }
    [selectedVC didMoveToParentViewController:self];
    _currentShowingChartVC = selectedVC;
    
}
#pragma mark - events
- (void)close:(UIButton *)sender {
    self.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - noti
// 长按分时线图，显示摘要信息
- (void)showLongPressView:(NSNotification *)notification {
    self.stockBriefView.hidden = NO;
    [self.stockBriefView configureViewTimeLineEntity:notification.userInfo[ktimeLineEntity]];
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

#pragma mark - 
- (void)addNotificationObserve {
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showLongPressView:) name:kTimeLineLongpress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showUnLongPressView:) name:kTimeLineUnLongpress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showKLineChartLongPressView:) name:kKLineChartLongPress object:nil];
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(showKLineChartUnLongPressView:) name:kKLineChartUnLongPress object:nil];
}
- (void)addChartViewController {
    KFMChartViewController *timeViewController = [[KFMChartViewController alloc]init];
    timeViewController.chartType = KFMTimeLineForDay;
    timeViewController.isLandscapeMode = YES;
    [self.controllerArray addObject:timeViewController];
    
    KFMChartViewController *fiveDayTimeViewController = [[KFMChartViewController alloc]init];
    fiveDayTimeViewController.chartType = KFMTimeLineForFiveDay;
    fiveDayTimeViewController.isLandscapeMode = YES;
    [self.controllerArray addObject:fiveDayTimeViewController];
    
    KFMChartViewController *kLineViewController = [[KFMChartViewController alloc]init];
    kLineViewController.chartType = KFMKLineForDay;
    kLineViewController.isLandscapeMode = YES;
    [self.controllerArray addObject:kLineViewController];
    
    KFMChartViewController *weeklyKLineViewController = [[KFMChartViewController alloc]init];
    weeklyKLineViewController.chartType = KFMKLineForWeek;
    weeklyKLineViewController.isLandscapeMode = YES;
    [self.controllerArray addObject:weeklyKLineViewController];
    
    KFMChartViewController *monthlyKLineViewController = [[KFMChartViewController alloc]init];
    monthlyKLineViewController.chartType = KFMKLineForMonth;
    monthlyKLineViewController.isLandscapeMode = YES;
    [self.controllerArray addObject:monthlyKLineViewController];
}
- (void)setUpView {
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [backBtn setTitle:@"退出" forState:UIControlStateNormal];
    [backBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [backBtn addTarget: self action:@selector(close:) forControlEvents:UIControlEventTouchUpInside];
    backBtn.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:backBtn];
    NSLayoutConstraint *t = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
    NSLayoutConstraint *r = [NSLayoutConstraint constraintWithItem:backBtn attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:-20];
    [self.view addConstraints:@[t,r]];
    
    
    _segmentMenu = [[KFMSegmentMenu alloc]initWithFrame:CGRectMake(0, 30, XMGHeight, 40)];
    _segmentMenu.menuTitleArray = @[@"分时", @"五日", @"日K", @"周K", @"月K"].mutableCopy;
    _segmentMenu.delegate = self;
    [self.view addSubview:_segmentMenu];
    
    _viewForChart = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentMenu.frame), XMGHeight, XMGWidth - 80)];
    [self.view addSubview:_viewForChart];
    
    _stockBriefView = [[KFMStockBriefView alloc]initWithFrame:CGRectMake(0, 30, XMGHeight, 40)];
    _stockBriefView.hidden = YES;
    [self.view addSubview:_stockBriefView];
    
    _kLineBriefView = [[KFMKLineBriefView alloc]initWithFrame:CGRectMake(0, 30, XMGHeight, 40)];
    _kLineBriefView.hidden = YES;
    [self.view addSubview:_kLineBriefView];
}
#pragma mark - lazy
- (NSMutableArray<UIViewController *> *)controllerArray {
    if (!_controllerArray) {
        _controllerArray = [[NSMutableArray alloc]init];
    }
    return _controllerArray;
}

#pragma mark - setting
- (BOOL)shouldAutorotate {
    return NO;
}
- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationLandscapeRight;
}
@end
