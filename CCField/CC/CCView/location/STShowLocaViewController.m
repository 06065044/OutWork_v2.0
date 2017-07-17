//
//  STShowLocaViewController.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/10.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STShowLocaViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import <AMapLocationKit/AMapLocationKit.h>
//#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import <AMapFoundationKit/AMapFoundationKit.h>
#import "ASIHTTPRequest.h"
#import "STRaceModel.h"
#import "CCUtil.h"
#import "STNoLocationView.h"
#import "STPeoInfoViewController.h"
#import "CCCustomAnnotationView.h"
@interface STShowLocaViewController ()<MAMapViewDelegate>
{
    MAMapView *_mapView;
    NSMutableArray *no_location_array;
}


@end

@implementation STShowLocaViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"small"];
    // Do any additional setup after loading the view.
    self.lableNav.text = @"位置查看";
    /***************************************添加地图*******************************************/
    _mapView = [[MAMapView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_lableNav.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds))];
    _mapView.delegate = self;
    _mapView.showsUserLocation = NO;    //YES 为打开定位，NO为关闭定位
    //  _mapView.userLocationVisible = NO;
//    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES]; //地图跟着位置移动
    
    //显示比例
    [_mapView setZoomLevel:11 animated:YES];
    
    
    //显示普通地图
    _mapView.mapType = MAMapTypeStandard;
    [self.view addSubview:_mapView];
    
    
    no_location_array = [NSMutableArray arrayWithCapacity:10];
    NSMutableString *stringIdArray = [NSMutableString stringWithCapacity:10];
    for (STRaceModel *model in self.peopleSelect) {
        [stringIdArray appendString:[model.ids stringByAppendingString:@","]];
    }
    stringIdArray = [[stringIdArray substringToIndex:stringIdArray.length-1]copy];
    /***************************************请求数据***************************************/
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *stringUrl = [CCUtil basedString:getSubPeopleLocation withDic:@{@"memberIds":stringIdArray}];
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:stringUrl]];
        [request setRequestMethod:@"GET"];
        [request setTimeOutSeconds:20];
        [request startSynchronous];
        NSData *data = [request responseData];
        NSArray *locationArray = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
        NSMutableArray * array_temp  = [locationArray mutableCopy];
        for (int i =0; i<locationArray.count; i++) {
            NSDictionary *dic = locationArray[i];
            if (![dic[@"userLng"] respondsToSelector:@selector(floatValue)]) {
                [self->no_location_array addObject:dic[@"name"]];
                [array_temp removeObject:dic];
            }
        }
        locationArray = [array_temp copy];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self->no_location_array.count>0) {
                UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                UIVisualEffectView *effectView = [[UIVisualEffectView alloc]initWithEffect:effect];
                effectView.frame = CGRectMake(0, 64, kFullScreenSizeWidth, kFullScreenSizeHeght-64);
                effectView.tag = 337;
                [self.view addSubview:effectView];
                
                STNoLocationView *no_location_view = [[STNoLocationView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-140, 200, 280, 200) peopleArray:self->no_location_array];
                no_location_view.vc = self;
                [self.view addSubview:no_location_view];
                no_location_view.showmore = ^(){
                    STPeoInfoViewController *peoInfo = [[STPeoInfoViewController alloc]init];
                    peoInfo.no_location_array = self->no_location_array;
                    [self.navigationController pushViewController:peoInfo animated:YES];
                };
            }
            
            //     NSArray *locationArray = @[@{@"lat":@"40.049665",@"lng":@"116.297228",@"name":@"贾玲"},@{@"name":@"鲁智深",@"lat":@"40.052924",@"lng":@"116.29209"}];
            [locationArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                /***************************************大头针*******************************************/
                
                
                CLLocationCoordinate2D pointCenter =CLLocationCoordinate2DMake([obj[@"userLat"] floatValue], [obj[@"userLng"] floatValue]);
               pointCenter = AMapCoordinateConvert(pointCenter, AMapCoordinateTypeBaidu);

                
                MAPointAnnotation* annotation=[[MAPointAnnotation alloc]init];
                 //经度
                
                annotation.coordinate = pointCenter;
                
                
                annotation.title = obj[@"name"];
                annotation.subtitle = obj[@"currLocation"];
                //        self->annotation.subtitle=paraString;
                if (idx == 0) {
                    [self->_mapView setCenterCoordinate:pointCenter];

                }
                [self->_mapView addAnnotation:annotation];
                [self->_mapView selectAnnotation:annotation animated:NO];
                
                
                
            }];
        });
        
    });
}
//-(void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view{
//    
////    CCCustomAnnotationView *annotationView = (CCCustomAnnotationView *) view;
////    [annotationView transformUI];
//    
//    
//}
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id<MAAnnotation>)annotation
{
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
        // 设置为NO，用以调用自定义的calloutView
        annotationView.canShowCallout = NO;
          annotationView.delegate3 = self;
        // 设置中心点偏移，使得标注底部中间点成为经纬度对应点
//        annotationView.centerOffset = CGPointMake(0, -20);
        return annotationView;
    }
    return nil;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults]setBool:false forKey:@"small"];
}
/**
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
