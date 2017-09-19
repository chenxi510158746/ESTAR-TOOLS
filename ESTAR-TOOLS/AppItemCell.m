//
//  AppItemCell.m
//  spirit
//
//  Created by 刘小兵 on 2017/7/11.
//  Copyright © 2017年 刘小兵. All rights reserved.
//

#import "AppItemCell.h"
#import "defines/Constants.h"
#import "NSBundle+MJRefresh.h"
#import "MJRefreshConst.h"
#import "UIImageView+WebCache.h"
#import "BleModel.h"
#import "SVProgressHUD.h"
#import "ConstantConfig.h"
#import "BZLog.h"

@implementation AppItemCell

//@override 重载父类方法
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{

    if (self=[super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initItemView];
    }
    return self;

}

/**
 * override bgView的读属性方法
 * 使用懒加载方式
 */
- (UIView *)bgView {
    if (!_bgView) {
        UIView *bgView = [[UIView alloc] init];
        _bgView = bgView;
        
        [self addSubview:bgView];
    }
    return _bgView;
}


-(void) initItemView{
    
    //添加bgView约束属性
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    //设置行号
    self.label_RowNo = [[UILabel alloc] init];
    self.label_RowNo.textColor = [UIColor colorWithRed:103.0 / 255.0 green:103.0 / 255.0 blue:103.0 / 255.0 alpha:1.0];
    self.label_RowNo.font = [UIFont systemFontOfSize:18];
    [self.bgView addSubview: self.label_RowNo];
    [self.label_RowNo mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(13);
        make.centerY.equalTo(self.bgView);
    }];
    
    
    //初始appIcon图标
    self.img_AppIcon = [[UIImageView alloc] init];
    [self.bgView addSubview:self.img_AppIcon];
    [self.img_AppIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(33.0);
        make.centerY.equalTo(self.bgView);
        make.size.mas_equalTo(CGSizeMake(61.0, 61.0));
    }];
    
    
    //初始appName
    self.label_AppName = [[UILabel alloc] init];
    self.label_AppName.textColor = [UIColor colorWithRed:52.0 / 255.0 green:52.0 / 255.0 blue:52.0 / 255.0 alpha:1.0];
    self.label_AppName.font = [UIFont systemFontOfSize:16];
    [self.bgView addSubview: self.label_AppName];
    [self.label_AppName mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(101.0);
        make.top.equalTo(self.bgView).offset(38.0);
    }];
    
    //初始文件大小
    self.label_FileSize = [[UILabel alloc] init];
    self.label_FileSize.textColor = [UIColor colorWithRed:103.0 / 255.0 green:103.0 / 255.0 blue:103.0 / 255.0 alpha:1.0];
    self.label_FileSize.font = [UIFont systemFontOfSize:13];
    [self.bgView addSubview: self.label_FileSize];
    [self.label_FileSize mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label_AppName).offset(0);
        make.top.equalTo(self.bgView).offset(65.0);
    }];
    
    
    
    //初始下载/卸载按钮
    self.btn_DownloadOrUninstall = [[UIButton alloc] init];
    self.btn_DownloadOrUninstall.layer.cornerRadius = 5;
    self.btn_DownloadOrUninstall.titleLabel.font = [UIFont systemFontOfSize:14];
    //self.btn_DownloadOrUninstall.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:145.0 / 255.0 blue:2 / 255.0 alpha:1.0];
    self.btn_DownloadOrUninstall.titleLabel.textColor = [UIColor whiteColor];
    [self.btn_DownloadOrUninstall addTarget:self action:@selector(onDownload:) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:self.btn_DownloadOrUninstall];
    [self.btn_DownloadOrUninstall mas_makeConstraints:^(MASConstraintMaker *make){
        make.size.mas_equalTo(CGSizeMake(90.0, 41.0));
        make.centerY.equalTo(self.bgView);
        make.right.equalTo(self.bgView).offset(-13);
    }];
    
    
    //初始下载进度条背景
    self.view_CancelLayout = [[UIView alloc] init];
    self.view_CancelLayout.hidden = true;
    //self.view_CancelLayout.backgroundColor = [UIColor yellowColor];
    [self.bgView addSubview:self.view_CancelLayout];
    [self.view_CancelLayout mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bgView).offset(0.0);
        make.size.mas_equalTo(CGSizeMake(SCREEN_WIDTH, 30.0));
        make.bottom.equalTo(self.bgView).offset(0.0);
    }];
    
    
    self.pro_DownProgressBar = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    
    self.pro_DownProgressBar.tintColor = [UIColor colorWithRed:242.0 / 255.0 green:32.0 / 255.0 blue:32.0 / 255.0 alpha:1.0];
    self.pro_DownProgressBar.backgroundColor = [UIColor colorWithRed:199.0 / 255.0 green:199.0 / 255.0 blue:199.0 / 255.0 alpha:1.0];
    //self.pro_DownProgressBar.progress = 0.5;
    [self.view_CancelLayout addSubview:self.pro_DownProgressBar];
    [self.pro_DownProgressBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.label_RowNo).offset(0.0);
        make.height.mas_equalTo(15.0);
        make.centerY.equalTo(self.view_CancelLayout);
        make.right.equalTo(self.view_CancelLayout).offset(-103);
    }];
    
    //添加取消图标
    self.img_cancelDownload = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"download_app_cancel.png"]];
    self.img_cancelDownload.userInteractionEnabled = YES;
    self.img_cancelDownload.contentMode = UIViewContentModeScaleAspectFit;
    UITapGestureRecognizer *singleTap =[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onCancel)];
    [self.img_cancelDownload addGestureRecognizer:singleTap];
    [self.view_CancelLayout  addSubview:self.img_cancelDownload];
    
    [self.img_cancelDownload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(22, 22));
        make.centerY.equalTo(self.view_CancelLayout);
        make.right.equalTo(self.view_CancelLayout).offset(-64);
    }];

    //添加取消文本
    self.label_cancelDownload = [[UILabel alloc] init];
    self.label_cancelDownload.text = NSLocalizedString(@"STORE_CANCEL", nil);
    self.label_cancelDownload.font = [UIFont systemFontOfSize:14];
    self.label_cancelDownload.textColor = [UIColor colorWithRed:143.0 / 255.0 green:143.0 / 255.0 blue:143.0 / 255.0 alpha:1.0];
    [self.view_CancelLayout addSubview:self.label_cancelDownload];
    
    [self.label_cancelDownload mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.view_CancelLayout);
        make.right.equalTo(self.view_CancelLayout).offset(-22);
    }];
    
    

}

