//
//  KFMSegmentMenu.h
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//  分栏选择器

#import <UIKit/UIKit.h>

@protocol KFMSegmentMenuDelegate <NSObject>

- (void)menuButtonDidClick:(NSInteger)index;

@end

@interface KFMSegmentMenu : UIView

/**
 文字数组
 */
@property (nonatomic, strong)NSMutableArray <NSString *>*menuTitleArray;
@property (nonatomic, weak)id<KFMSegmentMenuDelegate>delegate;

- (void)setSelectedButtonWithIndex:(NSInteger)index;
@end
