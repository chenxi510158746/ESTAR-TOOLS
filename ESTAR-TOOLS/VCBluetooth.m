//
//  VCBluetooth.m
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/6/30.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "VCBluetooth.h"
#import <CoreBluetooth/CoreBluetooth.h>
#import "ConstantConfig.h"
#import "SVProgressHUD.h"
#import "BleCell.h"
#import "VCOperation.h"
#import "MJRefresh.h"
#import "BZLog.h"
#import "StringUtils.h"

@interface VCBluetooth ()

@end

@implementation VCBluetooth

BOOL showNetworkConnect;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/4)];
    
    imgView.image = [UIImage imageNamed:@"bg2.jpg"];
    
    UIImageView *circleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(imgView.bounds.size.width/2 - 30, imgView.bounds.size.height/2 - 45, 60, 60)];
    circleImgView.image = [UIImage imageNamed:@"circle.png"];
    [imgView addSubview:circleImgView];
    
    UIImageView *glassImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
    glassImgView.image = [UIImage imageNamed:@"glass2.png"];
    [circleImgView addSubview:glassImgView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0.0, imgView.bounds.size.height - 60, imgView.bounds.size.width, 50)];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = NSLocalizedString(@"BLE_LABLE_TITLE", nil);
    label.textColor = [UIColor orangeColor];
    label.font = [UIFont systemFontOfSize:18];
    [imgView addSubview:label];
    
    [self.view addSubview:imgView];
    
    UILabel *listLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, imgView.bounds.size.height, self.view.bounds.size.width, 40)];
    listLabel.text = NSLocalizedString(@"BLE_DISCOVERED_TITLE", nil);
    listLabel.textColor = [UIColor grayColor];
    listLabel.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:listLabel];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, imgView.bounds.size.height+40, self.view.bounds.size.width, self.view.bounds.size.height - (imgView.bounds.size.height + listLabel.bounds.size.height)) style:UITableViewStylePlain];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    _deviceArray = [[NSMutableArray alloc] init];
    
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    _tableView.mj_header = header;
    header.lastUpdatedTimeLabel.hidden = YES;
    
    [self.view addSubview:_tableView];
    
    _autoConnectTimes = 0;
    showNetworkConnect = NO;
    _installPackages = [[NSMutableString alloc] init];
    _bleModel = [BleModel sharedSingleton];
    if (_bleModel.mManager == nil) {
        //dispatch_queue_t queue = dispatch_queue_create("BluetoothQueue", NULL);
        
        NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES],CBCentralManagerOptionShowPowerAlertKey, kRestoreIdentifierKey,CBCentralManagerOptionRestoreIdentifierKey,nil];
        
        _bleModel.mManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:options];
    } else {
        [_bleModel.mManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
    }
    //[SVProgressHUD showInfoWithStatus:@"蓝牙服务启动！"];
}

- (void) viewWillAppear:(BOOL)animated
{
    [self resetDevices];
    if (![_timer isValid]) {
        _timer =  [NSTimer scheduledTimerWithTimeInterval:60.0 target:self selector:@selector(resetDevices) userInfo:nil repeats:YES];
    }
}

- (void)dealloc{
    [_timer invalidate];
}

#pragma mark - CBCentralManagerDelegate

//恢复连接设备状态回调
- (void)centralManager:(CBCentralManager *)central willRestoreState:(NSDictionary<NSString *,id> *)dict{
    //NSArray *scanServices = dict[CBCentralManagerRestoredStateScanServicesKey];
    //NSArray *scanOptions = dict[CBCentralManagerRestoredStateScanOptionsKey];
    
    NSArray *peripherals = dict[CBCentralManagerRestoredStatePeripheralsKey];
    for (CBPeripheral *peripheral in peripherals) {
        [_deviceArray addObject:peripheral];
        peripheral.delegate = self;
    }
}

//启动蓝牙状态回调
- (void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBManagerStatePoweredOn:
            //[SVProgressHUD showInfoWithStatus:@"开始扫描..."];
            [_deviceArray removeAllObjects];
            [_bleModel.mManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
            break;
        case CBManagerStatePoweredOff: {
                _bleModel.mPeripheral = nil;
                _bleModel.mCharacterWrite = nil;
            
                [_tableView reloadData];
                UIViewController *viewController = [self getCurrentVC];
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"endFullScreen" object:nil]];
                [viewController dismissViewControllerAnimated:YES completion:nil];
            }
            
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_STATUS_POWERED_OFF", nil)];
            break;
        case CBManagerStateUnsupported:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_STATUS_UNSUPPORTED", nil)];
            break;
        case CBManagerStateUnauthorized:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_STATUS_UNAUTHORIZED", nil)];
            break;
        case CBManagerStateResetting:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_STATUS_RESETTING", nil)];
            break;
        case CBManagerStateUnknown:
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"BLE_STATUS_UNKNOWN", nil)];
            break;
    }
}

