//
//  AppItemModel.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 对应CoreData中的实体 方便作模型转换
 这里暂未与AppModel抽象合并
 */
@interface AppItemModel : NSObject


@property (nullable, nonatomic, copy) NSString *appId;
@property (nullable, nonatomic, copy) NSString *appName;
@property (nullable, nonatomic, copy) NSString *appSize;
@property (nullable, nonatomic, copy) NSString *deviceId;
@property (nullable, nonatomic, copy) NSString *imgUrl;
@property (nullable, nonatomic, copy) NSString *pkgName;

@end
