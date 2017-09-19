//
//  VCApplication.h
//
//  Created by chenxi on 2017/6/16.
//  Copyright © 2017年 chenxi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VCBase.h"
#import "AppItemModel.h"
#import "BZAppItemCDUtils.h"

@interface VCApplication : VCBase<UITableViewDataSource,UITableViewDelegate>
{
    UITableView *_tableView;
    
    NSMutableArray *_arrayApps;
    
    NSInteger _refreshCount;
    
    NSInteger _dataTotal;
}

- (void) loadData;

- (void) showData:(NSDictionary *) dataDic;



@property(assign,nonatomic)CGRect screenSize;
@property(assign,nonatomic) NSInteger nCount;  //缓存的信息条数，默认只缓存6条数据
/**
 创建导航栏
 */
-(void)createNavgationBar;


/**
 创建初始列表
 */
-(void)createTableView;


/**
 下载时更新进度条进度

 @param appId appId
 @param progress 进度
 */
-(void)updateProgressForAppId:(NSString*) appId
                  andProgress:(NSString* )progress;


/**
 更新下载时进度信息

 @param msg 通知发送过来的item字典类型信息
 */
-(void)updateProgressForAppId:(NSNotification *)msg;



/**
 更新下载按钮状态

 @param pkgName 包名
 @param status 按钮状态码
 */
-(void)updateBtnStatusForPkgName:(NSString*) pkgName statusCode:(NSInteger) status;



/**
 更新列表中按钮状态的数据
 */
-(void) updateDownloadBtnStatus:(NSNotification *)msg;


/**
 设置眼镜端网络对话框

 @param msg 通知的消息
 */
-(void)showNetworkDialog:(NSNotification *)msg;


/**
 ar眼镜取消下载消息反馈

 @param msg 通知消息
 */
-(void) arCancelDownload:(NSNotification *)msg;


/**
 眼镜下载失败异常处理
 
 @param msg 通知消息
 */
-(void) downloadFail:(NSNotification *)msg;

/**
 卸载/安装完成时的按钮回调

 @param msg 通知消息 卸载完成状 按钮文本为：下载安装 状态码为3 ： 安装完成时文本状态为：卸载  状态码为2：
 */
-(void) switchBtnStatu:(NSNotification *)msg;


/**
 缓存app信息到本地数据库中

 @param appCache 待缓存的数据对象
 */
-(void)saveAppInfo2DB:(AppItemModel*) appCache;


-(void)registerBrodcast;
-(void) removeBrodcast;


@end

