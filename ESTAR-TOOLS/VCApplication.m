//
//  VCApplication.m
//
//  Created by chenxi on 2017/6/16.
//  Copyright © 2017年 chenxi. All rights reserved.
//

#import "VCApplication.h"
#import "AppModel.h"
#import "UIImageView+WebCache.h"
#import "HttpRequest.h"
#import "AppItemCell.h"
#import "MJRefresh.h"
#import "Masonry.h"
#import "BZMarketRefrehHeader.h"
#import "NSBundle+MJRefresh.h"
#import "BZLog.h"
#import "BleModel.h"
#import "ConstantConfig.h"
#import "StringUtils.h"
#import "AppItemEmptyView.h"

extern NSInteger networkStatus;
@implementation VCApplication


- (void)viewDidLoad {
    [super viewDidLoad];
    self.nCount = 0;
    self.screenSize = [self getScreenSize];
    [self createNavgationBar];
    [self createTableView];
    
    [self registerBrodcast];
    
   
}

-(void)registerBrodcast{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDownloadBtnStatus:) name:@"getAllInstallPkg" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressForAppId:) name:@"updataProgress" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateProgressForAppId:) name:@"downloadDone" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchBtnStatu:) name:@"UnInstallDoneCB" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(switchBtnStatu:) name:@"InstallDoneCB" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showNetworkDialog:) name:@"noNetworkTips" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(arCancelDownload:) name:@"ARCancelDownload" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFail:) name:@"downloadFail" object:nil];
}

-(void) viewWillDisappear:(BOOL)animated{
    
    [self removeBrodcast];
}
-(void) removeBrodcast{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"getAllInstallPkg" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"updataProgress" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadDone" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UnInstallDoneCB" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InstallDoneCB" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"noNetworkTips" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"ARCancelDownload" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"downloadFail" object:nil];

}

-(void)createNavgationBar{
    UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0, self.screenSize.size.width, 65)];
    //导航栏背景颜色
    [navBar setBarTintColor:[UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1]];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    //创建左边返回按钮
    UIButton* backView = [[UIButton alloc] initWithFrame:CGRectMake(10, 25, 100, 30)];
    [backView addTarget:self action:@selector(appBack) forControlEvents:UIControlEventTouchUpInside];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 7.5, 10, 15);
    backBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [backBtn setBackgroundImage:[UIImage imageNamed:@"back_arrow.jpg"] forState:UIControlStateNormal];
    [backView addSubview:backBtn];
    
    UILabel* backTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 50, 30)];
    backTitle.textColor = [UIColor whiteColor];
    backTitle.font = [UIFont systemFontOfSize:17.0];
    backTitle.text = NSLocalizedString(@"STORE_BACK", nil);
    [backView addSubview:backTitle];

    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithCustomView:backView];
    
    //创建标题文本
    NSString* title = NSLocalizedString(@"STORE_TITLE", nil);
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 25, 100, 30)];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSMutableAttributedString *AttributedStr = [[NSMutableAttributedString alloc]initWithString:title];
    
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor colorWithRed:255.0 / 255 green:163.0 / 255 blue:2.0 / 255 alpha: 1.0]
                          range:NSMakeRange(0, 2)];
    
    [AttributedStr addAttribute:NSForegroundColorAttributeName
                          value:[UIColor whiteColor]
                          range:NSMakeRange(2, AttributedStr.length - 2)];
    
    titleLabel.attributedText = AttributedStr;
    UITapGestureRecognizer *labelTapGestureRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(labelTouchUpInside:)];
    [titleLabel setUserInteractionEnabled:YES];
    [titleLabel addGestureRecognizer:labelTapGestureRecognizer];
    [navItem setTitleView:titleLabel];
    
    //将UINavigationItem添加到navgationBar中
    [navBar pushNavigationItem:navItem animated:NO];
    [navItem setLeftBarButtonItem:leftButton];
    [self.view addSubview:navBar];
}

-(void)appBack{
    [self setStatusBarBackgroundColor:nil];
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) labelTouchUpInside:(UITapGestureRecognizer *)recognizer{
    
    [_tableView setContentOffset:CGPointMake(0,0) animated:YES];

}

