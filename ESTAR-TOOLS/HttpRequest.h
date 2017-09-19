//
//  HttpRequest.h
//
//  Created by chenxi on 2017/6/19.
//  Copyright © 2017年 chenxi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpRequest : NSObject

extern NSString * _Nonnull const appId;

extern NSString * _Nonnull const appSecret;

extern NSString * _Nonnull const getTokenUrl;

extern NSString * _Nonnull const appListUrl;

+ (void) netMonitor;

+ (void) getToken:(id _Nonnull ) VC loadType:(NSString * _Nullable) loadType;

+ (void) appList:(nullable NSDictionary *) parameters VC:(id _Nonnull ) VC;

@end
