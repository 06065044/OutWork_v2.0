//
//  CCAddPlanViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-15.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCAddPlanViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "STChoswTaskByPlanVC.h"
@interface CCAddPlanViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UITextViewDelegate>
{
    UITextField *tf0;
    UITextField *tf1;
    UITextField *tf2;
    UITextField *tf3;
    UITextField *tf4;
    NSArray *titleArr;
    UIView *view;
    UITableView *table;
    UIDatePicker *datePickerView;
    NSString *startTime;
    UIButton *button;
    NSString *taskId;

}
 @end

@implementation CCAddPlanViewController
static NSString *cellIDENTI=@"cellid";
 - (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.lableNav.text=@"添加计划";
    button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(savePlan) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    
    
    titleArr=[NSArray arrayWithObjects:@"任务名称:",@"计划名称:",@"计划内容:",@"计划开始时间:",@"计划结束时间:", nil];
 
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    table.scrollEnabled = YES;
    table.delegate=self;
    table.dataSource=self;
    table.rowHeight=40;
    table.backgroundColor = [UIColor clearColor];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:@"reuser"];
    table.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];

}
-(void)savePlan{
    [UIView animateWithDuration:0.25 animations:^{
        self->table.center = self->table.center;
        self->table.contentOffset=CGPointZero;
     }];
    if (tf1.text.length == 0||tf2.text.length==0||tf3.text.length==0||tf4.text.length==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请输入必填项"];
        return;
    }
    
dispatch_async(dispatch_get_main_queue(), ^{
    [self.view endEditing:YES];
    [CCUtil showMBLoading:@"正在提交" detailText:@"请稍候..."];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSString *title= self->tf1.text;
        NSString *content=self->tf2.text;
        NSString *time2=self->tf3.text;
        NSString *time3=self->tf4.text;
        
         NSMutableDictionary *dic=@{@"title":title,@"planContent":content,@"planStartTime":time2,@"planEndTime":time3}.mutableCopy;
        if (self->taskId) {
            [dic setObject:self->taskId forKey:@"taskId"];
        }
        NSString *final=[CCUtil basedString:addPlanUrl withDic:dic];
        ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [requset setRequestMethod:@"GET"];
        [requset setTimeOutSeconds:20];
        [requset startSynchronous];
        NSString *Str=[requset responseString];
        dispatch_async(dispatch_get_main_queue(), ^{
            [CCUtil hideMBLoading];

            
                if ([Str rangeOfString:@"true"].location!=NSNotFound) {
                    [CCUtil showMBProgressHUDLabel:@"提交成功" detailLabelText:nil];
                    [defaults setBool:YES forKey:PLAN_REFRESH];
                    [self.navigationController popViewControllerAnimated:YES];
                    
                }
                
                else{
                    [CCUtil showMBProgressHUDLabel:@"提交失败" detailLabelText:nil];
                }
 
             
        });
    });
});
   
   }
#pragma mark--table 

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:@"reuser" forIndexPath:indexPath];
    for (UIView *sub in cell.contentView.subviews) {
        [sub removeFromSuperview];
    }
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 30)];
    labTitle.text=titleArr[indexPath.row];
    labTitle.font=[UIFont systemFontOfSize:14];
    [labTitle sizeToFit];
    [cell.contentView addSubview:labTitle];
    CGRect rightRect = CGRectMake(CGRectGetMaxX(labTitle.frame)+5, 10, kFullScreenSizeWidth-120, 30);
    switch (indexPath.row) {
        case 0:
        {
            if (!tf0) {
                  tf0=[[UITextField alloc]initWithFrame:rightRect];
                }
                tf0.font=labTitle.font;
                tf0.tag=indexPath.row+3000;
                tf0.delegate=self;
            if ([defaults objectForKey:@"tf0"]) {
                tf0.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"tf0"];

            }
            
                [cell.contentView addSubview:tf0];
            
        
            }
            break;
           case 1:
        {
            if (!tf1) {
                tf1=[[UITextField alloc]initWithFrame:rightRect];
                }
                tf1.font=labTitle.font;
                tf1.tag=indexPath.row+3000;
                tf1.delegate=self;
                tf1.placeholder = @"必填";
                if ([defaults objectForKey:@"tf1"]) {
                    tf1.text=[[NSUserDefaults standardUserDefaults]objectForKey:@"tf1"];
                    
                }
                [cell.contentView addSubview:tf1];
            }
         
            break;
            case 2:
        {
            if (!tf2) {
                tf2=[[UITextField alloc]initWithFrame:rightRect];
            }
                tf2.font=labTitle.font;
                tf2.tag=indexPath.row+3000;
                tf2.placeholder = @"必填";
                 [cell.contentView addSubview:tf2];
          

        }break;
        case 3:
        {
            if (!tf3) {
                tf3=[[UITextField alloc]initWithFrame:rightRect];

            }
                tf3.font=labTitle.font;
                tf3.tag=indexPath.row+3000;
                tf3.userInteractionEnabled=NO;
                [cell.contentView addSubview:tf3];
                tf3.placeholder = @"必填";

                   }
            break;
        case 4:{
            if (!tf4) {
                tf4=[[UITextField alloc]initWithFrame:rightRect];

            }
            tf4.font=labTitle.font;
            tf4.tag=indexPath.row+3000;
            tf4.userInteractionEnabled=NO;
            [cell.contentView addSubview:tf4];
            tf4.placeholder = @"必填";
        }
            break;
        default:
            break;
            
    }
 
    return cell;
}
#pragma mark --textfield

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (textField==tf0) {
        if (textField.text.length==30) {
            return NO;
        }
    }
    NSArray *Arr=@[@"➋",@"➌",@"➍",@"➎",@"➏",@"➐",@"➑",@"➒"];
    if ([Arr containsObject:string]) {
        return YES;
    }

    if ([self isUserName:string]||string.length==0) {
        return YES;
    }
    return NO;
    
}

