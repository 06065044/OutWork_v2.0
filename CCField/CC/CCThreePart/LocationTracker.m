//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
// 自动上报
//此处取得高德地图的定位信息，取得百度的经纬度一并上传后台

#import "LocationTracker.h"
#import "CCUtil.h"
#import <objc/message.h>
//#import "DefaultSets.h"
#import "CSDataService.h"
#import "ASIFormDataRequest.h"
#import <MAMapKit/MAMapKit.h>
 #import "Util.h"
#import "CCLoginViewController.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapKit/BaiduMapAPI_Utils/BMKGeometry.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#define LATITUDE @"latitude"
#define LONGITUDE @"longitude"
#define ACCURACY @"theAccuracy"

#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
@interface LocationTracker()<MAMapViewDelegate,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate>
{
   
    NSString *_jing;    //百度地图经度
    NSString *_wei;     // 百度地图纬度
    NSString *_place;
   
    NSDateFormatter *foromatter;
    
    
}
@end
@implementation LocationTracker

+ (CLLocationManager *)sharedLocationManager {
    static CLLocationManager *_locationManager;
    
    @synchronized(self) {
        if (_locationManager == nil) {
            _locationManager = [[CLLocationManager alloc] init];
            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_8_4
            if (IS_OS_9_OR_LATER) {
                if ([_locationManager respondsToSelector:@selector(setAllowsBackgroundLocationUpdates:)]) {
                    _locationManager.allowsBackgroundLocationUpdates = YES;
                    
                }
            }
#endif
            _locationManager.pausesLocationUpdatesAutomatically = NO;
        }
    }
    return _locationManager;
}

- (id)init {
    if (self==[super init]) {
        //        mapView = [[MAMapView alloc]init];
        //        mapView.delegate = self;
        //        mapView.showsUserLocation = YES;
        //        //Get the share model and also initialize myLocationArray
        
        if (!foromatter) {
            foromatter = [[NSDateFormatter alloc]init];
            [foromatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        }
        //百度地图定位初始化
        //初始化BMKLocationService
        __locService = [[BMKLocationService alloc]init];
        __locService.delegate = self;
        __locService.desiredAccuracy =kCLLocationAccuracyBestForNavigation;
        __locService.pausesLocationUpdatesAutomatically=NO;
        [__locService setAllowsBackgroundLocationUpdates:YES];
        
        //启动LocationService
        [__locService startUserLocationService];
        
        self.shareModel = [LocationShareModel sharedModel];
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        
        if ([self.shareModel.fiveMinutesTimer isValid]) {
            [self.shareModel.fiveMinutesTimer invalidate];
        }
//        self.shareModel.fiveMinutesTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reportPosi) userInfo:nil repeats:YES];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

-(void)applicationEnterBackground{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    [locationManager startUpdatingLocation];
    
    //Use the BackgroundTaskManager to manage all the background Task
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
}

- (void) restartLocationUpdates
{
    if (![defaults boolForKey:@"autoLogin"]) {
        return;
    }
    
    NSLog(@"restartLocationUpdates");
    if (![[[UIApplication sharedApplication]keyWindow].rootViewController respondsToSelector:@selector(visibleViewController)]) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer =nil;
        return;
    }
    
    
    if ([ ((UINavigationController*)[[UIApplication sharedApplication]keyWindow].rootViewController).visibleViewController isKindOfClass:[CCLoginViewController class]]) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer =nil;
        return;
    }
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    if (![LocationTracker sharedLocationManager]) {
        return;
    }
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    
    if(IS_OS_8_OR_LATER) {
        [locationManager requestAlwaysAuthorization];
    }
    
    [locationManager startUpdatingLocation];
}


- (void)startLocationTracking {
    NSLog(@"startLocationTracking");
    //Location Services Disabled
    //You currently have all location services for this device disabled
    if ([CLLocationManager locationServicesEnabled] == NO) {
        NSLog(@"locationServicesEnabled false");
        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"不可用的位置服务" message:@"目前你的位置服务不可用，请打开定位" delegate:nil cancelButtonTitle:@"好" otherButtonTitles:nil];
        [servicesDisabledAlert show];
    } else {
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
        
        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
            NSLog(@"authorizationStatus failed");
        } else {
            NSLog(@"authorizationStatus authorized");
            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
            locationManager.delegate = self;
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            locationManager.distanceFilter = kCLDistanceFilterNone;
            
            if(IS_OS_8_OR_LATER) {
                [locationManager requestAlwaysAuthorization];
            }
            [locationManager startUpdatingLocation];
        }
    }
}


