//
//  CCRecordViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRecordViewController.h"
#import "CCKQJLViewController.h"
#import "CSDataService.h"
#import <objc/runtime.h>
//#import <MAMapKit/MAMapKit.h>
//#import <AMapLocationKit/AMapLocationKit.h>
//#import <AMapSearchKit/AMapSearchKit.h>
//#import <AMapFoundationKit/AMapFoundationKit.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "CCLocationController.h"
#import "STSignView.h"
UILabel *timeLabel;
UILabel *placeLabel;
UIButton *signInButton;
UIButton *signOutButton;
NSString *today;
CLLocationManager *locManager;
AMapSearchAPI *_search;
AMapGeocodeSearchRequest *_searcher;

@interface CCRecordViewController ()<BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,BMKMapViewDelegate,clickBtn>
{
    BMKLocationService *locationService;
//    NSString *singInTime1;
//    NSString *singOutTimeTerminal;
     AMapSearchAPI *_search;
    NSTimer *timer;
    __block  NSDate *currentDate;
    NSDateFormatter *formatter;
    UIView *viewLayer;
    BMKMapView *mapView;
    NSMutableArray *timeArray;
     NSArray *signDays;
    NSDictionary *rule_dic;
    //    NSArray *CurDaySignArr;//获取签到信息  后来放弃这个念头 因为签到信息需要及时更新，消耗太大，还是本地
    NSInteger day;//今天的day。index需要-1
    NSString *YMD;//年-月-日
    BMKPointAnnotation *animition;
    UITableView *_signTable;
}
@property(strong,nonatomic)CLLocation *currentLocation;
//
@property (assign, nonatomic) UIBackgroundTaskIdentifier bgTask;

@property (strong, nonatomic) dispatch_block_t expirationHandler;
@property (assign, nonatomic) BOOL jobExpired;
@property (assign, nonatomic) BOOL background;

@end

static NSString * const currentTimeUrl= @"http://117.78.42.226:8081/outside/dispatcher/signmgr/getCurrentTime";


@implementation CCRecordViewController
//点击代理
-(void)signBtnClickedAtIndex:(UIButton*)btn{
    [self clickToSign:btn];
}
#pragma mark --  获取签到规则
//-(void)exchangeMethod{
//   // ((UIView *)self).layer.cornerRadius = 10;
//    NSLog(@"哈哈哈哈");
//}

 - (void)viewDidLoad {
    [super viewDidLoad];
    self.lableNav.text=@"签到签退";
     
    timeArray = [NSMutableArray arrayWithCapacity:4];
    //创建签到签退按钮
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-90, 22, 80, 40)];
    [button setTitle:@"考勤记录" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(KQJL) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    
    formatter=[[NSDateFormatter alloc]init];
    [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
   
    [self getSignOutTimeByUserId:nil];
    
     
     viewLayer=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+10, kFullScreenSizeWidth, 120)];
    viewLayer.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:viewLayer];
     //星期几 和 时间
     NSCalendar *calender=[NSCalendar currentCalendar];
    NSDateComponents *comps;
    //星期几
    comps=[calender components:(NSCalendarUnitWeekday|NSCalendarUnitWeekdayOrdinal) fromDate:currentDate];
    NSInteger weekday=[comps weekday];
    NSString *str=[NSString stringWithFormat:@"%ld",weekday-1];
    switch ([str intValue]) {
        case 0:
            str=@"日";
            break;
        case 1:
            str=@"一";
            break;
        case 2:
            str=@"二";
            break;
        case 3:
            str=@"三";
            break;
        case 4:
            str=@"四";
            break;
        case 5:
            str=@"五";
            break;
        case 6:
            str=@"六";
            break;
        default:
            break;
    }
    
    UILabel *labWeek=[[UILabel alloc]initWithFrame:CGRectMake(15, 20, 100, 20)];
    labWeek.text=[NSString stringWithFormat:@"星期%@",str];
    labWeek.font = [UIFont boldSystemFontOfSize:15];
    [viewLayer addSubview:labWeek];
    
    //year month day
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour;
 
    comps=[calender components:unitFlags fromDate:currentDate];
    
    NSInteger year=[comps year];
    NSInteger month=[comps month];
    day=[comps day];
    
    YMD=[NSString stringWithFormat:@"%d-%d-%d",year,month,day];
    UILabel *labYMD=[[UILabel alloc]initWithFrame:CGRectOffset(labWeek.frame, 60, 2)];
    labYMD.text=YMD;
    labYMD.font=[UIFont systemFontOfSize:12];
    [viewLayer addSubview:labYMD];
