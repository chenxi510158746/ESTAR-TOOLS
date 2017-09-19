//
//  SendEventThread.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRequest.h"
#import "BZLog.h"


/**
 发送游戏按键值线程
 */
@interface SendEventThread : NSThread

@property(strong,nonatomic) EventRequest* eventRequest;

@property(assign,nonatomic) BOOL terminated;

@property(assign,nonatomic) NSString* type;


@property (nonatomic,strong) void (^send)(id type);       //发送游戏按键的block块



/**
 构造器

 @param eventRequest 游戏按键发送队列
 @param send 发送回调
 */
-(instancetype)initWithEventRequest:(EventRequest*) eventRequest onSend:(void(^)(id type))send;


/**
 线程运行，此处放线程运行逻辑
 */
-(void) run;

/**
 停止当前线程
 */
-(void) stop;


@end
