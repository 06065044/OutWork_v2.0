//
//  STCarDistanceVC.m
//  CCField
//
//  Created by 马伟恒 on 16/6/27.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STCarDistanceVC.h"
#import "STCarCell.h"
#import "STTaskDetailVC.h"
#import "STTaskAddVC.h"
#import "CCUtil.h"
#import "ASIHTTPRequest.h"
#import "STTeamCarVC.h"
#import "UIScrollView+MJRefresh.h"
@interface STCarDistanceVC()<UITableViewDelegate,UITableViewDataSource>
{
    UITableView             *_CarTable;
    NSMutableArray          *_taskArray;
    NSInteger               currentPage;
}
@end
@implementation STCarDistanceVC
/**
 * 加载view
 */
-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"行车里程";
    _taskArray = [NSMutableArray arrayWithCapacity:10];
    _CarTable = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-64) style:UITableViewStylePlain];
    _CarTable.delegate = self;
    _CarTable.dataSource = self;
    _CarTable.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    _CarTable.rowHeight = 80;
    _CarTable.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_CarTable registerClass:[STCarCell class] forCellReuseIdentifier:@"STCarCell0"];
    [self.view addSubview:_CarTable];
    [_CarTable addHeaderWithTarget:self action:@selector(rehreshHeader)];
    _CarTable.backgroundColor = [UIColor clearColor];
    [_CarTable addFooterWithTarget:self action:@selector(addMore)];
    UIButton *addBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    addBtn.frame =CGRectMake(kFullScreenSizeWidth-60, 30, 40, 30);
    [addBtn setTitle:@"更多" forState:UIControlStateNormal];
    [addBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [addBtn addTarget:self action:@selector(addTask) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:addBtn];
    [_taskArray removeAllObjects];
    NSDictionary *dic = @{@"currentPage":@(currentPage),@"pageSize":@(10),@"queryType":@"MY"};
    [self beginUrlWithDic:dic];


  }
-(void)rehreshHeader{
    currentPage = 1;
    [_taskArray removeAllObjects];
    NSDictionary *dic = @{@"currentPage":@(currentPage),@"pageSize":@(10),@"queryType":@"MY"};
    [self beginUrlWithDic:dic];
    
}
-(void)addMore{
    currentPage ++;
    NSDictionary *dic = @{@"currentPage":@(currentPage),@"pageSize":@(10),@"queryType":@"MY"};
    [self beginUrlWithDic:dic];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"my_mileage"];
    currentPage = 1;
}
//请求数据
-(void)beginUrlWithDic:(NSDictionary *)dic{

        [CCUtil showMBLoading:@"正在加载..." detailText:@"请稍候..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            
            NSString *final=[CCUtil basedString:getCarDisList withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset setUseCookiePersistence : YES ];
            [requset setShouldAttemptPersistentConnection:NO];
            [requset startSynchronous];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSData *Data=[requset responseData];
                     [CCUtil hideMBLoading];
                [self->_CarTable headerEndRefreshing];
                [self->_CarTable footerEndRefreshing];
                if ([Data length]==0) {
                    self->_CarTable.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                    
                    [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
                    return;
                }
                 NSArray *arr =[[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"result"]mutableCopy];
                if (self->currentPage==1) {
                    self->_taskArray = [arr mutableCopy];
                }
                else{
                    [self->_taskArray addObjectsFromArray:arr];
                }
                if (self->_taskArray.count%10!=0&&self->currentPage>1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                }
                if (self->_taskArray.count==0&&self->currentPage==1) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"暂无数据"];
                }
                [self->_CarTable reloadData];
                
            });
        });
        
  
    

    
    