//     [self exchangeMethod];
//     Method m1 = class_getInstanceMethod([BMKMapView class], @selector(initLogoIcon));
//     Method m2 = class_getInstanceMethod([self class], @selector(exchangeMethod));
//     
//     method_exchangeImplementations(m1, m2);
     
     
  
//获取百度地图的所有方法，可以替换方法来去掉logo
//     unsigned int outCountMethod = 0;
//     Method * methods =   class_copyMethodList([BMKMapView class], &outCountMethod);
//     for (int j = 0; j < outCountMethod; j++) {
//         
//         Method method = methods[j];
//         
//         SEL methodSEL = method_getName(method);
//         
//         const char * selName = sel_getName(methodSEL);
//         
//         if (methodSEL) {
//             NSLog(@"sel------%s", selName);
//         }
//     }
//    IMP c= class_getMethodImplementation([BMKMapView class], @selector(initLogoIcon));
     CGRect rect0 = CGRectMake(CGRectGetWidth(viewLayer.frame)-100, 20, 80, 80);
     UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 80, 80)];
//     igv.layer.cornerRadius = 15;
     igv.image = [UIImage imageNamed:@"map_resurce"];
     igv.clipsToBounds = YES;
//     [viewLayer addSubview:igv];
     
     
     mapView = [[BMKMapView alloc]initWithFrame:rect0];
     mapView.layer.cornerRadius  =5;
     mapView.showMapScaleBar = false;
     mapView.zoomLevel =18;
     mapView.mapType = BMKMapTypeStandard;
