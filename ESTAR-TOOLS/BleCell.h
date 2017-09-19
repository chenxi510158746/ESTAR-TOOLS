//
//  BleCell.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/3.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *bleNameLab;

@property (weak, nonatomic) IBOutlet UILabel *bleStatusLab;

@property (weak, nonatomic) IBOutlet UIImageView *bleImg;

@end
