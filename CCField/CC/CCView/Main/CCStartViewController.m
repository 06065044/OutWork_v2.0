//
//  CCStartViewController.m
//  CCField
//
//  Created by 李付 on 14-10-10.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCStartViewController.h"
#import "CCLoginViewController.h"

#define NPAGES		3

@interface CCStartViewController ()

@end

@implementation CCStartViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];

    StartScoll=[[UIScrollView alloc]initWithFrame:CGRectMake(0.0f,.0f, kFullScreenSizeWidth, kFullScreenSizeHeght)];
    [StartScoll setContentSize:CGSizeMake(NPAGES * kFullScreenSizeWidth, kFullScreenSizeHeght)];
    [StartScoll setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    [StartScoll setShowsVerticalScrollIndicator:NO];
     [StartScoll setScrollEnabled:YES];
    [StartScoll setPagingEnabled:YES];
    [StartScoll setBounces:NO];
    
    for (int i= 0; i<NPAGES; i++)
    {
        if (kFullScreenSizeHeght>500||[[UIDevice currentDevice]userInterfaceIdiom]==UIUserInterfaceIdiomPad)
        {
            StartImage=[UIImage imageNamed:[NSString stringWithFormat:@"引导%d.jpg",i+1]];
            StartImageView=[[UIImageView alloc]initWithImage:StartImage];
            StartImageView.frame=CGRectMake(kFullScreenSizeWidth*i,0, kFullScreenSizeWidth, kFullScreenSizeHeght);
            StartImageView.tag=i+1;
            [StartScoll addSubview:StartImageView];
        }else
        {
            StartImage=[UIImage imageNamed:[NSString stringWithFormat:@"引导%d.png",i+1]];
            StartImageView=[[UIImageView alloc]initWithImage:StartImage];
            StartImageView.frame=CGRectMake(320*i, 0, 320, 480);
            StartImageView.userInteractionEnabled=YES;
            StartImageView.tag=i+1;
            [StartScoll addSubview:StartImageView];
        }
        [self.view addSubview:StartScoll];
        
        if (StartImageView.tag==3)
        {
            StartImageView.userInteractionEnabled=YES;

            UITapGestureRecognizer *Tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(loadMainView)];
            [StartImageView addGestureRecognizer:Tap];
        }
    }
  }

-(void)loadMainView
{
    CCLoginViewController *login = [[CCLoginViewController alloc]init];
    [[UIApplication sharedApplication]keyWindow].rootViewController = login;
    
//    [(CCAppDelegate *)[UIApplication sharedApplication].delegate gotoMainView];

//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationDuration:0.3f];
//    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
//    [UIApplication sharedApplication].statusBarHidden=NO;
//    [(CCAppDelegate *)[UIApplication sharedApplication].delegate gotoMainView];
//     StartScoll.contentOffset = CGPointMake(320.0f *NPAGES, 0.0f);
//    [UIView commitAnimations];
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
