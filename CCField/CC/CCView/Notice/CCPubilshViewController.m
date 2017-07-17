//
//  CCPubilshViewController.m
//  CCField
//
//  Created by 李付 on 14/10/17.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPubilshViewController.h"
#import <objc/runtime.h>
#import <CoreText/CoreText.h>
#import "CCUtil.h"
#import "CCReadViewController.h"
#import "ASIHTTPRequest.h"
@interface CCPubilshViewController ()<UIAlertViewDelegate>
{
    
    UILabel *dataLable;
    UILabel *dataComent;
    UIScrollView *scroll;
}
@end

@implementation CCPubilshViewController
static char OperationKey;
@synthesize dataDic;
- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *dic  =@{@"type":@"notice",@"id":dataDic[@"id"]};
    NSString *str = [CCUtil basedString:upNoticeState withDic:dic];
    ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:str]];
    [request setTimeOutSeconds:20];
    [request setRequestMethod:@"GET"];
    [request startAsynchronous];
    
    self.lableNav.text=@"公告明细";
    scroll=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 64, kFullScreenSizeWidth, kFullScreenSizeHeght-64)];
    scroll.contentSize=CGSizeMake(kFullScreenSizeWidth, kFullScreenSizeHeght-64);
    [self.view addSubview:scroll];
     /** 调整布局，内容往上提*/
    /*
     *分别判断
     */
    if ([dataDic valueForKey:@"title"]!=Nil) {
        dataLable=[[UILabel alloc]initWithFrame:CGRectMake(10,0,kFullScreenSizeWidth-20,50)];
        dataLable.backgroundColor=[UIColor clearColor];
        dataLable.numberOfLines=0;
        dataLable.textColor=[UIColor blackColor];
        
        NSString *Str=dataDic[@"title"];
        if (Str.length>17) {
            
            CGRect rect=[Str boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-40, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:14]} context:nil];
            dataLable.frame=CGRectMake(20, 0, kFullScreenSizeWidth-40, MAX(30, rect.size.height));
        }
        dataLable.text=[dataDic valueForKey:@"title"];
        dataLable.textAlignment=NSTextAlignmentCenter;
        dataLable.font=[UIFont systemFontOfSize:14];
        
        [scroll addSubview:dataLable];
    }
    
    if ([dataDic valueForKey:@"content" ]!=Nil) {
        dataComent=[[UILabel alloc]init];
        dataComent.backgroundColor=[UIColor clearColor];
        dataComent.textColor=[UIColor blackColor];
        NSString *Str=dataDic[@"content"];
        CGRect rect=[Str boundingRectWithSize:CGSizeMake(250, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Helvetica-Bold" size:14]} context:nil];
        dataComent.frame=CGRectMake(30,CGRectGetMaxY(dataLable.frame)+2,250,rect.size.height+50);
        dataComent.text=[dataDic valueForKey:@"content" ];
        dataComent.font = [UIFont systemFontOfSize:14];
        dataComent.numberOfLines=0;
        dataComent.textAlignment=NSTextAlignmentLeft;
        [scroll addSubview:dataComent];
    }

    
    if ([dataDic valueForKey:@"createUser"]!=Nil) {
        UILabel *dataUser=[[UILabel alloc]initWithFrame:CGRectMake(20,CGRectGetMaxY(dataComent.frame)+2,300,25)];
        dataUser.backgroundColor=[UIColor clearColor];
        dataUser.textColor=[UIColor grayColor];
        dataUser.text=[NSString stringWithFormat:@"发布人:%@",[dataDic valueForKey:@"createUser"]];
        dataUser.textAlignment=NSTextAlignmentLeft;
        dataUser.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
        [scroll addSubview:dataUser];
    }
    
    if ([dataDic valueForKey:@"createTime"]!=Nil) {
        UILabel *dataTime=[[UILabel alloc]initWithFrame:CGRectMake(20,CGRectGetMaxY(dataComent.frame)+18,300,30)];
        dataTime.backgroundColor=[UIColor clearColor];
        dataTime.textColor=[UIColor grayColor];
        dataTime.text=[NSString stringWithFormat:@"发布时间:%@",[dataDic valueForKey:@"createTime"]];
        dataTime.textAlignment=NSTextAlignmentLeft;
        dataTime.font=[UIFont fontWithName:@"Helvetica-Bold" size:12];
        [scroll addSubview:dataTime];
    }
    
    
    if ([[dataDic valueForKey:@"notesFile"]respondsToSelector:@selector(substringFromIndex:)]) {
        NSString *recieveStr=[[[dataDic valueForKey:@"notesFile"]componentsSeparatedByString:@"/"]lastObject];
        NSString *fileSize=[NSString stringWithFormat:@"(%.1fKB)",([dataDic[@"fileSize"] longLongValue]/(1024*8.0))];
        
        recieveStr=[recieveStr stringByAppendingString:fileSize];
        NSMutableAttributedString *str=[[NSMutableAttributedString alloc]initWithString:recieveStr];
        [str addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:(id)[NSNumber numberWithInt:kCTUnderlineStyleDouble] range:NSMakeRange(0, recieveStr.length)];
        [str addAttribute:(NSString *)kCTForegroundColorAttributeName value:(id)[UIColor blueColor].CGColor range:NSMakeRange(0, str.length)];
        
        UIButton *dataFile=[UIButton buttonWithType:UIButtonTypeRoundedRect];
        dataFile.frame=CGRectMake(20,CGRectGetMaxY(dataComent.frame)+20,250,80);
        [dataFile setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        dataFile.titleLabel.font=[UIFont fontWithName:@"Helvetica-Bold" size:15];
        dataFile.titleLabel.numberOfLines=4;
        
        [dataFile setAttributedTitle:str forState:UIControlStateNormal];
        [dataFile addTarget:self action:@selector(pathLoad:) forControlEvents:UIControlEventTouchUpInside];
        objc_setAssociatedObject(self, &OperationKey, [dataDic objectForKey:@"notesFile"], OBJC_ASSOCIATION_RETAIN);
        [scroll addSubview:dataFile];
    }
    //    __weak CCPubilshViewController *weakSelf=self;
    //    alertC=^(NSInteger index){
    //        if (index==0) {
    //            [CCUtil showMBProgressHUDLabel:@"点击取消了" detailLabelText:nil];
    //            return;
    //        }
    //        if (index==1) {
    //            [CCUtil showMBProgressHUDLabel:@"开始下载" detailLabelText:nil];
    //            [NSThread sleepForTimeInterval:2];
    //            NSString *Str=(NSString *)objc_getAssociatedObject(weakSelf, &OperationKey);
    //           NSString *urlString=[NSString stringWithFormat:@"http://117.78.42.226:8081/outside/dispatcher/announcement/downLoad?path=%@",[Str substringFromIndex:0]];
    //            ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlString]];
    //            NSString *downLoadPath=[[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]stringByAppendingPathComponent:[[Str componentsSeparatedByString:@"/"]lastObject ]];
    //            NSLog(@"=====%@",downLoadPath);
    //            [Requset setDownloadDestinationPath:downLoadPath];
    //            [Requset startAsynchronous];
    //            [Requset setCompletionBlock:^{
    //                NSLog(@"1111");
    //                [CCUtil showMBProgressHUDLabel:@"下载完成" detailLabelText:nil];
    ////                NSString *Str=(NSString *)objc_getAssociatedObject(weakSelf, &OperationKey);
    ////                NSString *urlString=[NSString stringWithFormat:@"http://117.78.42.226:8081/outside/dispatcher/announcement/downLoad?path=%@",[Str substringFromIndex:0]];
    ////                UIWebView *Web=[[UIWebView alloc]initWithFrame:weakSelf.view.bounds];
    ////                [Web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
    ////                [weakSelf.view addSubview:Web];
    ////                QLPreviewController *ql=[[QLPreviewController alloc]init];
    ////                ql.navigationController.navigationBarHidden=YES;
    ////                ql.dataSource=weakSelf;
    ////                [ql setCurrentPreviewItemIndex:0];
    ////                UINavigationController *mav=[[UINavigationController alloc]initWithRootViewController:ql];
    ////                UIBarButtonItem *back=[[UIBarButtonItem alloc]initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:weakSelf action:@selector(backPre)];
    ////                ql.navigationItem.leftBarButtonItem=back;
    ////                [weakSelf presentViewController:mav animated:YES completion:nil];
    //
    //            }];
    //            [Requset setFailedBlock:^{
    //                NSLog(@"222");
    //                [CCUtil showMBProgressHUDLabel:@"下载失败" detailLabelText:nil];
    //            }];
    //
    //        }
    //
    //    };
    
    [scroll setContentSize:CGSizeMake(kFullScreenSizeWidth, MAX(kFullScreenSizeHeght-64, CGRectGetMaxY(dataComent.frame)+30))];
}

-(void)pathLoad:(UIButton *)button{
    //    UIAlertView *alset=[[UIAlertView alloc]initWithTitle:@"提示" message:@"您确定下载该附件?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    //    [alset show];
    
    //ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:pathUrl]];
    //在线预览
    NSString *Str=(NSString *)objc_getAssociatedObject(self, &OperationKey);
    NSString *urlString=[NSString stringWithFormat:@"http://117.78.42.226:8081/outside%@",[Str substringFromIndex:4]];
 
     CCReadViewController *read=[[CCReadViewController alloc]init];
    read.urlStr=urlString;
    [self.navigationController pushViewController:read animated:YES];
    
}
#pragma mark --quicklook

#pragma makk-other
-(void)backPre{
    [self dismissViewControllerAnimated:YES completion:nil];
    
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertC) {
        alertC(buttonIndex);
    }
    
}

-(void)dataRequest{
    //    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:accountUrl]];
    //    NSDictionary *dic=@{@"sessionId":[requset getSessionID]};
    //    NSString *final=[CCUtil basedString:accountUrl withDic:dic];
    //    requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    //    [ requset setUseCookiePersistence : YES ];
    //    // [requset addRequestHeader:@"sessionId" value:[requset getSessionID]];
    //    [requset setRequestMethod:@"GET"];
    //    [requset startSynchronous];
    //    NSData *Data=[requset responseData];
    //
    //    NSLog(@"666 %@",requset.responseString);
    //
    //    jsonDic=[NSJSONSerialization JSONObjectWithData:Data options:NSJSONReadingMutableLeaves error:nil];
    //    self.nameLable.text=[jsonDic  valueForKey:@"phone"];
    //    self.role.text=[jsonDic valueForKey:@"roleName"];
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
@end
