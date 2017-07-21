//
//  KFMKLineBriefView.m
//  KFMStockOC
//
//  Created by mac on 2017/7/21.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMKLineBriefView.h"

@interface KFMKLineBriefView ()
@property (weak, nonatomic) IBOutlet UILabel *open;
@property (weak, nonatomic) IBOutlet UILabel *high;
@property (weak, nonatomic) IBOutlet UILabel *volume;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *close;
@property (weak, nonatomic) IBOutlet UILabel *ratio;
@property (weak, nonatomic) IBOutlet UILabel *low;

@property (nonatomic, strong)UIView *view;

@end
@implementation KFMKLineBriefView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        {
            [self setupSubviews];
        }
    }
    return self;
}
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setupSubviews];
    }
    return self;
}


#pragma open
- (void)configureViewPreClose:(CGFloat)preClose kLineModel:(KFMKLineModel *)kLineModel {
    UIColor *riseColor = [UIColor redColor];
    UIColor *downColor = [UIColor kfm_colorWithHex:0x1dbf60];
    if (kLineModel.rate > 0) {
        self.close.textColor = riseColor;
        self.ratio.textColor = riseColor;
    } else {
        self.close.textColor = downColor;
        self.ratio.textColor = downColor;
    }
    
    if (preClose < kLineModel.open) {
        self.open.textColor = riseColor;
    } else {
        self.open.textColor = downColor;
    }
    
    if (preClose < kLineModel.high) {
        self.high.textColor = riseColor;
    } else {
        self.high.textColor = downColor;
    }
    
    if (preClose < kLineModel.low) {
        self.low.textColor = riseColor;
    } else {
        self.low.textColor = downColor;
    }
    
    self.open.text = [NSString toStringWithFormat:@".2" cfloat:kLineModel.open];
    self.close.text = [NSString toStringWithFormat:@".2" cfloat:kLineModel.close];
    self.high.text = [NSString toStringWithFormat:@".2" cfloat:kLineModel.high];
    self.low.text = [NSString toStringWithFormat:@".2" cfloat:kLineModel.low];
    self.volume.text = [NSString stringWithFormat:@"%@万",[NSString toStringWithFormat:@".2" cfloat:kLineModel.volume / 10000]];
    self.ratio.text = [NSString toPercentFormatCfloat:kLineModel.rate];
    self.time.text = [[kLineModel.date toDateWithFormat:@"yyyyMMddHHmmss"] toSringWithFormat:@"yyyy-MM-dd"];
}
#pragma mark - UI
- (void)layoutSubviews {
    self.view.frame = self.bounds;
}
- (void)setupSubviews {
    self.view = [self instanceViewFromNib];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.view];
}
- (UIView *)instanceViewFromNib {
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self.class) bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}
@end
