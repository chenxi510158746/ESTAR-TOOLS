//
//  StringUtils.m
//
//  Created by 刘小兵 on 2017/7/13.
//  Copyright © 2017年 刘小兵. All rights reserved.
//

#import "StringUtils.h"
#import "BZLog.h"

@implementation StringUtils


+(NSString* )dict2JSONString:(NSDictionary* )dict{
    
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    NSString *jsonString = @"";
    
    if (! jsonData){
        BZLog(@"转换失败: %@", error);
    }else{
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    jsonString = [jsonString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [jsonString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    
    return jsonString;
}

+(NSDictionary*) json2Dict:(NSString*) jsonString{

    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingAllowFragments
                                                          error:&err];
    
    if(err){
        BZLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

@end
