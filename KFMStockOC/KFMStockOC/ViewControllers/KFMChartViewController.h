//
//  KFMChartViewController.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  子控制器

#import <UIKit/UIKit.h>

@interface KFMChartViewController : UIViewController
@property (nonatomic, assign)KFMChartType chartType;
@property (nonatomic, assign)CGRect chartRect;
@property (nonatomic, assign)BOOL isLandscapeMode;

@end
