//
//  VCBase.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/14.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "VCBase.h"
#import "ConstantConfig.h"
#import "NSBundle+MJRefresh.h"
#import "MJRefreshConst.h"
#import <SystemConfiguration/CaptiveNetwork.h>
#import <ifaddrs.h>
#import <arpa/inet.h>

extern NSInteger networkStatus;

@implementation VCBase

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _networkStr = [[NSMutableString alloc] init];
}

-(CGRect)getScreenSize{
    
    return [UIScreen mainScreen ].bounds;
}

//设置状态栏颜色
- (void)setStatusBarBackgroundColor:(UIColor *)color {
    
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    if ([statusBar respondsToSelector:@selector(setBackgroundColor:)]) {
        statusBar.backgroundColor = color;
    }
}
//设置状态栏字体为白色
- (UIStatusBarStyle)preferredStatusBarStyle{
    return UIStatusBarStyleLightContent;
}

//发送蓝牙指令
- (void) sendDataWithType:(NSString *)type andContent:(NSString *) content
{
    BleModel *bleModel = [self getBleModel];
    if (bleModel == nil) {
        return;
    }
    
    if ([type isEqualToString:typeWifi]) {
        [_networkStr setString:content];
    }
    
    NSString *dataStr = [[NSString alloc] initWithFormat:@"{\"type\":%@,\"content\":\"%@\"}", type, content];
    
    [bleModel.mPeripheral writeValue:[dataStr dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:bleModel.mCharacterWrite type:CBCharacteristicWriteWithResponse];
}

//获取蓝牙连接模型
- (BleModel *) getBleModel
{
    BleModel *bleModel = [BleModel sharedSingleton];
    if (bleModel.mPeripheral == nil || bleModel.mCharacterWrite == nil) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_DISCONNECT", nil)];
        [SVProgressHUD dismissWithDelay:1];
        return nil;
    }
    return bleModel;
}

//WiFi或热点
-(void) showNetworkConfigDialog{
    NSString *wifiName = [self getWifiName];
    if (wifiName != nil) {
        _netName = wifiName;
        [self showAlertWithTextFiledStr:NSLocalizedString(@"OPERATION_WIFI_TEXT_TITLE", nil) andSubTitle:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"OPERATION_WIFI_TEXT_SUBTITLE", nil), wifiName] andNetType:2];
    } else if ([self isHotSpot] == YES) {
        NSString *iPhoneName = [UIDevice currentDevice].name;
        _netName = iPhoneName;
        [self showAlertWithTextFiledStr:NSLocalizedString(@"OPERATION_HOTSPOT_TEXT_TITLE", nil) andSubTitle:NSLocalizedString(@"OPERATION_HOTSPOT_TEXT_SUBTITLE", nil) andNetType:1];
    } else {
        [self showSetting];
    }
}

