//
//  EntityUtils.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
  本类提供2种方法：
  方法一：根据实体转换为相应的字典
  方法二：根据字典转换为相应的实体对象
  其中方法均为类方法
 */
@interface BZEntityUtils : NSObject



/**
 字典转换为相应实体对象

 @param dict 待转换的字典
 @param entity 转换后的实体
 */
+ (void) dict2Obj:(NSDictionary *)dict entity:(NSObject*)entity;



/**
 对象转换为字体
 
 @param entity 待转换的对象
 @return 返回转换后的字典对象，其中实体的属性为键，属性对应值为字典值
 */
+ (NSDictionary *) obj2Dict:(id)entity;

@end