-(void)createTableView{
    
    _tableView = [[UITableView alloc] init];
    _tableView.backgroundColor = [UIColor whiteColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if ([userDefault objectForKey:@"token"] == nil) {
        [HttpRequest getToken:self loadType:nil];
    }
    
    _tableView.mj_header = [BZMarketRefrehHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadNewData)];
    
    _tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    _refreshCount = 1;
    _dataTotal = 0;
    
    [_tableView.mj_header beginRefreshing];
    //[self loadData];
    _arrayApps = [[NSMutableArray alloc] init];
    
    [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    [self.view addSubview:_tableView];

    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(0);
        make.top.equalTo(self.view).offset(65);
        make.size.mas_equalTo(CGSizeMake(self.screenSize.size.width, self.screenSize.size.height - 65));
    }];

}


-(void)showNetworkDialog:(NSNotification *)msg{

    [self showNetworkConfigDialog];
}

-(void) arCancelDownload:(NSNotification *)msg{

    NSDictionary* cancelInfo = [msg object];
    NSString* appId = [cancelInfo objectForKey:@"appId"];
    [self updateProgressForAppId:appId andProgress:@"0.0"];
}

-(void) downloadFail:(NSNotification *)msg{

    NSDictionary* cancelInfo = [msg object];
    NSString* appId = [cancelInfo objectForKey:@"appId"];
    [self updateProgressForAppId:appId andProgress:@"0.0"];
    
    NSString* failTips = NSLocalizedString(@"STORE_DOWNLOAD_FAIL", nil);
    [SVProgressHUD showErrorWithStatus:failTips];
    [SVProgressHUD dismissWithDelay:1];
    
}

-(void) updateDownloadBtnStatus:(NSNotification *)msg{
    
    NSDictionary* appItemInfo = msg.userInfo;
    [appItemInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSMutableArray* appItemArray = (NSMutableArray*) obj;
        
        [appItemArray enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL* stop){
            
            [self updateBtnStatusForPkgName:[NSString stringWithFormat:@"%@",obj] statusCode:2];
            
        }];
        
    }];
    
}

-(void) switchBtnStatu:(NSNotification *)msg{

    NSDictionary* appItemInfo = [msg object];
    
    [self updateBtnStatusForPkgName:[appItemInfo objectForKey:@"pkgName"]
                         statusCode:[[appItemInfo objectForKey:@"statusCode"] intValue]];

}


-(void)updateProgressForAppId:(NSNotification *)msg{
    
    NSDictionary* appItemInfo = msg.userInfo;
   
    [appItemInfo enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        CGFloat fProgress = [obj floatValue] / 100;
        [_arrayApps enumerateObjectsUsingBlock:^(id arrayobj,NSUInteger idx,BOOL* stop){
            
            AppModel* tmpItem = (AppModel*) arrayobj;
            if([[tmpItem mAppId] isEqual:key]){
                
              [self updateProgressForAppId:key andProgress:[NSString stringWithFormat:@"%f",fProgress]];
            }
        }];
        
    }];

}


-(void)updateProgressForAppId:(NSString*) appId andProgress:(NSString* )progress{
    
    [_arrayApps enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        AppModel* entity = (AppModel*) obj;
        if([[entity mAppId] isEqualToString:appId]){
            entity.fDowmloadProgress = [progress floatValue];
            
            // 使用局部刷新
            NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
            [_tableView reloadRowsAtIndexPaths:@[path] withRowAnimation:UITableViewRowAnimationNone];
        }
    }];

    
}

-(void)updateBtnStatusForPkgName:(NSString*) pkgName statusCode:(NSInteger) status{
    
    [_arrayApps enumerateObjectsUsingBlock:^(id obj,NSUInteger idx,BOOL* stop){
        
        AppModel* appModel = (AppModel*) obj;
        if([[appModel mAppPackage] isEqualToString:pkgName]){
            appModel.btnStatus = status;
            [_tableView reloadData];
        }
        
    }];
}