//WiFi或热点-输入框显示
- (void) showAlertWithTextFiledStr:(NSString *) textFiledStr andSubTitle:(NSString *) subTitle andNetType:(NSInteger) netType
{
    _alertView = [[SCLAlertView alloc] initWithNewWindowWidth:300.0f];
    _alertView.shouldDismissOnTapOutside = YES;
    _alertView.horizontalButtons = true;
    _alertView.hideAnimationType = SCLAlertViewHideAnimationSlideOutToTop;
    _alertView.showAnimationType =  SCLAlertViewShowAnimationSlideInFromTop;
    _alertView.backgroundType = SCLAlertViewBackgroundBlur;
    _alertView.customViewColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    _alertView.iconTintColor = [UIColor orangeColor];
    
    _netPWTextField = [_alertView addTextField:textFiledStr];
    _netPWTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    _netPWTextField.spellCheckingType = UITextSpellCheckingTypeNo;
    _netPWTextField.frame = CGRectMake(0, 0, 120, 35);
    
    //加入密码隐藏、显示按钮
    UIView *rightVeiw = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 35, 20)];
    UIButton *rightImageV = [[UIButton alloc] init];
    _netPWTextField.secureTextEntry = YES;
    [rightImageV setBackgroundImage:[UIImage imageNamed:@"not-see"] forState:UIControlStateNormal];
    rightImageV.frame = CGRectMake(0, 0, 28, 18);
    [rightVeiw addSubview:rightImageV];
    _netPWTextField.rightView = rightVeiw;
    _netPWTextField.rightViewMode = UITextFieldViewModeAlways;
    [rightImageV addTarget:self action:@selector(btnShowHidePW:) forControlEvents:UIControlEventTouchDown];
    
    _netPWTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    _netPWTextField.returnKeyType = UIReturnKeySend;
    _netPWTextField.delegate = self;
    
    __block NSString *netName = _netName;
    __block VCBase *blockSelf = self;
    __block UITextField *textField = _netPWTextField;
    
    if (netType == 1) {
        [_alertView addButton:NSLocalizedString(@"OPERATION_HOTSPOT_BTN", nil) actionBlock:^(void) {
            NSURL *hotspotUrl = [NSURL URLWithString:@"App-Prefs:root=INTERNET_TETHERING"];
            if ([[UIApplication sharedApplication]canOpenURL:hotspotUrl]) {
                
                if ([UIDevice currentDevice].systemVersion.floatValue < 10.0f) {
                    [[UIApplication sharedApplication] openURL:hotspotUrl];
                } else {
                    [[UIApplication sharedApplication] openURL:hotspotUrl options:@{} completionHandler:^(BOOL success) {
                        
                    }];
                }
                //监听设置返回
                [[NSNotificationCenter defaultCenter] addObserver:blockSelf selector:@selector(networkSetBack) name:@"networkSetBack" object:nil];
            } else {
                [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"OPERATION_HOTSPOT_SET", nil)];
            }
            
        }];
    }
    
    [_alertView addButton:NSLocalizedString(@"OPERATION_SEND_PW", nil) actionBlock:^(void) {
        NSInteger pwType = 3;
        if ([textField.text isEqualToString:@""]) {
            pwType = 1;
        }
        NSString *content = [[NSString alloc] initWithFormat:@"%@:%@:%ld",netName,textField.text, pwType];
        [blockSelf sendDataWithType:typeWifi andContent:content];
        
        //消息回馈监听
        [[NSNotificationCenter defaultCenter] addObserver:blockSelf selector:@selector(netFeedbackNotice:) name:[NSString stringWithFormat:@"%d",CB2Client_WIFI_PWD_TYPE] object:nil];
        if (netType == 1) {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"OPERATION_HOTSPOT_SEND_SUCCESS", nil)];
        } else {
            [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"OPERATION_WIFI_SEND_SUCCESS", nil)];
        }
    }];
    
    [_alertView alertShowAnimationIsCompleted:^{
        NSString *networkInfo = [[NSUserDefaults standardUserDefaults] objectForKey:kNetworkInfo];
        if (networkInfo != nil) {
            NSArray *networkArr = [networkInfo componentsSeparatedByString:@":"];
            if (networkArr.count > 0) {
                NSString *netName = [networkArr objectAtIndex:0];
                if ([netName isEqualToString:_netName]) {
                    _netPWTextField.text = [networkArr objectAtIndex:1];
                    return;
                }
            }
        }
        if ([_netPWTextField canBecomeFirstResponder]) {
            [_netPWTextField becomeFirstResponder];
        }
    }];
    
    [_alertView showEdit:self title:NSLocalizedString(@"OPERATION_NETWORK_TEXT_TITLE", nil) subTitle:subTitle closeButtonTitle:nil duration:0.0f];
}


//WiFi或热点-网络连接回馈通知
- (void) netFeedbackNotice:(NSNotification *)notification
{
    NSDictionary *dataDic = notification.userInfo;
    NSString *content = [dataDic objectForKey:@"content"];
    if ([content isEqualToString:@"Y"]) {
        
        [[NSUserDefaults standardUserDefaults] setObject:_networkStr forKey:kNetworkInfo];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:[NSString stringWithFormat:@"%d",CB2Client_WIFI_PWD_TYPE] object:nil];
        
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"OPERATION_DEVICE_NETWORK_SUCCESS", nil)];
    } else {
        NSString *keyStr = [NSString stringWithFormat:@"%@", content];
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(keyStr, nil)];
    }
}

//WiFi或热点-引导跳转系统设置，返回应用通知监听
- (void) networkSetBack
{
    [self showNetworkConfigDialog];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"networkSetBack" object:nil];
}

