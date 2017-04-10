//
//  AppDelegate.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

