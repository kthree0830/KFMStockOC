//
//  KFMAcView.h
//  CustomRefOC
//
//  Created by mac on 2017/7/2.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFMRef.h"
@interface KFMAcView : UIView
@property (nonatomic, assign) KFMRefreshState state;
+(instancetype)refreshView;
@end
