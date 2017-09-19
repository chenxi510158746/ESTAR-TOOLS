//
//  BleModel.m
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/4.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "BleModel.h"

@implementation BleModel

@synthesize mManager = _manager;
@synthesize mPeripheral = _peripheral;
@synthesize mCharacterNotify = _characterNotify;
@synthesize mCharacterRead = _characterRead;
@synthesize mCharacterWrite = _characterWrite;
@synthesize mDeviceId = _deviceId;

+ (BleModel *)sharedSingleton
{
    static BleModel *sharedSingleton;
    
    @synchronized(self)
    {
        if (!sharedSingleton)
        {
            sharedSingleton = [[BleModel alloc] init];
        }
        return sharedSingleton;
    }
}

@end
