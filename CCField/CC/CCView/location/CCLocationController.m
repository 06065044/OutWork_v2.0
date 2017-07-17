//
//  CCLocationController.m
//  CCField
//
//  Created by issuser on 16/4/18.
//  Copyright © 2016年 Field. All rights reserved.
//手动上报
// 本机构为高德跟百度混编，取得高德的定位信息，取得百度的经纬度，一起上传后台

#import "CCLocationController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "CCUtil.h"
#import "CSDataService.h"
#import "CCReportViewController.h"
#import "CCCustomAnnotationView.h"
#import "CCCustomCalloutView.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "UIColor+STHxString.h"
@interface CCLocationController ()<MAMapViewDelegate,AMapSearchDelegate,AMapLocationManagerDelegate,UIGestureRecognizerDelegate,BMKLocationServiceDelegate,UISearchBarDelegate,UITableViewDelegate,UITableViewDataSource>
{   //高德地图基本地图全局变量AMapSearchDelegate
    MAMapView *_mapView;    //高德地图类
    BMKLocationService *_locService;//百度地图定位
    NSString *_jing; //百度地图精度
    NSString *_wei; //百度地图纬度
    __block   NSDictionary *_dic;
    UILabel *mapLabel;
    NSString *placeLable;
    AMapSearchAPI *_search;
    AMapLocationManager *locationManager;
    CLLocationManager *locationManager2;
    MAPointAnnotation *annotation;
    CCCustomCalloutView *view;
    UITableView * resultsTable;
    NSArray     * resultArray;
    UITableViewCell *cellCur;
    NSInteger indexCur;
    CGPoint originCenter;
    UIView *_grayAplpaView;
    
    //
    UISearchBar *search0;
    NSArray *searchArray;
    MAP_TYPE  maptype;
    NSString *curLat;
    NSString *curLon;
    UILabel *titleBale;
    UILabel *locaitionBale;
 }

@end

