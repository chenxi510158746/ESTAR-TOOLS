//
//  VCBase.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/14.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleModel.h"
#import "SVProgressHUD.h"
#import "SCLAlertView.h"
#import "ConstantConfig.h"

/**
 *ViewController基类新建的ViewControll统一继承于此类
 */
@interface VCBase : UIViewController<UITextViewDelegate, UITextFieldDelegate>
{
    NSMutableString *_oldTextStr;
    
    NSUInteger _lastLocation;
    
    SCLAlertView *_alertView;
    
    NSString *_netName;
    
    UITextField *_netPWTextField;
    
    NSMutableString *_networkStr;
}

//获取屏幕尺寸
-(CGRect)getScreenSize;

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color;

//WiFi或热点输入显示
- (void) showAlertWithTextFiledStr:(NSString *) textFiledStr andSubTitle:(NSString *) subTitle andNetType:(NSInteger) netType;

//WiFi、热点引导设置
- (void) showSetting;

/**
 发送信息接口

 @param type 信息类型
 @param content 信息内容
 */
- (void) sendDataWithType:(NSString *)type andContent:(NSString *) content;

/**
 获取蓝牙对象

 @return 返回蓝牙控制对象
 */
- (BleModel *) getBleModel;

/**
 显示wifi/ap配置对话框
 */
-(void) showNetworkConfigDialog;

/**
 获取wifi名称

 @return wifi名称
 */
- (NSString *) getWifiName;

//判断是否开启热点
- (BOOL) isHotSpot;

-(void) inputTextShow;

@end
