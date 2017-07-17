//
//  STSubChooseViewController.m
//  CCField
//
//  Created by 马伟恒 on 2017/2/9.
//  Copyright © 2017年 Field. All rights reserved.
//

#import "STSubChooseViewController.h"
#import "STPeopleView.h"
#import "AddressBookFoot.h"
@interface STSubChooseViewController ()
@property (retain, nonatomic) AddressBookFoot *addressFoot;

@end

@implementation STSubChooseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.lableNav.text = @"添加员工";
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDir = [[paths objectAtIndex:0]stringByAppendingPathComponent:PEOPLE_ALL_ARRAY];
    [NSKeyedArchiver archiveRootObject:@[] toFile:docDir];
     NSDictionary *Arr = @{@"销售部":@[@{@"name":@"贾玲"},@{@"name":@"鲁智深"}]};
    // Do any additional setup after loading the view.
    STPeopleView *view = [[STPeopleView alloc]initWithFrame:CGRectMake(0,64, kFullScreenSizeWidth, kFullScreenSizeHeght-64) andDataSource:Arr withVC:self];
    view.superVC = self;
    [self.view addSubview:view];

    //初始化底部视图
//    _addressFoot = [[AddressBookFoot alloc]initWithFrame:CGRectMake(0, kFullScreenSizeHeght - 49, kFullScreenSizeWidth, 49)];
//    _addressFoot.tag = 400;
//    _addressFoot.superVC= self;
//     [self.view addSubview:_addressFoot];

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