@implementation CCLocationController
-(void)sureSelect{
    
    //经纬度和地址
    AMapPOI *poi = resultArray[indexCur];
    NSArray *arr1 = @[@(poi.location.latitude),@(poi.location.longitude)];
    NSString *location = poi.address;
    if (_sure) {
        _sure(arr1,location);
    }
    [self.navigationController popViewControllerAnimated:YES];

}
-(void)setBlock:(sureLocation)blockA{
    _sure = [blockA copy];
    
}
- (void)viewDidLoad {
    [super viewDidLoad];
//     [self.buttonNav setImage:nil forState:UIControlStateNormal];
    //添加左右
    
    UIButton *sureBtn  =[UIButton buttonWithType:UIButtonTypeCustom];
    [sureBtn setFrame:CGRectMake(kFullScreenSizeWidth-65, 25, 50, 35)];
    [sureBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.imageNav addSubview:sureBtn];
    [sureBtn addTarget:self action:@selector(sureSelect) forControlEvents:UIControlEventTouchUpInside];
     //百度地图定位初始化
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    _locService.delegate = self;
    _locService.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    //启动LocationService
    [_locService startUserLocationService];
    maptype = MAP_TYPE_GAODE;
    
    //配置用户Key
    [AMapServices sharedServices].apiKey = AMAP_KEY;
    
    search0 = [[UISearchBar alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 30)];
    search0.delegate = self;
    search0.barStyle  =  UISearchBarStyleDefault;
      search0.placeholder = @"搜索";
    [self.view addSubview:search0];
    
    self.lableNav.text=@"签到位置";
    //地理位置
    mapLabel = [[UILabel alloc] init];
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lableNav.frame)+30, CGRectGetWidth(self.view.bounds), (CGRectGetHeight(self.view.bounds)-94)/2.0-30)];
    _mapView.delegate = self;
    // _mapView.showsUserLocation = NO;    //YES 为打开定位，NO为关闭定位
    //  _mapView.userLocationVisible = NO;
    // [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    [[_mapView subviews][1] removeFromSuperview];
    NSLog(@"%@",_mapView.subviews);
    //显示比例
    [_mapView setZoomLevel:16.8 animated:YES];
    
    //后台定位
    _mapView.pausesLocationUpdatesAutomatically = NO;
    
    _mapView.allowsBackgroundLocationUpdates = YES;//iOS9以上系统必须配置
    _mapView.showsScale = false;
    _mapView.showsCompass = false;
    //显示普通地图
    _mapView.mapType = MAMapTypeStandard;
    [self.view addSubview:_mapView];
    
    titleBale = [[UILabel alloc]initWithFrame:CGRectMake(15, CGRectGetMaxY(_mapView.frame), kFullScreenSizeWidth, 25)];
    titleBale.font = [UIFont systemFontOfSize:16];
    
    titleBale.textColor = [UIColor colorWithHexString:@"#000000"];
    [self.view addSubview:titleBale];
    
    locaitionBale = [[UILabel alloc]initWithFrame:CGRectOffset(titleBale.frame, 0, 25)];
    locaitionBale.font = [UIFont systemFontOfSize:12];
    locaitionBale.textColor = [UIColor colorWithHexString:@"#666666"];
    [self.view addSubview:locaitionBale];
    
    
    //添加table
    resultsTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_mapView.frame)+50, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(_mapView.frame)-50) style:UITableViewStylePlain];
    resultsTable.backgroundColor = [UIColor colorWithHexString:@"#efeff4"];
    resultsTable.delegate = self;
    resultsTable.dataSource = self;
    [self.view addSubview:resultsTable];
    
    
  
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
    locationManager = [[AMapLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    // 带逆地理信息的一次定位（返回坐标和地址信息）
    [locationManager startUpdatingLocation];
    
    originCenter = self.view.center;
    //添加三个button
    [self add3Button];
}
-(void)add3Button{
    UIButton *refreshBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [refreshBtn setFrame:CGRectMake(10, CGRectGetMaxY(_mapView.frame)-50, 40, 40)];
    [refreshBtn setImage:[UIImage imageNamed:@"ic_my_location_gray"] forState:UIControlStateNormal];
    [self.view addSubview:refreshBtn];
    [refreshBtn addTarget:self action:@selector(refrefhLocation) forControlEvents:UIControlEventTouchUpInside];
    
    
    UIButton *changeBtn = [UIButton  buttonWithType:UIButtonTypeCustom];
    [changeBtn setFrame:CGRectMake(kFullScreenSizeWidth-50, CGRectGetMinY(refreshBtn.frame), CGRectGetWidth(refreshBtn.frame), CGRectGetHeight(refreshBtn.frame))];
    [changeBtn setImage:[UIImage imageNamed:@"change_img_baidu_normal"] forState:UIControlStateNormal];
    changeBtn.tag  = 337;
    [self.view addSubview:changeBtn];
    [changeBtn addTarget:self action:@selector(changeMap0) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *helpBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [helpBtn setFrame:CGRectOffset(changeBtn.frame, 0, -50)];
    [helpBtn setImage:[UIImage imageNamed:@"ic_help_48dp"] forState:UIControlStateNormal];
    [self.view addSubview:helpBtn];
    [helpBtn addTarget:self action:@selector(showHelp) forControlEvents:UIControlEventTouchUpInside];
    
}
-(void)changeMap0{
    
    _grayAplpaView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(_imageNav.frame))];
    _grayAplpaView.backgroundColor = [UIColor lightGrayColor];
    _grayAplpaView.alpha = 0.5;
    [self.view addSubview:_grayAplpaView];
    UITapGestureRecognizer *removeView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
    removeView.numberOfTapsRequired = 1;
    removeView.numberOfTouchesRequired = 1;
    [_grayAplpaView addGestureRecognizer:removeView];
    
    
    UIView *whiteView = [[UIView alloc]initWithFrame:CGRectMake(10, CGRectGetMidY(_grayAplpaView.frame)-80, CGRectGetWidth(_grayAplpaView.frame)-20, 100)];
    whiteView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:whiteView];
    whiteView.tag = 334;

    whiteView.layer.cornerRadius = 8;
    
    NSArray *btnImageArray = @[[UIImage imageNamed:@"location_baidu_logo"],[UIImage imageNamed:@"location_gaode_logo"],[UIImage imageNamed:@"location_tencent_logo"]];
    for (int i=0; i<btnImageArray.count; ++i) {
        UIButton  *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        [btn setFrame:CGRectMake(10+100*i, 10, 90, 80)];
        [btn setImage:btnImageArray[i] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(changeMap:) forControlEvents:UIControlEventTouchUpInside];
        btn.tag = i;
        [whiteView addSubview:btn];
    }
  }
