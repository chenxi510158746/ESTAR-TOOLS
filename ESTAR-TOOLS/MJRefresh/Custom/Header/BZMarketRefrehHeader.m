//
//  BZMarketRefrehHeader.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/14.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "BZMarketRefrehHeader.h"
#import "Masonry.h"

@implementation BZMarketRefrehHeader

#pragma mark - 实现父类的方法
- (void)prepare
{
    [super prepare];
    [self hiddenSuperEelements];
    [self initHeadGifView];
}

-(void)hiddenSuperEelements{
    [self.lastUpdatedTimeLabel setHidden:YES];
    [self.stateLabel setHidden:YES];
}

-(void)initHeadGifView{

    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"market_loading" ofType:@"gif"];
    NSData *gif = [NSData dataWithContentsOfFile:filePath];
    UIWebView *webViewBG = [[UIWebView alloc] init];
    
    [webViewBG loadData:gif MIMEType:@"image/gif" textEncodingName:nil baseURL:nil];
    webViewBG.scalesPageToFit = YES;
    webViewBG.userInteractionEnabled = NO;
    [self addSubview:webViewBG];
    self.mj_h = 100.0;
    
    [webViewBG mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.centerX.equalTo(self);
        make.size.mas_equalTo(CGSizeMake(64.0, 80.0));
    }];
}

@end
