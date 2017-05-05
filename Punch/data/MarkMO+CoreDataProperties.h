//
//  MarkMO+CoreDataProperties.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/11.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "MarkMO+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface MarkMO (CoreDataProperties)

+ (NSFetchRequest<MarkMO *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *address_city;
@property (nullable, nonatomic, copy) NSString *address_country;
@property (nullable, nonatomic, copy) NSString *address_country_code;
@property (nullable, nonatomic, copy) NSString *address_name;
@property (nullable, nonatomic, copy) NSString *address_state;
@property (nullable, nonatomic, copy) NSString *address_street;
@property (nullable, nonatomic, copy) NSString *address_sub_locality;
@property (nullable, nonatomic, copy) NSString *address_sub_thoroughfare;
@property (nullable, nonatomic, copy) NSString *address_thoroughfare;
@property (nullable, nonatomic, copy) NSDate *date;
@property (nullable, nonatomic, copy) NSString *formatted_address_lines;
@property (nonatomic) double location_latitude;
@property (nonatomic) double location_longitude;

@end

NS_ASSUME_NONNULL_END