//    mapView.showsUserLocation = YES;    //YES 为打开定位，NO为关闭定位
     [viewLayer addSubview:mapView];
    [mapView addSubview:igv];
     
     UITapGestureRecognizer *sing = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(gotoLocation)];
     sing.numberOfTapsRequired = 1;
     sing.numberOfTouchesRequired = 1;
     [mapView addGestureRecognizer:sing];
     
     
    UIView *down_Cover_logo = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(viewLayer.frame), CGRectGetWidth(viewLayer.frame), 20)];
    down_Cover_logo.backgroundColor = self.view.backgroundColor ;
    [self.view addSubview:down_Cover_logo];
    
    timeLabel=[[UILabel alloc]initWithFrame:CGRectOffset(labYMD.frame, 65, 0)];
    timeLabel.font=[UIFont systemFontOfSize:12];
    //timeLabel.textColor=[UIColor colorWithRed:25.0/255 green:160.0/255 blue:135.0/255 alpha:1];
    timeLabel.textColor=[UIColor blackColor];
    [viewLayer addSubview:timeLabel];
    
    /**
     开启定位
     */
     //2.0不需要此项验证
      //[self getSIGNINFO];
     locationService=[[BMKLocationService alloc]init];
     locationService.delegate=self;
     locationService.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
         if ([CLLocationManager locationServicesEnabled]) {
            //由于IOS8中定位的授权机制改变 需要进行手动授权
            locManager = [[CLLocationManager alloc] init];
            //获取授权认证
#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
            if (IOS8_OR_LATER) {
//                [locManager requestWhenInUseAuthorization];
                [locManager requestAlwaysAuthorization];
                
            }
#endif
            [locationService startUserLocationService];
//              //初始化检索对象
//            _search = [[AMapSearchAPI alloc] init];
//            _search.delegate = self;
        
        }
     else
    {
        //检测系统定位服务是否开启
        if (![CLLocationManager locationServicesEnabled]) {
            UIAlertView *openLocationServiceAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [openLocationServiceAlert show];
        }
        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways) {
            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开本应用定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            myAlert.delegate = self;
            [myAlert show];
        }
    }
 
    //Place label
    placeLabel=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labWeek.frame), CGRectGetMaxY(labWeek.frame)+10, CGRectGetMinX(mapView.frame)-40, 40)];
    placeLabel.numberOfLines=0;
    placeLabel.font=[UIFont systemFontOfSize:12];
    placeLabel.lineBreakMode=NSLineBreakByWordWrapping;
    [viewLayer addSubview:placeLabel];
 
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        ASIHTTPRequest *requestRule = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:KQ_Rule_Url]];
        [requestRule setTimeOutSeconds:10];
        [requestRule setRequestMethod:@"GET"];
        [requestRule startSynchronous];
        NSData *rule_date = [requestRule responseData];
        if (!rule_date) {
            return ;
        }
        self->rule_dic = [NSJSONSerialization JSONObjectWithData:rule_date options:NSJSONReadingMutableLeaves error:nil];
        //将规则保存，方便后面读取
         dispatch_async(dispatch_get_main_queue(), ^{
            CGFloat button_width = kFullScreenSizeWidth/2.0-25;
            NSDictionary *data_dic = self->rule_dic[@"data"];
             
             //获取考勤日期
             NSArray *sign = [data_dic[@"days"] componentsSeparatedByString:@","];
             NSMutableArray *arr_replace = [NSMutableArray array];
             [sign enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 [arr_replace addObject:@(obj.integerValue)];
             }];
             self->signDays = arr_replace.copy;
             
             NSArray *time_key_array = @[@"time1",@"time2",@"time3",@"time4"];
             NSArray *imageNameArray = @[@"am",@"m",@"pm",@"n"];
             NSInteger count = [data_dic[@"signTimes"] integerValue];
             if (count==2) {
                 imageNameArray = @[@"am",@"n"];
             }
            for (int i=0; i<count; ++i) {
                NSString *signstr= @"签到";
                if (i%2==1) {
                    signstr = @"签退";
                }
                
                if (![self->signDays containsObject:@(self->day)]) {
                     UIImageView *ivg = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-30, CGRectGetMaxY(self->viewLayer.frame)+30, 60, 60)];
                    ivg.image = [UIImage imageNamed:@"rest"];
                    [self.view addSubview:ivg];
                    
                    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(ivg.frame)+10, kFullScreenSizeWidth-40, 30)];
                    lab.textAlignment = NSTextAlignmentCenter;
                    lab.text = @"休息日";
                    lab.font = [UIFont systemFontOfSize:14];
                    [self.view addSubview:lab];
                    return ;
                    
                }
                else{
                    NSString *strKey = [[defaults objectForKey:USER_NAME]stringByAppendingString:self->YMD];
                    NSString *curKey = [strKey stringByAppendingString:[NSString stringWithFormat:@"%d",i]];
                
                
                    
                    
                if ([[NSUserDefaults standardUserDefaults]boolForKey:curKey]) {
                    signstr = @"重签";
                    }
                }
               
                STSignView *view2 = [[STSignView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self->viewLayer.frame)+15+64*i, kFullScreenSizeWidth, 64) signTimt:data_dic[time_key_array[i]] index:i imageName:imageNameArray[i] buttonTitle:signstr ];
                view2.delegate  = self;
                if (i==count-1) {
                    [view2 removeDownLine];
                }
                 [self->timeArray addObject:data_dic[time_key_array[i]]];
                [self.view addSubview:view2];
                

           }

        });
        
    });
 }

