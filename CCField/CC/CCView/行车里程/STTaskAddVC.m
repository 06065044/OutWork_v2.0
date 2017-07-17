//
//  STTaskAddVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STTaskAddVC.h"
#import <BaiduMapAPI_Location/BMKLocationService.h>
#import <BaiduMapAPI_Search/BMKGeocodeSearch.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "STTaskChooseViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import <BaiduMapAPI_Search/BMKRouteSearch.h>
#import "CCNavigationController.h"
#import "STTabbarVC.h"

@interface STTaskAddVC()<UITableViewDelegate,UITableViewDataSource,BMKLocationServiceDelegate,BMKGeoCodeSearchDelegate,UITextFieldDelegate,BMKRouteSearchDelegate>
{
    UITextField *tfTaskName;
    NSArray *left_title;
    NSArray *right_value;
    NSArray *_placeHolderArray;
    UIButton *_recordBtn;
    UITableView *_table;
    NSString *_placeLocation;
    BMKLocationService *_bmkLocationService;
    CLLocationCoordinate2D startPoint;
    CLLocationCoordinate2D endPoint;
    
    BMKRouteSearch *rouch;
    
    UITextField *startCell;
    UITextField *endCell;
    UITextField *nameTf;
    UITextField *desTf;
    UITextField *KmTf;
    UITextField *feeTf;
    UITextField *remarkTf;
    
    NSString *memberId;
    NSString *carDisId;
    BOOL finish;
    NSMutableDictionary *CacheDic;
    NSString *endString;
    
    CGPoint originPoint;//最初的中心
    NSArray *keyArrays;
}
@end
const NSInteger tableHeight = 55;

@implementation STTaskAddVC
-(void)viewDidLoad{
    [super viewDidLoad];
    [self beginTimer];
    self.lableNav.text = @"添加里程";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"cacheDic"];
    CacheDic = [NSKeyedUnarchiver unarchiveObjectWithFile:docDir];