-(void) loadNewData{
    
    if(networkStatus == 0){
        [[BZAppItemCDUtils sharedInstance] queryAll:^(NSMutableArray* array){
            BZLog(@"无网络使用本地数据");
            [_arrayApps removeAllObjects];
            
            for (id obj in array) {
                
                AppItemModel* item = (AppItemModel*)obj;
                AppModel *app = [[AppModel alloc] init];
                app.mAppId = item.appId;
                app.mAppIcon = item.imgUrl;
                app.mAppName = item.appName;
                app.mAppPackage = item.pkgName;
                app.mSize = item.appSize;
                
                [_arrayApps addObject:app];
            }
            
            [_tableView reloadData];
            
        } onFail:^(NSError* error){
            BZLog(@"查询失败");
        }];

    }else{
        
        [_tableView.mj_header beginRefreshing];
        
        _refreshCount = 1;
        
        [_arrayApps removeAllObjects];
        
        [self loadData];
        
    }

    [_tableView.mj_footer resetNoMoreData];
    
    [_tableView.mj_header endRefreshing];
}

-(void) loadMoreData
{
    _refreshCount ++;
    
    [self loadData];
    
    if (_dataTotal > 0 && _arrayApps.count >= _dataTotal) {
        [_tableView.mj_footer endRefreshingWithNoMoreData];
    } else {
        [_tableView.mj_footer endRefreshing];
    }
}

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _arrayApps.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if([_arrayApps count] == 0){
    
        AppItemEmptyView* emptyView= [[AppItemEmptyView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EmptyView"];
        return emptyView;
    }
    
    AppItemCell* cell = [[AppItemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AppItem"];
    AppModel *data = [_arrayApps objectAtIndex:indexPath.row];
    data.nRowNO = indexPath.row + 1;
    [cell bindData:data];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 120.0;
}

- (void) loadData{
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    [parameters setValue:[[BleModel sharedSingleton] mDeviceId] forKey:@"deviceId"];
    [parameters setValue:@"appId,appIcon,appName,appPackage,size" forKey:@"fields"];
    [parameters setValue:@(_refreshCount) forKey:@"pageIndex"];
    [parameters setValue:@(6) forKey:@"limit"];
    
    [HttpRequest appList:parameters VC:self];
}


- (void) showData:(NSDictionary *) dataDic
{
    //加载数据
    NSArray *list = [dataDic objectForKey:@"list"];
    _dataTotal = [[dataDic objectForKey:@"total"] integerValue];
    
    for (NSDictionary *appDic in list) {
        //NSDictionary *appDic = [list objectAtIndex:i];
        
        AppModel *app = [[AppModel alloc] init];
        app.mAppId = [NSString stringWithFormat:@"%@",[appDic objectForKey:@"appId"]];
        app.mAppIcon = [appDic objectForKey:@"appIcon"];
        app.mAppName = [appDic objectForKey:@"appName"];
        app.mAppPackage = [appDic objectForKey:@"appPackage"];
        app.mSize = [appDic objectForKey:@"size"];
        
        [_arrayApps addObject:app];
        
        //缓存处理,只缓存6条记录,这里无需开启子线程作缓存处理
        self.nCount ++;
        if(self.nCount <= 6){
            AppItemModel* itemCache= [[AppItemModel alloc] init];
            itemCache.deviceId = [[BleModel sharedSingleton] mDeviceId];
            itemCache.appId = app.mAppId;
            itemCache.appName = app.mAppName;
            itemCache.pkgName = app.mAppPackage;
            itemCache.appSize = [NSString stringWithFormat:@"%@",app.mSize];
            itemCache.imgUrl = app.mAppIcon;
            [self saveAppInfo2DB:itemCache];
        }

    }
    
    [_tableView reloadData];
    
    [self sendDataWithType:typeAppInstallInfo andContent:@"getInstallApp"];
}

-(void)saveAppInfo2DB:(AppItemModel*) appCache{
    
    [[BZAppItemCDUtils sharedInstance] insertAppInfo:appCache onSuccess:^{
        BZLog(@"---------app信息缓存成功");
        
    } onFail:^(NSError* error){
        BZLog(@"---------app信息缓存失败");
    }];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
