//
//  KFMKLineView.h
//  KFMStockOC
//
//  Created by mac on 2017/7/19.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KFMKLineView : UIView
@property (nonatomic, assign)BOOL isLandscapeMode;
- (instancetype)initWithFrame:(CGRect)frame kLineType:(KFMChartType)kLineType;
@end
