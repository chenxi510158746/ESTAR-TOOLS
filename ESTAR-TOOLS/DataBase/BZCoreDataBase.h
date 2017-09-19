//
//  BZCoreDataBase.h
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

/**
 注意数据缓存使用CoreData
 本类为操作CoreData的基类，目前只封装了通用用法
 操作具体的数据实体对象时请自行扩展本类
 */
@interface BZCoreDataBase : NSObject

/**
 *  获取数据库存储的路径
 */
@property (nonatomic,copy) NSString *sqlPath;
/**
 *  获取.xcdatamodeld文件的名称
 */
@property (nonatomic,copy) NSString *modelName;
/**
 *  获取.xcdatamodeld文件中创建的实体的名称
 */
@property (nonatomic,copy) NSString *entityName;


//被管理的对象上下文
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
//被管理的对象模型
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;
//持久化存储协调者
@property (strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory;


/**
 *  创建CoreData数据库
 *
 *  @param entityName 实体名称
 *  @param modelName  .xcdatamodeld文件名称(为nil则主动从程序包加载模型文件)
 *  @param sqlPath    数据库存储的路径
 *  @param success    成功回调
 *  @param fail       失败回调
 *
 *  @return 返回CoreDataAPI对象
 */
- (instancetype)initWithCoreData:(NSString *)entityName
                       modelName:(NSString *)modelName
                         sqlPath:(NSString *)sqlPath
                         success:(void(^)(void))success
                            fail:(void(^)(NSError *error))fail;

/**
 *  插入数据
 *
 *  @param dict 字典中的键值对必须要与实体中的每个名字一一对应
 *  @param success    成功回调
 *  @param fail       失败回调
 */
- (void)insertNewEntity:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail;



/**
 查询所有数据
 
 @param success 成功回调
 @param fail 失败回调
 */
-(void)queryAll:(void(^)(NSMutableArray *results))success onFail:(void(^)(NSError *error))fail;



/**
 根据指定的值查询信息
 
 @param key 数据库中字段名称
 @param value 查询的值
 @param success 成功回调
 @param fail 失败回调
 */
-(void)queryWithKey:(NSString*) key forValue:(NSString*)value onSuccess:(void(^)(NSMutableArray *results))success onFail:(void(^)(NSError *error))fail;



/**
 根据信息更新数据库中的数据
 
 @param condition 更新需要的key,在数据库当中比对的值
 @param newData 需要添加的数据
 @param success 成功回调
 @param fail 失败回调
 */
-(void)updateWith:(NSString*) condition
          addData:(NSString*) newData
        onSuccess:(void(^)(void))success
           onFail:(void(^)(NSError *error))fail;

/**
 删除所有数据
 
 @param success 成功回调
 @param fail 失败回调
 */
-(void) deleteAll:(void(^)(void))success onFail:(void(^)(NSError *error))fail;


/**
 根据指定值删除数据记录
 
 @param key 数据库的字段名称
 @param value 数据库字段名称对应的值
 @param success 成功的回调
 @param fail 失败回调
 */
-(void)deleteWithKey:(NSString*)key forValue:(NSString*)value onSuccess:(void(^)(void)) success onFail:(void(^)(NSError* error)) fail;


@end
