//
//  VCOperation.m
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/5.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "VCOperation.h"
#import <AudioToolbox/AudioToolbox.h>
#import "VCApplication.h"
#import "VCGameOperation.h"
#import "NirKxMenu.h"

@interface VCOperation ()

extern NSInteger networkStatus;

@end

@implementation VCOperation

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    BleModel *bleModel = [self getBleModel];
    if (bleModel == nil) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    NSString *deviceName = bleModel.mPeripheral.name.length > 0 ? bleModel.mPeripheral.name : kDefaultDeviceName;
    [_btnBleBack setTitle:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"OPERATION_CONNECTED_DEVICE", nil), deviceName] forState:UIControlStateNormal];
    
    UISwipeGestureRecognizer * recognizer = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(handleSwipeFrom:)];
    [recognizer setDirection:(UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown)];
    [self.view addGestureRecognizer:recognizer];
}

#pragma 以下是按键、手势事件 start

//home按键
- (IBAction)home:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentCodeHomeKey];
}

//文本按键
- (IBAction)inputText:(id)sender {
    [self inputTextShow];
}

//回退按键
- (IBAction)back:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentBackKey];
}

//更多按键
- (IBAction)more:(id)sender {
    //菜单内容设置
    UIImage *gameIcon = [self scaleToSize:[UIImage imageNamed:@"icon_game.png"] size:CGSizeMake(42, 30)];
    UIImage *wifiIcon = [self scaleToSize:[UIImage imageNamed:@"icon_wifi.png"] size:CGSizeMake(42, 30)];
    UIImage *shopIcon = [self scaleToSize:[UIImage imageNamed:@"icon_shop.png"] size:CGSizeMake(42, 30)];
    
    NSArray * menuArray = @[
                            [KxMenuItem menuItem:NSLocalizedString(@"OPERATION_MENUITEM_GAME", nil) image:gameIcon target:self action:@selector(game:)],
                            [KxMenuItem menuItem:NSLocalizedString(@"OPERATION_MENUITEM_NETWORK", nil) image:wifiIcon target:self action:@selector(wifi:)],
                            [KxMenuItem menuItem:NSLocalizedString(@"OPERATION_MENUITEM_APPSTORE", nil) image:shopIcon target:self action:@selector(appStore:)]
                            ];
    
    //配置一：基础配置
    [KxMenu setTitleFont:[UIFont systemFontOfSize:17]];
    
    //配置二：拓展配置
    Color textColor = {1,0.6,0};
    Color backgroundColor = {0.2,0.2,0.2};
    OptionalConfiguration options = {15, 8, 15, 28, 15, true, true, false, false, textColor, backgroundColor};
    
    //菜单弹出方法
    [KxMenu showMenuInView:self.view
                  fromRect:_btnMore.frame
                 menuItems:menuArray
               withOptions: options
     ];
}

//游戏按键
- (void)game:(id)sender {
    BleModel *bleModel = [self getBleModel];
    if (bleModel == nil) {
        return;
    }
    VCGameOperation *vcGameOper = [[VCGameOperation alloc] init];
    [self presentViewController:vcGameOper animated:YES completion:nil];
}

//网络连接按键
- (void)wifi:(id)sender {
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

//应用商店按键
- (void)appStore:(id)sender {
    BleModel *bleModel = [self getBleModel];
    if (bleModel == nil) {
        return;
    }
    
    //创建动画
    CATransition *animation = [CATransition animation];
    //设置运动轨迹的速度
    animation.timingFunction = UIViewAnimationCurveEaseInOut;
    //设置动画类型为立方体动画
    animation.type = @"cube";
    //设置动画时长
    animation.duration =0.5f;
    //设置运动的方向
    animation.subtype =kCATransitionFromRight;
    
    VCApplication *vcApp = [[VCApplication alloc] init];
    [self presentViewController:vcApp animated:YES completion:nil];
}

//上按键
- (IBAction)up:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentUpKey];
}

//下按键
- (IBAction)down:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentDownKey];
}

//左按键
- (IBAction)left:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentLeftKey];
}

//右按键
- (IBAction)right:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentRightKey];
}

//中间按键
- (IBAction)center:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentEnterKey];
}

//返回蓝牙搜索按键
- (IBAction)bleBack:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//主屏翻页手势
- (void) handleSwipeFrom:(UISwipeGestureRecognizer *)recognizer {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [self sendDataWithType:typeKeyboard andContent:contentPageKey];
}

#pragma 以上是按键、手势事件 end

#pragma 以下是事件逻辑处理方法 start

//设置图片尺寸大小
- (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

#pragma 以上是事件逻辑处理方法 end

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
