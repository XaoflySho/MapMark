//
//  DataController.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/12.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreDateManage.h"
#import "MarkMO+CoreDataClass.h"

@interface DataController : NSObject

+ (BOOL)markToDatabaseWithDate:(NSDate *)date locationLatitude:(double)latitude locationLongitude:(double)longitude address:(NSDictionary *)address;

+ (NSArray *)dataFromDatabaseWithDate:(NSDate *)date;

@end
