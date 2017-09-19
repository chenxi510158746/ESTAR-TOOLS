//
//  BleModel.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/4.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

//应用数据模型
@interface BleModel : NSObject
{
    //蓝牙管理对象
    CBCentralManager *_manager;
    
    //当前连接设备
    CBPeripheral *_peripheral;
    
    //当前通知特征
    CBCharacteristic *_characterNotify;
    
    //当前读特征
    CBCharacteristic *_characterRead;
    
    //当前写特征
    CBCharacteristic *_characterWrite;
    
    //连接设备号
    NSString *_deviceId;
}

//属性对象
@property (strong, nonatomic) CBCentralManager *mManager;
@property (strong, nonatomic) CBPeripheral *mPeripheral;
@property (strong, nonatomic) CBCharacteristic *mCharacterNotify;
@property (strong, nonatomic) CBCharacteristic *mCharacterRead;
@property (strong, nonatomic) CBCharacteristic *mCharacterWrite;
@property (strong, nonatomic) NSString *mDeviceId;

+ (BleModel *)sharedSingleton;

@end
