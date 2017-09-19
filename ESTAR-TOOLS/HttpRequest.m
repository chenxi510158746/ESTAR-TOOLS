//
//  HttpRequest.m
//
//  Created by chenxi on 2017/6/19.
//  Copyright © 2017年 chenxi. All rights reserved.
//

#import "HttpRequest.h"
#import "AFNetworking.h"
#import "MD5Helper.h"
#include "crypt.h"
#import "AppModel.h"
#import "VCApplication.h"
#import "SVProgressHUD.h"
#import "BZLog.h"

@implementation HttpRequest

NSString * const appId = @"1";

NSString * const appSecret = @"M4urJXS5bo7E9OEq";

NSString * const getTokenUrl = @"https://app.espacetime.com/index.php?r=api/get/token";

NSString * const appListUrl = @"https://app.espacetime.com/index.php?r=api/app/list";

NSInteger networkStatus;

+ (void) netMonitor
{
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        networkStatus = status;
        switch (status) {
            case AFNetworkReachabilityStatusReachableViaWiFi:
                BZLog(@"WIFI网络连接！");
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                BZLog(@"蜂窝数据网络连接!");
                break;
            case AFNetworkReachabilityStatusUnknown:
                BZLog(@"未知网络！");
                break;
            case AFNetworkReachabilityStatusNotReachable:
                BZLog(@"无网络连接！");
                break;
            default:
                break;
        }
    }];
}

+ (void) getToken:(id)VC loadType:(NSString *)loadType
{
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
    
    security.allowInvalidCertificates = YES;
    
    security.validatesDomainName = NO;
    
    manager.securityPolicy = security;
    
    [manager.requestSerializer setValue:appId forHTTPHeaderField:@"App-Id"];
    
    [manager.requestSerializer setValue:[MD5Helper MD5ForLower32Bate:appSecret] forHTTPHeaderField:@"App-Secret"];
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_enter(group);
    [manager GET:getTokenUrl parameters:nil progress:nil
         success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
             
             NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
             
             NSDictionary *headers = response.allHeaderFields;
             
             if ([[headers objectForKey:@"Status"] isEqualToString:@"True"]) {
                 
                 NSError *err = nil;
                 
                 NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&err];
                 if (!err && [resultDic isKindOfClass:[NSDictionary class]]) {
                     //处理数据
                     NSString *accessToken = [resultDic objectForKey:@"accessToken"];
                     //C语言算法解密
                     char *dec = NULL;
                     const char *enc = [accessToken UTF8String];
                     const char *key = [appSecret UTF8String];
                     crypt_decode(enc, &dec, key, 0);
                     
                     NSString *token = [NSString stringWithUTF8String:dec];
                     
                     NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
                     
                     [userDefault setObject:token forKey:@"token"];
                     dispatch_group_leave(group);
                     BZLog(@"token：%@", token);
                 } else {
                     NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                     BZLog(@"服务器返回数据解析错误：%@", result);
                 }
             } else {
                 NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                 BZLog(@"服务器返回 Status: %@ result: %@", [headers objectForKey:@"Status"], result);
             }
         } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             BZLog(@"服务器连接失败！%@", error);
         }];
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        if ([loadType isEqualToString:@"appList"]) {
            [VC loadData];
        }
    });
}

+ (void) appList:(NSDictionary *)parameters VC:(id)VC
{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *token = [userDefault objectForKey:@"token"];
    __block int times = 0;
    if (token) {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        
        manager.responseSerializer = [AFHTTPResponseSerializer serializer];
        
        AFSecurityPolicy *security = [AFSecurityPolicy defaultPolicy];
        
        security.allowInvalidCertificates = YES;
        
        security.validatesDomainName = NO;
        
        manager.securityPolicy = security;
        
        [manager.requestSerializer setValue:appId forHTTPHeaderField:@"App-Id"];
        
        NSError *parseError = nil;
        
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parameters options:kNilOptions error:&parseError];
        if (parseError) {
            BZLog(@"parseError：%@", parseError);
            return ;
        }
        
        NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        NSString *dataMask = [[MD5Helper MD5ForLower32Bate:jsonStr] stringByAppendingString:token];
        
        [manager.requestSerializer setValue:[MD5Helper MD5ForLower32Bate:dataMask] forHTTPHeaderField:@"Data-Mask"];
        //[SVProgressHUD show];
        [manager POST:appListUrl parameters:parameters progress:nil
              success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                  NSHTTPURLResponse *response = (NSHTTPURLResponse *)task.response;
                  
                  NSDictionary *headers = response.allHeaderFields;
                  
                  if ([[headers objectForKey:@"Status"] isEqualToString:@"True"]) {
                      
                      NSError *err = nil;
                      
                      NSDictionary *resultDic = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&err];
                      if (!err && [resultDic isKindOfClass:[NSDictionary class]]) {
                          
                          [VC showData:resultDic];
                          
                      } else {
                          NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                          BZLog(@"服务器返回数据解析错误：%@", result);
                      }
                  } else if (times == 0 && ([[headers objectForKey:@"Status"] isEqualToString:@"AccessTokenExpired"] || [[headers objectForKey:@"Status"] isEqualToString:@"DataMaskError"])) {
                      times = 1;
                      [self getToken:VC loadType:@"appList"];
                  } else {
                      NSString *result = [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
                      BZLog(@"服务器返回 Status: %@ result: %@", [headers objectForKey:@"Status"], result);
                  }
                  //[SVProgressHUD dismiss];
              } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                  BZLog(@"服务器连接失败！%@", error);
                  //[SVProgressHUD dismiss];
              }];
    }
}

@end
