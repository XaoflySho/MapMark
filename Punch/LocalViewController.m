//
//  LocalViewController.m
//  Punch
//
//  Created by 邵晓飞 on 2017/4/10.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import "LocalViewController.h"
#import "ListTableViewCell.h"
#import "DataController.h"

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

@property (nonatomic, weak) IBOutlet UIButton *markButton;
@property (nonatomic, weak) IBOutlet UIView *punchView;

@property (nonatomic, weak) IBOutlet UIButton *locationButton;
@property (nonatomic, weak) IBOutlet UIButton *previousButton;
@property (nonatomic, weak) IBOutlet UIButton *dataButton;
@property (nonatomic, weak) IBOutlet UIButton *nextButton;
@property (nonatomic, weak) IBOutlet UIButton *chartButton;

@property (nonatomic, weak) IBOutlet UIView *listView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *listViewHeight;
@property (nonatomic, weak) IBOutlet UIVisualEffectView *visualEffectView;

@property (nonatomic, weak) IBOutlet UITableView *listTableView;

@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLGeocoder *geocoder;
@property (nonatomic, strong) MKUserLocation *userLocation;
@property (nonatomic, strong) MKPlacemark *placemark;

@property (nonatomic, assign) NSInteger todayMark;
@property (nonatomic, strong) NSDate *selectedDate;

@property (nonatomic, strong) NSArray *marks;

@end

static int listViewMinHeight = 68;
static int listViewInitHeight = 68;
static int localViewInitCenterY = 0;

@implementation LocalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIVisualEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    
    [_visualEffectView setEffect:blurEffect];
    
    [self timerInit];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    
    [self.locationManager requestWhenInUseAuthorization];
    
    self.geocoder = [[CLGeocoder alloc] init];
    
    self.selectedDate = [NSDate date];
    
    [self setDateButtonTitleWithDate:_selectedDate reloadAnimation:UITableViewRowAnimationAutomatic];
    
//    [self markFromDatabaseWithDate:_selectedDate reloadAnimation:UITableViewRowAnimationAutomatic];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
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

