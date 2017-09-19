//
//  AppItemMgrEntity+CoreDataProperties.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "AppItemMgrEntity+CoreDataProperties.h"

@implementation AppItemMgrEntity (CoreDataProperties)

+ (NSFetchRequest<AppItemMgrEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"AppItemEntity"];
}

@dynamic appId;
@dynamic appName;
@dynamic appSize;
@dynamic appUrl;
@dynamic deviceId;
@dynamic imgUrl;
@dynamic pkgName;

@end
