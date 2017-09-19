//
//  BZAppItemCDUtils.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "BZAppItemCDUtils.h"
#import "BZEntityUtils.h"


static NSString* const modelName = @"ESTAR_TOOLS";
static NSString* const entityName = @"AppItemEntity";
static NSString* const sqliteName = @"AppItemEntity.sqlite";

static BZAppItemCDUtils *appItemCDUtils = nil;

@implementation BZAppItemCDUtils

+ (instancetype)sharedInstance{
    
    @synchronized (self) {
        if(appItemCDUtils == nil){
            appItemCDUtils = [[BZAppItemCDUtils alloc] initWithCoreData:entityName modelName:modelName sqlPath:sqliteName success:^{
                
            } fail:^(NSError *error){
                
            }];
        }
        
    }
    return appItemCDUtils;
}

-(void)insertAppInfo:(AppItemModel*) appInfo onSuccess:(void(^)(void))success onFail:(void(^)(NSError* error)) fail{
    
    [self queryWithKey:@"pkgName" forValue:appInfo.pkgName onSuccess:^(NSMutableArray* successArray){
        
        if( successArray != nil && [successArray count] == 0){
            
            NSDictionary* dict = [BZEntityUtils obj2Dict:appInfo];
            
            [self insertNewEntity:dict success:^{
                if(success){
                    success();
                }
            } fail:^(NSError* error){
                if(fail){
                    fail(error);
                }
            }];
        }
        
    } onFail:^(NSError* error){
        
        fail(error);
    }];
    
}


@end
