////
////  CCLocationViewController.m
////  CCField
////
////  Created by 李付 on 14-10-9.
////  Copyright (c) 2014年 Field. All rights reserved.
////
//
//#import "CCReportViewController.h"
//#import "CCLocationViewController.h"
//#import "CSDataService.h"
//#import "BMKMapView.h"
//#import "BMKLocationService.h"
//#import "BMKGeocodeSearch.h"
//#import "ASIHTTPRequest.h"
//#import "CSDataService.h"
//#import "CCUtil.h"
//
//@interface CCLocationViewController ()<BMKMapViewDelegate,BMKLocationServiceDelegate,ASIHTTPRequestDelegate,BMKGeoCodeSearchDelegate>{
//    BMKMapView *mapView;
//    BMKLocationService *locationService;
//    ASIHTTPRequest *sendRequest;
//    BMKGeoCodeSearch *_searcher;
//}
//
//@end
//
//@implementation CCLocationViewController
//
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//    
//    self.lableNav.text=@"位置上报";
//    [self SendermapBasicClass];
//    [self SenderRequestRecord];
//    
//     //地理位置
//    mapLabel = [[UILabel alloc] init];
//   // mapLabel.frame=CGRectMake(0,80,200, 20);
//    mapLabel.textColor = [UIColor whiteColor];
//    mapLabel.font = [UIFont systemFontOfSize:12];
//    mapLabel.backgroundColor = RGBA(0, 0, 0, 0.4);
//    mapLabel.text = @"  正在获取地理位置信息..";
//    [self.view addSubview:mapLabel];
//    
//}
///*
// * 地图基本类
// */
//-(void)SendermapBasicClass
//{
//    mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.imageNav.frame),kFullScreenSizeWidth,kFullScreenSizeHeght)];
//    if ([[CCUtil getCurrentDeviceModel:nil]isEqualToString: @"iPhone 6 Plus (A1522/A1524)"]) {
//        //6p
//        NSLog(@"6p");
//        mapView=[[BMKMapView alloc]initWithFrame:CGRectMake(0,-500,500,kFullScreenSizeHeght*2)];
//        
//    }
//   
//    
//    mapView.mapType=BMKUserTrackingModeFollow;
//    mapView.showsUserLocation=YES;
//    mapView.delegate=self;
//    mapView.zoomLevel=5;
//    mapView.ChangeWithTouchPointCenterEnabled=YES;
//    [self.view addSubview:mapView];
//    [self.view sendSubviewToBack:mapView];
//    locationService=[[BMKLocationService alloc]init];
//    locationService.delegate=self;
////    定位精度
//    locationManager.desiredAccuracy=kCLLocationAccuracyBest;
//    if ([defaults objectForKey:kFirstLoction]==Nil) {
//        if ([[UIDevice currentDevice].systemVersion floatValue] >= 8) {
//            //由于IOS8中定位的授权机制改变 需要进行手动授权
//            locationManager = [[CLLocationManager alloc] init];
//            //获取授权认证
//#if __IPHONE_OS_VERSION_MAX_ALLOWED > __IPHONE_7_1
//            if (IOS8_OR_LATER) {
//                [locationManager requestWhenInUseAuthorization];
//                [locationManager requestAlwaysAuthorization];
//                
//            }
//#endif
//        }
//        [defaults setObject:@"isFirstRequestLocation" forKey:kFirstLoction];
//    }else
//    {
//        //检测系统定位服务是否开启
//        if (![CLLocationManager locationServicesEnabled]) {
//            UIAlertView *openLocationServiceAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            [openLocationServiceAlert show];
//        }
//        if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
//            UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开本应用定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
//            myAlert.delegate = self;
//            [myAlert show];
//        }
//    }
//    [locationService startUserLocationService];
//}
//-(void)didFailToLocateUserWithError:(NSError *)error{
//   // [CCUtil showMBProgressHUDLabel:@"定位失败" detailLabelText:@""];
//    [CCUtil showMBProgressHUDLabel:[error description]];
//    [locationService startUserLocationService];
//
//}
///*
// * 上报定位记录
// */
//-(void)SenderRequestRecord
//{
//    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//    button.frame=CGRectMake(260, 20, 40,50);
//    [button addTarget:self action:@selector(reportRecord) forControlEvents:UIControlEventTouchUpInside];
//    [self.imageNav addSubview:button];
//
//    UIImageView  *recordBtn=[[UIImageView alloc]initWithFrame:CGRectMake(10, 10, 25, 25)];
//    
//    [recordBtn setImage:[UIImage imageNamed:@"上报图标"]];
//
//     [button addSubview:recordBtn];
//    
//}
//
//- (void)GeoSearcher{
//    
//    //初始化检索对象
//    _searcher =[[BMKGeoCodeSearch alloc]init];
//    _searcher.delegate = self;
//    //发起反向地理编码检索
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){12, 116.404};
//    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
//    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
//   
//    
//}
//
//#pragma  -ditu delegate
//- (void)didUpdateUserLocation:(BMKUserLocation *)userLocation{
//    [locationService stopUserLocationService];
//    _jingLongitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
//    _weiLatitude = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
//    jingweiLabel.text= [NSString stringWithFormat:@"经 度 ： %@  纬 度 ： %@",_jingLongitude,_weiLatitude];
//
// 
//    CLLocationCoordinate2D coordinate;                  //设定经纬度
//    coordinate.latitude =[_weiLatitude floatValue];       //纬度
//    coordinate.longitude = [_jingLongitude floatValue];      //经度
//    
//    
//    
//    
//    //初始化检索对象
//    _searcher =[[BMKGeoCodeSearch alloc]init];
//    _searcher.delegate = self;
//    //发起反向地理编码检索
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){coordinate.latitude, coordinate.longitude};
//    BMKReverseGeoCodeOption *reverseGeoCodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeoCodeSearchOption.reverseGeoPoint = pt;
//    BOOL flag = [_searcher reverseGeoCode:reverseGeoCodeSearchOption];
//    if(flag)
//    {
//        NSLog(@"反geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"反geo检索发送失败");
//    }
//    
//    
//    
//    BMKCoordinateRegion viewRegion = BMKCoordinateRegionMake(coordinate, BMKCoordinateSpanMake(0.01, 0.01));
////     NSString *url = [NSString stringWithFormat:@"http://api.map.baidu.com/geocoder?location=%@,%@&output=json&key=%@",_weiLatitude,_jingLongitude,baiduKey];
////    [CSDataService requestWithURL:url params:nil httpMethod:@"GET" block:^(id result) {
////         self->_dic = (NSDictionary *)result;
////        NSLog(@"%@",self->_dic);
////        if (self->_dic[@"result"][@"formatted_address"] != nil) {
////            self->mapLabel.text = [NSString stringWithFormat:@"%@",self->_dic[@"result"][@"formatted_address"]];
////            NSLog(@"11111111111111%@",self->mapLabel.text);
//            if (self->mapLabel.text.length<5) {
//                [CCUtil showMBProgressHUDLabel:@"定位失败"];
//            }
//            else{
//                   //设置中心店
//                [self->mapView setCenterCoordinate:CLLocationCoordinate2DMake([self->_weiLatitude floatValue], [self->_jingLongitude floatValue])];
//                [self->mapView setRegion:viewRegion animated:YES];
//
////                [self loadAnonationView:<#(BMKGeoCodeSearch *)#> result:<#(BMKReverseGeoCodeResult *)#>];
//            }
////            }
////        else
//
////     }];
//  }
//
////-(void)loadAnonationView:(BMKGeoCodeSearch *)searcher result:
////(BMKReverseGeoCodeResult *)result
////{
////    [self onGetReverseGeoCodeResult:searcher result:result errorCode:nil];
////}
//
//
//-(BMKAnnotationView *)mapView:(BMKMapView *)mapView1 viewForAnnotation:(id<BMKAnnotation>)annotation{
//    if([annotation isKindOfClass:[BMKPointAnnotation class]]){
//        static NSString *identifie=@"test";
//        newAnnotationView = (BMKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:identifie];
//        if(newAnnotationView==nil){
//            newAnnotationView=[[BMKPinAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:identifie];
//            newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
//            newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
//                       newAnnotationView.canShowCallout=YES;
//        }
//        return newAnnotationView;
//    }
//    return nil;
//}
//
//- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
//{
////    NSLog(@"点击annotation view弹出的泡泡");
//    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:locationUrl]];
//     NSDictionary *dicParam=@{@"lng":_jingLongitude,@"lat":_weiLatitude,@"currLocation":mapLabel.text};
//    
//    NSString *final=[CCUtil basedString:locationUrl  withDic:dicParam];
//    requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
//    [ requset setUseCookiePersistence : YES ];
//    [requset setRequestMethod:@"GET"];
//    [requset startSynchronous];
//    NSData *Data=[requset responseData];
//    NSLog(@"666 %@",requset.responseString);
//    if (Data.length==0) {
//        [CCUtil showMBLoading:@"请检查网络" detailText:@"请检查网络"];
//        return;
//    }
//    dicJson=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
//    NSLog(@" %@",dicJson);
//    if ([[dicJson valueForKey:@"success"]intValue]==1) {
//        
//        [CCUtil showMBProgressHUDLabel:@"上传成功" detailLabelText:nil];
//    }
//    else{
//        [CCUtil showMBProgressHUDLabel:@"上传失败" detailLabelText:nil];
//    }
//    
//}
//-(void)reportRecord{
//    CCReportViewController *CCReport=[[CCReportViewController alloc]init];
//    [self.navigationController pushViewController:CCReport animated:YES];
//}
//#pragma mark - 反地理编码
////接收反向地理编码结果
//-(void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:
//(BMKReverseGeoCodeResult *)result
//                        errorCode:(BMKSearchErrorCode)error{
//    if (error == BMK_SEARCH_NO_ERROR) {
////        在此处理正常结果
////        for (int i = 0; i < result.poiList.count; i++)
////        {
//            BMKPoiInfo* poi = [result.poiList firstObject];
//            mapLabel.text = [NSString stringWithFormat:@"%@\n",poi.address];
//        NSLog(@"2222222222222%@",self->mapLabel.text);
//
//        BMKPointAnnotation *annotation=[[BMKPointAnnotation alloc]init];
//        CLLocationCoordinate2D coor;
//        coor.latitude =[_weiLatitude  floatValue];       //纬度
//        coor.longitude =[_jingLongitude floatValue];      //经度
//        annotation.coordinate=coor;
//        NSString *paraString=[NSString stringWithFormat:@"%@－－%@",[CCUtil timeCurrte],@"点击上报"];
//        annotation.title=mapLabel.text;
//        annotation.subtitle=paraString;
//        [mapView addAnnotation:annotation];
//        [mapView selectAnnotation:annotation animated:YES];
//
//
////            BMKPoiInfo就是检索出来的poi信息
////        }
////        NSString *map = [NSString stringWithFormat:@"%@\n",result.poiList];
//////        NSLog(@"%@",result.poiList);
////        [CCUtil showMBProgressHUDLabel:map];
//    
//    }
//    else {
//        NSLog(@"抱歉，未找到结果");
//    }
//}
//
////不使用时将delegate设置为 nil
//-(void)viewWillDisappear:(BOOL)animated
//{
//    _searcher.delegate = nil;
//}
//
//@end
