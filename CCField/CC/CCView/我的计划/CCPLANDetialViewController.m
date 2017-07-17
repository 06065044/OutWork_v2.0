//
//  CCPLANDetialViewController.m
//  CCField
//
//  Created by 马伟恒 on 14/10/24.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCPLANDetialViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "ASIHTTPRequest.h"
#import "CCCheckReplyViewController.h"
#import "CCRootViewController.h"
#import "NSObject+CC0utString.h"
#import "STPlanChangeVC.h"
static NSString *cellIDENTI=@"cellid";
static NSString *updateUrlPlan=@"http://117.78.42.226:8081/outside/dispatcher/workplan/updateWorkPlan";


@interface CCPLANDetialViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate,UITextFieldDelegate,UIActionSheetDelegate,UITextViewDelegate>
{
    UITextView *t0;
    UITextView *t1;
    UIView *view;
    NSArray* responseArr;//批示的条数
    NSArray *titleArr;
    NSArray *contentArr;
    UITableView *table;
    UIDatePicker *datePickerView;
    NSString *startTime;
}
@end

@implementation CCPLANDetialViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.lableNav.text=@"计划详情";
     titleArr=[NSArray arrayWithObjects:@"任务名称:",@"计划名称:",@"计划内容:",@"计划开始时间:",@"计划结束时间:", @"批示情况:", nil];
 
    contentArr=[NSArray arrayWithObjects:@"taskName",@"title",@"planContent",@"planStartTime",@"planEndTime",@"planAppCount",nil];
    if ([self.INFODIC[@"status"] integerValue]==2||[self.INFODIC[@"status"] integerValue]==4) {
        //已完成
        titleArr=[NSArray arrayWithObjects:@"任务名称:",@"计划名称:",@"计划内容:",@"计划开始时间:",@"计划结束时间:", @"批示情况:",@"实际完成时间:", nil];
        
        contentArr=[NSArray arrayWithObjects:@"taskName",@"title",@"planContent",@"planStartTime",@"planEndTime",@"planAppCount",@"finishTime",nil];

    }
    
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(moreChoice) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    button.tag=234;
    if ([self.INFODIC[@"status"] intValue]==2||[self.INFODIC[@"status"] intValue]==4) {
        [button removeFromSuperview];
    }

    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.dataSource=self;
    
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    table.backgroundColor = [UIColor clearColor];
    if ([table respondsToSelector:@selector(setSeparatorInset:)]) {
        [table setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([table respondsToSelector:@selector(setLayoutMargins:)]) {
        [table setLayoutMargins:UIEdgeInsetsZero];
    }

    [self.view addSubview:table];
    
}
/**
 *  点击更多选择
 */
-(void)moreChoice{
    UIActionSheet *action = [[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"修改",@"完成",@"删除",nil];
        [action showInView:self.view];
    action.tag = 333;//tag
}
//-(void)viewWillAppear:(BOOL)animated{
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        NSDictionary *doc=@{@"pageSize":@"10",@"currentPage":@"1",@"id":[self.INFODIC objectForKey:@"id"]};
//        NSString * detialStr=[CCUtil basedString:planDetailUrl withDic:doc];
//        NSURL *url=[NSURL URLWithString:[detialStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
//        ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:url];
//        [requset setRequestMethod:@"GET"];
//        [requset startSynchronous];
//        NSData *respon=[requset responseData];
//        if (respon.length==0) {
//            [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
//            return  ;
//        }
//        
//         self->responseArr =[NSJSONSerialization JSONObjectWithData:respon options:NSJSONReadingMutableLeaves error:nil][@"result"] ;
//        dispatch_async(dispatch_get_main_queue(), ^{
//             [self->table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//        });;
//        
//        
//        
//    });
//}


-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex==actionSheet.cancelButtonIndex) {
        return;
    }

    if (actionSheet.tag == 333) {
        //更多选项
        switch (buttonIndex) {
            case 0:
            {
                STPlanChangeVC *planVC = [[STPlanChangeVC alloc]init];
                planVC.INFODIC = self.INFODIC;
                [self.navigationController pushViewController:planVC animated:YES];
            }
                break;
            case 1:
                //完成
            {
                [self overPlan];
            }
                break;
            case 2:
                //删除
                {
                    [self deleteCurrentPlan];
                }
                
                break;
            default:
                break;
        }
    }
    


}
#pragma mark =- 完成
-(void)overPlan{
    NSDictionary *dic=@{@"ids":self.INFODIC[@"id"]};
    NSString *final=[CCUtil basedString:completePlan withDic:dic];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setRequestMethod:@"GET"];
    [requset setTimeOutSeconds:20];
    [requset startSynchronous];
    NSString *Str=[requset responseString];
    if ([Str rangeOfString:@"true"].location==NSNotFound) {
        //失败
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"提交失败"];
    }
    else{
        //更新上一个页面，返回
        [defaults setBool:true forKey:PLAN_REFRESH];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
}
#pragma mark == 删除
-(void)deleteCurrentPlan{
    //TODO: 补齐参数
    if (responseArr.count>0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"已经批示的计划无法删除"];
        return;
    }
    NSDictionary *dic=@{@"id":self.INFODIC[@"id"]};
    NSString *final=[CCUtil basedString:deletePlanUrl withDic:dic];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [requset setRequestMethod:@"GET"];
    [requset setTimeOutSeconds:20];
    [requset startSynchronous];
    NSString *Str=[requset responseString];
    if ([Str rangeOfString:@"true"].location==NSNotFound) {
        //失败
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"提交失败"];
    }
    else{
        //更新上一个页面，返回
        [defaults setBool:true forKey:PLAN_REFRESH];
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    }
 

}

