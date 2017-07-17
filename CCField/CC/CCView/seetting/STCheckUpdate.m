//
//  STCheckUpdate.m
//  CCField
//
//  Created by 马伟恒 on 16/6/20.
//  Copyright © 2016年 Field. All rights reserved.
//

#import "STCheckUpdate.h"

@implementation STCheckUpdate
-(void)viewDidLoad{
    [super viewDidLoad];
    self.lableNav.text = @"版本更新";
    NSDictionary *dic = [defaults objectForKey:@"updateDic"];
    //获得更新信息的dic
    UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(20, 80, 60, 60)];
    igv.image = [UIImage imageNamed:@"APP icon"];
    [self.view addSubview:igv];
    
    UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(igv.frame)+10, CGRectGetMinY(igv.frame), 200, CGRectGetHeight(igv.frame))];
    label.numberOfLines = 0;
    [self.view addSubview:label];
    
    NSDictionary *local_info = [[NSBundle mainBundle]infoDictionary];
    NSString *currVersion = [local_info objectForKey:@"CFBundleShortVersionString"];
    NSString *str_1 = [@"IOS,"stringByReplacingOccurrencesOfString:@"," withString:currVersion];
    CGFloat updateVersion = [[dic[@"updateVersion"] stringByReplacingOccurrencesOfString:@"." withString:@""]floatValue];
    CGFloat currentVersion = [[currVersion stringByReplacingOccurrencesOfString:@"." withString:@""]floatValue];
    NSString *str_3 = @"您的当前应用是最新版本";
    if (currentVersion < updateVersion) {
       //有新版本
        str_3 = @"有新版本";
        UIButton *downButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        downButton.layer.cornerRadius = 5;
        [downButton setBackgroundColor:RGBA(220, 52, 65, 1)];
        downButton.frame = CGRectMake(20, CGRectGetMaxY(igv.frame)+20, kFullScreenSizeWidth-40, 30);
        [downButton setTitle:@"下载并安装" forState:UIControlStateNormal];
        [downButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.view addSubview:downButton];
        [downButton addTarget:self action:@selector(godoDown) forControlEvents:UIControlEventTouchUpInside];
    }
    label.font = [UIFont systemFontOfSize:13];
    label.text = [NSString stringWithFormat:@"%@\n%@",str_1,str_3];
}
-(void)godoDown{
    NSDictionary *versonDic = [defaults objectForKey:@"updateDic"];

    [[UIApplication sharedApplication]openURL:[NSURL URLWithString:versonDic[@"updateURL"]]];

}
@end
