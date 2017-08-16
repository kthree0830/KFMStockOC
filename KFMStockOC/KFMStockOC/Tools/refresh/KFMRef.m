//
//  KFMRef.m
//  CustomRefOC
//
//  Created by mac on 2017/7/2.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMRef.h"
#import "KFMAcView.h"
#define KFMRefOffset 68
@interface KFMRef ()
@property (nonatomic, weak)UIScrollView *scrollView;
@property (nonatomic, strong)KFMAcView *refreshView;
@end

@implementation KFMRef

- (instancetype)init
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        [self setupUI];
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        
    }
    return self;
}
#pragma mark - 生命
-(void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    
    if ([newSuperview isKindOfClass:[UIScrollView class]]) {
        _scrollView = (UIScrollView *)newSuperview;
        
        [_scrollView addObserver:self forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
    }else {
        return;
    }
    
    
}
-(void)removeFromSuperview {
    
    [self.superview removeObserver:self forKeyPath:@"contentOffset"];
    
    [super removeFromSuperview];
}
#pragma mark - VIP
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (_scrollView) {
        CGFloat height = -(_scrollView.contentInset.left + _scrollView.contentOffset.x);
        
        if (height < 0) {
            return;
        }
        
        self.frame = CGRectMake(-height,0,height,_scrollView.bounds.size.height);
        
        if (_scrollView.isDragging) {
            if (height > KFMRefOffset && self.refreshView.state == 0) {
                self.refreshView.state = 1;
            }else if (height <= KFMRefOffset && self.refreshView.state == 1) {
                self.refreshView.state = 0;
            }
        } else {
            if (self.refreshView.state == 1) {
                //给父视图发消息，开始执行刷新
                [self sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    
}

#pragma mark - open
- (void)beginRefreshing {
    if (_scrollView) {

        if (self.refreshView.state == 2) {
            return;
        }
        self.refreshView.state = 2;

        // 停留显示
        UIEdgeInsets insets = _scrollView.contentInset;
        insets.left += KFMRefOffset;
        _scrollView.contentInset = insets;
        _scrollView.contentOffset = CGPointMake(-KFMRefOffset, 0);
        
    }
}
- (void)endRefreshing {
    if (self.refreshView.state == 2) {
        self.refreshView.state = 0;
    }
    
    if (_scrollView) {
        UIEdgeInsets insets = _scrollView.contentInset;
        insets.left -= KFMRefOffset;
        _scrollView.contentInset = insets;
//        _scrollView.contentOffset = CGPointMake(0, 0);
    }
}

#pragma mark - UI
- (void)setupUI {
    self.backgroundColor = self.superview.backgroundColor;
    [self addSubview:self.refreshView];
    
    self.refreshView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSLayoutConstraint * conRight = [NSLayoutConstraint constraintWithItem:self.refreshView
                                                                   attribute:NSLayoutAttributeRight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeRight
                                                                  multiplier:1.0
                                                                    constant:-20];

    NSLayoutConstraint * conCenterY = [NSLayoutConstraint constraintWithItem:self.refreshView
                                                                attribute:NSLayoutAttributeCenterY
                                                                relatedBy:NSLayoutRelationEqual
                                                                   toItem:self
                                                                attribute:NSLayoutAttributeCenterY
                                                               multiplier:1.0
                                                                 constant:0];

    NSLayoutConstraint * conWidth = [NSLayoutConstraint constraintWithItem:self.refreshView
                                                                 attribute:NSLayoutAttributeWidth
                                                                 relatedBy:NSLayoutRelationEqual
                                                                    toItem:nil
                                                                 attribute:NSLayoutAttributeNotAnAttribute
                                                                multiplier:1.0
                                                                  constant:self.refreshView.bounds.size.height];
    NSLayoutConstraint * conHeight = [NSLayoutConstraint constraintWithItem:self.refreshView
                                                                  attribute:NSLayoutAttributeHeight
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil
                                                                  attribute:NSLayoutAttributeNotAnAttribute
                                                                 multiplier:1.0
                                                                   constant:self.refreshView.bounds.size.height];
    
    [self addConstraints:@[conRight,conCenterY,conWidth,conHeight]];

}
-(KFMAcView *)refreshView {
    if (!_refreshView) {
        _refreshView = [KFMAcView refreshView];
    }
    return _refreshView;
}

@end
