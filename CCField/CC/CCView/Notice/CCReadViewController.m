//
//  CCReadViewController.m
//  CCField
//
//  Created by 马伟恒 on 15/9/1.
//  Copyright (c) 2015年 Field. All rights reserved.
//

#import "CCReadViewController.h"

@interface CCReadViewController ()<UIWebViewDelegate>

@end

@implementation CCReadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lableNav.text = @"附件详情";
    NSURL *url=[NSURL URLWithString:self.urlStr];
    
    self.view.backgroundColor=[UIColor whiteColor];
    UIWebView *Web=[[UIWebView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame))];
    Web.scalesPageToFit=YES;
    Web.delegate = self;
    
    NSString *str=[[self.urlStr componentsSeparatedByString:@"."]lastObject];
    NSLog(@"%@",str);
    if ([str isEqualToString:@"txt"]) {
    
    NSStringEncoding * usedEncoding = nil;
    //带编码头的如 utf-8等 这里会识别
    NSString *body = [NSString stringWithContentsOfURL:url usedEncoding:usedEncoding error:nil];
    if (!body)
    {
        //如果之前不能解码，现在使用GBK解码
        NSLog(@"GBK");
        body = [NSString stringWithContentsOfURL:url encoding:0x80000632 error:nil];
    }
    if (!body) {
        //再使用GB18030解码
        NSLog(@"GBK18030");
        body = [NSString stringWithContentsOfURL:url encoding:0x80000631 error:nil];
    }
    if (body) {
        [Web loadHTMLString:body baseURL:nil];
    }
    else {
        NSLog(@"没有合适的编码");
    }
    
   
    }else{
        [Web loadRequest:[NSURLRequest requestWithURL:url]];
        
        [Web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:[self.urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]]];
    }
    [self.view addSubview:Web];

}


-(void)webViewDidFinishLoad:(UIWebView *)webView{
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.webkitTextSizeAdjust= '250%'"];
    [webView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('body')[0].style.background='#19e64dff'"];
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