-(void) bindData:(AppModel*) data{
    
    if(self.data != data){
        self.data = data;
        if([self.data fDowmloadProgress] > 0){
            self.view_CancelLayout.hidden = false;
            self.pro_DownProgressBar.hidden = false;
            self.pro_DownProgressBar.progress = [self.data fDowmloadProgress];
            
            if([self.data fDowmloadProgress] >= 0.95){
                self.view_CancelLayout.hidden = true;
                [self.data setFDowmloadProgress:0.0];
                [self.data setBtnStatus:2];
                
            }
        }else{
            self.view_CancelLayout.hidden = true;
        }
        self.label_RowNo.text = [NSString stringWithFormat:@"%ld", (long)[self.data nRowNO]];
        self.label_AppName.text = [self.data mAppName];
        self.label_FileSize.text = [self byteFormat:self.data.mSize];
        [self.img_AppIcon sd_setImageWithURL:[NSURL URLWithString:self.data.mAppIcon] placeholderImage:[UIImage imageNamed:@"icon-armarket.png"]];
        
       
        if([self.data btnStatus] == 2){
            self.btn_DownloadOrUninstall.backgroundColor = [UIColor colorWithRed:16.0 / 255.0 green:182.0 / 255.0 blue:36.0 / 255.0 alpha:1.0];
            NSString* sUninstall = NSLocalizedString(@"STORE_UNINSTALL", nil);
            [self.btn_DownloadOrUninstall setTitle:sUninstall forState:UIControlStateNormal];
            self.data.fDowmloadProgress = 0.0;
            self.view_CancelLayout.hidden = true;
        }else{
            self.btn_DownloadOrUninstall.backgroundColor = [UIColor colorWithRed:255.0 / 255.0 green:145.0 / 255.0 blue:2 / 255.0 alpha:1.0];
            NSString* sDownload = NSLocalizedString(@"STORE_DOWNLOAD", nil);
            [self.btn_DownloadOrUninstall setTitle:sDownload forState:UIControlStateNormal];
        }
        
    }
    
    
}

- (void)onDownload:(UIButton *)button{
    
     NSString* AppId = [self.data mAppId];
    if([button.titleLabel.text isEqualToString:NSLocalizedString(@"STORE_DOWNLOAD", nil)]){
        [self sendAppInfo2Server:typeAppDownload andMsg:AppId];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"STORE_SEND_DOWNLOAD_INFO", nil)];
        
    }else{
        [self sendAppInfo2Server:typeAppUninstall andMsg:[self.data mAppPackage]];
        [SVProgressHUD showInfoWithStatus:NSLocalizedString(@"STORE_SEND_UNINSTALL", nil)];
    }
}
-(void)onCancel{
    self.data.fDowmloadProgress = 0.0;
    self.view_CancelLayout.hidden = true;
    [self sendAppInfo2Server:typeAppCancelDownload andMsg:[self.data mAppId]];
    
}

- (NSString *)byteFormat:(NSString *)size{
    double KSize = [size doubleValue];
    int GB = 1024 * 1024 * 1024;
    int MB = 1024 * 1024;
    int KB = 1024;
    if (KSize/GB >= 1) {
        return  [NSString stringWithFormat:@"%.2f GB", KSize/(float)GB];
    } else if (KSize/MB >= 1) {
        return [NSString stringWithFormat:@"%.2f MB", KSize/(float)MB];
    } else if (KSize/KB >= 1) {
        return [NSString stringWithFormat:@"%.2f KB", KSize/(float)KB];
    } else {
        return [NSString stringWithFormat:@"%f Byte", KSize];
    }
}

-(void)sendAppInfo2Server:(NSString*_Nonnull)type andMsg:(NSString* _Nonnull) msg{

    BleModel *bleModel = [BleModel sharedSingleton];
    if (bleModel.mPeripheral == nil || bleModel.mCharacterWrite == nil) {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"STORE_UNCONTECT_GLASS", nil)];
        [SVProgressHUD dismissWithDelay:1];
        return;
    }
    
    NSString *dataStr = [[NSString alloc] initWithFormat:@"{\"type\":%@,\"content\":\"%@\"}", type, msg];
    [bleModel.mPeripheral writeValue:[dataStr dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:bleModel.mCharacterWrite type:CBCharacteristicWriteWithResponse];
    BZLog(@" 发送消息类型为：type--:%@  msg---:%@",type,msg);
}



- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//
//    // Configure the view for the selected state
//}

@end