//    if (self.carModel) {
//        CacheDic=[self.carModel mutableCopy];
//    }
    _placeHolderArray = @[@"请输入里程名称",@"请输入里程描述",@"",@"",@"",@"",@"非必填项"];
    memberId = [[NSUserDefaults standardUserDefaults]objectForKey:@"memberId"];
    if (!memberId) {
        NSString *final=[CCUtil basedString:accountUrl withDic:nil];
        ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [requset setTimeOutSeconds:20];
        [ requset setUseCookiePersistence : YES ];
        [requset setRequestMethod:@"GET"];
        [requset startSynchronous];
        NSData *Data = [requset responseData];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
        memberId = dic[@"memberId"];
    }
    //启动百度定位
    _bmkLocationService  = [[BMKLocationService alloc]init];
    _bmkLocationService.delegate = self;
    _bmkLocationService.pausesLocationUpdatesAutomatically = false;
    _bmkLocationService.allowsBackgroundLocationUpdates = true;
    _bmkLocationService.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    [_bmkLocationService startUserLocationService];
    //数据初始化
    
    
    left_title = @[@"里程名称:",@"里程描述:",@"出发地:",@"目的地:",@"里程(公里):",@"费用(元)",@"备注"];
    keyArrays  = @[@"name",@"description",@"startPlace",@"endPlace",@"distance",@"fee",@"remark"];
    _table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+5, kFullScreenSizeWidth, kFullScreenSizeHeght)];
    _table.delegate = self;
    _table.dataSource = self;
    _table.backgroundColor = [UIColor clearColor];
     [self.view addSubview:_table];

    _table.rowHeight = tableHeight;
    [_table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuserCell"];
    if ([_table respondsToSelector:@selector(setSeparatorInset:)]) {
        [_table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([_table respondsToSelector:@selector(setLayoutMargins:)]) {
        [_table setLayoutMargins:UIEdgeInsetsZero];
    }
    originPoint = _table.center;
    
    
    _table.tableFooterView=({
    
        UIView *footerView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 50)];
    //按钮  CGRectGetMaxY(_table.frame)+2
    _recordBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _recordBtn.frame = CGRectMake(15, 10, kFullScreenSizeWidth-30, 40);
    [_recordBtn setTitle:@"里程记录开始" forState:UIControlStateNormal];
    if ([CacheDic isKindOfClass:[NSDictionary class]]&&[[CacheDic allKeys]count]>0) {
        if ([CacheDic[@"clicked"] isEqualToString:@"1"]) {
            [_recordBtn setTitle:@"里程记录结束" forState:UIControlStateNormal];
            carDisId = CacheDic[@"carDisid"];
        }
        if ([CacheDic[@"clicked"] isEqualToString:@"2"]) {
            [_recordBtn setTitle:@"提交" forState:UIControlStateNormal];
            carDisId = CacheDic[@"carDisid"];
        }
        if ([CacheDic objectForKey:@"startPoint"]) {
            startPoint = [(CLLocation *)[CacheDic objectForKey:@"startPoint"] coordinate];
        }
     }
//        if (self.carModel) {
//            [_recordBtn setTitle:@"里程记录结束" forState:UIControlStateNormal];
//            carDisId = CacheDic[@"carDisid"];
//            if (![[CacheDic[@"endPlace"]outString]isEqualToString:@""]) {
//                [_recordBtn setTitle:@"提交" forState:UIControlStateNormal];
//             }
//        }
    [footerView addSubview:_recordBtn];
    [_recordBtn setBackgroundColor:self.imageNav.backgroundColor];
    [_recordBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _recordBtn.layer.cornerRadius = 5.0f;
    [_recordBtn addTarget:self action:@selector(changeTitle) forControlEvents:UIControlEventTouchUpInside];
    
        footerView;
    });
}
STMainVC *main1;
-(void)beginTimer{
    CCNavigationController *main = (CCNavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    STTabbarVC  *tab1 = (STTabbarVC*)main.viewControllers[0];
    main1 =(STMainVC *)([(UINavigationController *) tab1.viewControllers[1] viewControllers][0]);

    self.recordTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(record) userInfo:nil repeats:YES];
}
-(void)record{
        LocationTracker *track = main1.locationTracker;
        [track recordCoordinate];
}
#pragma mark --bmkdelegate
-(void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation{
    [_bmkLocationService stopUserLocationService];
    if (!_placeLocation) {
        if (startPoint.latitude==0) {
            startPoint = userLocation.location.coordinate;
        }
    }
    else {
        endPoint = userLocation.location.coordinate;
    }
    BMKGeoCodeSearch *search = [[BMKGeoCodeSearch alloc]init];
    search.delegate = self;
    BMKReverseGeoCodeOption * reverseGeo = [[BMKReverseGeoCodeOption alloc]init];
    [reverseGeo setReverseGeoPoint:userLocation.location.coordinate];
    [search reverseGeoCode:reverseGeo];
}
-(void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error != 0) {
        return;
    }
    
    if ([[_recordBtn titleForState:UIControlStateNormal]isEqualToString:@"里程记录开始"]) {
        //        startPoint = BMKMapPointForCoordinate(userLocation.location.coordinate);
        if (startCell.text.length==0) {
            startCell.text = result.address;
        }
        
    }
    else  {
        if (!_placeLocation) {
            //刚进来
            _placeLocation = result.address;
            return;
        }
        if (endCell.text.length==0) {
            endCell.text = result.address;
            [self confirmDistance];
        }
    }
    _placeLocation = result.address;
}
#pragma mark - button event
-(void)changeTitle{
    if ([[_recordBtn titleForState:UIControlStateNormal]isEqualToString:@"里程记录开始"]) {
        
        [self beginTrack];
    }
    else if([[_recordBtn titleForState:UIControlStateNormal]isEqualToString:@"里程记录结束"]){
        //  里程记录结束 //定位
        
        [_bmkLocationService startUserLocationService];
        [_recordBtn setTitle:@"提交" forState:UIControlStateNormal];
    }
    else{
        //提交
        [_recordBtn setBackgroundColor:[UIColor lightGrayColor]];
        [_recordBtn setUserInteractionEnabled:FALSE];
        [self confim];
    }
}

-(NSMutableArray *)recordPointArray{

    NSArray *arrPoint = [[[NSUserDefaults standardUserDefaults]objectForKey:@"pointArr"]copy];//获取行车轨迹的数组
    if (arrPoint.count==0) {
        arrPoint = @[];
    }
    NSDictionary *dic0 = @{
                           @"userLng": @(startPoint.longitude),
                           @"userLat": @(startPoint.latitude),
                           @"createTime":@"2016-11-14 12:21:33"
                           };
    
    NSDictionary *dicLast = @{
                              @"userLng": @(endPoint.longitude),
                              @"userLat": @(endPoint.latitude),
                              @"createTime":@"2016-11-14 12:21:33"
                              };
    NSMutableArray *arr = [arrPoint mutableCopy];
    [arr insertObject:dic0 atIndex:0];
    [arr addObject:dicLast];
  
    NSMutableArray *arrcopy = [[arr copy]mutableCopy];
    //删除坏点
    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSDictionary *dicCur = arr[idx];
        //开始的
        CLLocationCoordinate2D point =CLLocationCoordinate2DMake([dicCur[@"userLat"] floatValue], [dicCur[@"userLng"] floatValue]);
        if (![CCUtil whetherUsefulCoordinate:point]) {
            [arrcopy removeObjectAtIndex:idx];
        }
    }];
    arr = [arrcopy mutableCopy];
    return  arr;
   }
