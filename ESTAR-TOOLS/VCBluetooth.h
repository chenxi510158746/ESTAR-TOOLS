//
//  VCBluetooth.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/6/30.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BleModel.h"

@interface VCBluetooth : UIViewController <UITableViewDataSource,UITableViewDelegate,CBCentralManagerDelegate,CBPeripheralDelegate>
{
    UITableView *_tableView;
    
    NSInteger _autoConnectTimes;
    
    NSTimer *_timer;
    
    NSMutableString *_installPackages;
}

@property (nonatomic, strong) NSMutableArray *deviceArray; //搜索到外围设备

@property (nonatomic, strong) BleModel *bleModel; //蓝牙数据模型

@end
