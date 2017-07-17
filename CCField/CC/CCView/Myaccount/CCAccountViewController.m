//
//  CCAccountViewController.m
//  CCField
//
//  Created by 李付 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCUtil.h"
#import "CCAccountViewController.h"

@interface CCAccountViewController ()
  @end

@implementation CCAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lableNav.text=@"我的账户";
    [self beginRequset];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [MobClick event:@"accinfo"];
}

-(void)beginRequset{
      NSString *final=[CCUtil basedString:accountUrl withDic:nil];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setTimeOutSeconds:20];
    [ requset setUseCookiePersistence : YES ];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
     NSData *Data=[requset responseData];
        if (Data.length==0) {
            [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:nil];
            return;
        }

    jsonDic=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    self.nameLable.text=[jsonDic  valueForKey:@"phone"];
    self.nameLable.font = [UIFont systemFontOfSize:12];
    self.role.text=[jsonDic valueForKey:@"roleName"];
    self.role.font = [UIFont systemFontOfSize:12];
    [[NSUserDefaults standardUserDefaults]setObject:jsonDic[@"memberId"] forKey:@"memberId"];
}




-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