-(void)gotoLocation{
    CCLocationController *location = [[CCLocationController alloc]init];
    [location setBlock:^(NSArray *arr, NSString *loca) {
//        NSString *lati = [NSString stringWithFormat:@"%f",[arr[0] floatValue]];
//        NSString *longti  = [NSString stringWithFormat:@"%f",[arr[1] floatValue]];
      NSDictionary * dic = BMKConvertBaiduCoorFrom(CLLocationCoordinate2DMake([arr[0] floatValue],[arr[1] floatValue]), BMK_COORDTYPE_COMMON);
        CLLocationCoordinate2D trans = BMKCoorDictionaryDecode(dic);
        
        self.currentLocation=[[CLLocation alloc]initWithLatitude:trans.latitude longitude:trans.longitude];

        placeLabel.text = loca;
        self->mapView.centerCoordinate = self.currentLocation.coordinate;
        
         self->animition.coordinate = self.currentLocation.coordinate;
        placeLabel.text = loca;
     }];
    [self.navigationController pushViewController:location animated:YES];

}
#pragma mark--点击签到签退
-(void)clickToSign:(UIButton *)clickBtn{
    if (self.currentLocation.coordinate.latitude == 0 ) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"未获取到定位信息，无法打卡"];
        return;
    }
    
    NSString *startLng = rule_dic[@"data"][@"startLng"];
    if ([startLng isKindOfClass:[NSNull class]]||[startLng length]==0) {
        startLng = @"0";
    }
    NSString *startLat = rule_dic[@"data"][@"startLat"];
    if ([startLat isKindOfClass:[NSNull class]]||[startLat length]==0) {
        startLat = @"0";
    }
    NSString *endLng = rule_dic[@"data"][@"endLng"];
    if ([endLng isKindOfClass:[NSNull class]]||[endLng length]==0) {
        endLng = @"200";
    }
    NSString *endLat = rule_dic[@"data"][@"endLat"];
    if ([endLat isKindOfClass:[NSNull class]]||[endLat length]==0) {
        endLat = @"200";
    }
    double latitude = _currentLocation.coordinate.latitude;
    double longitude = _currentLocation.coordinate.longitude;
    if ((latitude-startLat.floatValue)*(latitude-endLat.floatValue)>0) {
        //说明不在区域内
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"当前不在考勤区域内，无法打卡"];
        return;
        
    }else if ((longitude-startLng.floatValue)*(longitude-endLng.floatValue)>0)
    {//说明不在区域内
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"当前不在考勤区域内，无法打卡"];
        return;
    }
    NSInteger btnTag = clickBtn.tag;
    NSString *_confirmString = @"确认重新签到";
    if (btnTag%2==1) {
        _confirmString = @"确认重新签退";
    }
    NSString *strKey = [[defaults objectForKey:USER_NAME]stringByAppendingString:self->YMD];
    NSString *curKey = [strKey stringByAppendingString:[NSString stringWithFormat:@"%d",btnTag]];
    
    if ([[NSUserDefaults standardUserDefaults]boolForKey:curKey]) {
        //需要进行说明
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:_confirmString preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                //进行签到
                NSString *sign_checkType=btnTag%2==0?@"0":@"1";
                NSString *times = btnTag>1?@"2":@"1";
                NSDictionary *sign_dic = @{@"type":@"0",@"checkType":sign_checkType,@"signLat":@(self.currentLocation.coordinate.latitude),@"signLng":@(self.currentLocation.coordinate.longitude),@"location":[placeLabel.text length]==0?@"北京市海淀区":placeLabel.text,@"times":times};
                NSURL *sign_url =[NSURL URLWithString:[[CCUtil basedString:signInOrOutUrl withDic:sign_dic] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
                ASIHTTPRequest *sign_request = [ASIHTTPRequest requestWithURL:sign_url];
                [sign_request setTimeOutSeconds:20];
                [sign_request setRequestMethod:@"GET"];
                [sign_request startSynchronous];
                NSString *sign_reponseString = [sign_request responseString];
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    if ([sign_reponseString rangeOfString:@"true"].location!=NSNotFound) {
                        //  成功
                        
                        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"打卡成功"];

                    }
                    
                });
            });
        }];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        [alert addAction:sureAction];
        [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
    else{
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            //进行签到
            NSString *sign_checkType=btnTag%2==0?@"0":@"1";
            NSString *times = btnTag>1?@"2":@"1";
            NSDictionary *sign_dic = @{@"type":@"0",@"checkType":sign_checkType,@"signLat":@(self.currentLocation.coordinate.latitude),@"signLng":@(self.currentLocation.coordinate.longitude),@"location":[placeLabel.text length]==0?@"北京市海淀区":placeLabel.text,@"times":times};
            NSURL *sign_url =[NSURL URLWithString:[[CCUtil basedString:signInOrOutUrl withDic:sign_dic] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            ASIHTTPRequest *sign_request = [ASIHTTPRequest requestWithURL:sign_url];
            [sign_request setTimeOutSeconds:20];
            [sign_request setRequestMethod:@"GET"];
            [sign_request startSynchronous];
            NSString *sign_reponseString = [sign_request responseString];
            dispatch_async(dispatch_get_main_queue(), ^{
                
                if ([sign_reponseString rangeOfString:@"true"].location!=NSNotFound) {
                    //  成功
                    [clickBtn setBackgroundColor:[UIColor orangeColor]];
                    [clickBtn setTitle:@"重签" forState:UIControlStateNormal];
                    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:curKey];

                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"打卡成功"];
                }
                
            });
        });

    
    }
    
