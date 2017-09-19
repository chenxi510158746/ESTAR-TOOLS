//
//  AppItemCell.h
//  spirit
//
//  Created by 刘小兵 on 2017/7/11.
//  Copyright © 2017年 刘小兵. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#import "AppModel.h"


@interface AppItemCell : UITableViewCell

/**
 * 取代self
 * 主要用于添加约束进行屏幕适配
 */
@property (nonatomic, weak) UIView *bgView;

@property(strong,nonatomic) UIImageView* img_AppIcon;

@property(strong,nonatomic) UILabel* label_RowNo;

@property(strong,nonatomic) UILabel* label_AppName;

@property(strong,nonatomic) UILabel* label_FileSize;

@property(strong,nonatomic) UIButton* btn_DownloadOrUninstall;

@property(strong,nonatomic) UIProgressView* pro_DownProgressBar;

@property(strong,nonatomic) UIImageView* img_cancelDownload;

@property(strong,nonatomic) UILabel* label_cancelDownload;

@property(strong,nonatomic) UIView* view_CancelLayout;

@property(strong,nonatomic) AppModel* data;


-(void) initItemView;

-(void) bindData:(AppModel*_Nonnull) data;


-(void)sendAppInfo2Server:(NSString*_Nonnull)type andMsg:(NSString* _Nonnull) msg;


@end
