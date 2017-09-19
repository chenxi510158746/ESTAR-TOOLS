//
//  VCGameOperation.m
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/7/6.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "VCGameOperation.h"
#import <AudioToolbox/AudioToolbox.h>
#import "BleModel.h"
#import "SVProgressHUD.h"
#import "ConstantConfig.h"
#import "BZLog.h"
#import "AudioToolbox/AudioToolbox.h"



@implementation VCGameOperation

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"startFullScreen" object:nil]];
    
    [self getBleModel];
    [self initGameCtrl];
    
}
-(void) initGameCtrl{
    
    self.btnLeft.tag = 21;
    self.btnUp.tag = 22;
    self.btnRight.tag = 23;
    self.btnDown.tag = 24;
    
    self.btnA.tag = 31;
    self.btnB.tag = 32;
    
    [self.btnLeft addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnUp addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnRight addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnDown addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    
    [self.btnA addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    [self.btnB addTarget:self action:@selector(onActionDown:) forControlEvents:UIControlEventTouchDown];
    
    
    [self.btnLeft addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnUp addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnRight addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnDown addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.btnA addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnB addTarget:self action:@selector(onActionUp:) forControlEvents:UIControlEventTouchUpInside];
    
    self.queSerial = dispatch_queue_create("BZGameQueue", DISPATCH_QUEUE_SERIAL);
    
}

-(NSMutableArray*) getGameKeyList{
    if(self.gameKeyList == nil){
        self.gameKeyList = [[NSMutableArray alloc] init];
    }
    return self.gameKeyList;
}

- (void)onActionDown:(UIButton *)button{
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    __weak VCGameOperation* weakSelf = self;
    
    switch(button.tag){
            
        case 21:{
            
            self.leftKeyThread = [[GameThreadMgr alloc] initWithType:contentGameLeft];
            [self.leftKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
            }];
            [self.leftKeyThread startThread];
        }
            break;
            
        case 22:{
            
            self.upKeyThread = [[GameThreadMgr alloc] initWithType:contentGameUp];
            [self.upKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
            }];
            [self.upKeyThread startThread];
        }
            
            
            break;
            
        case 23:{
            self.rightKeyThread = [[GameThreadMgr alloc] initWithType:contentGameRight];
            [self.rightKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
                
            }];
            [self.rightKeyThread startThread];
            
        }
            
            
            break;
            
        case 24:{
            self.downKeyThread = [[GameThreadMgr alloc] initWithType:contentGameDown];
            [self.downKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
            }];
            [self.downKeyThread startThread];
        }
            
            break;
            
        case 31:{
            self.aKeyThread = [[GameThreadMgr alloc] initWithType:contentGameA];
            [self.aKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
                
            }];
            [self.aKeyThread startThread];
        }
            
            break;
            
        case 32:{
            self.bKeyThread = [[GameThreadMgr alloc] initWithType:contentGameB];
            [self.bKeyThread bindSendKeyListener:^(id type){
                __strong VCGameOperation* strongSelf = weakSelf;
                [[strongSelf getGameKeyList] addObject:type];
                [strongSelf addGameKeyTask2Queue];
            }];
            [self.bKeyThread startThread];
        }
            
            break;
    }
    
    
}

-(void)onActionUp:(UIButton*) button{
    
    switch(button.tag){
            
        case 21:
            [self.leftKeyThread stopThread];
            
            break;
            
        case 22:
            [self.upKeyThread stopThread];
            break;
            
        case 23:
            [self.rightKeyThread stopThread];
            break;
            
        case 24:
            [self.downKeyThread stopThread];
            break;
            
        case 31:
            [self.aKeyThread stopThread];
            break;
            
        case 32:
            [self.bKeyThread stopThread];
            break;
    }
    
    
    
}


-(void)addGameKeyTask2Queue{
    __weak VCGameOperation* weakSelf = self;
    dispatch_async(self.queSerial, ^{
        __strong VCGameOperation* strongSelf = weakSelf;
        if([[strongSelf getGameKeyList] count] > 0 ){
            [self sendDataWithType:typeGame andContent:[[strongSelf getGameKeyList] objectAtIndex:0]];
            BZLog(@"send key is %@ ",[[strongSelf getGameKeyList] objectAtIndex:0]);
            [[strongSelf getGameKeyList] removeObjectAtIndex:0];
        }
        
    });
    
}

-(void)viewWillDisappear:(BOOL)animated{
    
    [self.gameKeyList removeAllObjects];
    self.gameKeyList = nil;
    self.leftKeyThread = nil;
    self.upKeyThread = nil;
    self.rightKeyThread = nil;
    self.downKeyThread = nil;
    self.aKeyThread = nil;
    self.bKeyThread = nil;
    
}

- (IBAction)gameBack:(id)sender {
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"endFullScreen" object:nil]];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)PauseOrStart:(id)sender{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    [[self getGameKeyList] addObject:contentGamePause];
    [self addGameKeyTask2Queue];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