- (void)stopLocationTracking {
    NSLog(@"stopLocationTracking");
    
    if (self.shareModel.timer) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    if (![[[UIApplication sharedApplication]keyWindow].rootViewController respondsToSelector:@selector(visibleViewController)]) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer =nil;
        return;;
    }
    
    if ([ ((UINavigationController*)[[UIApplication sharedApplication]keyWindow].rootViewController).visibleViewController isKindOfClass:[CCLoginViewController class]]) {
        return;}
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate Methods

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
    [manager stopUpdatingLocation];
    NSLog(@"locationManager didUpdateLocations");
    
    for(int i=0;i<locations.count;i++){
        CLLocation * newLocation = [locations objectAtIndex:i];
        CLLocationCoordinate2D theLocation = newLocation.coordinate;
        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
        
        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
        
        if (locationAge > 30.0)
        {
            continue;
        }
        
        //Select only valid location and also location with good accuracy
        if(newLocation!=nil&&theAccuracy>0
           &&theAccuracy<2000
           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
            self.myLastLocation = theLocation;
            self.myLastLocationAccuracy= theAccuracy;
            
            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
            
            //Add the vallid location with good accuracy into an array
            //Every 1 minute, I will select the best location based on accuracy and send to server
            [self.shareModel.myLocationArray addObject:dict];
        }
    }
    
    //If the timer still valid, return it (Will not run the code below)
    if (self.shareModel.timer) {
        return;
    }
    
    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
    [self.shareModel.bgTask beginNewBackgroundTask];
    
    //Restart the locationMaanger after 1 minute
    if ([self.shareModel.timer isValid]) {
        [self.shareModel.timer invalidate];
        self.shareModel.timer = nil;
    }
    if (self.shareModel.shouldStopTimer) {
        CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
        [locationManager stopUpdatingLocation];
        return;
    }
    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
                                                           selector:@selector(restartLocationUpdates)
                                                           userInfo:nil
                                                            repeats:NO];
    
    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
    //The location manager will only operate for 10 seconds to save battery
    if (self.shareModel.delay10Seconds) {
        [self.shareModel.delay10Seconds invalidate];
        self.shareModel.delay10Seconds = nil;
    }
    
    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
                                                                    selector:@selector(stopLocationDelayBy10Seconds)
                                                                    userInfo:nil
                                                                     repeats:NO];
    
}


//Stop the locationManager
-(void)stopLocationDelayBy10Seconds{
    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
    [locationManager stopUpdatingLocation];
    
    NSLog(@"locationManager stop Updating after 10 seconds");
}


- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
{
    // NSLog(@"locationManager error:%@",error);
    [manager stopUpdatingHeading];
    switch([error code])
    {
        case kCLErrorNetwork: // general, network-related error
        {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case kCLErrorDenied:{
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"能否定位服务" message:@"如果选择不允许，应用中自动上报位置功能将无法使用，如需使用请在手机中重新设置，Iphone>设置>隐私中重新设置。" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        default:
        {
            
        }
            break;
    }
}
//#pragma mark - 逆向地理编码
//- (void)onReGeocodeSearchWithla:(CGFloat )la lo:(CGFloat )lo{
//
//    [AMapSearchServices sharedServices].apiKey = @"21af4e9c071b8bdf9d63d5641ce69c3d";
//
//    //初始化检索对象
//    _search = [[AMapSearchAPI alloc] init];
//    _search.delegate = self;
//
//    //构造AMapReGeocodeSearchRequest对象
//    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
//    regeo.location = [AMapGeoPoint locationWithLatitude:la     longitude:lo];
//    regeo.radius = 10000;
//    regeo.requireExtension = YES;
//    //发起逆地理编码
//    [_search AMapReGoecodeSearch: regeo];
//}

#pragma mark - 实现逆地理编码的回调函数
//- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
//{
//    if(response.regeocode != nil)
//    {
//
//        _place = [NSString stringWithFormat:@"%@%@",response.regeocode.formattedAddress,response.regeocode.addressComponent.building];
//    }
//    else
//        _place=@"on failure";
//
//}

//- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation{
//    _jingLongitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
//
//    _weiLatitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
//    CLLocationCoordinate2D coordinate;                  //设定经纬度
//    coordinate.latitude =[_weiLatitude floatValue];       //纬度
//    coordinate.longitude = [_jingLongitude floatValue];      //精度
//
//    [self onReGeocodeSearchWithla:coordinate.latitude lo:coordinate.longitude];
//}


//百度地图，定位
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    _jing = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    
    _wei = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
    //存储经纬度
//    NSArray *Arr =@[_jing,_wei];
//   [[NSUserDefaults standardUserDefaults]setObject:Arr forKey:@"lololo"];
 
}
-(void)didFailToLocateUserWithError:(NSError *)error{
    _place = @"on failure";
}
-(void)recordCoordinate{
    NSString *lng = nil;
    NSString *lat = nil;
    if ([self->_jing floatValue]>[self->_wei floatValue]) {
        lng = self->_jing;
        lat = self->_wei;
    }
    else{
        lng = self->_wei;
        lat= self->_jing;
    }
    //    if (lng&&lat) {
    //        NSArray *Arr =@[lng,lat];
    //        [[NSUserDefaults standardUserDefaults]setObject:Arr forKey:@"lololo"];
    //    }
    //开始记录
    if ([[NSUserDefaults standardUserDefaults]boolForKey:@"beginTrack"]) {
        NSMutableArray *ar = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pointArr"]mutableCopy];
        if (!ar) {
            ar =  [NSMutableArray array];
            [[NSUserDefaults standardUserDefaults]setObject:ar forKey:@"pointArr"];
        }
        if (lng&&lat) {
            NSDictionary *dic = @{
                                  @"userLng": lng,
                                  @"userLat": lat,
                                  @"createTime":[foromatter stringFromDate:[NSDate date]]
                                  };
            [ar addObject:dic];
            [[NSUserDefaults standardUserDefaults]setObject:ar forKey:@"pointArr"];
        }
    }
}
//Send the location to Server
- (void)updateLocationToServer {
    
//   
//    NSLog(@"updateLocationToServer");
//    // Find the best location from the array based on accuracy
//    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
//    
//    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
//        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
//        
//        if(i==0)
//            myBestLocation = currentLocation;
//        else{
//            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
//                myBestLocation = currentLocation;
//            }
//        }
//    }
//    NSLog(@"My Best location:%@",myBestLocation);
//    
//    //If the array is 0, get the last location
//    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
//    if(self.shareModel.myLocationArray.count==0)
//    {
//        NSLog(@"Unable to get location, use the last known location");
//        
//        self.myLocation=self.myLastLocation;
//        self.myLocationAccuracy=self.myLastLocationAccuracy;
//        
//    }else{
//        CLLocationCoordinate2D theBestLocation;
//        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
//        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
//        self.myLocation=theBestLocation;
//        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
//    }
//    
//    NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
//    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
//    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
    NSString *lng = nil;
    NSString *lat = nil;
    if ([self->_jing floatValue]>[self->_wei floatValue]) {
        lng = self->_jing;
        lat = self->_wei;
    }
    else{
        lng = self->_wei;
        lat= self->_jing;
    }

        //开始记录

    NSDate *date= [NSDate date];
    if ([defaults objectForKey:@"updatedate"]) {
        NSDate *DatePre = [defaults objectForKey:@"updatedate"];
        [defaults setObject:date forKey:@"updatedate"];
         if (fabs([date timeIntervalSinceDate:DatePre])<55) {
            return;
        }
    }
    [defaults setObject:date forKey:@"updatedate"];
    
    BOOL canUp=[CCUtil whetherCanUPload];
    if (!canUp) {
        [self.shareModel.myLocationArray removeAllObjects];
        self.shareModel.myLocationArray = nil;
        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
        return;
    }
    if (!_jing) {
        return;
    }
    BMKGeoCodeSearch *Search = [[BMKGeoCodeSearch alloc]init];
    Search.delegate = self;
    
    //经纬度
    CLLocationCoordinate2D  testCoor;
    testCoor.latitude=lat.floatValue;
    testCoor.longitude = lng.floatValue;
    BMKReverseGeoCodeOption *reverOpition = [[BMKReverseGeoCodeOption alloc]init];
    reverOpition.reverseGeoPoint =testCoor;
    [Search reverseGeoCode:reverOpition];

    [self.shareModel.myLocationArray removeAllObjects];
    self.shareModel.myLocationArray = nil;
    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
}
#pragma mark -- geo
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    //获得地址
    if (error!=0) {
        return;
    }
    if (result.address) {
        _place = result.address;
    }
    if (_place.length<4) {
        return;
    }
    NSDictionary *dicParam=@{@"lng":@(result.location.longitude),@"lat":@(result.location.latitude),@"currLocation":result.address};
    NSString *final=[CCUtil basedString:locationUrl  withDic:dicParam];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [ requset setUseCookiePersistence : YES ];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@"%@11111",dic);
}
#pragma mark -- 每分钟定位
//-(void)reportPosi{
//     dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        
//        if (![self->_place isEqualToString:@"on failure"]) {
//            NSString *lng = nil;
//            NSString *lat = nil;
//            if ([self->_jing floatValue]>[self->_wei floatValue]) {
//                lng = self->_jing;
//                lat = self->_wei;
//            }
//            else{
//                lng = self->_wei;
//                lat= self->_jing;
//            }
//            if (self->_place&&lng&&lat) {
//                NSDictionary *dicParam=@{@"lng":lng,@"lat":lat,@"currLocation":self->_place};
//                NSString *final=[CCUtil basedString:saveFiveURL  withDic:dicParam];
//              __weak  ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//                [ requset setUseCookiePersistence : YES ];
//                [requset setRequestMethod:@"GET"];
//                [requset startAsynchronous];
//                [requset setCompletionBlock:^{
//                    NSLog(@"22222%@",requset.responseString);
//                }];
//            }
//            
//        }
//    });
//    
//    
//    
//    
//}
@end
//
//  LocationTracker.m
//  Location
//
//  Created by Rick
//  Copyright (c) 2014 Location All rights reserved.
//