-(void)confirmDistance{
    
    NSMutableArray *arr = [self recordPointArray];
      CGFloat distance = 0;
    if (arr.count>1) {
        
        //进行遍历计算
        for (int i=1; i<arr.count; ++i) {
            NSDictionary *dicCur = arr[i];
            //开始的
            
            BMKMapPoint  pointCur = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([dicCur[@"userLat"] floatValue], [dicCur[@"userLng"] floatValue]));
            
            //之前的
            NSDictionary *dicPre = arr[i-1];
            BMKMapPoint  pointPre = BMKMapPointForCoordinate(CLLocationCoordinate2DMake([dicPre[@"userLat"] floatValue], [dicPre[@"userLng"] floatValue]));
            //计算距离
            CLLocationDistance distanceCur = BMKMetersBetweenMapPoints(pointCur,pointPre);
            distance += distanceCur;
        }
        KmTf.text = [NSString stringWithFormat:@"%.2f",distance/1000.];
     }
    else{
          KmTf.text = [NSString stringWithFormat:@"0"];
    }
  
    
    //进行确认
    
    [UIView animateWithDuration:0.25 animations:^{
        [self.view sendSubviewToBack:self->_table];
        self->_table.center = CGPointMake(self->originPoint.x, self->originPoint.y-120);
    }];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:nil message:@"请确定是否已到达目的地" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [UIView animateWithDuration:0.25 animations:^{
            self->_table.center = self->originPoint;
        }];
        //        [self endTrack];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [UIView animateWithDuration:0.25 animations:^{
            self->_table.center = self->originPoint;
        }];
        [self->_recordBtn setBackgroundColor:self.imageNav.backgroundColor];
        [self->_recordBtn setUserInteractionEnabled:true];
        [self->_recordBtn setTitle:@"里程记录结束" forState:UIControlStateNormal];
        self->endCell.text = @"";
        self->KmTf.text = @"";
        self->endString = self->endCell.text;
    }];
    [controller addAction:sure];
    [controller addAction:cancel];
    [self presentViewController:controller animated:YES completion:nil];
    
    
    
    return;
    
    rouch  =[[BMKRouteSearch alloc]init];
    rouch.delegate = self;
    //发起检索
    BMKPlanNode *start = [[BMKPlanNode alloc]init];
    start.pt = startPoint;
    BMKPlanNode *end = [[BMKPlanNode alloc]init];
    end.pt = endPoint;
    
    BMKDrivingRoutePlanOption *transi = [[BMKDrivingRoutePlanOption alloc]init];
    transi.from = start;
    transi.to = end;
    BOOL flag = [rouch drivingSearch:transi];
    if (!flag) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"检索发送失败"];
    }
}
-(void)onGetDrivingRouteResult:(BMKRouteSearch *)searcher result:(BMKDrivingRouteResult *)result errorCode:(BMKSearchErrorCode)error{
    if (error== BMK_SEARCH_NO_ERROR) {
        BMKTaxiInfo * info = result.taxiInfo;
        int km = info.distance;
        KmTf.text = [NSString stringWithFormat:@"%.2f",km/1000.0];
    }
    else{
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:[NSString stringWithFormat:@"%d",error]];
    }
}
#pragma mark == tableView
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 7;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"reuserCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
    //左边
    UILabel *left_Title = nil;
    left_Title = [cell.contentView viewWithTag:300];
    if (!left_Title) {
        left_Title = [[UILabel alloc]initWithFrame:CGRectMake(20, 5, 100, 30)];
        left_Title.font = [UIFont boldSystemFontOfSize:14];
        [cell.contentView addSubview:left_Title];
        left_Title.tag = 300;
    }
    left_Title.text = left_title[indexPath.row];
    [left_Title sizeToFit];
    
    //右边
    UITextField *value_for = nil;
    value_for = [cell.contentView viewWithTag:400];
    if (!value_for) {
        
        value_for = [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMinX(left_Title.frame), CGRectGetMaxY(left_Title.frame), kFullScreenSizeWidth-50, 30)];
        value_for.placeholder = _placeHolderArray[indexPath.row];
        [cell.contentView addSubview:value_for];
        value_for.tag =400;
        value_for.font = [UIFont systemFontOfSize:14];
        value_for.delegate = self;
    }
    if ([[CacheDic allKeys]count]>0) {
//        if (!self.carModel) {
//            value_for.text = CacheDic[@(indexPath.row)];
//         }
//        else
                    value_for.text = CacheDic[@(indexPath.row)];
    }
    
    if (indexPath.row==0) {
        nameTf = value_for;
    }
    if (indexPath.row==1) {
        desTf =value_for;
    }
    if (indexPath.row==2) {
        startCell = value_for;
        startCell.userInteractionEnabled  = NO;
    }
    if (indexPath.row==3) {
        endCell = value_for;
        endString = endCell.text;
        endCell.userInteractionEnabled = false;
    }
    if (indexPath.row==4) {
        KmTf = value_for;
        KmTf.userInteractionEnabled = false;
    }
    if (indexPath.row==5) {
        feeTf = value_for;
        value_for.keyboardType = UIKeyboardTypeDecimalPad;
    }
    if (indexPath.row==6) {
        remarkTf = value_for;
    }
    return cell;
}
-(void)beginTrack{
    [self.view endEditing:YES];
    if (nameTf.text.length == 0||![nameTf.text respondsToSelector:@selector(substringFromIndex:)]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请输入里程名称"];
        [_recordBtn setTitle:@"里程记录开始" forState:UIControlStateNormal];
        return;
    }
    if (desTf.text.length == 0||![desTf.text respondsToSelector:@selector(substringFromIndex:)]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请输入里程描述"];
        [_recordBtn setTitle:@"里程记录开始" forState:UIControlStateNormal];
        return;
    }
    if (_placeLocation.length == 0||![_placeLocation respondsToSelector:@selector(substringFromIndex:)]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"未获取到定位信息"];
        [_recordBtn setTitle:@"里程记录开始" forState:UIControlStateNormal];
        return;
    }
    if (memberId.length == 0||![memberId respondsToSelector:@selector(substringFromIndex:)]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"网络延迟,请再试一次"];
        return;
    }
    
    
    NSDictionary *dic = @{@"memberId":memberId,@"name":nameTf.text,@"description":desTf.text,@"startPlace":_placeLocation};
    NSString *final = [[CCUtil basedString:startCarDistTrack withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    ASIHTTPRequest *requekt = [ASIHTTPRequest requestWithURL:[NSURL URLWithString: final]];
    [requekt setTimeOutSeconds:20];
    [requekt setRequestMethod:@"GET"];
    [requekt startSynchronous];
    NSString *ResponStr= requekt.responseString;
    if ([ResponStr rangeOfString:@"true"].location!=NSNotFound) {
        [[NSUserDefaults standardUserDefaults]setBool:YES forKey:@"beginTrack"];
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:requekt.responseData options:NSJSONReadingMutableLeaves error:nil];
        self->carDisId =dic[@"data"];
         [_recordBtn setTitle:@"里程记录结束" forState:UIControlStateNormal];
        
    }
    else{
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请求失败"];
    }
    
}
-(void)confim{
    endString = endCell.text;
    if (endString.length == 0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请选择目的地"];
        [_recordBtn setBackgroundColor:self.imageNav.backgroundColor];
        [_recordBtn setUserInteractionEnabled:true];
        
        return;
    }
    
    if (feeTf.text.length ==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请输入费用"];
        [_recordBtn setBackgroundColor:self.imageNav.backgroundColor];
        [_recordBtn setUserInteractionEnabled:true];
        return;
    }
    if (carDisId.length==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请稍等"];
        [_recordBtn setBackgroundColor:self.imageNav.backgroundColor];
        [_recordBtn setUserInteractionEnabled:true];
        return;
    }
    [self endTrack];
    
}
-(void)endTrack{
    
    NSMutableArray *arrPoint = [self recordPointArray];
    [[NSUserDefaults standardUserDefaults]setBool:NO forKey:@"beginTrack"];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSMutableDictionary *mutableDic = [NSMutableDictionary dictionary];
        [mutableDic setObject:self->carDisId forKey:@"carDistanceId"];
        [mutableDic setObject:self->endString forKey:@"endPlace"];
        [mutableDic setObject:self->feeTf.text forKey:@"fee"];
        if (self->remarkTf.text.length >0) {
            [mutableDic setObject:self->remarkTf.text forKey:@"remark"];
        }
        [mutableDic setObject:self->KmTf.text forKey:@"distance"];
        [mutableDic setObject:arrPoint forKey:@"carDistancePoints"];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:mutableDic options:NSJSONWritingPrettyPrinted error: nil];
        NSMutableData *tempJsonData = [NSMutableData dataWithData:jsonData];
        
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:endCarDisTrack]];
        [request setTimeOutSeconds:20];
        [request setRequestMethod:@"POST"];
        [request addRequestHeader:@"Content-Type" value:@"application/json; charset=utf-8"];
        [request setPostBody:tempJsonData];
        [request startSynchronous];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            NSString *ResponStr= request.responseString;
            if ([ResponStr rangeOfString:@"true"].location!=NSNotFound) {
                [[NSUserDefaults standardUserDefaults]setObject:[NSMutableArray array] forKey:@"pointArr"];
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"cacheDic"];
                [NSKeyedArchiver archiveRootObject:@{} toFile:docDir];
                
                self->finish = YES;
                [self.navigationController popViewControllerAnimated:YES];
            }
            else{
                [CCUtil showMBProgressHUDLabel:nil detailLabelText:ResponStr];
                [self->_recordBtn setBackgroundColor:self->_imageNav.backgroundColor];
                [self->_recordBtn setUserInteractionEnabled:true];
            }
            
        });
        
    });
}
-(void)viewWillDisappear:(BOOL)animated{
    _bmkLocationService.delegate = nil;
    rouch.delegate =nil;
    [self.recordTimer invalidate];
    self.recordTimer = nil;
}
-(void)returnBack{
    //
    _bmkLocationService.delegate = nil;
    
    if (!finish) {
        //如果没有结束成功，那么要存起来
        CacheDic = [NSMutableDictionary dictionary];
        for (int i=0; i<7; ++i) {
            UITableViewCell *cell  =[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            UITextField *tf = [cell.contentView viewWithTag:400];
            if (tf.text.length == 0 ) {
                continue;
            }
            [CacheDic setObject:tf.text forKey:@(i)];
        }
        if (startPoint.latitude!=0) {
            //存在起始点
            CLLocation *loca = [[CLLocation alloc]initWithLatitude:startPoint.latitude longitude:startPoint.longitude];
            [CacheDic setObject:loca forKey:@"startPoint"];
        }
        
        if (carDisId) {
            [CacheDic setObject:@"1" forKey:@"clicked"];
            [CacheDic setObject:carDisId forKey:@"carDisid"];
            if (endCell.text.length>0) {
                //已经有结束的
                [CacheDic setObject:@"2" forKey:@"clicked"];
            }
        }
        else{
            [CacheDic setObject:@"0" forKey:@"clicked"];
            
        }
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:@"cacheDic"];
        [NSKeyedArchiver archiveRootObject:CacheDic toFile:docDir];
    }
    if (self._refreshBlock) {
        self._refreshBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark == textfiled
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    if (textField == endCell) {
//        //获取任务
//        STTaskChooseViewController *choseVC = [[STTaskChooseViewController alloc]init];
//        choseVC.coor = startPoint;
//        [choseVC setBlock:^(NSArray * result) {
//           [self->feeTf becomeFirstResponder];
//             [self.view endEditing:YES];
//            if (result.count<2) {
//                return ;
//            }
//            self->endCell.text = result[0];
//            self->endString = result[0];
//            self->endPoint = CLLocationCoordinate2DMake([result[1] doubleValue], [result[2] doubleValue]);
//            [self cacluteDis];
//        }];
//        [self.navigationController pushViewController:choseVC animated:YES];
//
//     }
//
// }

//-(void)cacluteDis{
//
//    BMKMapPoint point1 = BMKMapPointForCoordinate(startPoint);
//    BMKMapPoint point2 = BMKMapPointForCoordinate(endPoint);
//    CLLocationDistance distance = BMKMetersBetweenMapPoints(point1,point2);
//    UITableViewCell *Cell  =[_table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
//    UITextField *tf = [Cell.contentView viewWithTag:400];
//    tf.text = [NSString stringWithFormat:@"%.2f",distance/1000];
//}


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
