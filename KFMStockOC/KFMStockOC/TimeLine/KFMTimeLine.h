//
//  KFMTimeLine.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  分时线

#import <UIKit/UIKit.h>
#import "KFMTimeLineModel.h"
@interface KFMTimeLine : UIView

@property (nonatomic, assign)BOOL isLandscapeMode;

- (instancetype)initWithFrame:(CGRect)frame isFiveDay:(BOOL)isFiveDay;
- (void)configDataT:(NSMutableArray <KFMTimeLineModel *>*)dataT;
@end
