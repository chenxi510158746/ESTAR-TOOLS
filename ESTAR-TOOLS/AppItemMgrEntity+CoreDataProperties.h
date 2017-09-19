//
//  AppItemMgrEntity+CoreDataProperties.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "AppItemMgrEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface AppItemMgrEntity (CoreDataProperties)

+ (NSFetchRequest<AppItemMgrEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *appId;
@property (nullable, nonatomic, copy) NSString *appName;
@property (nullable, nonatomic, copy) NSString *appSize;
@property (nullable, nonatomic, copy) NSString *appUrl;
@property (nullable, nonatomic, copy) NSString *deviceId;
@property (nullable, nonatomic, copy) NSString *imgUrl;
@property (nullable, nonatomic, copy) NSString *pkgName;

@end

NS_ASSUME_NONNULL_END