-(void)changeMap:(UIButton *)btn{
    [_grayAplpaView removeFromSuperview];
    _grayAplpaView=nil;
    [[self.view viewWithTag:334]removeFromSuperview];
    NSInteger tag = btn.tag;
    
    [_mapView removeAnnotation:annotation];
    annotation = nil;
    resultArray = [NSArray array];
    [resultsTable reloadData];
    indexCur = 0;
    UIButton *cBtn = (UIButton *)[self.view viewWithTag:337];
    if (tag==MAP_TYPE_BAIDU) {
        //
        [cBtn setImage:[UIImage imageNamed:@"change_img_baidu_normal"] forState:UIControlStateNormal];
         maptype = MAP_TYPE_BAIDU;
        
        curLon = [_jing copy];
        curLat = [_wei copy];
 
        CLLocationCoordinate2D amapcoord = AMapCoordinateConvert(CLLocationCoordinate2DMake(curLat.floatValue,curLon.floatValue),AMapCoordinateTypeBaidu);
        
        [self onReGeocodeSearchWithla:amapcoord.latitude lo:amapcoord.longitude];
    }
    else if(tag == MAP_TYPE_GAODE)  {
        //调用高德
          [cBtn setImage:[UIImage imageNamed:@"change_img_gaode_normal"] forState:UIControlStateNormal];
        maptype = MAP_TYPE_GAODE;
    
        curLat = [_weiLatitude copy];
        curLon = [_jingLongitude copy];
        [self onReGeocodeSearchWithla:curLat.floatValue lo:curLon.floatValue];
    
    }
    else{
        [cBtn setImage:[UIImage imageNamed:@"change_img_tencent_normal"] forState:UIControlStateNormal];
        maptype = MAP_TYPE_GAODE;
        curLat = [_weiLatitude copy];
        curLon = [_jingLongitude copy];
        [self onReGeocodeSearchWithla:curLat.floatValue lo:curLon.floatValue];
    }
   
}
//刷新地址
-(void)refrefhLocation{
    [_mapView removeAnnotation:annotation];
    annotation = nil;
    resultArray = [NSArray array];
    [resultsTable reloadData];
    indexCur = 0;
    //重新添加大头针
    [locationManager startUpdatingLocation];

}
//展示帮助
-(void)showHelp{
    _grayAplpaView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(_imageNav.frame))];
    _grayAplpaView.backgroundColor = [UIColor lightGrayColor];
    _grayAplpaView.alpha = 0.5;
    [self.view addSubview:_grayAplpaView];
    UITapGestureRecognizer *removeView = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(removeSelf)];
    removeView.numberOfTapsRequired = 1;
    removeView.numberOfTouchesRequired = 1;
    [_grayAplpaView addGestureRecognizer:removeView];
    
    UIView *helpView = [[UIView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-120, kFullScreenSizeHeght/2.0-100, 240, 260)];
    helpView.backgroundColor = [UIColor whiteColor];
      helpView.layer.cornerRadius =5;
    helpView.tag = 333;
     [self.view addSubview:helpView];
    
  
    UILabel *title = [[UILabel alloc]initWithFrame:CGRectMake(0, 5,CGRectGetWidth(helpView.frame), 30)];
    title.text = @"手机不能定位/定位偏差";
    title.textAlignment = NSTextAlignmentCenter;
    title.font = [UIFont systemFontOfSize:14];
    [helpView addSubview:title];
    
    
    UILabel *sub1 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(title.frame), CGRectGetWidth(helpView.frame)-20, 40)];
    sub1.numberOfLines = 0;
    sub1.lineBreakMode = NSLineBreakByWordWrapping;
    sub1.font = [UIFont systemFontOfSize:12];
    sub1.text = @"1、请到‘设置’-‘隐私’-‘定位服务’中开启本应用定位服务;";
    [helpView addSubview:sub1];
    
    UILabel *sub2 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(sub1.frame), CGRectGetWidth(helpView.frame)-20, 40)];
    sub2.numberOfLines = 0;
    sub2.font = sub1.font;
    sub2.lineBreakMode = NSLineBreakByWordWrapping;
    sub2.text = @"2、确认网络是否正常连接，在网络环境较差的情况下可能出现定位延迟或失败;";
    [helpView addSubview:sub2];
    
    UILabel *sub3 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(sub2.frame), CGRectGetWidth(helpView.frame)-20, 40)];
    sub3.numberOfLines = 0;
    sub3.font = sub1.font;
    sub3.lineBreakMode = NSLineBreakByWordWrapping;
    sub3.text = @"3、如果定位有偏差开启GPS可以获得更精准的定位;";
    [helpView addSubview:sub3];
    
    
    UILabel *sub4 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(sub3.frame), CGRectGetWidth(helpView.frame)-20, 40)];
    sub4.numberOfLines = 0;
    sub4.font = sub1.font;
    sub4.lineBreakMode = NSLineBreakByWordWrapping;
    sub4.text = @"4、可以尝试切换地图减少定位偏差，支持百度和高德地图切换功能;";
    [helpView addSubview:sub4];
    
    
    UILabel *sub5 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(sub4.frame), CGRectGetWidth(helpView.frame)-20, 40)];
    sub5.numberOfLines = 0;
    sub5.font = sub1.font;
    sub5.lineBreakMode = NSLineBreakByWordWrapping;
    sub5.text = @"5、打开手机WIFI（无线网络）有助于提高定位准确度;";
    [helpView addSubview:sub5];
    
 }
