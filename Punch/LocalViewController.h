//
//  LocalViewController.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


//自定义输出，输出格式：文件名，方法名，行
#ifdef DEBUG
#define NSLog(...) printf("%s %s Line %d: %s\n", [[NSString stringWithFormat:@"%s", __FILE__].lastPathComponent UTF8String], __PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:__VA_ARGS__] UTF8String])
#else
#define NSLog(...)
#endif


@interface LocalViewController : UIViewController

@end
