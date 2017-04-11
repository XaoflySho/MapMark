//
//  LocalViewController.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "LocalViewController.h"
#import "ListTableViewCell.h"
#import "CoreDateManage.h"
#import "MarkMO+CoreDataClass.h"
#import "MarkAnnotation.h"

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
@property (nonatomic, strong) NSDictionary *addressDictionary;

@property (nonatomic, strong) CLLocationManager *locationManager;

@property (nonatomic, strong) NSArray *marks;

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
    
    [self markFromDatabase];
    
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
    
    [self moveLocationToMapViewCenter:_userLocation.location];

    [self saveToDatabase];
    
}

#pragma mark - DatabaseController

- (void)saveToDatabase {
    
    MarkMO *mark = [NSEntityDescription insertNewObjectForEntityForName:@"Mark" inManagedObjectContext:[[CoreDateManage sharedManager] managedObjectContext]];
    
    mark.date = [NSDate date];
    mark.location_latitude = _userLocation.location.coordinate.latitude;
    mark.location_longitude = _userLocation.location.coordinate.longitude;
    
    mark.address_city = _addressDictionary[@"City"];
    mark.address_country = _addressDictionary[@"Country"];
    mark.address_country_code = _addressDictionary[@"CountryCode"];
    mark.address_name = _addressDictionary[@"Name"];
    mark.address_state = _addressDictionary[@"State"];
    mark.address_street = _addressDictionary[@"Street"];
    mark.address_sub_locality = _addressDictionary[@"SubLocality"];
    mark.address_sub_thoroughfare = _addressDictionary[@"SubThoroughfare"];
    mark.address_thoroughfare = _addressDictionary[@"Thoroughfare"];
    
    mark.formatted_address_lines = _addressDictionary[@"FormattedAddressLines"][0];
    
    NSError * error = nil ;
    if (![[[CoreDateManage sharedManager] managedObjectContext] save:&error]) {
        NSAssert (NO, @"Error saving context: %@ \n %@", [error localizedDescription], [error userInfo]);
    }
    
    NSLog(@"%@", NSHomeDirectory());
    
    [self markFromDatabase];
    
}

- (void)markFromDatabase {
    
    NSManagedObjectContext *moc = [[CoreDateManage sharedManager] managedObjectContext];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Mark"];
    
    NSDate *date = [NSDate date];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *comps = [calendar components:NSCalendarUnitEra |NSCalendarUnitYear | NSCalendarUnitMonth| NSCalendarUnitDay | NSCalendarUnitHour  fromDate: date];
    NSDate *beginDate = [calendar dateFromComponents:comps];
    NSDate *endDate = [beginDate dateByAddingTimeInterval:3600*24];
    
    request.predicate = [NSPredicate predicateWithFormat:@"date >= %@ AND date < %@", beginDate, endDate];
    
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    request.sortDescriptors = [NSArray arrayWithObject:sort];
    
    NSError * error = nil ;
    NSArray * results = [moc executeFetchRequest:request error:&error];
    if (!results) {
        NSLog (@"Error fetching Employee objects: %@ \n %@", [error localizedDescription], [error userInfo]);
        abort ();
    }
    
    _marks = results;
    
    [_listTableView reloadData];
    
}

#pragma mark - MapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    NSLog(@"位置坐标：%f，%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    
    _userLocation = userLocation;
    
    [self moveLocationToMapViewCenter:userLocation.location];
    
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

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
//
//    MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"Annotation"];
//
//
//    return annotationView;
//}

- (void)moveLocationToMapViewCenter:(CLLocation *)location {
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.003, 0.003));
    
    [self.mapView setRegion:region animated:YES];
    
}

- (void)reverseGeocodeLocation:(nonnull CLLocation *)location {
    
    //地理位置反编码
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location
                   completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                       
                       if (error || placemarks.count == 0) {
                           
                           NSLog(@"地理位置反编码失败：%@",error);
                           
                           NSLog(@"未获取到设备位置！");
                           
                       }else{
                           
                           CLPlacemark *placemark = [placemarks lastObject];
                           
                           _addressDictionary = placemark.addressDictionary;

                       }
                       
                   }];
    
}

#pragma mark - TableViewDelegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return _marks.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    MarkMO *mark = _marks[indexPath.row];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"HH:mm";
    NSString *dateStr = [dateFormatter stringFromDate:mark.date];
    
    cell.timeLabel.text = dateStr;
    cell.nameLabel.text = mark.address_name;
    cell.formattedAddressLineLabel.text = mark.formatted_address_lines;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MarkMO *mark = _marks[indexPath.row];
    
    [_mapView removeAnnotations:[_mapView annotations]];
    
    MarkAnnotation *markAnnotation = [[MarkAnnotation alloc]init];
    markAnnotation.coordinate = CLLocationCoordinate2DMake(mark.location_latitude, mark.location_longitude);
    markAnnotation.title = mark.address_name;
    
    [_mapView addAnnotation:markAnnotation];
    
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
