//
//  KFMRef.h
//  CustomRefOC
//
//  Created by mac on 2017/7/2.
//  Copyright © 2017年 mac. All rights reserved.
// 侧拉

#import <UIKit/UIKit.h>

/**
 刷新状态
 */
typedef NS_ENUM(NSUInteger,KFMRefreshState)
{
    KFMRefStateNormal = 0,
    KFMRefStatePulling = 1,
    KFMRefStateWillRefresh = 2,
};
@interface KFMRef : UIControl

- (void)beginRefreshing;
- (void)endRefreshing;
@end
