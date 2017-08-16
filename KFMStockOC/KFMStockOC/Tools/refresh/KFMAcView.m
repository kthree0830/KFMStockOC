//
//  KFMAcView.m
//  CustomRefOC
//
//  Created by mac on 2017/7/2.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "KFMAcView.h"

@interface KFMAcView ()
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation KFMAcView

+ (instancetype)refreshView {
    UINib * nib = [UINib nibWithNibName:@"KFMAcView" bundle:nil];
    return [nib instantiateWithOwner:nil options:nil].firstObject;

}

-(void)setState:(KFMRefreshState)state {
    _state = state;
    switch (state) {
        case KFMRefStateNormal:
            ({
                [_indicator stopAnimating];
                _indicator.hidden = NO;
            });
            break;
        case KFMRefStatePulling:
            ({
            
            });
            break;
        case KFMRefStateWillRefresh:
            ({
                _indicator.hidden = NO;
                [_indicator startAnimating];
            });
            break;
        default:
            break;
    }
}
@end
