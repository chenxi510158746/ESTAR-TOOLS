//
//  EventRequest.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 本类为游戏手按键值发送与构建中心
 */
@interface EventRequest : NSObject


@property(strong,nonatomic) NSMutableArray* requestQueue;

@property(assign,nonatomic)NSInteger  count;

@property(strong,nonatomic) NSCondition* condition;


/**
 构建游戏按键值到队列中

 @param request 待添加到发送队列中的游戏按键值
 */
-(void)buildEvent:(id)request;


/**
 发送游戏按键值

 @return 取出队列中队头元素
 */
-(id)sendEvent;

@end