//    //根据按钮进行签到签退
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        //进行签到
//        NSString *sign_checkType=btnTag%2==0?@"0":@"1";
//        NSString *times = btnTag>1?@"2":@"1";
//        NSDictionary *sign_dic = @{@"type":@"0",@"checkType":sign_checkType,@"signLat":@(self.currentLocation.coordinate.latitude),@"signLng":@(self.currentLocation.coordinate.longitude),@"location":[placeLabel.text length]==0?@"北京市海淀区":placeLabel.text,@"times":times};
//        NSURL *sign_url =[NSURL URLWithString:[[CCUtil basedString:signInOrOutUrl withDic:sign_dic] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        ASIHTTPRequest *sign_request = [ASIHTTPRequest requestWithURL:sign_url];
//        [sign_request setTimeOutSeconds:20];
//        [sign_request setRequestMethod:@"GET"];
//        [sign_request startSynchronous];
//        NSString *sign_reponseString = [sign_request responseString];
//        dispatch_async(dispatch_get_main_queue(), ^{
//       
//        if ([sign_reponseString rangeOfString:@"true"].location!=NSNotFound) {
//            //  成功
//            
//            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"打卡成功"];
//        }
//            
//        });
//    });
    
}
#pragma mark-custom tap
//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
        [locationService stopUserLocationService];
    
        self.currentLocation=userLocation.location;
    mapView.centerCoordinate = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    
    animition =  [[BMKPointAnnotation alloc]init];
    animition.coordinate = userLocation.location.coordinate;
    [mapView addAnnotation:animition];
    
    
    
    BMKGeoCodeSearch *Search = [[BMKGeoCodeSearch alloc]init];
    Search.delegate = self;
    
    BMKReverseGeoCodeOption *reverOpition = [[BMKReverseGeoCodeOption alloc]init];
    reverOpition.reverseGeoPoint =self.currentLocation.coordinate;
    [Search reverseGeoCode:reverOpition];
}
#pragma  mark -- 大头针
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation{
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotation = [[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:@"myAnimation"];
        newAnnotation.pinColor  = BMKPinAnnotationColorPurple;
        newAnnotation.animatesDrop = YES;
        return newAnnotation;
    }
    return  nil;
}
#pragma mark -- 地理编码
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error!=0) {
        return;
    }
   
    placeLabel.text = [NSString stringWithFormat:@"%@",result.address];
    [[NSUserDefaults standardUserDefaults]setObject:placeLabel.text forKey:@"location"];

}
/**
 *  添加标注
 */