-(void)removeSelf{
    [_grayAplpaView removeFromSuperview];
    _grayAplpaView = nil;
    [[self.view viewWithTag:333]removeFromSuperview];
}
#pragma  mark -- search

-(BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = CGPointMake(self->originCenter.x, self->originCenter.y-38);
        self.imageNav.hidden = YES;
    }];
    searchBar.showsCancelButton = true;
    if (!_grayAplpaView) {
         _grayAplpaView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(searchBar.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(searchBar.frame)+38)];
        _grayAplpaView.backgroundColor = [UIColor lightGrayColor];
        _grayAplpaView.alpha = 0.5;
        [self.view addSubview:_grayAplpaView];
    }
    return  YES;
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    
}
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    [UIView animateWithDuration:0.3 animations:^{
        self.view.center = self->originCenter;
        self.imageNav.hidden = false;
    }];
    searchBar.text = @"";
    searchBar.showsCancelButton  = false;
    [searchBar resignFirstResponder];
    [_grayAplpaView removeFromSuperview];
    _grayAplpaView = nil;
}


-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
     if (searchBar.text.length==0) {
        
        _grayAplpaView.alpha = 0.5;
        UITableView *table = [_grayAplpaView viewWithTag:300];
        if (table) {
            table.hidden = YES;
        }
    }
    else{
        
        _grayAplpaView.alpha = 1;
        UITableView *table = [_grayAplpaView viewWithTag:300];
        
        if (!table) {
            table = [[UITableView alloc]initWithFrame:_grayAplpaView.bounds];
            table.delegate = self;
            table.dataSource = self;
            table.tag = 300;
            table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
            [_grayAplpaView addSubview:table];
        }
        else{
            table.hidden = NO;
        }
        
        [self beginSearch:searchBar.text];
        
    }
    
}



#pragma mark == 百度地图