//WiFi或热点-密码切换明文、暗文显示
-(void)btnShowHidePW:(UIButton *)btn{
    NSString *text = _netPWTextField.text;
    _netPWTextField.text = @" ";
    _netPWTextField.text = text;
    btn.selected = !btn.selected;
    if (!btn.selected) {
        [btn setBackgroundImage:[UIImage imageNamed:@"not-see"] forState:UIControlStateNormal];
        _netPWTextField.secureTextEntry = YES;
    }else{
        [btn setBackgroundImage:[UIImage imageNamed:@"see"] forState:UIControlStateSelected];
        _netPWTextField.secureTextEntry = NO;
    }
}

//WiFi或热点-键盘Return键处理
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger pwType = 3;
    if ([textField.text isEqualToString:@""]) {
        pwType = 1;
    }
    NSString *content = [[NSString alloc] initWithFormat:@"%@:%@:%ld",_netName,textField.text,pwType];
    [self sendDataWithType:typeWifi andContent:content];
    
    //消息回馈监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(netFeedbackNotice:) name:[NSString stringWithFormat:@"%d",CB2Client_WIFI_PWD_TYPE] object:nil];
    
    if ([self getWifiName] != nil) {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"OPERATION_WIFI_SEND_SUCCESS", nil)];
    } else {
        [SVProgressHUD showSuccessWithStatus:NSLocalizedString(@"OPERATION_HOTSPOT_SEND_SUCCESS", nil)];
    }
    
    [_alertView hideView];
    return YES;
}

//WiFi或热点-引导设置
- (void) showSetting
{
    SCLAlertView *alert = [[SCLAlertView alloc] initWithNewWindowWidth:300.0f];
    alert.shouldDismissOnTapOutside = YES;
    alert.horizontalButtons = true;
    alert.hideAnimationType = SCLAlertViewHideAnimationSlideOutToTop;
    alert.showAnimationType =  SCLAlertViewShowAnimationSlideInFromTop;
    alert.backgroundType = SCLAlertViewBackgroundBlur;
    alert.customViewColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    alert.iconTintColor = [UIColor orangeColor];
    
    __block VCBase *blockSelf = self;
    
    [alert addButton:NSLocalizedString(@"OPERATION_OPEN_WIFI_BTN", nil) actionBlock:^(void) {
        NSURL *wifiUrl = [NSURL URLWithString:@"App-Prefs:root=WIFI"];
        if ([[UIApplication sharedApplication]canOpenURL:wifiUrl]) {
            
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0f) {
                [[UIApplication sharedApplication] openURL:wifiUrl];
            } else {
                [[UIApplication sharedApplication] openURL:wifiUrl options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
            //监听设置返回
            [[NSNotificationCenter defaultCenter] addObserver:blockSelf selector:@selector(networkSetBack) name:@"networkSetBack" object:nil];
        } else {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"OPERATION_WIFI_SET_MSG", nil)];
        }
    }];
    
    [alert addButton:NSLocalizedString(@"OPERATION_OPEN_HOTSPOT_BTN", nil) actionBlock:^(void) {
        NSURL *hotspotUrl = [NSURL URLWithString:@"App-Prefs:root=MOBILE_DATA_SETTINGS_ID"];
        if ([[UIApplication sharedApplication]canOpenURL:hotspotUrl]) {
            
            if ([UIDevice currentDevice].systemVersion.floatValue < 10.0f) {
                [[UIApplication sharedApplication] openURL:hotspotUrl];
            } else {
                [[UIApplication sharedApplication] openURL:hotspotUrl options:@{} completionHandler:^(BOOL success) {
                    
                }];
            }
            //监听设置返回
            [[NSNotificationCenter defaultCenter] addObserver:blockSelf selector:@selector(networkSetBack) name:@"networkSetBack" object:nil];
        } else {
            [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"OPERATION_HOTSPOT_SET", nil)];
        }
        
    }];
    
    [alert showNotice:self title:NSLocalizedString(@"OPERATION_NETWORK_TEXT_TITLE", nil) subTitle:NSLocalizedString(@"OPERATION_NETWORK_TEXT_SUBTITLE", nil) closeButtonTitle:nil duration:0.0f];
}

