//
//  EventRequest.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/19.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "EventRequest.h"
#import "BZLog.h"

@implementation EventRequest

- (instancetype)init{
    if(self == [super init]){
        self.requestQueue = [[NSMutableArray alloc] init];
        self.count = 0;
        self.condition = [[NSCondition alloc] init];
    }
    return self;
}

-(void) buildEvent:(id)request{
    
    
    @try{
        
        [self.condition lock];
        
        while([self.requestQueue count] != 0 && self.count >= 2){
            
            [self.condition wait];
            
        }
        
        [self.requestQueue addObject:request];
        self.count ++;
        [self.condition signal];
        
    }@catch(NSException *exception){
        
        BZLog(@"游戏按键值构建失败,本线程即将终止 %@",exception);
        
    }@finally{
        
        [self.condition unlock];
    }
    
}

-(id)sendEvent{
    
    @try{
        
        [self.condition lock];
        
        while(self.count <= 0 || [self.requestQueue count] <= 0){
            
            [self.condition wait];
        }
        
        id obj = [self.requestQueue objectAtIndex:0];
        [self.requestQueue removeObjectAtIndex:0];
        self.count --;
        [self.condition signal];
        return obj;
        
    }@catch(NSException* exception){
        
        BZLog(@"发送游戏按键值失败，本线程即将终止 %@",exception);
        
    }@finally{
        
        [self.condition unlock];
    }
}

@end
