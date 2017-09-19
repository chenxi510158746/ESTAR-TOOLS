//
//  AppModel.h
//
//  Created by chenxi on 2017/6/19.
//  Copyright © 2017年 chenxi. All rights reserved.
//

#import <Foundation/Foundation.h>

//应用数据模型
@interface AppModel : NSObject
{
    //应用编号
    NSString *_appId;
    //应用图标
    NSString *_appIcon;
    //应用名称
    NSString *_appName;
    //应用包名
    NSString *_appPackage;
    //应用大小
    NSString *_size;
    
    float _fDowmloadProgress;
    NSInteger _nRowNO;
    
    NSInteger _btnStatus;   ////3:初始状态 button 显示下载安装 2：button 显示 卸载
    
    
}
//属性对象
@property (strong, nonatomic) NSString *mAppId;
@property (strong, nonatomic) NSString *mAppIcon;
@property (strong, nonatomic) NSString *mAppName;
@property (strong, nonatomic) NSString *mAppPackage;
@property (strong, nonatomic) NSString *mSize;

@property(assign,nonatomic) NSInteger nRowNO;
@property(assign,nonatomic) float fDowmloadProgress;

@property(assign,nonatomic) NSInteger btnStatus;

@end
