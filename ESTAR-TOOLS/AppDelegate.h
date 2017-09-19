//
//  AppDelegate.h
//  ESTAR-TOOLS
//
//  Created by chenxi on 2017/6/30.
//  Copyright © 2017年 BaiZe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

/***  是否允许横屏的标记 */
@property (nonatomic,assign)BOOL allowRotation;

- (void)saveContext;


@end

