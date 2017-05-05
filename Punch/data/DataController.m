//
//  DataController.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/12.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "DataController.h"

@implementation DataController

+ (BOOL)markToDatabaseWithDate:(NSDate *)date locationLatitude:(double)latitude locationLongitude:(double)longitude address:(NSDictionary *)address {
    
    NSManagedObjectContext *moc = [[CoreDateManage sharedManager] managedObjectContext];
    
    MarkMO *mark = [NSEntityDescription insertNewObjectForEntityForName:@"Mark" inManagedObjectContext:moc];
    
    mark.date = date;
    mark.location_latitude = latitude;
    mark.location_longitude = longitude;
    
    mark.address_city = address[@"City"];
    mark.address_country = address[@"Country"];
    mark.address_country_code = address[@"CountryCode"];
    mark.address_name = address[@"Name"];
    mark.address_state = address[@"State"];
    mark.address_street = address[@"Street"];
    mark.address_sub_locality = address[@"SubLocality"];
    mark.address_sub_thoroughfare = address[@"SubThoroughfare"];
    mark.address_thoroughfare = address[@"Thoroughfare"];
    
    NSArray *addressLines = address[@"FormattedAddressLines"];
    NSString *addressLine = addressLines[0];
    for (int i = 1; i < addressLines.count; i ++) {
        addressLine = [NSString stringWithFormat:@"%@, %@", addressLine, addressLines[i]];
    }
    
    mark.formatted_address_lines = addressLine;
    
    NSError * error = nil ;
    if (![moc save:&error]) {
//        NSAssert (NO, @"Error saving context: %@ \n %@", [error localizedDescription], [error userInfo]);
        return NO;
    }else {
        return YES;
    }
}

+ (NSArray *)dataFromDatabaseWithDate:(NSDate *)date {
    
    NSManagedObjectContext *moc = [[CoreDateManage sharedManager] managedObjectContext];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date];
    NSDate *startDate = [calendar dateFromComponents:components];
    NSDate *endDate = [calendar dateByAddingUnit:NSCalendarUnitDay value:1 toDate:startDate options:0];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mark"];
    
    request.predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", startDate, endDate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError * error = nil ;
    NSArray * results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog (@"Error fetching Mark objects: %@ \n %@", [error localizedDescription], [error userInfo]);
        abort ();
    }
    
    return results;
    
}

@end
