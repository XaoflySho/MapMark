//
//  LocalViewController.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "LocalViewController.h"
#import "ListTableViewCell.h"

//屏幕宽度
#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
//屏幕高度
#define SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

@interface LocalViewController () <MKMapViewDelegate, CLLocationManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIView *localView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *localViewCenterY;
@property (nonatomic, weak) IBOutlet MKMapView *mapView;

@property (nonatomic, weak) IBOutlet UILabel *dateLabel;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UILabel *markNumberLabel;

@property (nonatomic, weak) IBOutlet UIButton *punchButton;
@property (nonatomic, weak) IBOutlet UIView *punchView;

@property (nonatomic, weak) IBOutlet UIView *listView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *listViewHeight;
@property (nonatomic, weak) IBOutlet UIVisualEffectView *visualEffectView;

@property (nonatomic, weak) IBOutlet UITableView *listTableView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) MKUserLocation *userLocation;

@property (nonatomic, strong) CLLocationManager *locationManager;

@end

static int listViewMinHeight = 68;
static int listViewInitHeight = 68;
static int localViewInitCenterY = 0;

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    _listTableView.tableHeaderView = _localView;
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    [_visualEffectView setEffect:blurEffect];
    
    [self timerInit];
    
    if ([CLLocationManager locationServicesEnabled]) {

        self.locationManager = [[CLLocationManager alloc] init];
        
        //定位服务授权：使用时
        [self.locationManager requestWhenInUseAuthorization];
        
    }else {
        
    }
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
}

- (void)timerInit {
    
    if (!_timer) {
        
        _timer = [NSTimer scheduledTimerWithTimeInterval:0.01 repeats:YES block:^(NSTimer * _Nonnull timer) {
            
            [self timeLabelReload];
            
        }];
        
    }
    
}

- (void)timeLabelReload {
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd|HH:mm:ss";
    NSString *nowDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSArray *subStrings = [nowDateStr componentsSeparatedByString:@"|"];
    
    _dateLabel.text = subStrings[0];
    _timeLabel.text = subStrings[1];
    
}

- (IBAction)pan:(UIPanGestureRecognizer *)sender {
    
    CGPoint pt = [sender translationInView:_visualEffectView];
    
    _listViewHeight.constant = listViewInitHeight - pt.y;
    
    CGFloat scale = (_listViewHeight.constant - listViewMinHeight) / (SCREEN_HEIGHT * 2 / 3  - listViewMinHeight);
    _localViewCenterY.constant = scale * - SCREEN_HEIGHT / 3;
    _punchView.alpha = 1 - scale;
    
    if (_listViewHeight.constant < listViewMinHeight) {
        
        _listViewHeight.constant = listViewMinHeight;
        _localViewCenterY.constant = 0;
        
    }

    if (_listViewHeight.constant > SCREEN_HEIGHT * 2 / 3) {
        
        _listViewHeight.constant = SCREEN_HEIGHT * 2 / 3;
        _localViewCenterY.constant = - SCREEN_HEIGHT / 3;
        
    }
    
    if (sender.state == UIGestureRecognizerStateEnded) {
        
        [UIView animateWithDuration:0.3
                         animations:^{
                             
                             if (_listViewHeight.constant > SCREEN_HEIGHT / 3) {
                                 
                                 CGRect listViewFrame = _listView.frame;
                                 listViewFrame = CGRectMake(0, SCREEN_HEIGHT / 3, listViewFrame.size.width, listViewFrame.size.height);
                                 _listView.frame = listViewFrame;
                                 
                                 CGRect localViewFrame = _localView.frame;
                                 localViewFrame = CGRectMake(0, - SCREEN_HEIGHT / 3, localViewFrame.size.width, localViewFrame.size.height);
                                 _localView.frame = localViewFrame;
                                 
                                 _punchView.alpha = 0;
                                 
                                 _listViewHeight.constant = SCREEN_HEIGHT * 2 / 3;
                                 _localViewCenterY.constant = - SCREEN_HEIGHT / 3;
                                 
                             }else {
                                 
                                 CGRect listViewFrame = _listView.frame;
                                 listViewFrame = CGRectMake(0, SCREEN_HEIGHT - listViewMinHeight, listViewFrame.size.width, listViewFrame.size.height);
                                 _listView.frame = listViewFrame;
                                 
                                 CGRect localViewFrame = _localView.frame;
                                 localViewFrame = CGRectMake(0, 0, localViewFrame.size.width, localViewFrame.size.height);
                                 _localView.frame = localViewFrame;
                                 
                                 _punchView.alpha = 1;
                                 
                                 _listViewHeight.constant = listViewMinHeight;
                                 _localViewCenterY.constant = 0;
                                 
                             }
                             
                         } completion:^(BOOL finished) {
                             
                             if (finished) {
                                 
                                 listViewInitHeight = _listViewHeight.constant;
                                 localViewInitCenterY = _localViewCenterY.constant;
                                 
                             }
                             
                         }];
        
    }
    
}

