//
//  KFMStockBriefView.m
//  KFMStockOC
//
//  Created by mac on 2017/7/20.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMStockBriefView.h"

@interface KFMStockBriefView ()
@property (weak, nonatomic) IBOutlet UILabel *timelabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *ratioLabel;
@property (weak, nonatomic) IBOutlet UILabel *volumeLabel;

@property (nonatomic, strong)UIView *view;
@end

@implementation KFMStockBriefView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
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
- (void)layoutSubviews {
    self.view.frame = self.bounds;
}
#pragma mark - open
- (void)configureViewTimeLineEntity:(KFMTimeLineModel *)timeLineEntity {
    UIColor *labelColor;
    if (timeLineEntity.rate < 0 ) {
        labelColor = [UIColor kfm_colorWithHex:0x1dbf60];
    } else if (timeLineEntity.rate > 0) {
        labelColor = [UIColor redColor];
    } else {
        labelColor = [UIColor grayColor];
    }
    
    self.priceLabel.textColor = labelColor;
    self.ratioLabel.textColor = labelColor;
    
    self.priceLabel.text = [NSString toStringWithFormat:@".2" cfloat:timeLineEntity.price];
    self.ratioLabel.text =  [NSString toPercentFormatCfloat:timeLineEntity.rate * 100];
    self.timelabel.text = timeLineEntity.time;
    self.volumeLabel.text = [NSString toStringWithFormat:@".2" cfloat:timeLineEntity.volume];
}
#pragma mark - UI
- (void)setupSubviews {
    self.view = [self instanceViewFromNib];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
   
    [self addSubview:self.view];
}
- (UIView *)instanceViewFromNib {
    UINib *nib = [UINib nibWithNibName:@"KFMStockBriefView" bundle:nil];
    return [nib instantiateWithOwner:self options:nil].firstObject;
}
@end