//百度地图位置更新，把经纬度传到后台
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    [_locService stopUserLocationService];
    _jing = [NSString stringWithFormat:@"%f",userLocation.location.coordinate.longitude];
    _wei =  [NSString stringWithFormat:@"%f",userLocation.location.coordinate.latitude];

}

//高德地图持续定位，取到上传的气泡内容
- (void)amapLocationManager:(AMapLocationManager *)manager didUpdateLocation:(CLLocation *)location
{
    [manager stopUpdatingLocation];
    
 
    _jingLongitude = [NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    _weiLatitude = [NSString stringWithFormat:@"%f",location.coordinate.latitude];
    
    _horizontalAccuracy = location.horizontalAccuracy;
    
    
    curLat = [_weiLatitude copy];
    curLon = [_jingLongitude copy];
    
    CLLocationCoordinate2D coordinate;                  //设定经纬度
    coordinate.latitude =[curLat floatValue];       //纬度
    coordinate.longitude = [curLon floatValue];
 
    //设置中心点
    self->_mapView.centerCoordinate = CLLocationCoordinate2DMake(coordinate.latitude,coordinate.longitude);
    
    [self onReGeocodeSearchWithla:coordinate.latitude lo:coordinate.longitude];
}
-(void)beginSearch:(NSString *)text{
    //    [AMapServices sharedServices].apiKey = @"21af4e9c071b8bdf9d63d5641ce69c3d";
    
    AMapPOIAroundSearchRequest *request = [[AMapPOIAroundSearchRequest alloc]init];
    request.location = [AMapGeoPoint locationWithLatitude:curLat.floatValue longitude:curLon.floatValue];
    request.sortrule = 0;
    request.keywords = text;
    request.requireExtension = YES;
    request.radius = 1000;
    [_search AMapPOIAroundSearch:request];
}
#pragma 周边搜索

-(void)onPOISearchDone:(AMapPOISearchBaseRequest *)request response:(AMapPOISearchResponse *)response{
    if (response.pois.count == 0)
    {
        return;
    }
    searchArray = response.pois;
    //    NSMutableArray *poiAnnotations = [NSMutableArray arrayWithCapacity:response.pois.count];
    [[_grayAplpaView viewWithTag:300] reloadData];
    
    
    
    //    [response.pois enumerateObjectsUsingBlock:^(AMapPOI *obj, NSUInteger idx, BOOL *stop) {
    //
    //        [poiAnnotations addObject:[[POIAnnotation alloc] initWithPOI:obj]];
    //
    //    }];
    //
    //    /* 将结果以annotation的形式加载到地图上. */
    //    [self.mapView addAnnotations:poiAnnotations];
    //
    //    /* 如果只有一个结果，设置其为中心点. */
    //    if (poiAnnotations.count == 1)
    //    {
    //        [self.mapView setCenterCoordinate:[poiAnnotations[0] coordinate]];
    //    }
    //    /* 如果有多个结果, 设置地图使所有的annotation都可见. */
    //    else
    //    {
    //        [self.mapView showAnnotations:poiAnnotations animated:NO];
    //    }
    
}
#pragma mark -- table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (tableView.tag == 300) {
        return searchArray.count;
    }
    return resultArray.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuser = @"reuser";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuser];
    if (!cell) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuser];
        cell.backgroundColor  = [UIColor clearColor];
    }
    AMapPOI * result  = nil;
    if (tableView.tag ==300) {
        result = searchArray[indexPath.row];
    }
    else
        result  = resultArray [indexPath.row];
    
    cell.textLabel.text = result.name;
    cell.accessoryType = UITableViewCellAccessoryNone;
    if (indexPath.row==0&&tableView.tag!=300&&resultArray.count>1) {
        cell.textLabel.text = [@"" stringByAppendingString:result.name];
        if (!cellCur) {
            cellCur = cell;
            indexCur = 0;
        }
    }
    cell.detailTextLabel.text = result.address;
    cell.detailTextLabel.textColor = [UIColor colorWithHexString:@"#666666"];
    return cell;
}
//点击切换
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (tableView.tag == 300) {
        AMapPOI *poi = searchArray[indexPath.row];
        resultArray = [NSArray arrayWithObject:poi];
        
        
        [UIView animateWithDuration:0.3 animations:^{
            self.view.center = self->originCenter;
            self.imageNav.hidden = false;
        }];
        search0.showsCancelButton  = false;
        search0.text = @"";
        [search0 resignFirstResponder];
        
        [_grayAplpaView removeFromSuperview];
        _grayAplpaView = nil;
        [resultsTable reloadData];
        
        indexCur = 0;
        [_mapView removeAnnotation:annotation];
        annotation = nil;
        //重新添加大头针
        [self loadAnonationView];
        return;
    }
    
    
    if (cellCur != cell) {
         cellCur = cell;
         indexCur = indexPath.row;
        [_mapView removeAnnotation:annotation];
        annotation = nil;
        //重新添加大头针
        AMapPOI * result = resultArray[indexCur];
        titleBale.text =[@"当前位置: " stringByAppendingString:result.name ];
        locaitionBale.text = result.address;
        [self loadAnonationView];
    }
    
    
}
#pragma mark - 逆向地理编码
- (void)onReGeocodeSearchWithla:(CGFloat )la lo:(CGFloat )lo{
    //    [AMapServices sharedServices].apiKey = @"21af4e9c071b8bdf9d63d5641ce69c3d";
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
         resultArray = response.regeocode.pois;
        [resultsTable reloadData];
   
        [self loadAnonationView];
        if (resultArray.count==0) {
            return;
        }
        
        AMapPOI * result = resultArray[0];
        titleBale.text =[@"当前位置: " stringByAppendingString:result.name];
        locaitionBale.text = result.address;
    }
    
}