//扫描到设备回调
- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *, id> *)advertisementData RSSI:(NSNumber *)RSSI
{
    BZLog(@"发现蓝牙设备：%@，UUID：%@", peripheral.name, peripheral.identifier);
//    if (peripheral.name.length <= 0) {
//        return ;
//    }
    
    if (_deviceArray.count == 0) {
        [_deviceArray addObject:peripheral];
    } else {
        BOOL isExist = NO;
        for (int i = 0; i < _deviceArray.count; i++) {
            CBPeripheral *per = [_deviceArray objectAtIndex:i];
            if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
                isExist = YES;
                [_deviceArray replaceObjectAtIndex:i withObject:peripheral];
            }
        }
        
        if (!isExist) {
            [_deviceArray addObject:peripheral];
        }
    }
    [_tableView reloadData];
    
    if (_bleModel.mPeripheral == nil && _autoConnectTimes <= 3) {
        NSString *lastUUIDStr = [[NSUserDefaults standardUserDefaults] objectForKey:kLastConnectKey];
        if (lastUUIDStr != nil) {
            //if ([peripheral.identifier.UUIDString isEqualToString:lastUUIDStr]) {
            if ([peripheral.name isEqualToString:lastUUIDStr]) {
                [_bleModel.mManager connectPeripheral:peripheral options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];
                if (_autoConnectTimes >= 1) {
                    [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%ld %@", (long)_autoConnectTimes, NSLocalizedString(@"BLE_RECONNECTION_TIMES", nil)]];
                }
                _autoConnectTimes ++;
            }
        }
    }
}

//连接（配对）设备成功回调
- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    
    peripheral.delegate = self;
    
    _bleModel.mPeripheral = peripheral;
    
    //外围设备开始寻找服务
    [peripheral discoverServices:nil];
    //[SVProgressHUD showInfoWithStatus:@"开始查找设备服务..."];
    
    //保存连接的UUID
    [[NSUserDefaults standardUserDefaults] setObject:peripheral.name forKey:kLastConnectKey];
    
    [_tableView reloadData];
}

//连接（配对）失败回调
- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(nullable NSError *)error
{
    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BLE_CONNECT_FAIL", nil),peripheral.name]];
}

//断开连接回调
- (void) centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error
{
    [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"BLE_DISCONNECT", nil)];
    _bleModel.mPeripheral = nil;
    _bleModel.mCharacterWrite = nil;
        
    [_tableView reloadData];
    UIViewController *viewController = [self getCurrentVC];
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"endFullScreen" object:nil]];
    [viewController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - CBPeripheralDelegate

//扫描到服务回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    if (error) {
        return;
    }
    for (CBService *service in peripheral.services) {
        //外围设备查找指定服务中的特征
        if ([service.UUID.UUIDString isEqualToString:kServiceUUID]) {
            //[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"已发现可用服务码：%@",kServiceUUID]];
            [peripheral discoverCharacteristics:nil forService:service]; //指定service UDID
        }
    }
}