- (IBAction)punchButtonClick:(id)sender {
    
    [self moveUserLocationToMapViewCenter];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    NSString *nowDateStr = [dateFormatter stringFromDate:[NSDate date]];
    
    NSLog(@"时间：%@", nowDateStr);
    NSLog(@"坐标：%@", _userLocation);
    
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"位置坐标：%f，%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    _userLocation = userLocation;
    
    [self moveUserLocationToMapViewCenter];
    
    [self reverseGeocodeLocation:userLocation.location];
    
}
/*
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
//    [_punchButton setImage:[UIImage imageNamed:@"local"] forState:UIControlStateNormal];
//    [_punchButton setTitle:@"" forState:UIControlStateNormal];
    
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {

    NSLog(@"中心坐标：%f，%f", mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude);
    
//    if (fabs(mapView.centerCoordinate.latitude - _userLocation.location.coordinate.latitude) < 0.00005&&
//        fabs(mapView.centerCoordinate.longitude - _userLocation.location.coordinate.longitude) < 0.00005) {
//        
//        [_punchButton setImage:nil forState:UIControlStateNormal];
//        [_punchButton setTitle:@"签到" forState:UIControlStateNormal];
//        
//    }else {
//        
//        [_punchButton setImage:[UIImage imageNamed:@"local"] forState:UIControlStateNormal];
//        [_punchButton setTitle:@"" forState:UIControlStateNormal];
//        
//    }
    
}*/

- (void)moveUserLocationToMapViewCenter {
    
    MKCoordinateRegion region = MKCoordinateRegionMake(_userLocation.location.coordinate, MKCoordinateSpanMake(0.003, 0.003));
    
    [self.mapView setRegion:region animated:YES];
    
}

- (void)reverseGeocodeLocation:(nonnull CLLocation *)location {
    
    //地理位置反编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       
                       if (error || placemarks.count == 0) {
                           
                           NSLog(@"地理位置反编码失败：%@",error);
                           
                           //                           self.areaString = @"未知";
                           //                           self.cityString = @"未知";
                           //                           self.provinceString = @"未知";
                           
                           NSLog(@"未获取到设备位置！");
                           
                           //                           self.areaLabel.text = @"定位失败,请选择";
//                           self.provinceString = @"定位失败";
                           
                           
                       }else{
                           
                           CLPlacemark *placemark = [placemarks lastObject];
                           
                           NSDictionary *addressDictionary = placemark.addressDictionary;
                           
                           NSLog(@"0：%@",placemark.addressDictionary);
                           NSLog(@"1：%@",placemark.administrativeArea);
                           NSLog(@"2：%@",placemark.locality);
                           NSLog(@"3：%@",placemark.name);
                           NSLog(@"4：%@",placemark.thoroughfare);
                           NSLog(@"5：%@",placemark.subThoroughfare);
                           NSLog(@"6：%@",placemark.subLocality);
                           NSLog(@"7：%@",placemark.areasOfInterest);
//                           self.provinceString = placemark.administrativeArea;
//                           self.cityString = placemark.locality;
//                           self.areaString = placemark.name;
                           
                           //                           self.areaLabel.text = placemark.name;
                       }
                       
                   }];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 30;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.timeLabel.text = [NSString stringWithFormat:@"%d", indexPath.row];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
