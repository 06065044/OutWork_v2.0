//
//  CCReportViewController.m
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCReportViewController.h"
#import "UIScrollView+MJRefresh.h"
#import "NSObject+CC0utString.h"
#import "WSDatePickerView.h"
@interface CCReportViewController ()
{
    UIActivityIndicatorView *activity;
    UIButton *dateButton;
    NSDateFormatter *_formatter;
    NSInteger pageNumber;
    NSString *dateString;
}
@end

@implementation CCReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lableNav.text=@"上报记录";
    jsonArray=[NSArray array];
    pageNumber=1;

    _formatter = [[NSDateFormatter alloc]init];
    [_formatter setDateFormat:@"YYYY-MM-dd"];
    dateString = [_formatter stringFromDate:[NSDate date]];
    
    
    dateButton = [UIButton buttonWithType:UIButtonTypeCustom];
    dateButton.frame = CGRectMake(0, CGRectGetMaxY(self.lableNav.frame), kFullScreenSizeWidth, 30);
    [dateButton setTitle:dateString forState:UIControlStateNormal];
    [dateButton setBackgroundColor:[self.view backgroundColor]];
    [dateButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [self.view addSubview:dateButton];
    
    UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake( CGRectGetWidth(dateButton.frame)-30,10, 10, 10)];
    igv.image = [UIImage imageNamed:@"arrow"];
    [dateButton addSubview:igv];
    
    
    UIView *_downBackView = [[UIView alloc]initWithFrame:CGRectMake(0, 29, kFullScreenSizeWidth, 1)];
    _downBackView.backgroundColor = [UIColor grayColor];
    [dateButton addSubview:_downBackView];
    [dateButton addTarget:self action:@selector(datePick) forControlEvents:UIControlEventTouchUpInside];
    
    reportView=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.lableNav.frame)+30, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.lableNav.frame)-30) style:UITableViewStylePlain];
    reportView.delegate=self;
    reportView.backgroundColor = [UIColor clearColor];

    reportView.dataSource=self;
    reportView.rowHeight=90;
    reportView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:reportView];
    [reportView addFooterWithTarget:self action:@selector(showMore:)];
    //网络请求
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":@"10",@"memberId":[defaults objectForKey:@"memberId"],@"strDate":dateString};
    [self beginRequestwithDic:dic];
}
-(void)datePick{
//
    WSDatePickerView *datepicker = [[WSDatePickerView alloc] initWithDateStyle:DateStyleShowYearMonthDay CompleteBlock:^(NSDate *startDate) {
        self->dateString = [startDate stringWithFormat:@"yyyy-MM-dd"];
        
        [self->dateButton setTitle:self->dateString forState:UIControlStateNormal];
        NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":@"10",@"memberId":[defaults objectForKey:@"memberId"],@"strDate":self->dateString};
        self->pageNumber = 1;
        self->jsonArray = [NSArray array];
        [self beginRequestwithDic:dic];
        
    }]; 
    datepicker.doneButtonColor = [UIColor orangeColor];//确定按钮的颜色
    datepicker.maxLimitDate = [NSDate date];
    [datepicker show];
}
-(void)showMore:(id)sender{
    activity = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];//指定进度轮的大小
    
    [activity setCenter:CGPointMake(kFullScreenSizeWidth/2-90, kFullScreenSizeHeght-20)];//指定进度轮中心点
    
    [activity setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];//设置进度轮显示类型
    [activity startAnimating];
    
    [self.view addSubview:activity];
    [self.view bringSubviewToFront:activity];

    pageNumber++;
    NSString *size=[NSString stringWithFormat:@"%ld",pageNumber*10];
    NSDictionary *dic=@{@"currentPage": @"1",@"pageSize":size,@"memberId":[defaults objectForKey:@"memberId"],@"strDate":dateString};
    [self beginRequestwithDic:dic];
}

-(void)beginRequestwithDic:(NSDictionary *)dic{
    dispatch_async(dispatch_get_main_queue(), ^{
        [CCUtil showMBLoading:@"正在加载..." detailText:@"请稍候..."];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSString *final=[CCUtil basedString:locationArcord  withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [requset setRequestMethod:@"GET"];
            [requset setTimeOutSeconds:20];
            [requset startSynchronous];
            NSData *Data=[requset responseData];
            dispatch_async(dispatch_get_main_queue(), ^{
                [CCUtil hideMBLoading];
                [self->reportView footerEndRefreshing];
                 if (Data.length==0) {
                    [CCUtil showMBProgressHUDLabel:@"请检查网络" detailLabelText:nil];
                    return;
                }
                if (self->activity) {
                    [self->activity stopAnimating];
                    [self->activity removeFromSuperview];
                }
                
                if (Data!=nil) {
                    self->jsonArray=[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil]objectForKey:@"result"];
                }else{
                    self->reportView.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
                    [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
                    return;
                }
                if ((self->jsonArray.count%10!=0&&self->pageNumber>1)||jsonArray.count==0) {
                    [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"无更多数据"];
                }
                [self->reportView reloadData];
            });
        });
        
    });
    
    
   
}


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return jsonArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"UITableViewCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {  //没有重用
        cell =[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        if ([jsonArray count]!=0) {
            UILabel *CComent=[[UILabel alloc]initWithFrame:CGRectMake(20,5, kFullScreenSizeWidth-40, 40)];
            CComent.text=[jsonArray[indexPath.row] objectForKey:@"currLocation"];
            CComent.tag=110;
            CComent.numberOfLines = 0;
            CComent.font = [UIFont systemFontOfSize:12];
            CComent.textColor=[UIColor blackColor];
            [cell.contentView addSubview:CComent];
            
            UILabel *userCreate=[[UILabel alloc]initWithFrame:CGRectMake(20,50,kFullScreenSizeWidth-100, 25)];
            userCreate.text=[NSString stringWithFormat:@"发送人:%@",[jsonArray[indexPath.row] objectForKey:@"userName"]];
            userCreate.textColor=[UIColor grayColor];
            userCreate.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
            userCreate.tag=111;
            [cell.contentView addSubview:userCreate];
            
            UILabel *lableTime=[[UILabel alloc]initWithFrame:CGRectOffset(userCreate.frame, 0, 18)];
            lableTime.textColor=[UIColor grayColor];
            lableTime.text=[NSString stringWithFormat:@"时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];
            lableTime.tag=112;
            lableTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
            [cell.contentView addSubview:lableTime];
        }
    }
    else  //有值了 就可以重用
    {
        UILabel *lable =(UILabel*)[cell.contentView viewWithTag:110];
        lable.text=[jsonArray[indexPath.row] objectForKey:@"currLocation"];
        UILabel *user =(UILabel*)[cell.contentView viewWithTag:111];
        user.text=[NSString stringWithFormat:@"发送人:%@",[jsonArray[indexPath.row] objectForKey:@"userName"]];
        UILabel *time=(UILabel*)[cell.contentView viewWithTag:112];
        time.text=[NSString stringWithFormat:@"时间:%@",[jsonArray[indexPath.row] objectForKey:@"createTime"]];
    }
    return cell;
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
