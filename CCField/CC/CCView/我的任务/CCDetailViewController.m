//
//  CCDetailViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-13.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCDetailViewController.h"
#import "CCHBRWVC.h"
#import "UILabel+CCAlignTop.h"
#import "CCUtil.h"
#import "ASIHTTPRequest.h"
#import "CCReadViewController.h"

static NSString *cellIDENTI=@"cellid";
@interface CCDetailViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray *titleArr;
    NSArray *contentArr;
    UITableView *table;
    int height;
}
@end

@implementation CCDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.lableNav.text=@"任务详情";
    height=60;
    titleArr=[NSArray arrayWithObjects:@"任务名称:",@"任务内容:",@"发布时间:",@"规定完成时间:",@"发布人姓名:",@"执行人姓名:",@"是否需要照片:",@"附件:", nil];
    contentArr=[NSArray arrayWithObjects:@"title",@"content",@"pubTaskTime",@"setTime",@"pubUser",@"excUser",@"isHave",@"notesFile", nil];
  
    
    NSDictionary *dic  =@{@"type":@"task",@"id":_INFODIC[@"id"]};
    NSString *str = [CCUtil basedString:upNoticeState withDic:dic];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:str]];
    [request setTimeOutSeconds:20];
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    NSString *Text=@"汇报";
    NSString *taskStatus = [self.INFODIC objectForKey:@"status"];
    if ([taskStatus isEqualToString:@"4"]||[taskStatus isEqualToString:@"3"]) {
        Text=@"明细";
    }
    
    [button setTitle:Text forState:UIControlStateNormal];
    [button addTarget:self action:@selector(report) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.backgroundColor = [UIColor clearColor];

    table.delegate=self;
    table.scrollEnabled = NO;
    table.dataSource=self;
    if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
        [table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
        [table setLayoutMargins:UIEdgeInsetsZero];
    }

    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];
    //TODO: 判断是否有附件
    if ([[self.INFODIC objectForKey:@"notesFile"]isKindOfClass:[NSNull class]]) {
        NSMutableArray *mutable  = [titleArr mutableCopy];
        [mutable removeLastObject];
        titleArr = [mutable copy];
        [table deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:7 inSection:0]] withRowAnimation:UITableViewRowAnimationLeft];
        
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //CGContextRef context=cgcontextgetcu;
}
#pragma mark===table data
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==1||indexPath.row==5) {
        NSString *textStr=[self.INFODIC objectForKey:contentArr[indexPath.row]];
        
        
        CGRect recta=[textStr boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-100, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}  context:nil];
        NSInteger height1 =  MAX(45, CGRectGetHeight(recta)+10) ;
        return  height1;
    }
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        
        [cell setSeparatorInset:UIEdgeInsetsZero];
        
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }

    UILabel *labTitle=nil;
    if ([cell.contentView viewWithTag:333]) {
        labTitle = (UILabel *)[cell.contentView viewWithTag:333];
    }
    else{
        labTitle=[[UILabel alloc]initWithFrame:CGRectMake(20,10, 100, 30)];
        
        labTitle.font=[UIFont systemFontOfSize:14];
        labTitle.tag = 333;
        [cell.contentView addSubview:labTitle];
    }
    labTitle.text=titleArr[indexPath.row];
    [labTitle sizeToFit];
    NSString *textStr=[self.INFODIC objectForKey:contentArr[indexPath.row]];
    
    
    CGRect recta=[textStr boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-100, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}  context:nil];
    
    NSInteger height1 =  MAX(40, CGRectGetHeight(recta));
    UILabel *content=nil;
    if ([cell.contentView viewWithTag:334]) {
        content = (UILabel *)[cell.contentView viewWithTag:334];
    }
    else{
        content=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame), CGRectGetMinY(labTitle.frame), kFullScreenSizeWidth-100, height1)];
        content.font=labTitle.font;
        content.numberOfLines=0;
        
        content.tag = 334;
        [cell.contentView addSubview:content];
        
    }
    content.text=textStr;
    if (indexPath.row==6) {
        
        content.text=@"是";
        
        if ([[self.INFODIC objectForKey:contentArr[indexPath.row]] isEqualToString:@"N"]) {
            content.text=@"否";
        }
    }
    if (indexPath.row==7) {
        //附件
        NSString *fileName = [[self.INFODIC[@"notesFile"] componentsSeparatedByString:@"/"]lastObject];
        content.text = fileName;
      }
      [content sizeToFit];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row==7) {
        //查看附件
        NSString *urlString=[NSString stringWithFormat:@"http://117.78.42.226:8081%@",self.INFODIC[@"notesFile"]];
        
        
        CCReadViewController *read=[[CCReadViewController alloc]init];
        read.urlStr=urlString;
        [self.navigationController pushViewController:read animated:YES];
    }
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
#pragma mark==customMethod
-(void)report{
    CCHBRWVC *HB=[[CCHBRWVC alloc]init];
    HB.HBDIC=self.INFODIC;
    if ([[self.INFODIC objectForKey:@"status"]isEqualToString:@"3"]) {
        HB.canEdit=NO;
    }
    else
        HB.canEdit=YES;
    [self.navigationController pushViewController:HB animated:YES];
    
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