//-(void)loadAnimation:(CLLocation *)location{
//    MAPointAnnotation *point = [[MAPointAnnotation alloc]init];
//    point.coordinate = location.coordinate;
//    [mapView addAnnotation:point];
//}
//-(MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation{
//    if ([annotation isKindOfClass:[MAPointAnnotation class]])
//    {
//        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
//        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
//        }
//        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
////        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
////        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
//        annotationView.pinColor = MAPinAnnotationColorPurple;
//        return annotationView;
//    }
//    return nil;
//
//}
#pragma mark - 逆向地理编码
//- (void)onReGeocodeSearchWithla:(CGFloat )la lo:(CGFloat )lo{
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
//        placeLabel.text = [NSString stringWithFormat:@"%@",response.regeocode.formattedAddress];
//        [[NSUserDefaults standardUserDefaults]setObject:placeLabel.text forKey:@"location"];
//    }
//    
//}


-(void)KQJL{
    CCKQJLViewController *kqjl=[[CCKQJLViewController alloc]init];
    kqjl.currDate = currentDate;
    kqjl.signTimeArray = [timeArray copy];
    [self.navigationController pushViewController:kqjl animated:YES];
}
-(void)signIn{
    [self chageStatusWithStr:@"0"];
    
}
-(void)signOut{
    if (signInButton.userInteractionEnabled==YES) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"请先签到" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    [self chageStatusWithStr:@"1"];
}
-(void)chageStatusWithStr:(NSString *)statusCode{
    //@"http://117.78.42.226:8081/outside/signmgr/sign?checkType=0&memberId=99999";
    //不在签到区域不能打卡

    
    
    
    
    if (placeLabel.text.length==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"还未定位完成" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    
    
    
     NSDictionary *dic=@{@"checkType":statusCode,@"singLng":[NSString stringWithFormat:@"%f",self.currentLocation.coordinate.longitude],@"singLat":[NSString stringWithFormat:@"%f",self.currentLocation.coordinate.latitude],@"location":placeLabel.text};
    NSString *  urlString=[CCUtil basedString:signInOrOutUrl withDic:dic];
    ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [Requset setRequestMethod:@"GET"];
    [Requset setTimeOutSeconds:20];
    [Requset startSynchronous];
    NSString *Str=[Requset responseString];
    if ([Str rangeOfString:@"false"].location!=NSNotFound) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"签到错误" delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    if ([Str rangeOfString:@"true"].location!=NSNotFound) {
        switch ([statusCode intValue]) {
            case 0:
            {
                signInButton.userInteractionEnabled=NO;
                [signInButton setTitle:@"您已签到" forState:UIControlStateNormal];
                [signInButton setBackgroundColor:[UIColor grayColor]];
                [CCUtil showMBProgressHUDLabel:@"签到成功" detailLabelText:nil];
                
            }
                break;
            case 1:{
                signOutButton.userInteractionEnabled=NO;
                [signOutButton setTitle:@"您已签退" forState:UIControlStateNormal];
                [signOutButton setBackgroundColor:[UIColor grayColor]];
                [CCUtil showMBProgressHUDLabel:@"签退成功" detailLabelText:nil];
            }
                
            default:
                break;
        }
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_signoff"];

    if (timer.isValid) {
        [timer invalidate];
    }
    timer=[NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(updateTime) userInfo:nil repeats:YES];
    
}

#pragma mark -获取当天签到信息
-(void)getSIGNINFO{
    
    [formatter setDateFormat:@"yyyy-MM-dd"];
    today=[formatter stringFromDate:currentDate];
    
    NSString *startTime=[NSString stringWithFormat:@"%@ 00:00:00",today];
    NSDictionary *dic=@{@"startTime":startTime,@"endTime":startTime,@"pageSize":@"17"};
    NSString *final=[CCUtil basedString:signInfoURL withDic:dic];
    ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [Requset setRequestMethod:@"GET"];
    [Requset setTimeOutSeconds:20];
    [Requset startSynchronous];
    NSLog(@"%@",Requset.responseString);
    NSData *responData=[Requset responseData];
    if ([responData length]==0) {
        [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
        return;
    }
    NSArray * CurDaySignArr=[[[NSJSONSerialization JSONObjectWithData:responData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"data"]objectAtIndex:0][@"signInfoRsp"];
   
//    if (![CurDaySignArr[2] isKindOfClass:[NSNull class]]) {
//        signInButton.userInteractionEnabled=NO;
//        [signInButton setTitle:@"您已签到" forState:UIControlStateNormal];
//        [signInButton setBackgroundColor:[UIColor grayColor]];
//        
//    }
//    if (![CurDaySignArr[3] isKindOfClass:[NSNull class]]) {
//        signOutButton.userInteractionEnabled=NO;
//        [signOutButton setTitle:@"您已签退" forState:UIControlStateNormal];
//        [signOutButton setBackgroundColor:[UIColor grayColor]];
//    }
}
#pragma mark--location delegate
//获取服务器的签到时间
-(void)getSignOutTimeByUserId:(NSString *)string{
    //return;[0]	(null)	@"message" : @"2015-11-12 14:42:21"
    
//    NSDictionary *dic=nil;
//    NSString *final=[CCUtil basedString:quertTimeUrl withDic:dic];
//    ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [Requset setRequestMethod:@"GET"];
//    [Requset setTimeOutSeconds:20];
//    [Requset startSynchronous];
//    NSLog(@"%@",Requset.responseString);
//    NSData *responData=[Requset responseData];
//    if ([responData length]==0) {
//        [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
//        return;
//    }
//    NSDictionary *dic1=[NSJSONSerialization JSONObjectWithData:responData options:NSJSONReadingMutableLeaves error:nil];
//    singInTime1=dic1[@"signIn"];
//    singOutTimeTerminal=dic1[@"sign"];
    ASIHTTPRequest *Requset2=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[currentTimeUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [Requset2 setRequestMethod:@"GET"];
    [Requset2 setTimeOutSeconds:20];
    [Requset2 startSynchronous];
     NSData *responData2=[Requset2 responseData];
    if ([responData2 length]==0) {
        [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
        return;
    }
    NSDictionary *dic12=[NSJSONSerialization JSONObjectWithData:responData2 options:NSJSONReadingMutableLeaves error:nil];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str=dic12[@"message"];
    currentDate=[formatter dateFromString:str];
 
    NSDate *date_local = [NSDate date];
    if (fabs([date_local timeIntervalSinceDate:currentDate])>100) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"您的本机时间和服务器时间有较大误差,可能会造成考勤数据的异常"];
    }
    
    
}
/**
 *  更新时间
 */
-(void)updateTime{
    
    currentDate=[currentDate dateByAddingTimeInterval:1];
    
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateAndTime =  [formatter stringFromDate:currentDate];
    [timeLabel setText:[dateAndTime substringFromIndex:10]];
    
//    currentDate=[CCUtil convertDateFromString:dateAndTime];
//    
//    NSString *string=[dateAndTime substringWithRange:NSMakeRange(0, 10)];
//    //    NSString *StartTime=[NSString stringWithFormat:@"%@ 09:00:00",string];
//    NSString *StartTime=[NSString stringWithFormat:@"%@ %@",string,singInTime1];
//    NSString *endTime=[NSString stringWithFormat:@"%@ %@",string,singOutTimeTerminal];
//    
//    long singInTime=[currentDate timeIntervalSinceDate:[CCUtil convertDateFromString:StartTime]]*(-1);
//    
//    long singOutTime=[currentDate timeIntervalSinceDate:[CCUtil convertDateFromString:endTime]]*(-1);
//    
//    [signInLabel setText:[CCUtil changeDateWithInterval:singInTime]];
//    NSString *str=[CCUtil changeDateWithInterval:singOutTime];
//    str=[str stringByReplacingOccurrencesOfString:@"签到" withString:@"签退"];
//    [signOutLabel setText:str];
//    
//    NSLog(@"---------%@",[NSThread currentThread]);
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [timer invalidate];
 }
-(void)returnBack{
    [timer invalidate];
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    if (!self.view.window&&self.isViewLoaded) {
        for (UIView *subView in self.view.subviews) {
            [subView removeFromSuperview];
        }
        self.view = nil;
        
    }
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
