//
//  STPeoInfoViewController.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/27.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STPeoInfoViewController.h"
#import "STHeadView.h"

@interface STPeoInfoViewController ()

@end

@implementation STPeoInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *lab_text = [[UILabel alloc]initWithFrame:
                         CGRectMake(20, 64, CGRectGetWidth(self.view.frame), 25)];
    NSString *btn_title = [NSString stringWithFormat:@"共%lu个员工未搜到",(unsigned long)_no_location_array.count];
    lab_text.font = [UIFont systemFontOfSize:14];
    lab_text.textColor = [UIColor grayColor];
    lab_text.text = btn_title;
      [self.view addSubview:lab_text];

    UIView *down_view = [[UIView alloc]initWithFrame:CGRectMake(20, CGRectGetMaxY(lab_text.frame), CGRectGetWidth(self.view.frame), 1)];
    down_view.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:down_view];
   
    
    NSInteger show_view_width = kFullScreenSizeWidth-30;
    NSInteger view_height =60;
    CGFloat view_width = show_view_width/5.0;
    for (int i=0; i<_no_location_array.count; i++) {
        CGRect frame = CGRectMake(15+view_width*(i%5),CGRectGetMaxY(down_view.frame)+(view_height*(i/5)), view_width, view_height);
                STHeadView *headView = [[STHeadView alloc]initWithFrame:frame name:_no_location_array[i]];
        [self.view addSubview:headView];
    }

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
