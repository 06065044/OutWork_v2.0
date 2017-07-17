//
//  CCLoginViewController.m
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCUtil.h"
#import "CSDataService.h"
#import "ASIFormDataRequest.h"
#import "CCLoginViewController.h"
#import "NSString+MD5Addition.h"
#import "AFHTTPRequestOperation.h"
#import "SAMKeychain.h"
#import "JPUSHService.h"
#import "HcdGuideViewManager.h"
NSString * const tagURL=@"http://117.78.42.226:8081/outside/dispatcher/issUser/updateTag";

@interface CCLoginViewController ()<ASIHTTPRequestDelegate>
{
    CGPoint center;
    UIColor *backColor;
 }
@property (weak, nonatomic) IBOutlet UIButton *login;

@end

@implementation CCLoginViewController

@synthesize userName=_userName,passWord=_passWord;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
     center=self.view.center;
    self.userName.delegate=self;
    self.passWord.delegate=self;
    backColor=self.view.backgroundColor;
    if ([defaults objectForKey:USER_NAME]) {
        self.userName.text=[defaults objectForKey:USER_NAME];
    }
    if ([defaults objectForKey:PASS_WORD]) {
        self.passWord.text=[defaults objectForKey:PASS_WORD];
    }
    
   //审核删除
//    UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0-100, kFullScreenSizeHeght-60, 120, 30)];
//    lab.text = @"未注册用户请联系:";
//    lab.font = [UIFont systemFontOfSize:14];
//    lab.textColor = [UIColor blackColor];
//    [self.view addSubview:lab];
//    
//    
//    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
//    [btn setFrame:CGRectMake(CGRectGetMaxX(lab.frame),CGRectGetMinY(lab.frame),210-CGRectGetWidth(lab.frame), 30)];
//    [btn setTitle:@"4001019977" forState:UIControlStateNormal];
//    [btn.titleLabel setFont:[UIFont systemFontOfSize:14]];
//    [btn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
//    [self.view addSubview:btn];
//    [btn addTarget:self action:@selector(telPhone:) forControlEvents:UIControlEventTouchUpInside];
    
 }
