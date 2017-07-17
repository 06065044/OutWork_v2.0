//
//  CCPlanViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPlanViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "ASIHTTPRequest+CCGetSessionId.h"
#import "CCPLANDetialViewController.h"
#import "CCAddPlanViewController.h"
//instance all
NSString *urlString=@"http://123.139.56.221:6001/outside/dispatcher/workplan/queryWorkPlan";
static NSString *cellID=@"cellID";
NSArray *resultArr;
UITableView *table;


@interface CCPlanViewController ()<UITableViewDataSource,UITableViewDelegate>

@end

@implementation CCPlanViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lableNav.text=@"计划安排";
    //
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame))];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellID];
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=60;
    [self.view addSubview:table];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    button.frame=CGRectMake(kFullScreenSizeWidth-48, 22, 40, 40);
    [button setTitle:@"添加" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(ADDPLAN:) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    
    
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self beginRequset];

}
-(void)ADDPLAN:(id)sender{
    CCAddPlanViewController *add=[[CCAddPlanViewController alloc]init];
    [self.navigationController pushViewController:add animated:YES];


}
-(void)beginRequset{
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSDictionary *dic=@{@"sessionId":[requset getSessionID]};
    NSString *final=[CCUtil basedString:urlString withDic:dic];
   requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    resultArr=[[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil]objectForKey:@"result"];
    dispatch_async(dispatch_get_main_queue(), ^{
        [table reloadData];
    });
   
    

}
#pragma mark-table delegate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *Cell=[tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    for (UIView *viewA in Cell.contentView.subviews) {
        [viewA removeFromSuperview];
    }
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(10, 5, kFullScreenSizeWidth, 30)];
    labTitle.text=[[resultArr[indexPath.row]objectForKey:@"title"] outString];
    [Cell.contentView addSubview:labTitle];
    
    UILabel *labReply=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame)+5, 100, 20)];
    int a=0;
    if (![[resultArr[indexPath.row] objectForKey:@"planAppCount"]isKindOfClass:[NSNull class]]) {
        a=[[resultArr[indexPath.row] objectForKey:@"planAppCount"]intValue];
    }
    labReply.text=[NSString stringWithFormat:@"批示%d条",a];
    labReply.textColor=[UIColor blueColor];
    [Cell.contentView addSubview:labReply];
    
    
    UILabel *startTime=[[UILabel alloc]initWithFrame:CGRectMake(120, CGRectGetMinY(labReply.frame), kFullScreenSizeWidth-120, 20)];
    startTime.textColor=[UIColor blueColor];
    startTime.text=[[resultArr[indexPath.row]objectForKey:@"planStartTime"]outString];
    [Cell.contentView addSubview:startTime];
    return Cell;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return resultArr.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    CCPLANDetialViewController *detial=[[CCPLANDetialViewController alloc]init];
    detial.INFODIC=resultArr[indexPath.row];
    [self.navigationController pushViewController:detial animated:YES];

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
