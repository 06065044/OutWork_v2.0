//
//  CCLocationController.m
//  CCField
//
//  Created by issuser on 16/4/18.
//  Copyright © 2016年 Field. All rights reserved.
//手动上报
// 本页面为高德跟百度混编，取得高德的定位信息，取得百度的经纬度，一起上传后台

#import "STLocationUp.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import "CCUtil.h"
#import "CSDataService.h"
#import "CCReportViewController.h"
#import "CCCustomAnnotationView.h"
#import "CCCustomCalloutView.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "STSubChooseViewController.h"

@interface STLocationUp()<MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate,CLLocationManagerDelegate,UIGestureRecognizerDelegate,CCCustomAnnotationViewDelegate,BMKLocationServiceDelegate>
{   //高德地图基本地图全局变量
    MAMapView *_mapView;    //高德地图类
    BMKLocationService *_locService;//百度地图定位
    NSString *_jing; //百度地图精度
    NSString *_wei; //百度地图纬度
    __block   NSDictionary *_dic;
    UILabel *mapLabel;
    NSString *placeLable;
    NSDictionary *dicJson;
    AMapSearchAPI *_search;
    AMapLocationManager *locationManager;
     MAPointAnnotation *annotation;
    UIButton *portraitView;
    CCCustomCalloutView *view;
    //转换坐标之后经纬度
    NSString * Newlongitude;
    NSString * Newlatitude;
    UIButton *button;
}

@end

@implementation STLocationUp
- (void)viewDidLoad {
    [super viewDidLoad];
    //百度地图定位初始化
    [self addRightBtn];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"small"];
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    
    //启动LocationService
    [_locService startUserLocationService];
    
    //配置用户Key
    [AMapServices sharedServices].apiKey = AMAP_KEY;
    
    //  21af4e9c071b8bdf9d63d5641ce69c3d  test: 63b48a115accad2095a547bfa7d4fbf4
    self.lableNav.text=@"位置上报";
    //地理位置
    mapLabel = [[UILabel alloc] init];
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lableNav.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.showsUserLocation = NO;    //YES 为打开定位，NO为关闭定位
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    
    //显示比例
    [_mapView setZoomLevel:16.8 animated:YES];
    
 
    //显示普通地图
    _mapView.mapType = MAMapTypeStandard;
    [self.view addSubview:_mapView];
    
    
    [self SenderRequestRecord];
    
    //显示普通地图
    //    if ([[CCUtil getCurrentDeviceModel:nil]isEqualToString: @"iPhone 6 Plus (A1522/A1524)"]) {
    //        //6p
    //        NSLog(@"6p");
    //        _mapView=[[MAMapView alloc]initWithFrame:CGRectMake(0,-500,500,kFullScreenSizeHeght*2)];
    //
    //    }
    //检测系统定位服务是否开启
    if (![CLLocationManager locationServicesEnabled]) {
        UIAlertView *openLocationServiceAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [openLocationServiceAlert show];
    }
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized) {
        UIAlertView *myAlert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请先到系统设置中打开本应用定位服务" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        myAlert.delegate = self;
        [myAlert show];
    }
    locationManager = [[AMapLocationManager alloc] init];
    locationManager.delegate = self;
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [locationManager startUpdatingLocation];
}
-(void)addRightBtn{
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame = CGRectMake(kFullScreenSizeWidth-50, CGRectGetMinY(self.lableNav.frame)+5, 30, 30);
    [self.view addSubview:addBtn];
    [addBtn setImage:[UIImage imageNamed:@"addfriend"] forState:UIControlStateNormal];
     [addBtn addTarget:self action:@selector(addPeople) forControlEvents:UIControlEventTouchUpInside];
    
}

/**
 选择员工
 */
-(void)addPeople{
    STSubChooseViewController *sub = [[STSubChooseViewController alloc]init];
    [self.navigationController pushViewController:sub animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_location"];
    if (!button.userInteractionEnabled) {
        button.userInteractionEnabled = YES;
    }
}
//百度地图位置更新，把经纬度传到后台
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    _jing = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    _wei =  [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];
  //  [_locService stopUserLocationService];
}

//高德地图持续定位，取到上传的气泡内容
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
  //  [locationManager stopUpdatingLocation];
    
    _jingLongitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    _weiLatitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    
    _horizontalAccuracy = location.horizontalAccuracy;
    
    CLLocationCoordinate2D coordinate;                  //设定经纬度
    coordinate.latitude =[_weiLatitude floatValue];       //纬度
    coordinate.longitude = [_jingLongitude floatValue];
    //经度
    
    //    NSLog(@"location:{lat:%f; lon:%f; accuracy:%f}", coordinate.latitude, coordinate.longitude, location.horizontalAccuracy);
    
    //设置中心店
   _mapView.centerCoordinate = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude);
    
    [self onReGeocodeSearchWithla:coordinate.latitude lo:coordinate.longitude];
    
}
#pragma mark - 逆向地理编码
- (void)onReGeocodeSearchWithla:(CGFloat )la lo:(CGFloat )lo{
    [AMapServices sharedServices].apiKey = AMAP_KEY;
    
    //初始化检索对象
    _search = [[AMapSearchAPI alloc] init];
    _search.delegate = self;
    
    //构造AMapReGeocodeSearchRequest对象
    AMapReGeocodeSearchRequest *regeo = [[AMapReGeocodeSearchRequest alloc] init];
    regeo.location = [AMapGeoPoint locationWithLatitude:la     longitude:lo];
    regeo.radius = 10000;
    regeo.requireExtension = YES;
    //发起逆地理编码
    [_search AMapReGoecodeSearch: regeo];
}

