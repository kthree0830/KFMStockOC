//
//  KFMSegmentMenu.m
//  KFMStockOC
//
//  Created by mac on 2017/7/17.
//  Copyright © 2017年 mac. All rights reserved.
//
#define indicatorHeight 2
#import "KFMSegmentMenu.h"

@interface KFMSegmentMenu ()
@property (nonatomic, strong)UIView *bottomIndicator;
@property (nonatomic, strong)UIView *bottomLine;//下划线
@property (nonatomic, strong)NSMutableArray <UIButton *>*menuButtonArray;
@property (nonatomic, strong)UIButton *selectedButton;
@end


@implementation KFMSegmentMenu
{
    CGFloat _buttonWidth;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _buttonWidth = 0;
        self.backgroundColor = kColorWhite;
        _bottomIndicator = [[UIView alloc]init];
        _bottomIndicator.backgroundColor = [UIColor kfm_colorWithHex:0x1782d0];
        _bottomLine = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height  - 0.5, frame.size.width, 0.5)];
        _bottomLine.backgroundColor = [UIColor kfm_colorWithHex:0xe4e4e4];
        [self addSubview:_bottomIndicator];
        [self addSubview:_bottomLine];
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
#pragma mark - events 
- (void)menuButtonDidClick:(UIButton *)button {
    [self setSelectedButtonWithIndex:button.tag];
}
- (void)setSelectedButtonWithIndex:(NSInteger)index {
    if (self.menuButtonArray.count > 0) {
        UIButton *newSelectButton = self.menuButtonArray[index];
        if (newSelectButton == self.selectedButton) {
            return;
        }else {
            [self.selectedButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [newSelectButton setTitleColor:[UIColor kfm_colorWithHex:0x1782d0] forState:UIControlStateNormal];
            [UIView animateWithDuration:0.3 animations:^{
                self.bottomIndicator.x = _buttonWidth * newSelectButton.tag;
            } completion:^(BOOL finished) {
                self.selectedButton = newSelectButton;
            }];
            if (self.delegate && [self.delegate respondsToSelector:@selector(menuButtonDidClick:)]) {
                [self.delegate menuButtonDidClick:index];
            }
        }
    }
}
- (void)setMenuTitleArray:(NSMutableArray<NSString *> *)menuTitleArray {
    _menuTitleArray = menuTitleArray;
    
    [self.menuButtonArray enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    [self.menuButtonArray removeAllObjects];
    _buttonWidth = self.width / menuTitleArray.count;
    __block CGFloat x = 0;
    [menuTitleArray enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:obj forState:UIControlStateNormal];
        button.titleLabel.font = Font(16);
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(menuButtonDidClick:) forControlEvents:UIControlEventTouchUpInside];
        button.tag = idx;
        button.frame = CGRectMake(x, 0, _buttonWidth, self.height);
        x += _buttonWidth;
        [self addSubview:button];
        [self.menuButtonArray addObject:button];
    }];
    _bottomIndicator.frame = CGRectMake(0, self.height - indicatorHeight, _buttonWidth, indicatorHeight);
    
}
#pragma mark - lazy
- (NSMutableArray<UIButton *> *)menuButtonArray {
    if (!_menuButtonArray) {
        _menuButtonArray = [[NSMutableArray alloc]init];
    }
    return _menuButtonArray;
}
@end
