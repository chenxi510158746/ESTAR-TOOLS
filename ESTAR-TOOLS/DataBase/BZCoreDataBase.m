//
//  BZCoreDataBase.m
//  ESTAR-TOOLS
//
//  Created by 刘小兵 on 2017/7/18.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import "BZCoreDataBase.h"

@implementation BZCoreDataBase


@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;




- (instancetype)initWithCoreData:(NSString *)entityName
                       modelName:(NSString *)modelName
                         sqlPath:(NSString *)sqlPath
                         success:(void(^)(void))success
                            fail:(void(^)(NSError *error))fail{
    if (self = [super init]) {
        self.entityName = entityName;
        self.modelName = modelName;
        self.sqlPath = sqlPath;
        
        [self managedObjectContext];        //初始化对象上下文
        
        [self managedObjectModel];          //创建模型
        
        [self persistentStoreCoordinator];  //初始对象操作条件
        
    }
    
    return self;
}



#pragma mark - Core Data 堆栈
//返回 被管理的对象上下文
- (NSManagedObjectContext *)managedObjectContext{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// 返回 持久化存储协调者
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:self.sqlPath];
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
    NSError *error = nil;
    [_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType
                                              configuration:nil
                                                        URL:storeURL
                                                    options:nil
                                                      error:nil];
    
    if (error) {
        NSLog(@"添加数据库失败:%@",error);
    } else {
        NSLog(@"添加数据库成功");
    }
    
    
    return _persistentStoreCoordinator;
}

//  返回 被管理的对象模型
- (NSManagedObjectModel *)managedObjectModel{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:self.modelName withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

#pragma mark - 应用程序沙箱
// 返回应用程序Docment目录的NSURL类型
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

// 添加数据
- (void)insertNewEntity:(NSDictionary *)dict success:(void(^)(void))success fail:(void(^)(NSError *error))fail{
    
    if (!dict||dict.allKeys.count == 0) return;
    
    // 通过传入上下文和实体名称，创建一个名称对应的实体对象（相当于数据库一组数据，其中含有多个字段）
    NSManagedObject *newEntity = [NSEntityDescription insertNewObjectForEntityForName:self.entityName inManagedObjectContext:_managedObjectContext];
    
    // 实体对象存储属性值（相当于数据库中将一个值存入对应字段)
    for (NSString *key in [dict allKeys]) {
        [newEntity setValue:[dict objectForKey:key] forKey:key];
    }
    
    // 保存信息，同步数据
    NSError *error = nil;
    BOOL result = [_managedObjectContext save:&error];
    if (!result) {
        if (fail) {
            fail(error);
        }
    } else {
        if (success) {
            success();
        }
    }
}


-(void)queryAll:(void(^)(NSMutableArray *results))success onFail:(void(^)(NSError *error))fail{
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.entityName inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    //    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
    //
    //    [request setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if(error){
        if(fail){
            fail(error);
        }
    }else{
        if(success){
            NSMutableArray *resListData = [[NSMutableArray alloc] init];
            [resListData addObjectsFromArray:listData];
            success(resListData);

            
        }
        
    }
}

-(void)queryWithKey:(NSString*) key forValue:(NSString*)value onSuccess:(void(^)(NSMutableArray *results))success onFail:(void(^)(NSError *error))fail{
    
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.entityName inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    //声明指定查询条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
    
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if(error){
        if(fail){
            fail(error);
        }
    }else{
        if(success){
            NSMutableArray *resListData = [[NSMutableArray alloc] init];
            [resListData addObjectsFromArray:listData];
            success(resListData);
            
        }
        
    }
    
}



-(void)deleteAll:(void (^)(void))success onFail:(void (^)(NSError *))fail{
    
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.entityName inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        for(id obj in listData){
            [self.managedObjectContext deleteObject:obj];
        }
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            if(success){
                success();
            }
            
        } else {
            if(fail){
                fail(savingError);
            }
        }
    }
    
}

-(void)deleteWithKey:(NSString*)key forValue:(NSString*)value onSuccess:(void(^)(void)) success onFail:(void(^)(NSError* error)) fail{
    
    
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.entityName inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    //声明删除条件
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@",key,value];
    
    
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    
    if ([listData count] > 0) {
        
        for(id obj in listData){
            [self.managedObjectContext deleteObject:obj];
        }
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            if(success){
                success();
            }
            
        } else {
            if(fail){
                fail(savingError);
            }
        }
    }
}


//todo
-(void)updateWith:(NSString*) info
          addData:(NSString*) newData
        onSuccess:(void(^)(void))success
           onFail:(void(^)(NSError *error))fail{
    
    
    NSManagedObjectContext *cxt = [self managedObjectContext];
    
    NSEntityDescription *entityDescription = [NSEntityDescription
                                              entityForName:self.entityName inManagedObjectContext:cxt];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDescription];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name = %@", info];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *listData = [cxt executeFetchRequest:request error:&error];
    if ([listData count] > 0) {
        
        //todo
//        for(id obj in listData){
//            
//            StudentMgrObj *note = obj;
//            note.name = newData;
//        }
        
        
        NSError *savingError = nil;
        if ([self.managedObjectContext save:&savingError]){
            if(success){
                success();
            }
        } else {
            if(fail){
                fail(error);
            }
            
        }
    }
    
    
}


@end