//判断是否开启热点
- (BOOL)isHotSpot
{
    bool isHotSpot = NO;
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    @try {
        NSInteger success = getifaddrs(&interfaces);
        if (success == 0) {
            temp_addr = interfaces;
            while(temp_addr != NULL) {
                if(temp_addr->ifa_addr->sa_family == AF_INET) {
                    NSString *ifaName = [NSString stringWithUTF8String:temp_addr->ifa_name];
                    
                    //NSString *address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_addr)->sin_addr)];
                    //NSString *mask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_netmask)->sin_addr)];
                    //NSString *gateway = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *) temp_addr->ifa_dstaddr)->sin_addr)];
                    
                    if ( ifaName && [ifaName containsString:@"bridge"]) {
                        isHotSpot = YES;
                        break;
                    }
                    
                    if ( ifaName && [ifaName containsString:@"pdp_ip"]) {
                        isHotSpot = YES;
                        break;
                    }
                }
                temp_addr = temp_addr->ifa_next;
            }
        }
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        freeifaddrs(interfaces);
    }
    return isHotSpot;
}

//获取WiFi名称
- (NSString *)getWifiName
{
    NSString *wifiName = nil;
    
    CFArrayRef wifiInterfaces = CNCopySupportedInterfaces();
    if (!wifiInterfaces) {
        return nil;
    }
    
    NSArray *interfaces = (__bridge NSArray *)wifiInterfaces;
    
    for (NSString *interfaceName in interfaces) {
        CFDictionaryRef dictRef = CNCopyCurrentNetworkInfo((__bridge CFStringRef)(interfaceName));
        
        if (dictRef) {
            NSDictionary *networkInfo = (__bridge NSDictionary *)dictRef;
            
            wifiName = [networkInfo objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            
            CFRelease(dictRef);
        }
    }
    
    CFRelease(wifiInterfaces);
    return wifiName;
}

//发送文本消息-文本框显示
-(void) inputTextShow
{
    _alertView = [[SCLAlertView alloc] initWithNewWindowWidth:300.0f];
    _alertView.shouldDismissOnTapOutside = YES;
    _alertView.hideAnimationType = SCLAlertViewHideAnimationSlideOutToTop;
    _alertView.showAnimationType =  SCLAlertViewShowAnimationSlideInFromTop;
    _alertView.backgroundType = SCLAlertViewBackgroundBlur;
    _alertView.customViewColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1];
    _alertView.iconTintColor = [UIColor orangeColor];
    
    _oldTextStr = [[NSMutableString alloc] init];
    _lastLocation = 0;
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, _alertView.viewText.bounds.size.width, _alertView.viewText.bounds.size.height - 20)];
    textView.font = [UIFont systemFontOfSize:17.f];
    textView.delegate = self;
    
    textView.layer.borderColor = [[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1] CGColor];
    textView.layer.borderWidth = 1.0;
    [textView.layer setMasksToBounds:YES];
    
    textView.returnKeyType = UIReturnKeyDone;
    
    [_alertView addCustomView:textView];
    
    [_alertView alertShowAnimationIsCompleted:^{
        if ([textView canBecomeFirstResponder]) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(inputTextKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
            [textView becomeFirstResponder];
        }
    }];
    
    [_alertView showEdit:self title:nil subTitle:NSLocalizedString(@"OPERATION_SEND_TEXT_MSG", nil) closeButtonTitle:nil duration:0.0f];
}

//发送文本消息-键盘弹出计算高度
- (void) inputTextKeyboardWillShow:(NSNotification *)notification {
    CGFloat kbHeight = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    CGFloat offset = (_alertView.view.frame.origin.y + _alertView.view.frame.size.height + 40) - (self.view.frame.size.height - kbHeight);
    double duration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    if(offset > 0) {
        [UIView animateWithDuration:duration animations:^{
            _alertView.view.frame = CGRectMake(_alertView.view.frame.origin.x, _alertView.view.frame.origin.y - offset, _alertView.view.frame.size.width, _alertView.view.frame.size.height);
        }];
    }
}