//    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"begin"];
//    NSString *stringURL = [[CCUtil basedString:getCarDisList withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    __weak   ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:stringURL]];
//    [request setRequestMethod:@"GET"];
//    [request setTimeOutSeconds:20];
//    [request startSynchronous];
//         [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"ok"];
//        [self->_CarTable headerEndRefreshing];
//        [self->_CarTable footerEndRefreshing];
//       NSArray *Arr= [NSJSONSerialization JSONObjectWithData:request.responseData options:NSJSONReadingMutableLeaves error:nil][@"result"];
//        self->_taskArray = [Arr copy];
//        [ self->_CarTable reloadData];
//    }];
//    [request setFailedBlock:^{
//        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"fial"];
//        [self->_CarTable headerEndRefreshing];
//        [self->_CarTable footerEndRefreshing];
//    }];

}
#pragma mark -- 添加任务
-(void)addTask{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //action我的
    UIAlertAction *carMine = [UIAlertAction actionWithTitle:@"添加里程" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STTaskAddVC *taskAdd = [[STTaskAddVC alloc]init];
        taskAdd._refreshBlock=^(){
            self->currentPage = 1;
            [self->_taskArray removeAllObjects];
             NSDictionary *dic = @{@"currentPage":@(self->currentPage),@"pageSize":@(10),@"queryType":@"MY"};
            [self beginUrlWithDic:dic];
        };
        [self.navigationController pushViewController:taskAdd animated:YES];

    }];
    UIAlertAction *actionTeam = [UIAlertAction actionWithTitle:@"团队里程" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        STTeamCarVC *Car = [[STTeamCarVC alloc]init];
        Car.urlType = Type_Url_Car;
        [self.navigationController pushViewController:Car animated:YES];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:carMine];
    [alertVC addAction:actionTeam];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
    
}
#pragma mark == table delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _taskArray.count;
}
-(  UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    STCarCell *Cell = [tableView dequeueReusableCellWithIdentifier:@"STCarCell0" forIndexPath:indexPath];
//    [Cell addSub];
//    NSDictionary *carModel = _taskArray[indexPath.row];
//    [Cell setData:carModel];
//    return Cell;
    
    static NSString *cellID=@"cellID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:cellID];
    if (!cell) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
  
    for (UIView *viewSub in cell.contentView.subviews) {
        [viewSub removeFromSuperview];
    }
    if (_taskArray.count==0) {
        return cell;
    }
    /**修改外勤工作样式，改为三行显示*/
    UIView *upGray = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 5)];
    upGray.backgroundColor =self.view.backgroundColor;
    [cell.contentView addSubview:upGray];
    // big title
    NSDictionary *dic =_taskArray[indexPath.row];
    UILabel *Big=[[UILabel alloc]initWithFrame:CGRectMake(20,5,kFullScreenSizeWidth-20, 30)];
    //    Big.text=[[responArr[indexPath.row] objectForKey:@"workTitle"] isKindOfClass:[NSNull class]]?@"":[responArr[indexPath.row] objectForKey:@"workTitle"] ;
   NSString *Text=[[dic objectForKey:@"name"]outString];
    Big.text = [@"里程名称:" stringByAppendingString:Text];
     Big.font = [UIFont systemFontOfSize:14];
    [cell.contentView addSubview:Big];
    
    //rightlocation
    UILabel *labelRig=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(Big.frame), CGRectGetMaxY(Big.frame)+2, kFullScreenSizeWidth-170, 20)];
    NSString *str1=[dic objectForKey:@"fee"];
    labelRig.text = [@"里程费用:" stringByAppendingString:str1];
    
    //    labelRig.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    labelRig.font = [UIFont systemFontOfSize:12];
    labelRig.textColor=[UIColor grayColor];
    [cell.contentView addSubview:labelRig];
    
    // small
    UILabel *labLeft=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labelRig.frame), CGRectGetMaxY(labelRig.frame), 200, 20)];
    NSString *str2=[dic objectForKey:@"createDate"];
    labLeft.text = [@"提交时间:" stringByAppendingString:str2];
    labLeft.textColor=[UIColor grayColor];
    //  labLeft.font=[UIFont fontWithName:@"Helvetica-Bold" size:14];
    labLeft.font = [UIFont systemFontOfSize:12];
    [cell.contentView addSubview:labLeft];
    
    return cell;

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *Dic = _taskArray[indexPath.row];
    if ([[Dic[@"endPlace"]outString]isEqualToString:@""]) {
        //不存在
        STTaskAddVC *taskDetail = [[STTaskAddVC alloc]init];
         [self.navigationController pushViewController:taskDetail animated:YES];

    }
    else{
    STTaskDetailVC *taskDetail = [[STTaskDetailVC alloc]init];
    taskDetail.carModel = _taskArray[indexPath.row];
    [self.navigationController pushViewController:taskDetail animated:YES];
    }
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
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
 }
@end