- (void)setDateButtonTitleWithDate:(NSDate *)date reloadAnimation:(UITableViewRowAnimation)animation {
    
    NSString *dateStr;
    
    if ([self isSameDate:date andDate:[NSDate date]]) {
        
        dateStr = @"Today";
        
        [_nextButton setEnabled:NO];
    }else {
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
        dateFormatter.dateFormat = @"yyyy-MM-dd";
        dateStr = [dateFormatter stringFromDate:date];
        
        [_nextButton setEnabled:YES];
    }

    [_dataButton setTitle:dateStr forState:UIControlStateNormal];
    
    _selectedDate = date;
    
    [self markFromDatabaseWithDate:date reloadAnimation:animation];
    
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

- (IBAction)markButtonClick:(id)sender {
    
    [self moveLocationToMapViewCenter:_userLocation.location];

    [self saveToDatabase];
    
}

- (IBAction)locationButtonClick:(id)sender {
    
    [self moveLocationToMapViewCenter:_userLocation.location];
    
}

- (IBAction)previousButtonClick:(id)sender {
    
    NSDate *previousDay = [NSDate dateWithTimeInterval:-(24*60*60) sinceDate:_selectedDate];
    
    [self setDateButtonTitleWithDate:previousDay reloadAnimation:UITableViewRowAnimationRight];
    
}

- (IBAction)nextButtonClick:(id)sender {
    
    NSDate *nextDay = [NSDate dateWithTimeInterval:24*60*60 sinceDate:_selectedDate];
    
    [self setDateButtonTitleWithDate:nextDay reloadAnimation:UITableViewRowAnimationLeft];
    
}

- (IBAction)dateButtonClick:(id)sender {
    
    NSDate *today = [NSDate date];
    
    [self setDateButtonTitleWithDate:today reloadAnimation:UITableViewRowAnimationLeft];
    
}

- (IBAction)dateButtonLongPress:(id)sender {
    

    NSLog(@"!");
    
}



#pragma mark - MKMapViewDelegate

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    // Center the map the first time we get a real location change.
    static dispatch_once_t centerMapFirstTime;
    
    if ((userLocation.coordinate.latitude != 0.0) && (userLocation.coordinate.longitude != 0.0)) {
        dispatch_once(&centerMapFirstTime, ^{
            
            [self moveLocationToMapViewCenter:userLocation.location];
            _userLocation = userLocation;
            NSLog(@"位置坐标：%f，%f", userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
            
            _locationButton.enabled = YES;
            
        });
    }
    
    [self reverseGeocodeLocation:userLocation.location];
    
}

- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error {
    
    self.markButton.enabled = NO;
    [self.markButton setBackgroundColor:[UIColor lightGrayColor]];

    self.locationButton.enabled = NO;
    
    if (!self.presentedViewController) {
        NSString *message = nil;
        if (error.code == kCLErrorLocationUnknown) {
            // If you receive this error while using the iOS Simulator, location simulatiion may not be on.  Choose a location from the Debug > Simulate Location menu in Xcode.
            message = @"Your location could not be determined.";
        }else {
            message = error.localizedDescription;
        }
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Error"
                                                                       message:message
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    [_locationButton setImage:[UIImage imageNamed:@"Location_0"] forState:UIControlStateNormal];
    
}

- (void)moveLocationToMapViewCenter:(CLLocation *)location {
    
    MKCoordinateRegion region = MKCoordinateRegionMake(location.coordinate, MKCoordinateSpanMake(0.003, 0.003));
    
    [self.mapView setRegion:region animated:YES];
    
    [_locationButton setImage:[UIImage imageNamed:@"Location"] forState:UIControlStateNormal];
    
}

- (void)reverseGeocodeLocation:(nonnull CLLocation *)location {
    
    // Lookup the information for the current location of the user.
    [self.geocoder reverseGeocodeLocation:self.mapView.userLocation.location completionHandler:^(NSArray *placemarks, NSError *error) {
        if ((placemarks != nil) && (placemarks.count > 0)) {
            // If the placemark is not nil then we have at least one placemark. Typically there will only be one.
            self.placemark = placemarks[0];
            
            // we have received our current location, so enable the "Get Current Address" button
            self.markButton.enabled = YES;
            [self.markButton setBackgroundColor:[UIColor colorWithRed:0.0/255.0 green:122.0/255.0 blue:255.0/255.0 alpha:1.0]];
            
        }
        else {
            // Handle the nil case if necessary.
            self.placemark = nil;
            
            self.markButton.enabled = NO;
            [self.markButton setBackgroundColor:[UIColor lightGrayColor]];
            
        }
    }];
    
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    if (status == kCLAuthorizationStatusRestricted || status == kCLAuthorizationStatusDenied) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Location Disabled"
                                                                       message:@"Please enable location services in the Settings app."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        // This will implicitly try to get the user's location, so this can't be set
        // until we know the user granted this app location access
        self.mapView.showsUserLocation = YES;
    }
}

#pragma mark - DataController

- (void)saveToDatabase {
    
    NSLog(@"%@", _placemark.addressDictionary);
    
    BOOL result = [DataController markToDatabaseWithDate:[NSDate date]
                          locationLatitude:_userLocation.location.coordinate.latitude
                         locationLongitude:_userLocation.location.coordinate.longitude
                                   address:_placemark.addressDictionary];
    
    if (result) {
        
        [self markFromDatabaseWithDate:[NSDate date] reloadAnimation:UITableViewRowAnimationAutomatic];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mark"
                                                                       message:@""
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
        
    }else {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Mark Fail"
                                                                       message:@"Please enable location services in the Settings app."
                                                                preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"OK"
                                                  style:UIAlertActionStyleDefault
                                                handler:nil]];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)markFromDatabaseWithDate:(NSDate *)date reloadAnimation:(UITableViewRowAnimation)animation {
    
    NSArray *results = [DataController dataFromDatabaseWithDate:date];
    
    if ([self isSameDate:date andDate:_selectedDate]) {
        
        _marks = results;
        
        [self.listTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:animation];
        
    }
    
    if ([self isSameDate:date andDate:[NSDate date]]) {
        
        _markNumberLabel.text = [NSString stringWithFormat:@"%lu", (unsigned long)results.count];
        
    }
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

    cell.countryCodeLabel.text = mark.address_country_code;
    cell.nameLabel.text = mark.address_name;
    cell.formattedAddressLineLabel.text = mark.formatted_address_lines;
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 57;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MarkMO *mark = _marks[indexPath.row];
    
    [_mapView removeAnnotations:[_mapView annotations]];
    
    MarkAnnotation *markAnnotation = [[MarkAnnotation alloc]init];
    markAnnotation.coordinate = CLLocationCoordinate2DMake(mark.location_latitude, mark.location_longitude);
    markAnnotation.title = mark.address_name;
    
    [_mapView addAnnotation:markAnnotation];
    [_mapView selectAnnotation:markAnnotation animated:YES];
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:mark.location_latitude longitude:mark.location_longitude];
    [self moveLocationToMapViewCenter:location];
    
}

- (BOOL)isSameDate:(NSDate*)date1 andDate:(NSDate*)date2 {
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *date1Components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date1];
    NSDateComponents *date2Components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    
    BOOL isSameDay = [date1Components day] == [date2Components day];
    BOOL isSameMonth = [date1Components month] == [date2Components month];
    BOOL isSameYear = [date1Components year] == [date2Components year];
    
    return isSameDay && isSameMonth && isSameYear;
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