- (BOOL)isUserName:(NSString *)str
{
    NSString *      regex = @"^[\u4e00-\u9fa5_a-zA-Z0-9]+$";
    NSPredicate *   pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    
    return [pred evaluateWithObject:str];
}
#pragma mark-fieldend
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if (tf0 == textField) {
        //任务选择
        STChoswTaskByPlanVC *task  = [[STChoswTaskByPlanVC alloc]init];
        [task setBLock:^(NSArray *arr) {
            self->tf0.text = arr[1];
            self->taskId = arr[0];
            
        }];
        [self->tf1 becomeFirstResponder];
        [self.navigationController pushViewController:task animated:YES];
    }

}
#pragma mark -- table
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    if (textField==tf0) {
        [[NSUserDefaults standardUserDefaults]setObject:textField.text forKey:@"tf0"];
    }
  

}
-(void)textViewDidEndEditing:(UITextView *)textView{
    [[NSUserDefaults standardUserDefaults]setObject:textView.text forKey:@"tf1"];

}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        [tf0 becomeFirstResponder];
    }
    if (indexPath.row==1) {
        [tf1 becomeFirstResponder];
    }
    
    
    if (indexPath.row>2) {
        
        [self.view endEditing:YES];
        if (view) {
            [view removeFromSuperview];
        }
        if (datePickerView) {
            [datePickerView removeFromSuperview];
        }
        if ([self.view viewWithTag:2090]) {
            [[self.view viewWithTag:2090 ]removeFromSuperview];
        }
        
        
        view=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 120)];
        view.frame = CGRectMake(0, kFullScreenSizeHeght,kFullScreenSizeWidth,200);
        view.backgroundColor=[UIColor grayColor];
        [self.view addSubview:view];
        
        UIButton *quxiaoBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        quxiaoBtn.backgroundColor=[UIColor redColor];
        quxiaoBtn.frame=CGRectMake(20, 5,80, 40);
        quxiaoBtn.clipsToBounds = YES;
        quxiaoBtn.layer.cornerRadius=3.0f;
        
        [quxiaoBtn addTarget:self action:@selector(quxiao) forControlEvents:UIControlEventTouchUpInside];
        [quxiaoBtn setTitle:@"确定" forState:UIControlStateNormal];
        [view addSubview:quxiaoBtn];
        UIButton *cancel=[UIButton buttonWithType:UIButtonTypeCustom];
        cancel.frame=CGRectOffset(quxiaoBtn.frame, kFullScreenSizeWidth-120, 0);
        cancel.clipsToBounds = YES;
        cancel.layer.cornerRadius=3.0f;
        [cancel addTarget:self action:@selector(cancnelapick) forControlEvents:UIControlEventTouchUpInside];
        [cancel setTitle:@"取消" forState:UIControlStateNormal];
        cancel.backgroundColor=[UIColor redColor];
        [view addSubview:cancel];
        
        datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDate;
        datePickerView.frame=CGRectMake(0,50,kFullScreenSizeWidth,150);
        [view addSubview:datePickerView];
        [UIView animateWithDuration:0.3 animations:^{
            
            self->view.frame=CGRectMake(0,kFullScreenSizeHeght-200,kFullScreenSizeWidth,200);
            
        } completion:^(BOOL finished) {
            
        }];

        
//        if (table.indexPathForSelectedRow.row == 2 | table.indexPathForSelectedRow.row == 3 ) {
//            
//            int offset = (5-indexPath.row+2)*60-(kFullScreenSizeHeght - 216.0);//求出键盘顶部与textfield底部大小的距离
//            table.contentSize = CGSizeMake(0.0f, 100.0f);
//            if (offset<0) {
//                table.contentOffset = CGPointMake(0, -offset);
//            }
//        }
        
        
        
        
//        table.tableFooterView=view;
//    }
//    else{
//        table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
//    }

    }
}

-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
//    [UIView animateWithDuration:0.5 animations:^{
//        view.frame = CGRectMake(0, kFullScreenSizeHeght, kFullScreenSizeWidth, );
        [view removeFromSuperview];
//    }];
}
-(void)viewWillDisappear:(BOOL)animated{
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"tf0"];
    [[NSUserDefaults standardUserDefaults]removeObjectForKey:@"tf1"];

}
- (void)cancnelapick{
    if (view) {
        [view removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
    table.contentOffset = CGPointMake(0.0f, 0.0f);
}

-(void)quxiao{

    UITableViewCell *cell=[table cellForRowAtIndexPath:table.indexPathForSelectedRow ];
    table.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
    NSDate *select = [datePickerView date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    text.text=dateAndTime;
    if (table.indexPathForSelectedRow.row==3) {
        startTime=dateAndTime;
        if (tf4.text.length>0) {
            //结束的存在
            NSString *endString = tf4.text;
            
            NSString *end=[[[endString stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
            NSString *start=[[[dateAndTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
            if ([end longLongValue]<[start longLongValue]) {
                [CCUtil showMBProgressHUDLabel:@"结束时间不能小于开始时间"];
                text.text=@"";
            }
        }

    }
    if (table.indexPathForSelectedRow.row==4) {
        NSString *end=[[[dateAndTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *start=[[[startTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([end longLongValue]<[start longLongValue]) {
            [CCUtil showMBProgressHUDLabel:@"结束时间不能小于开始时间"];
            text.text=@"";
        }
        
    }
    if (view) {
        [view removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }

//    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    table.contentOffset = CGPointMake(0.0f, 0.0f);
    [table deselectRowAtIndexPath:table.indexPathForSelectedRow animated:YES];
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
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
