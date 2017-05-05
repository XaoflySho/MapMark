//
//  CoreDateManage.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/11.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface CoreDateManage : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, readonly) NSManagedObjectContext *managedObjectContext;

@end
