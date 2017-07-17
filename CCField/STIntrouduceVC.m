//
//  STIntrouduceVC.m
//  CCField
//
//  Created by 马伟恒 on 16/8/9.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STIntrouduceVC.h"
@interface STIntrouduceVC()<UIWebViewDelegate>
@end
@implementation STIntrouduceVC
-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"功能简介";
    UIWebView *web = [[UIWebView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame))];
    web.delegate = self;
//    web.scalesPageToFit = YES;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"introduce" ofType:@"html"];
    
    NSString *htmlString = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    NSString *basePath = [[NSBundle mainBundle] bundlePath];
    
    NSURL *baseURL = [NSURL fileURLWithPath:basePath];
    
    [web loadHTMLString:htmlString baseURL:baseURL];
    [self.view addSubview:web];
}
-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    NSLog(@"%@",error.localizedDescription);
}
@end
