//
//  CCPassViewController.m
//  CCField
//
//  Created by 李付 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPassViewController.h"

@interface CCPassViewController ()

@end

@implementation CCPassViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lableNav.text=@"修改密码";
    
    UIButton *saveBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    saveBtn.frame=CGRectMake(270,30, 40, 30);
    [saveBtn setTitle:@"提交" forState:UIControlStateNormal];
    [saveBtn setBackgroundColor:[UIColor blackColor]];
    [saveBtn addTarget:self action:@selector(save) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:saveBtn];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    user=[[NSUserDefaults standardUserDefaults]objectForKey:@"pass"];
    NSLog(@" 44 %@",user);
}

-(void)save{
    if (self.oldPass.text.length==0||self.passNew.text.length==0) {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"修改密码不能为空..." delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }else if ([self.oldPass.text isEqualToString:self.passNew.text]){
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"新密码不能与旧密码相同" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
        return;
    }    
     NSDictionary *dic=@{@"memberId":@"1234563",@"passWord":[user stringFromMD5mima],@"newPassWord":[self.passNew.text stringFromMD5mima]};
    NSString *final=[CCUtil basedString:passUrl withDic:dic];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [ requset setUseCookiePersistence : YES ];
    [requset setTimeOutSeconds:20];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *Data=[requset responseData];
    if (Data.length==0) {
        [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:nil];
        return;
    }
    dicJson=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    if ([[dicJson valueForKey:@"success"]integerValue]==1) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}




@end