-(void)telPhone:(UIButton *)btn{
    UIWebView*callWebview =[[UIWebView alloc] init];
    callWebview.userInteractionEnabled=YES;
    NSURL *telURL =[NSURL URLWithString:[NSString stringWithFormat:@"tel:%@",[btn titleForState:UIControlStateNormal]]];// 貌似tel:// 或者 tel: 都行
    [callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
    //记得添加到view上
    [self.view addSubview:callWebview];
}





- (IBAction)login:(UIButton *)sender
{
//    [UIView beginAnimations:@"curlUp" context:nil];
//    
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];//指定动画曲线类型，该枚举是默认的，线性的是匀速的
//    
//    //设置动画时常
//    
//    [UIView setAnimationDuration:1];
//    
//    
//    //设置翻页的方向
//    
//    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:sender cache:YES];
//    
//    //关闭动画
//    
//    [UIView commitAnimations];
    
    
 
       [self.view endEditing:YES];
    if (self.userName.text.length==0||self.passWord.text.length==0) {
        [CCUtil showMBProgressHUDLabel:@"账号或者密码不能为空" detailLabelText:@"请输入账号与密码"];
        return;
    }
    [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        NSString *UUidstr=[SAMKeychain passwordForService:@"com.ccfield.isoftstone" account:@"user" error:&error];
         if (error) {
            NSLog(@"%@",error.localizedDescription);
        }
        if (UUidstr.length==0) {
            //新建一个
            CFUUIDRef uuidRef=CFUUIDCreate(kCFAllocatorDefault);
            UUidstr=(NSString *)CFBridgingRelease(CFUUIDCreateString(kCFAllocatorDefault, uuidRef));
           BOOL whe =  [SAMKeychain setPassword:UUidstr forService:@"com.ccfield.isoftstone" account:@"user" error:&error];
            if (!whe) {
                NSLog(@"111%@",error.localizedDescription);
            }
          
         }
        //正式版
          NSDictionary *dic=@{@"userName":self.userName.text,@"userPass":[self.passWord.text stringFromMD5mima],@"mobileFlag":UUidstr};
       // 测试版
        // NSDictionary *dic=@{@"memberCode":self.userName.text ,@"passWord":[self.passWord.text stringFromMD5mima],@"mobileFlag":UUidstr};
        NSString *final=[CCUtil basedString:loginUrl withDic:dic];
         ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [ requset setUseCookiePersistence : YES ];
        [requset setTimeOutSeconds:20];
        [requset setShouldAttemptPersistentConnection:NO];
        [requset setRequestMethod:@"GET"];
        [requset startSynchronous];
        NSData *Data=[requset responseData];
         dispatch_async(dispatch_get_main_queue(), ^{
    
    if ([Data length]==0||[requset.responseString rangeOfString:@"false"].location!=NSNotFound) {
        [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
        if (Data.length==0) {
            [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:nil];
        }
        else{
        self->jsonDic=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
            if (![self->jsonDic[@"message"] isKindOfClass:[NSString class]]) {
                [CCUtil showMBProgressHUDLabel:@"登录失败" detailLabelText:nil];
            }
            else
                [CCUtil showMBProgressHUDLabel:nil detailLabelText:self->jsonDic[@"message"]];
        
        }
        return;
    }
    
    [MBProgressHUD hideAllHUDsForView:[UIApplication sharedApplication].keyWindow animated:YES];
   // NSString *tag=[IP stringByAppendingFormat:@"_%@",self.userName.text];
      NSString *tag=@"471847699620845";
    if ([[defaults objectForKey:@"tokenStr"]isKindOfClass:[NSString class]]) {
        if ([[defaults objectForKey:@"tokenStr"]length]>10) {
            tag=[defaults objectForKey:@"tokenStr"];
            //[CCUtil showMBProgressHUDLabel:tag];
                }
            }
    [JPUSHService setTags:[NSSet setWithObject:tag] callbackSelector:nil object:nil];
    self->jsonDic=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    if ([[self->jsonDic valueForKey:@"success"]integerValue]==1) {
        //添加设备唯一标示id
        //NSString *Udid=[UIDevice currentDevice]
        //if ([jsonDic [@"tag"]isKindOfClass:[NSNull class]]) {
            NSDictionary *dic=@{@"tag":tag};
             NSString *url=[CCUtil basedString:tagURL withDic:dic];
            ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[url stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
            [requset setUseCookiePersistence : YES ];
            [requset setTimeOutSeconds:20];
            [requset setShouldAttemptPersistentConnection:NO];
            [requset setRequestMethod:@"GET"];
            [requset startSynchronous];
       
        
        //}
        [defaults setBool:YES forKey:@"autoLogin"];
        if ([self->jsonDic[@"memberId"] isKindOfClass:[NSString class]]) {
            [defaults setObject:self->jsonDic[@"memberId"] forKey:@"memberId"];
        }
        
        [defaults setObject:self.userName.text forKey:USER_NAME];
        [defaults setObject:self.passWord.text forKey:PASS_WORD];
        [defaults setBool:true forKey:@"clickOut"];
        [[NSUserDefaults standardUserDefaults]setObject:self.passWord.text forKey:@"pass"];
        CCAppDelegate  *app=(CCAppDelegate*)[[UIApplication sharedApplication] delegate];
        [app gotoMainView];
    }else{
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:self->jsonDic[@"message"] delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }

});
    });
    
    
    }
#pragma mark --textfield
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];


    return YES;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField == self.passWord) {
        return  YES;
    }
    
     if ([self isUserName:string]||string.length==0||[string isEqualToString:@"@"]||[string isEqualToString:@"."]) {
        return YES;
    }
    return NO;
}
- (BOOL)isUserName:(NSString *)str
{
    NSString *      regex = @"^[A-Za-z0-9]+$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:str];
}

- (BOOL)isPassword:(NSString *)str
{
    NSString *      regex = @"(^[A-Za-z0-9]{6,20}$)";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:str];
}

- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
#pragma mark-fieldend
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    [self.view endEditing:YES];
 
}


@end