#pragma mark===table data
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==2 ) {
        NSString *textStr=[self.INFODIC objectForKey:contentArr[indexPath.row]];
         CGRect recta=[textStr boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-40, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}  context:nil];
        
        int heighg=  MAX(40, CGRectGetHeight(recta)+35) ;
        return heighg;
    }
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    startTime=[self.INFODIC objectForKey:contentArr[3]];
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    if ([cell.contentView viewWithTag:300+indexPath.row ]) {
        [[cell.contentView viewWithTag:300+indexPath.row]removeFromSuperview];
    }
    
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 15, 100, 25)];
    labTitle.text=titleArr[indexPath.row];
    labTitle.font=[UIFont systemFontOfSize:14];
    labTitle.tag = 300+indexPath.row;
    [labTitle sizeToFit];
    [cell.contentView addSubview:labTitle];
    
    if ([cell.contentView viewWithTag:3000+indexPath.row ]) {
        [[cell.contentView viewWithTag:3000+indexPath.row]removeFromSuperview];
    }
    
    UITextField *content=[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame) , CGRectGetMinY(labTitle.frame)-6, kFullScreenSizeWidth-120, 30)];
    content.delegate = self;
    content.font=[UIFont systemFontOfSize:14];
    content.tag=indexPath.row+3000;
    content.userInteractionEnabled = false;
    [cell.contentView addSubview:content];
    if (indexPath.row!=2 ) {
        //一般情况
        NSString *textStr = [self.INFODIC[contentArr[indexPath.row]]outString];
        if (indexPath.row==titleArr.count-1) {
            if ([textStr length]==0) {
                textStr = @"0";
            }
            
        }
        content.text = textStr;
    }
    else
    {
        [content removeFromSuperview];
        NSString *textStr=[self.INFODIC objectForKey:contentArr[indexPath.row]];
    
         
        CGRect recta=[textStr boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-40, 10000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:16]}  context:nil];
        
        int heighg=   CGRectGetHeight(recta)  ;
        labTitle.transform = CGAffineTransformMakeTranslation(0, -5);
        
        UILabel *tv = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame) , 30, kFullScreenSizeWidth-40, heighg)];
        tv.font = [UIFont systemFontOfSize:14];
         tv.numberOfLines = 0;
        tv.lineBreakMode = NSLineBreakByWordWrapping;
         tv.text = textStr;
        [cell.contentView addSubview:tv];


    }
 
    return cell;
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
-(void)checkreply{
    
    NSDictionary *doc=@{@"pageSize":@"10",@"currentPage":@"1",@"id":[self.INFODIC objectForKey:@"id"]};
    NSString * detialStr=[CCUtil basedString:planReply withDic:doc];
    NSURL *url=[NSURL URLWithString:[detialStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    ASIHTTPRequest *requset=[ASIHTTPRequest requestWithURL:url];
    [requset setRequestMethod:@"GET"];
    [requset startSynchronous];
    NSData *respon=[requset responseData];
    if (respon.length==0) {
        [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
        return  ;
    }
    
    responseArr =[NSJSONSerialization JSONObjectWithData:respon options:NSJSONReadingMutableLeaves error:nil][@"result"] ;
  
    if (responseArr.count==0) {
        return;
    }
         CCCheckReplyViewController *checkReply=[[CCCheckReplyViewController alloc]init];
        checkReply.infoArr=responseArr;
        [self.navigationController pushViewController:checkReply animated:YES];
     
}
#pragma makr --other


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [table deselectRowAtIndexPath:indexPath animated:YES];
    
      if(indexPath.row==5){
        //批示详情
        [self checkreply];
        
    }
    

}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}
-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    
    //    [UIView animateWithDuration:0.5 animations:^{
    //        view.frame = CGRectMake(0, kFullScreenSizeHeght, kFullScreenSizeWidth, );
    [view removeFromSuperview];
    //    }];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
- (void)cancnelapick{
    if (view) {
        [view removeFromSuperview];
    }
    if (datePickerView) {
        [datePickerView removeFromSuperview];
    }
//    table.contentOffset = CGPointMake(0.0f, 0.0f);
}
-(void)quxiao{
    UITableViewCell *cell=[table cellForRowAtIndexPath:table.indexPathForSelectedRow];
    UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
    NSDate *select = [datePickerView date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    text.text=dateAndTime;
    //    [[self.view viewWithTag:2090]removeFromSuperview];
    if (table.indexPathForSelectedRow.row==3) {
        startTime=dateAndTime;
    }
    if (table.indexPathForSelectedRow.row==4) {
        NSString *end=[[[dateAndTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        NSString *start=[[[startTime stringByReplacingOccurrencesOfString:@"-" withString:@""]stringByReplacingOccurrencesOfString:@" " withString:@""]stringByReplacingOccurrencesOfString:@":" withString:@""];
        if ([end longLongValue]<[start longLongValue]) {
            [CCUtil showMBProgressHUDLabel:@"结束时间不能小于开始时间" detailLabelText:nil];
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
//    table.contentOffset = CGPointMake(0.0f, 0.0f);
    [table deselectRowAtIndexPath:table.indexPathForSelectedRow animated:YES];
    
    //    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSArray *Arr=@[@"➋",@"➌",@"➍",@"➎",@"➏",@"➐",@"➑",@"➒"];
    if ([Arr containsObject:string]) {
        return YES;
    }
    
    if ([self isUserName:string]||string.length==0) {
        return YES;
    }
    return NO;
    
}
-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    NSArray *Arr=@[@"➋",@"➌",@"➍",@"➎",@"➏",@"➐",@"➑",@"➒"];
    if ([Arr containsObject:text]) {
        return YES;
    }
    
    if ([self isUserName:text]||text.length==0) {
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