//#import "LocationTracker.h"
//#import "CCUtil.h"
//#import <objc/message.h>
////#import "DefaultSets.h"
//#import "CSDataService.h"
//#import "ASIFormDataRequest.h"
//#import <BaiduMapAPI_Location/BMKLocationService.h>
//
////#import "BMKLocationService.h"
//#import "Util.h"
//#import "CCLoginViewController.h"
//#import <BaiduMapKit/BaiduMapAPI_Utils/BMKGeometry.h>
//#define LATITUDE @"latitude"
//#define LONGITUDE @"longitude"
//#define ACCURACY @"theAccuracy"
//
//#define IS_OS_8_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
//#define IS_OS_9_OR_LATER ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0)
//@interface LocationTracker()<BMKLocationServiceDelegate>
//{
//    BMKLocationService *locationService;;
//}
//@end
//@implementation LocationTracker
//
//+ (CLLocationManager *)sharedLocationManager {
//    static CLLocationManager *_locationManager;
//
//    @synchronized(self) {
//        if (_locationManager == nil) {
//            _locationManager = [[CLLocationManager alloc] init];
//            _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
//            if (IS_OS_9_OR_LATER) {
//                _locationManager.allowsBackgroundLocationUpdates = YES;
//            }
//#endif
//            _locationManager.pausesLocationUpdatesAutomatically = NO;
//        }
//    }
//    return _locationManager;
//}
//
//- (id)init {
//    if (self==[super init]) {
//        //Get the share model and also initialize myLocationArray
//        self.shareModel = [LocationShareModel sharedModel];
//        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
//
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
//    }
//    return self;
//}
//
//-(void)applicationEnterBackground{
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
//
//    if(IS_OS_8_OR_LATER) {
//        [locationManager requestAlwaysAuthorization];
//    }
//    [locationManager startUpdatingLocation];
//
//    //Use the BackgroundTaskManager to manage all the background Task
//    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
//    [self.shareModel.bgTask beginNewBackgroundTask];
//}
//
//- (void) restartLocationUpdates
//{
//    NSLog(@"restartLocationUpdates");
//    if (![[[UIApplication sharedApplication]keyWindow].rootViewController respondsToSelector:@selector(visibleViewController)]) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer =nil;
//        return;;
//    }
//
//
//    if ([ ((UINavigationController*)[[UIApplication sharedApplication]keyWindow].rootViewController).visibleViewController isKindOfClass:[CCLoginViewController class]]) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer =nil;
//        return;
//    }
//    if (self.shareModel.timer) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer = nil;
//    }
//    if (![LocationTracker sharedLocationManager ]) {
//        return;
//    }
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    locationManager.delegate = self;
//    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//    locationManager.distanceFilter = kCLDistanceFilterNone;
//
//    if(IS_OS_8_OR_LATER) {
//        [locationManager requestAlwaysAuthorization];
//    }
//
//    [locationManager startUpdatingLocation];
//}
//
//
//- (void)startLocationTracking {
//    NSLog(@"startLocationTracking");
//
//    if ([CLLocationManager locationServicesEnabled] == NO) {
//        NSLog(@"locationServicesEnabled false");
//        UIAlertView *servicesDisabledAlert = [[UIAlertView alloc] initWithTitle:@"Location Services Disabled" message:@"You currently have all location services for this device disabled" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
//        [servicesDisabledAlert show];
//    } else {
//        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];
//
//        if(authorizationStatus == kCLAuthorizationStatusDenied || authorizationStatus == kCLAuthorizationStatusRestricted){
//            NSLog(@"authorizationStatus failed");
//        } else {
//            NSLog(@"authorizationStatus authorized");
//            CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//            locationManager.delegate = self;
//            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
//            locationManager.distanceFilter = kCLDistanceFilterNone;
//
//            if(IS_OS_8_OR_LATER) {
//                [locationManager requestAlwaysAuthorization];
//            }
//            [locationManager startUpdatingLocation];
//        }
//    }
//}
//
//
//- (void)stopLocationTracking {
//    NSLog(@"stopLocationTracking");
//
//    if (self.shareModel.timer) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer = nil;
//    }
//    if (![[[UIApplication sharedApplication]keyWindow].rootViewController respondsToSelector:@selector(visibleViewController)]) {
//        [self.shareModel.timer invalidate];
//        self.shareModel.timer =nil;
//        return;;
//    }
//
//    if ([ ((UINavigationController*)[[UIApplication sharedApplication]keyWindow].rootViewController).visibleViewController isKindOfClass:[CCLoginViewController class]]) {
//        return;}
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    [locationManager stopUpdatingLocation];
//}
//
//#pragma mark - CLLocationManagerDelegate Methods
//
//-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations{
//
//    NSLog(@"locationManager didUpdateLocations");
//
//    for(int i=0;i<locations.count;i++){
//        CLLocation * newLocation = [locations objectAtIndex:i];
//        CLLocationCoordinate2D theLocation = newLocation.coordinate;
//        CLLocationAccuracy theAccuracy = newLocation.horizontalAccuracy;
//
//        NSTimeInterval locationAge = -[newLocation.timestamp timeIntervalSinceNow];
//
//        if (locationAge > 30.0)
//        {
//            continue;
//        }
//
//        //Select only valid location and also location with good accuracy
//        if(newLocation!=nil&&theAccuracy>0
//           &&theAccuracy<2000
//           &&(!(theLocation.latitude==0.0&&theLocation.longitude==0.0))){
//            self.myLastLocation = theLocation;
//            self.myLastLocationAccuracy= theAccuracy;
//
//            NSMutableDictionary * dict = [[NSMutableDictionary alloc]init];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.latitude] forKey:@"latitude"];
//            [dict setObject:[NSNumber numberWithFloat:theLocation.longitude] forKey:@"longitude"];
//            [dict setObject:[NSNumber numberWithFloat:theAccuracy] forKey:@"theAccuracy"];
//
//            //Add the vallid location with good accuracy into an array
//            //Every 1 minute, I will select the best location based on accuracy and send to server
//            [self.shareModel.myLocationArray addObject:dict];
//        }
//    }
//
//    //If the timer still valid, return it (Will not run the code below)
//    if (self.shareModel.timer) {
//        return;
//    }
//
//    self.shareModel.bgTask = [BackgroundTaskManager sharedBackgroundTaskManager];
//    [self.shareModel.bgTask beginNewBackgroundTask];
//
//    //Restart the locationMaanger after 1 minute
//    self.shareModel.timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self
//                                                           selector:@selector(restartLocationUpdates)
//                                                           userInfo:nil
//                                                            repeats:NO];
//
//    //Will only stop the locationManager after 10 seconds, so that we can get some accurate locations
//    //The location manager will only operate for 10 seconds to save battery
//    if (self.shareModel.delay10Seconds) {
//        [self.shareModel.delay10Seconds invalidate];
//        self.shareModel.delay10Seconds = nil;
//    }
//
//    self.shareModel.delay10Seconds = [NSTimer scheduledTimerWithTimeInterval:10 target:self
//                                                                    selector:@selector(stopLocationDelayBy10Seconds)
//                                                                    userInfo:nil
//                                                                     repeats:NO];
//
//}
//
//
////Stop the locationManager
//-(void)stopLocationDelayBy10Seconds{
//    CLLocationManager *locationManager = [LocationTracker sharedLocationManager];
//    [locationManager stopUpdatingLocation];
//
//    NSLog(@"locationManager stop Updating after 10 seconds");
//}
//
//
//- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error
//{
//    // NSLog(@"locationManager error:%@",error);
//
//    switch([error code])
//    {
//        case kCLErrorNetwork: // general, network-related error
//        {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Network Error" message:@"Please check your network connection." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//            break;
//        case kCLErrorDenied:{
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Enable Location Service" message:@"You have to enable the Location Service to use this App. To enable, please go to Settings->Privacy->Location Services" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil];
//            [alert show];
//        }
//            break;
//        default:
//        {
//
//        }
//            break;
//    }
//}
//
//
////Send the location to Server
//- (void)updateLocationToServer {
//
//    NSLog(@"updateLocationToServer");
//
//    // Find the best location from the array based on accuracy
//    NSMutableDictionary * myBestLocation = [[NSMutableDictionary alloc]init];
//
//    for(int i=0;i<self.shareModel.myLocationArray.count;i++){
//        NSMutableDictionary * currentLocation = [self.shareModel.myLocationArray objectAtIndex:i];
//
//        if(i==0)
//            myBestLocation = currentLocation;
//        else{
//            if([[currentLocation objectForKey:ACCURACY]floatValue]<=[[myBestLocation objectForKey:ACCURACY]floatValue]){
//                myBestLocation = currentLocation;
//            }
//        }
//    }
//    NSLog(@"My Best location:%@",myBestLocation);
//
//    //If the array is 0, get the last location
//    //Sometimes due to network issue or unknown reason, you could not get the location during that  period, the best you can do is sending the last known location to the server
//    if(self.shareModel.myLocationArray.count==0)
//    {
//        NSLog(@"Unable to get location, use the last known location");
//
//        self.myLocation=self.myLastLocation;
//        self.myLocationAccuracy=self.myLastLocationAccuracy;
//
//    }else{
//        CLLocationCoordinate2D theBestLocation;
//        theBestLocation.latitude =[[myBestLocation objectForKey:LATITUDE]floatValue];
//        theBestLocation.longitude =[[myBestLocation objectForKey:LONGITUDE]floatValue];
//        self.myLocation=theBestLocation;
//        self.myLocationAccuracy =[[myBestLocation objectForKey:ACCURACY]floatValue];
//    }
//
//    NSLog(@"Send to Server: Latitude(%f) Longitude(%f) Accuracy(%f)",self.myLocation.latitude, self.myLocation.longitude,self.myLocationAccuracy);
//    //TODO: Your code to send the self.myLocation and self.myLocationAccuracy to your server
//    //After sending the location to the server successful, remember to clear the current array with the following code. It is to make sure that you clear up old location in the array and add the new locations from locationManager
//    BOOL canUp=[CCUtil whetherCanUPload];
//    if (!canUp) {
//        [self.shareModel.myLocationArray removeAllObjects];
//        self.shareModel.myLocationArray = nil;
//        self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
//        return;
//    }
//
//    CLLocationCoordinate2D coor;
//    coor.latitude = self.myLocation.latitude;
//    coor.longitude = self.myLocation.longitude;
//    NSDictionary *tip =  BMKConvertBaiduCoorFrom(coor,BMK_COORDTYPE_GPS);
//    CLLocationCoordinate2D coor1=  BMKCoorDictionaryDecode(tip);
//
//
//    NSString *url = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?location=%f,%f&output=json&key=%@",coor1.latitude,coor1.longitude,baiduKey];
//
//    [CSDataService requestWithURL:url params:nil httpMethod:@"GET" block:^(id result) {
//        NSString *   _place=[NSString stringWithFormat:@"%@",result[@"result"][@"formatted_address"]];
//
//
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSString *a=[NSString stringWithFormat:@"%f",coor1.longitude];
//            NSString *b=[NSString stringWithFormat:@"%f",coor1.latitude];
//            NSString *str=@"http://117.78.42.226:8081/fastPin/dispatcher/location/uploadCurrentPostion";
//
//            NSDictionary *dic=@{@"lng":a,@"lat":b,@"currLocation":_place};//[_place outString]
//
//            ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:str]];
//            for (NSString *key in dic.allKeys) {
//                [requset setPostValue:dic[key] forKey:key];
//            }
//            [requset setUseSessionPersistence:YES];
//            [requset startSynchronous];
//
//            //                NSLog(@"111-==-=-=--=-=-=-=%@",requset.responseString);
//            //                NSDictionary *dicAll  =[NSJSONSerialization JSONObjectWithData:requset.responseData options:NSJSONReadingMutableLeaves error:nil];
//            //                if ([dicAll[@"success"] integerValue]==1) {
//            //                    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:1];
//            //
//            //                    //chuagjian一个本地推送
//            //
//            //                    UILocalNotification *noti = [[UILocalNotification alloc] init];
//            //
//            //                    if (noti) {
//            //
//            //                        //设置推送时间
//            //
//            //                        noti.fireDate = date;
//            //
//            //                        //设置时区
//            //
//            //                        noti.timeZone = [NSTimeZone defaultTimeZone];
//            //
//            //                        //                        //设置重复间隔
//            //                        //
//            //                        //                        noti.repeatInterval = NSWeekCalendarUnit;
//            //
//            //                        //推送声音
//            //
//            //                        noti.soundName = UILocalNotificationDefaultSoundName;
//            //
//            //                        noti.alertTitle=_place;
//            //                        //内容
//            //
//            //                        noti.alertBody = url;
//            //
//            //                        //显示在icon上的红色圈中的数子
//            //
//            //                        noti.applicationIconBadgeNumber = 1;
//            //
//            //                        //设置userinfo 方便在之后需要撤销的时候使用
//            //
//            //                        NSDictionary *infoDic = [NSDictionary dictionaryWithObject:@"name" forKey:@"key"];
//            //
//            //                        noti.userInfo = infoDic;
//            //
//            //                        //添加推送到uiapplication
//            //
//            //                        UIApplication *app = [UIApplication sharedApplication];
//            //
//            //                        [app scheduleLocalNotification:noti];
//            //
//            //                    }
//            //
//            //                }
//            //
//        });
//
//
//    }
//
//     ];
//    //
//
//
//
//    [self.shareModel.myLocationArray removeAllObjects];
//    self.shareModel.myLocationArray = nil;
//    self.shareModel.myLocationArray = [[NSMutableArray alloc]init];
//}
//@end
//
