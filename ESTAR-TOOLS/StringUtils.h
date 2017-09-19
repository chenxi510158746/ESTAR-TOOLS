//
//  StringUtils.h
//
//  Created by 刘小兵 on 2017/7/13.
//  Copyright © 2017年 刘小兵. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *字符串工具类
 */
@interface StringUtils : NSObject


+(NSString* )dict2JSONString:(NSDictionary* )dict;

+(NSDictionary*) json2Dict:(NSString*) jsonString;


@end