#pragma textView代理方法
//发送文本消息-输入框光标处理
- (void)textViewDidChangeSelection:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    if (!selectedRange) {
        NSUInteger _curLocation = textView.selectedRange.location;
        if (_curLocation == _lastLocation) {
            return;
        }
        
        if (_oldTextStr.length != textView.text.length) {
            _lastLocation = _curLocation;
            return;
        }
        
        if (_curLocation == 0) {
            [self sendDataWithType:typeKeyboard andContent:contentHomeKey];
        } else if (_curLocation == textView.text.length) {
            [self sendDataWithType:typeKeyboard andContent:contentEndKey];
        } else {
            if (_curLocation < _lastLocation) { //新光标到左边👈
                int Dvalue = (int)_lastLocation - (int)_curLocation;
                int middle = (int)round(_lastLocation/2);
                if (Dvalue <= middle) { //直接左移
                    for (int i = 0; i < Dvalue; i ++) {
                        [self sendDataWithType:typeKeyboard andContent:contentLeftKey];
                    }
                } else { //先首位，再右移
                    [self sendDataWithType:typeKeyboard andContent:contentHomeKey];
                    for (int i = 0; i < _curLocation; i ++) {
                        [self sendDataWithType:typeKeyboard andContent:contentRightKey];
                    }
                }
            } else { //新光标到右边👉
                int Dvalue = (int)_curLocation - (int)_lastLocation;
                int middle = (int)round((textView.text.length - _lastLocation)/2);
                if (Dvalue > middle) { //先尾位，再左移
                    [self sendDataWithType:typeKeyboard andContent:contentEndKey];
                    for (int i = 0; i < (textView.text.length - _curLocation); i ++) {
                        [self sendDataWithType:typeKeyboard andContent:contentLeftKey];
                    }
                } else { //直接右移
                    for (int i = 0; i < Dvalue; i ++) {
                        [self sendDataWithType:typeKeyboard andContent:contentRightKey];
                    }
                }
            }
        }
        _lastLocation = _curLocation;
    }
}

//发送文本消息-输入框文字处理
- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    if (!selectedRange) {
        NSString *_newTextStr = textView.text;
        if ([_oldTextStr isEqualToString:_newTextStr]) {
            return;
        }
        
        if (_oldTextStr.length > _newTextStr.length) { //删除字符
            for (int i = 0; i < _oldTextStr.length; i ++) {
                NSRange oldRange = NSMakeRange(i, 1);
                NSString *tempStr = [_oldTextStr substringWithRange:oldRange];
                if (i >= _newTextStr.length) {
                    [self sendDataWithType:typeKeyboard andContent:contentBackSpaceKey];
                    [_oldTextStr deleteCharactersInRange:oldRange];
                } else {
                    NSRange newRange = [_newTextStr rangeOfString:tempStr options:NSAnchoredSearch range:oldRange];
                    if (newRange.location != i) {
                        [self sendDataWithType:typeKeyboard andContent:contentBackSpaceKey];
                        [_oldTextStr deleteCharactersInRange:oldRange];
                    }
                }
            }
        } else if (_oldTextStr.length < _newTextStr.length) { //新增字符
            NSMutableString *addTextStr = [[NSMutableString alloc] init];
            for (int j = 0; j < _newTextStr.length; j ++) {
                NSRange newRange = NSMakeRange(j, 1);
                NSString *tempStr = [_newTextStr substringWithRange:newRange];
                if (j >= _oldTextStr.length) {
                    [addTextStr appendString:tempStr];
                    [_oldTextStr insertString:tempStr atIndex:j];
                } else {
                    NSRange oldRange = [_oldTextStr rangeOfString:tempStr options:NSAnchoredSearch range:newRange];
                    if (oldRange.location != j) {
                        [addTextStr appendString:tempStr];
                        [_oldTextStr insertString:tempStr atIndex:j];
                    }
                }
            }
            if (addTextStr) {
                [self sendDataWithType:typeText andContent:addTextStr];
            }
        } else {
            //长度相等
        }
        
        [_oldTextStr setString:textView.text];
    }
}

//发送文本消息-键盘换行键、删除键处理
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]){
        [self sendDataWithType:typeKeyboard andContent:contentEnterKey];
        return NO;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    if (!selectedRange && text.length == 0 && range.location == 0 && textView.text.length == 0) {
        [self sendDataWithType:typeKeyboard andContent:contentBackSpaceKey];
    }
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
