//
//  SendEventThread.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "SendEventThread.h"

@implementation SendEventThread


-(instancetype) initWithEventRequest:(EventRequest *)eventRequest onSend:(void (^)(id type))send{
    
    self.eventRequest = eventRequest;
    
    self.send = send;
    
    self.terminated = NO;
    
    return [self initWithTarget:self selector:@selector(run) object:nil];
    
}

-(void)run{
    
    while(!self.terminated && !self.isCancelled){
        
        @try{
            
            if(self.send){
                self.type = [self.eventRequest sendEvent];
                self.send(self.type);
                
                if([self.type integerValue] == 99 || [self.type integerValue] == 118){
                    
                    [NSThread sleepForTimeInterval:0.18];
                }else{
                    [NSThread sleepForTimeInterval:0.09];
                }
                
            }
            
        }@catch(NSException* exeception){
            self.terminated = YES;
        }
    }
    
}


-(void)stop{
    
    self.terminated  = YES;
    [self cancel];
}

@end
