//
//  BZAppItemCDUtils.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BZCoreDataBase.h"
#import "AppItemModel.h"

@interface BZAppItemCDUtils : BZCoreDataBase

/**
 单例方法
 
 @return 当前唯一实例
 */
+ (instancetype)sharedInstance;


/**
 加入一条新数据

 @param appInfo 待加入的信息
 @param success 成功回调
 @param fail 失败回调
 */
-(void)insertAppInfo:(AppItemModel*) appInfo onSuccess:(void(^)(void))success onFail:(void(^)(NSError* error)) fail;


@end
