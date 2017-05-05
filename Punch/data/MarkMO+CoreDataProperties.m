//
//  MarkMO+CoreDataProperties.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/11.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "MarkMO+CoreDataProperties.h"

@implementation MarkMO (CoreDataProperties)

+ (NSFetchRequest<MarkMO *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"Mark"];
}

@dynamic address_city;
@dynamic address_country;
@dynamic address_country_code;
@dynamic address_name;
@dynamic address_state;
@dynamic address_street;
@dynamic address_sub_locality;
@dynamic address_sub_thoroughfare;
@dynamic address_thoroughfare;
@dynamic date;
@dynamic formatted_address_lines;
@dynamic location_latitude;
@dynamic location_longitude;

@end
