//
//  KFMChartViewController.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMChartViewController.h"
#import "KFMTimeLine.h"
#import "KFMKLineView.h"
@interface KFMChartViewController ()
@property (nonatomic, strong)KFMTimeLine *timeLineView;
@end

@implementation KFMChartViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        _chartRect = CGRectZero;
        _chartType = KFMTimeLineForDay;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupViewController];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)setupViewController {
    KFMStockBasicInfoModel *stockBasicInfo = [KFMStockBasicInfoModel getStockBasicInfoModel:[self getJsonDataFormFie:@"SZ300033"]];
    switch (_chartType) {
        case KFMTimeLineForDay:
        {
            self.timeLineView = [[KFMTimeLine alloc]initWithFrame:self.chartRect isFiveDay:NO
                                 ];
            NSArray *modelArray = [KFMTimeLineModel getTimeLineModelArrayWithDic:[self getJsonDataFormFie:@"timeLineForDay"] type:self.chartType basicInfo:stockBasicInfo];
            [self.timeLineView configDataT:modelArray.mutableCopy];
            self.timeLineView.userInteractionEnabled = YES;
            self.timeLineView.tag = self.chartType;
            self.timeLineView.isLandscapeMode = self.isLandscapeMode;
            [self.view addSubview:self.timeLineView];
            break;
        }
        case KFMTimeLineForFiveDay:
        {
            KFMTimeLine *stockChartView = [[KFMTimeLine alloc]initWithFrame:self.chartRect isFiveDay:YES];
            NSArray *modelArray = [KFMTimeLineModel getTimeLineModelArrayWithDic:[self getJsonDataFormFie:@"timeLineForFiveday"] type:self.chartType basicInfo:stockBasicInfo];
            [stockChartView configDataT:modelArray.mutableCopy];
            stockChartView.userInteractionEnabled = YES;
            stockChartView.tag = self.chartType;
            stockChartView.isLandscapeMode = self.isLandscapeMode;
            [self.view addSubview:stockChartView];
            break;
        }
        case KFMKLineForDay:
        {
            KFMKLineView *stockChartView = [[KFMKLineView alloc]initWithFrame:self.chartRect kLineType:KFMKLineForDay];
            stockChartView.tag = self.chartType;
            stockChartView.isLandscapeMode = self.isLandscapeMode;
            [self.view addSubview:stockChartView];
            break;
        }
        case KFMKLineForWeek:
        {
            KFMKLineView *stockChartView = [[KFMKLineView alloc]initWithFrame:self.chartRect kLineType:KFMKLineForWeek];
            stockChartView.tag = self.chartType;
            stockChartView.isLandscapeMode = self.isLandscapeMode;
            [self.view addSubview:stockChartView];
            break;
        }
        case KFMKLineForMonth:
        {
            KFMKLineView *stockChartView = [[KFMKLineView alloc]initWithFrame:self.chartRect kLineType:KFMKLineForMonth];
            stockChartView.tag = self.chartType;
            stockChartView.isLandscapeMode = self.isLandscapeMode;
            [self.view addSubview:stockChartView];
            break;
        }
        default:
            break;
    }
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
