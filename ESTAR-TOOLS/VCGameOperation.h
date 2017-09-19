//
//  VCGameOperation.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/6.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GameThreadMgr.h"
#import "VCBase.h"

@interface VCGameOperation : VCBase

@property (weak, nonatomic) IBOutlet UIButton *btnBack;

@property (weak, nonatomic) IBOutlet UIButton *btnUp;

@property (weak, nonatomic) IBOutlet UIButton *btnRight;

@property (weak, nonatomic) IBOutlet UIButton *btnDown;

@property (weak, nonatomic) IBOutlet UIButton *btnLeft;

@property (weak, nonatomic) IBOutlet UIButton *btnY;

@property (weak, nonatomic) IBOutlet UIButton *btnX;

@property (weak, nonatomic) IBOutlet UIButton *btnA;

@property (weak, nonatomic) IBOutlet UIButton *btnB;

@property (weak, nonatomic) IBOutlet UIImageView *imgBg;

@property (weak, nonatomic) IBOutlet UIImageView *imgCircleLeft;

@property (weak, nonatomic) IBOutlet UIImageView *imgCircleRight;

@property (weak, nonatomic) IBOutlet UIImageView *imgBCenter;

@property (weak, nonatomic) IBOutlet UIButton *btnPause;
- (IBAction)PauseOrStart:(id)sender;

@property(strong,nonatomic) GameThreadMgr* leftKeyThread;
@property(strong,nonatomic) GameThreadMgr* rightKeyThread;
@property(strong,nonatomic) GameThreadMgr* upKeyThread;
@property(strong,nonatomic) GameThreadMgr* downKeyThread;

@property(strong,nonatomic) GameThreadMgr* aKeyThread;
@property(strong,nonatomic) GameThreadMgr* bKeyThread;
@property(strong,nonatomic) NSMutableArray* gameKeyList;
@property(strong,nonatomic)dispatch_queue_t queSerial;

-(void) initGameCtrl;
-(NSMutableArray*) getGameKeyList;
-(void) addGameKeyTask2Queue;


@end
