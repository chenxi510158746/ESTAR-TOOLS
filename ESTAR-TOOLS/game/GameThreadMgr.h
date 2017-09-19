//
//  GameThreadMgr.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ProduceEventThread.h"
#import "SendEventThread.h"
#import "EventRequest.h"


/**
 线程管理类，主要管理生命周期与游戏按键数据仓库
 */
@interface GameThreadMgr : NSObject


@property(assign,nonatomic) id type;

@property(strong,nonatomic) EventRequest* eventRequest;

@property(strong,nonatomic) ProduceEventThread* produceEventThread;

@property(strong,nonatomic) SendEventThread* sendEventThread;

@property (nonatomic,strong) void (^send)(id type);       //发送游戏按键的block块

-(instancetype) initWithType:(id) type;


/**
 绑定发送游戏按键值的监听器

 @param send 发送回调
 */
-(void) bindSendKeyListener:(void(^)(id type))send;


-(void) startThread;


-(void) stopThread;


@end
