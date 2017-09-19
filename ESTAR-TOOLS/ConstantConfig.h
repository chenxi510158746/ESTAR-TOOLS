//
//  ConstantConfig.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/7.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#ifndef ConstantConfig_h
#define ConstantConfig_h

/**
 * 蓝牙配置常量
 */
#define kServiceUUID @"0714"                //服务的 UUID 00000714-0000-1000-8000-00805F9B34FB
#define kNotifyUUID  @"0722"                //特征的 UUID 00000722-0000-1000-8000-00805F9B34FB
#define kReadUUID @"0720"                   //特征的 UUID 00000720-0000-1000-8000-00805F9B34FB
#define kWriteUUID @"0721"                  //特征的 UUID 00000721-0000-1000-8000-00805F9B34FB
#define kRestoreIdentifierKey @"ESTAR TOOLS"//恢复重连 Key
#define kLastConnectKey @"LAST_CONNECT_KEY" //上次连接存储 Key
#define kDefaultDeviceName @"Android Bluedroid" //如设备名为空，默认使用名称
#define kNetworkInfo @"NET_WORK_INFO"       //保持设备网络连接信息KEY

/**
 * 发送数据协议
 * 传输格式：{"type":int,"content":"*"}
 */
//type 类型
#define typeMouse @"1"             //模拟鼠标座标的前缀
#define typeGame @"2"              //游戏按键消息类型
#define typeKeyboard @"3"          //发送键盘值的前缀
#define typeText @"4"              //发送文本消息类型
#define typeWifi @"5"              //发送的wifi密码
#define typeAppDownload @"6"       //应用市场手机发送下载的appId
#define typeAppCancelDownload @"7" //取消正在下载的应用
#define typeAppInstallInfo @"8"    //将眼镜端用户安装的信息传给手机
#define typeAppUninstall @"9"      //卸载用户已安装APP

//content 普通按键
#define contentEnterKey @"502"
#define contentBackSpaceKey @"500"
#define contentBackKey @"506"
#define contentCodeHomeKey @"507"
#define contentHomeKey @"508"
#define contentEndKey @"509"
#define contentUpKey @"510"
#define contentDownKey @"511"
#define contentLeftKey @"512"
#define contentRightKey @"513"
#define contentPageKey @"56"

//content 游戏手柄按键
#define contentGameLeft @"512"
#define contentGameUp @"510"
#define contentGameRight @"513"
#define contentGameDown @"511"
#define contentGameX @"120"
#define contentGameY @"509"
#define contentGameA @"99"
#define contentGameB @"120"
#define contentGamePause @"118"

/**
 * 接收数据协议
 * 传输格式：{"type":int,"content":"*"}
 */
//type 类型
#define CB2Client_WIFI_PWD_TYPE 1           //wifi、热点反馈，content内容(Y、N)
#define CB2Client_INSTALL_TYPE 2            //应用安装完成后反馈，content内容为应用包名
#define CB2Client_UNINSTALL_TYPE 3          //应用卸载完成后反馈，content内容为应用包名
#define CB2Client_DOWNLOAD_PROGRESS 4       //反馈应用下载进度，content内容为appId + ":" + 进度，例：5:99
#define CB2Client_DEVICEID 5                //反馈设备ID，content内容为设备ID
#define CB2Client_USER_INSTALLED_PACKAGES 6 //反馈设备用户已安装的应用包名，content内容为Json的字串 {"mUserInstalledPackages":[]}
#define CB2Client_AR_GLASSES_NO_NETWORK 7   //网络状态反馈，没有网络content内容为7，占位用无实际意义
#define CB2Client_CANCEL_DOWNLOADAPK 8      //应用取消下载反馈，content内容为appId
#define CB2Client_DOWNLOADAPK_FINISHED 9    //应用下载完成反馈，content内容为应用的appId
#define CB2Client_DOWNLOADAPK_FAILUE 10     //下载失败，content内容为应用的appId



#endif /* ConstantConfig_h */
