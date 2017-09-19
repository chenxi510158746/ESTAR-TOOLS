//
//  ProduceEventThread.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EventRequest.h"
#import "BZLog.h"


/**
 构建游戏按键值线程
 */
@interface ProduceEventThread : NSThread

@property(strong,nonatomic) EventRequest* eventRequest;

@property(assign,nonatomic) BOOL terminated;

@property(assign,nonatomic) NSString* type;


/**
 初始构造类型与仓库

 @param type 发送游戏按键值
 @param eventRequest 构造队列请求器
 */
-(instancetype)initWithType:(NSString*) type andEventRequest:(EventRequest*) eventRequest;



/**
 线程运行，此处放线程运行逻辑
 */
-(void) run;

/**
 停止当前线程
 */
-(void) stop;



@end