#pragma mark - 实现逆地理编码的回调函数
- (void)onReGeocodeSearchDone:(AMapReGeocodeSearchRequest *)request response:(AMapReGeocodeSearchResponse *)response
{
    
    if(response.regeocode != nil)
    {
        NSString *time=[NSString stringWithFormat:@"%@",[CCUtil timeCurrte]];
        
        self->mapLabel.text = [NSString stringWithFormat:@"%@\n%@",response.regeocode.formattedAddress,time];
        placeLable = [NSString stringWithFormat:@"%@",response.regeocode.formattedAddress];
        //添加标注
        [self loadAnonationView];
        
    }
    
}


- (void)loadAnonationView{
    if (self->annotation == nil) {
        self->annotation=[[MAPointAnnotation alloc]init];
        CLLocationCoordinate2D coordinate;                  //设定经纬度
        coordinate.latitude =[self->_weiLatitude floatValue];       //纬度
        
        coordinate.longitude = [self->_jingLongitude floatValue];      //经度
        
        self->annotation.coordinate = coordinate;
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 10)];
        label.backgroundColor = [UIColor blackColor];
        label.text = @"点击上报";
        label.textColor = [UIColor redColor];
        
        NSString *paraString=[NSString stringWithFormat:@"%@",label.text];
        
        self->annotation.title= self->mapLabel.text;
        self->annotation.subtitle=paraString;
        [self->_mapView addAnnotation:self->annotation];
        [_mapView selectAnnotation:self->annotation animated:YES];
    }
    
}
- (void)click{
    [self btnClick];
}
//-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
//
//    NSLog(@"33");
//    [view setSelected:NO];
//}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
//    if ([annotation isKindOfClass:[MAPinAnnotationView class]])
//    {
//        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
//        CCCustomAnnotationView *annotationView = (CCCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
//        if (annotationView == nil)
//        {
//            annotationView = [[CCCustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
//        }
//        
//        // 设置为NO，用以调用自定义的calloutView
//        annotationView.canShowCallout = NO;
//        
//        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -18);
//        return annotationView;
//    }
//    return nil;
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isKindOfClass:[MAUserLocation class]])
    {
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        return annotationView;
    }
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        CCCustomAnnotationView *annotationView = (CCCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:
                                                                            reuseIndetifier];
        
        
        
        if (annotationView == nil)
        {
            annotationView = [[CCCustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
         }
        annotationView.delegate3 = self;

        // 设置为NO，用以调用自定义的calloutView
        annotationView.canShowCallout = NO;
        
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}
/*
 * 上报定位记录按钮
 */
-(void)SenderRequestRecord
{
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(kFullScreenSizeWidth/2-50, kFullScreenSizeHeght-30, 100, 30);
    
    [button addTarget:self action:@selector(reportRecord:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.imageNav.userInteractionEnabled = YES;
//    UIImageView  *recordBtn=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 100, 40)];
//    
//    [recordBtn setImage:[UIImage imageNamed:@"上报图标"]];
//    [button addSubview:recordBtn];
    
    [button setImage:[UIImage imageNamed:@"map"] forState:UIControlStateNormal];
    [button setTitle:@"我的位置记录" forState:UIControlStateNormal];
    [button setBackgroundColor:self.imageNav.backgroundColor];
    [button.titleLabel setFont:[UIFont systemFontOfSize:12]];

    UIBezierPath *peah = [UIBezierPath bezierPathWithRoundedRect:button.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
    CAShapeLayer *layer  = [[CAShapeLayer alloc]init];
    layer.frame = button.bounds;
    layer.path = peah.CGPath;
    button.layer.mask = layer;
    


}

-(void)reportRecord:(UIButton *)ben{
    ben.userInteractionEnabled = NO;
    CCReportViewController *CCReport=[[CCReportViewController alloc]init];
    //    CCReport.mapLable = mapLabel;
    [self.navigationController pushViewController:CCReport animated:YES];
}
- (void)btnClick{
    NSLog(@"点击annotation view弹出的泡泡");
    
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
    if (placeLable.length<4) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无具体位置"];
        return;
    }
    NSDictionary *dicParam=@{@"lng":lng,@"lat":lat,@"currLocation":placeLable};
    NSString *final=[CCUtil basedString:locationUrl  withDic:dicParam];
    
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [ requset setUseCookiePersistence : YES ];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    NSLog(@"666 %@",requset.responseString);
    if (Data.length==0) {
        [CCUtil showMBLoading:nil detailText:@"请检查网络"];
        return;
    }
    dicJson=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    NSLog(@" %@",dicJson);
    if ([[dicJson valueForKey:@"success"]intValue]==1) {
        [CCUtil showMBProgressHUDLabel:@"上传成功" detailLabelText:nil];
    }
    else{
        [CCUtil showMBProgressHUDLabel:@"上传失败" detailLabelText:nil];
    }
    
}
- (void)didReceiveMemoryWarning {
    // Dispose of any resources that can be recreated.
    [super didReceiveMemoryWarning];
    if (!self.view.window&&self.isViewLoaded) {
        for (UIView *subView in self.view.subviews) {
            [subView removeFromSuperview];
        }
        [_locService stopUserLocationService];
        [locationManager stopUpdatingLocation];
        self.view = nil;
        
    }
}
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [locationManager stopUpdatingLocation];
    [_locService stopUserLocationService];
    
 }
@end