//扫描到特征回调
- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(nonnull CBService *)service error:(nullable NSError *)error{
    
    if (error) {
        return;
    }
    
    for (CBCharacteristic *characteristic in service.characteristics) {
        
        //[SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"发现特征码：%@", characteristic.UUID.UUIDString]];
        
        CBCharacteristicProperties properties = characteristic.properties;
        
        //情景一：通知
        if (properties & CBCharacteristicPropertyNotify) {
            if ([characteristic.UUID.UUIDString isEqualToString:kNotifyUUID]) {
                _bleModel.mCharacterNotify = characteristic;
                [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            }
        }
        
        //情景二：读取
        if (properties & CBCharacteristicPropertyRead) {
            if ([characteristic.UUID.UUIDString isEqualToString:kReadUUID]) {
                _bleModel.mCharacterRead = characteristic;
                [peripheral readValueForCharacteristic:characteristic];
            }
        }
        
        //情景二：写数据
        if (properties & CBCharacteristicPropertyWrite) {
            if ([characteristic.UUID.UUIDString isEqualToString:kWriteUUID]) {
                _bleModel.mCharacterWrite = characteristic;
                [_tableView reloadData];
            }
        }
    }
    
    if (_bleModel.mCharacterWrite != nil) {
        [SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BLE_CONNECT_SUCCESS", nil), peripheral.name]];
        [SVProgressHUD dismissWithDelay:1];
        [self pushOperation];
    } else {
        [_bleModel.mManager cancelPeripheralConnection:_bleModel.mPeripheral];
    }
}

//更新通知状态回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateNotificationStateForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error
{
    if (error) {
        //[SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"读取通知错误：%@", error]];
        return;
    }
    NSString *value=[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding];
    if (value) {
        BZLog(@"读取到通知：%@", value);
    }
}

//读取消息回调
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error
{
    if (error) {
        return;
    }
    if (characteristic.value) {
        [self feedbackHandle:characteristic.value];
    }
}

//写消息回调
- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(nonnull CBCharacteristic *)characteristic error:(nullable NSError *)error{
    
    if (error) {
        return;
    }
    //[SVProgressHUD showSuccessWithStatus:[NSString stringWithFormat:@"成功写消息到：%@", peripheral.name]];
}

//更新名称回调
-(void) peripheralDidUpdateName:(CBPeripheral *)peripheral
{
    for (int i = 0; i < _deviceArray.count; i++) {
        CBPeripheral *per = [_deviceArray objectAtIndex:i];
        if ([per.identifier.UUIDString isEqualToString:peripheral.identifier.UUIDString]) {
            [_deviceArray replaceObjectAtIndex:i withObject:peripheral];
        }
    }
}

//修改服务回调
-(void) peripheral:(CBPeripheral *)peripheral didModifyServices:(NSArray<CBService *> *)invalidatedServices
{
    [peripheral discoverServices:@[[CBUUID UUIDWithString:kServiceUUID]]];
}

#pragma mark - tableView 处理

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _deviceArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *strID = @"BLUETOOTH_TABLE_ID";
    
    BleCell *cell = [_tableView dequeueReusableCellWithIdentifier:strID];
    
    if (cell == nil) {
        cell = (BleCell *)[[[NSBundle mainBundle] loadNibNamed:@"BleCell" owner:self options:nil] lastObject];
    }
    
    CBPeripheral *per = [_deviceArray objectAtIndex:indexPath.row];
    
    cell.bleNameLab.text = per.name.length > 0 ? per.name : kDefaultDeviceName;
    cell.bleStatusLab.text = NSLocalizedString(@"BLE_UNCONNECT_STATUS", nil);
    if ([_bleModel.mPeripheral.identifier.UUIDString isEqualToString:per.identifier.UUIDString]) {
        if (_bleModel.mCharacterWrite != nil) {
            cell.bleStatusLab.text = NSLocalizedString(@"BLE_CONNECTED_STATUS", nil);
        } else {
            cell.bleStatusLab.text = NSLocalizedString(@"BLE_PAIRED_STATUS", nil);
        }
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CBPeripheral *per = [_deviceArray objectAtIndex:indexPath.row];
    
    if (_bleModel.mPeripheral != nil && _bleModel.mCharacterWrite != nil) {
        
        if ([per.identifier.UUIDString isEqualToString:_bleModel.mPeripheral.identifier.UUIDString]) {
            [self pushOperation];
            return;
        } else {
            [_bleModel.mManager cancelPeripheralConnection:_bleModel.mPeripheral];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:kLastConnectKey];
        }
    }
    
    [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"BLE_CONNECTING", nil), per.name.length > 0 ? per.name : kDefaultDeviceName]];

    [_bleModel.mManager connectPeripheral:per options:@{CBConnectPeripheralOptionNotifyOnDisconnectionKey:@(YES)}];

    _autoConnectTimes = 0;
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void) loadNewData
{
    [_tableView.mj_header beginRefreshing];
    
    [_deviceArray removeAllObjects];
    
    [_bleModel.mManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
    
    [_tableView reloadData];
    
    [_tableView.mj_header endRefreshing];
}

#pragma mark - 逻辑方法

//推出 Operation 界面
- (void) pushOperation
{
    [_timer invalidate];
    [_bleModel.mManager stopScan];
    VCOperation *vcOper = [[VCOperation alloc] init];
    [self presentViewController:vcOper animated:YES completion:nil];
    
//    VCOperation *vcOper = [[VCOperation alloc] init];
//    UINavigationController *_nav = [[UINavigationController alloc]initWithRootViewController:vcOper];
//    [self presentViewController:_nav animated:YES completion:nil];
}

//获取当前屏幕显示的 viewcontroller
- (UIViewController *)getCurrentVC
{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

- (void) resetDevices
{
    if (_bleModel.mManager.state == CBManagerStatePoweredOn) {
        [_deviceArray removeAllObjects];
        [_tableView reloadData];
        [_bleModel.mManager scanForPeripheralsWithServices:@[[CBUUID UUIDWithString:kServiceUUID]] options:@{CBCentralManagerScanOptionAllowDuplicatesKey:@(NO)}];
        BZLog(@"resetDevices");
    }
}

//蓝牙回馈消息处理
- (void) feedbackHandle:(NSData *) data
{
    NSString *value = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    BZLog(@"读取到消息：%@", value);
    
    NSError *err = nil;
    NSDictionary *dataDic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&err];
    if (!err && [dataDic isKindOfClass:[NSDictionary class]]) {
        NSInteger type = [[dataDic objectForKey:@"type"] integerValue];
        NSString *content = [dataDic objectForKey:@"content"];
        if (!type) {
            return;
        }
        switch (type) {
            case CB2Client_WIFI_PWD_TYPE:
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:[NSString stringWithFormat:@"%d",CB2Client_WIFI_PWD_TYPE] object:nil userInfo:dataDic]];
                break;
            case CB2Client_INSTALL_TYPE:{
                
                @try {
                    NSDictionary* installDone = @{@"pkgName":content,
                                                  @"statusCode":@2};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"InstallDoneCB" object:installDone];
                    
                } @catch (NSException *exception) {
                    BZLog(@" error:%@",exception);
                }

            }
                
                break;
                
            case CB2Client_UNINSTALL_TYPE:
                
                @try {
                    NSDictionary* unInstallInfo = @{@"pkgName":content,
                                                    @"statusCode":@3};
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"UnInstallDoneCB" object:unInstallInfo];
                   
                } @catch (NSException *exception) {
                    BZLog(@" error:%@",exception);
                }
                
                break;
            case CB2Client_DOWNLOAD_PROGRESS:{
                
                @try{
                    NSArray* progress = [content componentsSeparatedByString:@":"];
                    NSDictionary* progressInfo = [NSDictionary dictionaryWithObject:[progress objectAtIndex:1]      //key :appid value :progress
                                                                             forKey:[progress objectAtIndex:0]];
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"updataProgress" object:nil userInfo:progressInfo]];
                }@catch(NSException* exeception){
                    BZLog(@" ------error:%@",exeception);
                }
                
            }
                break;
            case CB2Client_DEVICEID:
                _bleModel.mDeviceId = content;
                break;
            case CB2Client_USER_INSTALLED_PACKAGES:{
               
                if ([content isEqualToString:@"end"]) {
                    NSMutableString *installPackages = [_installPackages copy];
                    _installPackages = nil;
                    @try {
                        NSDictionary* userinfo = [StringUtils json2Dict:installPackages];
                        if(userinfo == nil) return;
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"getAllInstallPkg" object:nil userInfo:userinfo]];
                    } @catch (NSException *exception) {
                        BZLog(@" error:%@",exception);
                    }
                    
                } else {
                    if(_installPackages == nil){
                        _installPackages = [[NSMutableString alloc] init];
                    }
                    [_installPackages appendString:content];
                }
            }
                
                break;
            case CB2Client_AR_GLASSES_NO_NETWORK:
                if ([content isEqualToString:@"7"]) {
                    showNetworkConnect = YES;
                    @try {
                        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"noNetworkTips" object:nil userInfo:nil]];
                    } @catch (NSException *exception) {
                        BZLog(@" error:%@",exception);
                    }
                }
                
                break;
            case CB2Client_CANCEL_DOWNLOADAPK:{
            
                NSDictionary* cancelInfo = [NSDictionary dictionaryWithObject:content      //key :appid value :appId value
                                                                       forKey:@"appId"];
        
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"ARCancelDownload" object:cancelInfo userInfo:nil]];
            }
                
               
                break;
            case CB2Client_DOWNLOADAPK_FINISHED:
                @try{
                    NSDictionary* finishInfo = [NSDictionary dictionaryWithObject:@"100"      //key :appid value :progress = 100
                                                                           forKey:content];
                    
                    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"downloadDone" object:nil userInfo:finishInfo]];
                }@catch(NSException* exeception){
                    BZLog(@" ------error:%@",exeception);
                }

                break;
            
            case CB2Client_DOWNLOADAPK_FAILUE:{
                
                NSDictionary* fail = [NSDictionary dictionaryWithObject:content      //key :appid value :appId value
                                                                       forKey:@"appId"];
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"downloadFail" object:fail userInfo:nil]];
            }
                break;
                
            default:
                BZLog(@"蓝牙回馈类型不存在：%ld", (long)type);
                break;
        }
    } else {
        BZLog(@"蓝牙回馈数据解析错误：%@", err);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
