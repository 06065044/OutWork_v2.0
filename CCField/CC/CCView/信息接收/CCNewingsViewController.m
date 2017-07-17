//
//  CCNewingsViewController.m
//  CCField
//
//  Created by 李付 on 14/10/20.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCNewingsViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"

@interface CCNewingsViewController ()

@end

@implementation CCNewingsViewController
@synthesize dataDic;


- (void)viewDidLoad {
    [super viewDidLoad];
   
    self.lableNav.text=@"信息明细";
    
    NSLog(@" dataDic=%@",dataDic);
    
    /*
     *分别判断
     */
   // if ([[dataDic valueForKey:@"content"]respondsToSelector:@selector(substringFromIndex:)]) {
    
    NSDictionary *dic  =@{@"type":@"msg",@"id":dataDic[@"id"]};
    NSString *str = [CCUtil basedString:upNoticeState withDic:dic];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:str]];
    [request setTimeOutSeconds:20];
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
    
    UITextView *dataLable=[[UITextView alloc]init];
        dataLable.backgroundColor=[UIColor clearColor];
        dataLable.textColor=[UIColor blackColor];
        dataLable.text=[[dataDic valueForKey:@"content"]outString];
    CGRect rect=[dataLable.text boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-40, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}  context:nil];
     dataLable.font = [UIFont systemFontOfSize:14];
    dataLable.frame = CGRectMake(20, CGRectGetMaxY (self.imageNav.frame)+10,kFullScreenSizeWidth-40,rect.size.height+10);
    dataLable.userInteractionEnabled = NO;
        [self.view addSubview:dataLable];
  //  }
    
   // if ([dataDic valueForKey:@"sendUser"]!=Nil) {
        UILabel *dataUser=[[UILabel alloc]initWithFrame:CGRectMake(20,CGRectGetMaxY(dataLable.frame)+10,140,30)];
        dataUser.backgroundColor=[UIColor clearColor];
        dataUser.textColor=[UIColor grayColor];
        dataUser.text=[NSString stringWithFormat:@"发送人:%@",[[dataDic valueForKey:@"sendUser"] outString]];
        dataUser.textAlignment=NSTextAlignmentLeft;
        dataUser.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
        [self.view addSubview:dataUser];
  //  }
    
 //   if ([dataDic valueForKey:@"createTime"]!=Nil) {
        UILabel *dataTime=[[UILabel alloc]initWithFrame:CGRectOffset(dataUser.frame, 0, 30)];
        dataTime.backgroundColor=[UIColor clearColor];
        dataTime.textColor=[UIColor grayColor];
        dataTime.text=[NSString stringWithFormat:@"时间:%@",[[dataDic valueForKey:@"createTime"] outString]];
        dataTime.textAlignment=NSTextAlignmentLeft;
        dataTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
        [self.view addSubview:dataTime];
    //}
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
