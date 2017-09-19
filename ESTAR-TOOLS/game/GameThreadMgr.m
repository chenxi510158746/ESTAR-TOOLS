//
//  GameThreadMgr.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "GameThreadMgr.h"


@implementation GameThreadMgr

-(instancetype) initWithType:(id)type{
    
    if(self == [super init]){
        self.type = type;
        self.eventRequest = [[EventRequest alloc] init];
    }
    return self;
    
}

-(void)bindSendKeyListener:(void (^)(id type))send{
    self.send = send;
}

-(void) startThread{
    
    self.produceEventThread = [[ProduceEventThread alloc] initWithType:self.type andEventRequest:self.eventRequest];
    [self.produceEventThread start];
    
    
    self.sendEventThread = [[SendEventThread alloc] initWithEventRequest:self.eventRequest onSend:self.send];
    [self.sendEventThread start];

}

-(void) stopThread{
    
    if(self.produceEventThread){
        
        [self.produceEventThread stop];
        self.produceEventThread = nil;
    }
    
    if(self.sendEventThread){
        
        [self.sendEventThread stop];
        self.sendEventThread = nil;
    }
}

@end