- (void)loadAnonationView{
    if (self->annotation == nil) {
        self->annotation=[[MAPointAnnotation alloc]init];
        //        CLLocationCoordinate2D coordinate;                  //设定经纬度
        //        coordinate.latitude =[self->_weiLatitude floatValue];       //纬度
        //
        //        coordinate.longitude = [self->_jingLongitude floatValue];      //经度
        if (indexCur>=resultArray.count) {
            return;
        }
        AMapPOI *poi = resultArray[indexCur];
        
        //        self->annotation.coordinate = coordinate;
        annotation.coordinate = CLLocationCoordinate2DMake(poi.location.latitude, poi.location.longitude);
        //            UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, 10)];
        //            label.backgroundColor = [UIColor blackColor];
        //            label.text = @"点击上报";
        //            label.textColor = [UIColor redColor];
        //
        //        NSString *paraString=[NSString stringWithFormat:@"%@",label.text];
        //
        //        self->annotation.title= self->mapLabel.text;
        //        self->annotation.subtitle=paraString;
        [self->_mapView addAnnotation:self->annotation];
        [_mapView selectAnnotation:self->annotation animated:YES];
        self->_mapView.centerCoordinate = annotation.coordinate;
    }
    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
    //    /* 自定义userLocation对应的annotationView. */
    //    if ([annotation isKindOfClass:[MAUserLocation class]])
    //    {
    //        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
    //        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
    //        if (annotationView == nil)
    //        {
    //            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
    //                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
    //        }
    //
    //        return annotationView;
    //    }
    //    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    //    {
    //        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
    //        CCCustomAnnotationView *annotationView = (CCCustomAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:
    //                                                                reuseIndetifier];
    //
    //
    //
    //    annotationView.delegate3 = self;
    //
    //        if (annotationView == nil)
    //        {
    //            annotationView = [[CCCustomAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
    //        annotationView.delegate3 = self;
    //        }
    //        // 设置为NO，用以调用自定义的calloutView
    //        annotationView.canShowCallout = NO;
    //
    //        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
    //        annotationView.centerOffset = CGPointMake(0, -18);
    //        return annotationView;
    //    }
    //    return nil;
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= false;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = YES;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
        return annotationView;
    }
    return nil;
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
}@end
