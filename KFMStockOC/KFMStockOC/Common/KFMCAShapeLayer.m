//
//  KFMCAShapeLayer.m
//  KFMStockOC
//
//  Created by mac on 2017/7/18.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMCAShapeLayer.h"

@implementation KFMCAShapeLayer
// 关闭 CAShapeLayer 的隐式动画，避免滑动时候或者十字线出现时有残影的现象(实际上是因为 Layer 的 position 属性变化而产生的隐式动画)
- (id<CAAction>)actionForKey:(NSString *)event {
    return nil;
}
@end
