//
//  AppItemEmptyView.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/25.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "AppItemEmptyView.h"

@implementation AppItemEmptyView

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
    
}

-(void)initView{
    
    UIButton* appItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 100, 50)];
    
    appItemBtn.titleLabel.text = @"appItemBtn";
    
    appItemBtn.backgroundColor = [UIColor yellowColor];
    
    [self addSubview:appItemBtn];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    
}

@end
