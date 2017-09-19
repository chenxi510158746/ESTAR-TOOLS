//
//  ProduceEventThread.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "ProduceEventThread.h"
#import "BZLog.h"

@implementation ProduceEventThread


-(instancetype)initWithType:(NSString *)type andEventRequest:(EventRequest *)eventRequest{
    
    self.eventRequest = eventRequest;
    
    self.type = type;
    
    self.terminated = NO;
    
    return [self initWithTarget:self selector:@selector(run) object:nil];
    
    
}


- (void) run{
    
    while(!self.terminated && !self.isCancelled){
        
        @try{
            [self.eventRequest buildEvent:self.type];
            
        }@catch(NSException *exception){
            
            self.terminated = YES;
        }
    }

}



-(void)stop{
    self.terminated  = YES;
    [self cancel];
    
}

@end
