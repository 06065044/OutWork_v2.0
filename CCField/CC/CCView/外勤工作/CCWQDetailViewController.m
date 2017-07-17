//
//  CCWQDetailViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCWQDetailViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
 #import "UIImageView+WebCache.h"
#import "ASIFormDataRequest.h"
#import "CTAssetsPickerController.h"
NSString *upDataUrl=@"http://117.78.42.226:8081/outside/dispatcher/workRecord/saveOrUpdateWorkList";
@interface CCWQDetailViewController ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UITextViewDelegate>
{
    NSMutableData *dataF;
    UIView *backGroundView;
    NSMutableArray *imageArr;//存储图片的数组
    NSArray *titleArr;//存储title的数组
    NSArray *contentArr;//存储key的数组
    UITableView *table;
    UITextField *content;
    
    UIDatePicker *datePickerView;
    NSInteger indexSelect;
}
@end

@implementation CCWQDetailViewController

static NSString *cellIDENTI=@"cellid";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lableNav.text=@"外勤工作详情";
    titleArr=[NSArray arrayWithObjects:@"工作名称:",@"工作内容:",@"工作时间:",@"工作位置:", @"工作地点:",@"工作图片", nil];
    contentArr=[NSArray arrayWithObjects:@"workTitle",@"workContent",@"workTime",@"location",@"workLocation",@"pic", nil];
    imageArr=[NSMutableArray array];
    
    if (![[self.INFODIC objectForKey:@"pic"]isKindOfClass:[NSNull class]]) {
        imageArr=[NSMutableArray arrayWithArray:[[self.INFODIC objectForKeyedSubscript:@"pic"]componentsSeparatedByString:@";"]];
        [imageArr removeLastObject];
        for (int i=0; i<imageArr.count; i++) {
            if ([imageArr[i]hasSuffix:@"/1.jpg"]) {
                [imageArr removeObjectAtIndex:i];
            }
        }
    }
 
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.backgroundColor = [UIColor clearColor];

    table.dataSource=self;
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 3)];
     [self.view addSubview:table];
 }

/**
 * 提交修改
 */
//-(void)weihu{
//            [self.view endEditing:YES];
//        
//        NSMutableArray *Arr=[NSMutableArray array];
//        for (int i=0; i<5; i++) {
//            UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
//            if (i<2) {
//                UITextView *tf=(UITextView *)[cell.contentView viewWithTag:3000+i];
//                [Arr addObject:tf.text];
//                continue;
//            }
//            
//            UITextField *tf=(UITextField *)[cell.contentView viewWithTag:3000+i];
//            [Arr addObject:tf.text];
//        }
//        [CCUtil showMBLoading:@"请稍候..." detailText:@"请稍候..."];
//        /**
//         *  post
//         */
//        ASIHTTPRequest *requset0=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:upDataUrl]];
//        NSDictionary *dic=@{@"sessionId":[requset0 getSessionID],@"workContent":Arr[1],@"workTime":Arr[2],@"workLocation":Arr[3],@"location":Arr[4],@"workTitle":Arr[0],@"id":[self.INFODIC objectForKey:@"id"]};
//        ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:upDataUrl]];
//        [requset setTimeOutSeconds:10];
//        [requset setURL:[NSURL URLWithString:upDataUrl]];
//        
//        NSArray *Array=[dic allKeys];
//        for (int i=0; i<Array.count; i++) {
//            [requset setPostValue:[dic objectForKey:Array[i]] forKey:Array[i]];
//        }
//        for (int i=0; i<imageArr.count; i++) {
//            UIImage *image=imageArr[i];
//            NSData *imagedata=nil;
//            if ([imageArr[i]isKindOfClass:[UIImage class]]) {
//                imagedata=UIImageJPEGRepresentation(image, 0.5);
//            }
//            else{
//                NSString *str=imageArr[i];
//                
//                if([str rangeOfString:@"/opt"].location!=NSNotFound){
//                    imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/opt" withString:@"http://117.78.42.226:8081"]]];
//                    
//                }
//                else
//                    imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/outside" withString:@"http://117.78.42.226:8081/outside"]]];
//                //                imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/outside" withString:@"http://117.78.42.226:8081/outside"]]];
//                //  break;
//            }
//            NSString *name=[NSString stringWithFormat:@"%@.jpg",[CCUtil currentStamp]];
//            NSString *key=[NSString stringWithFormat:@"%d",i];
//            [requset addData:imagedata withFileName:name andContentType:@"multipart/form-data;boundary=*****" forKey:key];
//        }
//        //        if (![imageArr isKindOfClass:[NSArray class]]||imageArr.count==0) {
//        //            UIImage *image=[UIImage imageNamed:@"1.png"];
//        //            NSData *imagedata=UIImageJPEGRepresentation(image, 0.5);
//        //            [requset addData:imagedata withFileName:@"1.jpg" andContentType:@"multipart/form-data;boundary=*****" forKey:@"1"];
//        //        }
//        requset.delegate=self;
//        [requset startAsynchronous];
//        [table reloadData];
//  }
//#pragma mark--ASI
//-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
//    NSLog(@"%@",responseHeaders);
//    dataF=[NSMutableData data];
//}
//-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
//    [dataF appendData:data];
//    
//}
//-(void)requestFinished:(ASIHTTPRequest *)request{
//    NSString *str=[[NSString alloc]initWithData:dataF encoding:NSUTF8StringEncoding];
//    if ([str rangeOfString:@"true"].location!=NSNotFound) {
//        //modi success
//        [CCUtil hideMBLoading];
//        [CCUtil showMBProgressHUDLabel:@"修改成功" detailLabelText:nil];
//        [defaults setBool:YES forKey:WQGZ_REFRESH];
//        [self.navigationController popViewControllerAnimated:YES];
//    }
//    else{
//        [CCUtil hideMBLoading];
//        [CCUtil showMBProgressHUDLabel:@"保存失败" detailLabelText:nil];
//        
//    }
//}
//
//-(void)requestFailed:(ASIHTTPRequest *)request{
//    [CCUtil hideMBLoading];
//    [CCUtil showMBProgressHUDLabel:@"保存失败" detailLabelText:nil];
//    
//}
//#pragma mark===table data
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(void)selfUserNo{
    for (int i=0; i<5; i++) {
        UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        Cell.userInteractionEnabled=NO;
    }
    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.userInteractionEnabled=NO;
        }
    }
}
-(void)selfUserYes{
    for (int i=0; i<5; i++) {
        UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        Cell.userInteractionEnabled=YES;
    }
    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    for (UIView *view in cell.contentView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.userInteractionEnabled=YES;
        }
    }
    
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==5) {
        return 180;
    }
    if (indexPath.row==1) {
        return 80;
    }
//    if (indexPath.row<=1) {
//        if ([[self.INFODIC objectForKey:contentArr[indexPath.row]]isKindOfClass:[NSNull class]]) {
//            return 45;
//            
//        }
//        NSString *text=[self.INFODIC objectForKey:contentArr[indexPath.row]];
//        
//        CGRect rect=[text boundingRectWithSize:CGSizeMake(kFullScreenSizeWidth-20, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:13]} context:nil];
//        return rect.size.height+45;
//        
//    }
//    content.returnKeyType = UIReturnKeyDone;
//
    return 40;
}
#pragma mark - textFieldDelegate
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (textField.tag == 3003) {
//        if (textField.text.length > 16) {
//            textField.text = [textField.text substringToIndex:16];
//        }
//    }
//    return YES;
//}
//
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    CGRect frame = textField.frame;
//    table.contentSize = CGSizeMake(0.0f, 50.0f);
//    
//    
//    NSTimeInterval animationDuration = 0.30f;
//    
//    [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
//    
//    [UIView setAnimationDuration:animationDuration];
//    
//    int offset = frame.origin.y+100- (self.view.frame.size.height - 216.0);//求出键盘顶部与textfield底部大小的距离
//    table.contentOffset = CGPointMake(0, -offset);
//    
//    [UIView commitAnimations];
//}
//-(BOOL)textFieldShouldReturn:(UITextField *)textField{
//    table.contentOffset = CGPointMake(0, 0);
//    [textField resignFirstResponder];
//    return YES;
//}
#pragma mark - scrollView
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    for (int i=0; i<5; i++) {
        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UITextField *tf=(UITextField *)[cell.contentView viewWithTag:3000+i];
        [tf resignFirstResponder];
    }
}
-(BOOL)textViewShouldBeginEditing:(UITextView *)textView{
    return NO;
}
#pragma mark - tableviewdelegate
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    }
    UILabel *labTitle=[[UILabel alloc]initWithFrame:CGRectMake(15, 10, 120, 30)];
    labTitle.text=titleArr[indexPath.row];
    labTitle.font=[UIFont systemFontOfSize:14];
    [cell.contentView addSubview:labTitle];
    [labTitle sizeToFit];
    if (indexPath.row<5) {
        
        content=[[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame), CGRectGetMinY(labTitle.frame)-5, kFullScreenSizeWidth-120, 30)];
        content.userInteractionEnabled  = NO;
        content.font=[UIFont systemFontOfSize:14];
        content.tag=indexPath.row+3000;
        content.delegate = self;
        content.returnKeyType = UIReturnKeyDefault;
        content.text=[[self.INFODIC objectForKey:contentArr[indexPath.row]] outString];
        [cell.contentView addSubview:content];
        if (indexPath.row == 1) {
            [content removeFromSuperview];
            
            UITextView *textView=[[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame)+5, kFullScreenSizeWidth-20, 30)];
             textView.tag=3000+indexPath.row;
            textView.contentInset=UIEdgeInsetsMake(-10, 0, 0, 0);
            textView.delegate  = self;
            textView.font = [UIFont systemFontOfSize:14];
            if ([[self.INFODIC objectForKey:contentArr[indexPath.row]]isKindOfClass:[NSNull class]]) {
                textView.text=@"";
                
            }else
            {
               
                NSString *text=[self.INFODIC objectForKey:contentArr[indexPath.row]];

                textView.text=text;
           
            }
                [cell.contentView addSubview:textView];
      }
    }
    else{
    
        for (int i=0; i<MIN(imageArr.count, 9); i++) {
            UIImageView *igv=[[UIImageView alloc]initWithFrame:CGRectMake(15+((i)%3)*100, 35+((i)/3)*60, 80, 50)];
            if ([imageArr[i]isKindOfClass:[NSString class]]) {
                NSString *str=imageArr[i];
                if([str rangeOfString:@"/opt"].location!=NSNotFound){
                    str=[imageArr[i]
                         stringByReplacingOccurrencesOfString:@"/opt" withString:@"http://117.78.42.226:8081"];
                }
                else
                    str=[imageArr[i]
                         stringByReplacingOccurrencesOfString:@"/outside" withString:@"http://117.78.42.226:8081/outside"];
                
                
                [igv setImageWithURL:[NSURL URLWithString:str] placeholderImage:[UIImage imageNamed:@"1.png"]];}
            if ([imageArr[i]isKindOfClass:[UIImage class]]) {
                [igv setImage:imageArr[i]];
            }
            igv.userInteractionEnabled=YES;
            UITapGestureRecognizer *single=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImage:)];
            igv.tag=109+i;
            [igv addGestureRecognizer:single];
            [cell.contentView addSubview:igv];
            
        }
 
    }
    return cell;
}

-(void)showImage:(UIGestureRecognizer *)recog{
    
    UIImageView *igv=(UIImageView *)recog.view;
    int l=igv.tag-109;
    UIView *view=[[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view.backgroundColor=[UIColor blackColor];
    view.tag=2901;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    UIScrollView *scr=[[UIScrollView alloc]initWithFrame:CGRectMake(0,40, kFullScreenSizeWidth, kFullScreenSizeHeght-80)];
    scr.pagingEnabled=YES;
    [scr setContentOffset:CGPointMake(kFullScreenSizeWidth*l, 0)];
    scr.contentSize=CGSizeMake(kFullScreenSizeWidth*imageArr.count, kFullScreenSizeHeght-80);
    scr.tag=2902;
    [[UIApplication sharedApplication].keyWindow addSubview:scr];
    UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]];
    
    for (int i=0; i<imageArr.count; i++) {
        
        UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(0+kFullScreenSizeWidth*i, 0,kFullScreenSizeWidth,CGRectGetHeight(scr.frame))];
        UIImageView *ig=(UIImageView *)[Cell.contentView viewWithTag:109+i];
        [image setImage:ig.image];
        image.tag=i+123;;
        image.userInteractionEnabled=YES;
        UITapGestureRecognizer *single=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hidden:)];
        
        [image addGestureRecognizer:single];
        [scr addSubview:image];
        if (i==l) {
            [UIView animateWithDuration:0.5 animations:^{
                image.frame =CGRectMake(0+kFullScreenSizeWidth*i, 0,kFullScreenSizeWidth,CGRectGetHeight(scr.frame));
            }];
        }
    }
    
}
-(void)hidden:(UIGestureRecognizer *)recognize{
    
    UIImageView *igv1=(UIImageView *)recognize.view;
    int closeIndex=igv1.tag-123;
    igv1.frame=CGRectOffset(igv1.frame, -320*closeIndex, 0);
    [[UIApplication sharedApplication].keyWindow addSubview:igv1];
    UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
    
    UIImageView *  igv=(UIImageView *)[Cell.contentView viewWithTag:closeIndex+109];
    
    
    CGRect final=[[UIApplication sharedApplication].keyWindow convertRect:igv.frame fromView:Cell.contentView];
    
    
    UIView *view=[[UIApplication sharedApplication].keyWindow viewWithTag:2901];
    [view removeFromSuperview];
    UIScrollView *scr=(UIScrollView *)[[UIApplication sharedApplication].keyWindow viewWithTag:2902];
    [scr removeFromSuperview];
    
    [UIView animateWithDuration:0.5 animations:^{
        igv1.frame=final;
    } completion:^(BOOL finished) {
        [igv1 removeFromSuperview];
    }];
    // [igv1 removeFromSuperview];
}



#pragma mark--pick delegate
//-(void)pickPhoto{
//    UIActionSheet *Act=[[UIActionSheet alloc]initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"照相",nil];
//    [Act showInView:self.view];
//    
//}
//-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
//    if (buttonIndex!=actionSheet.cancelButtonIndex) {
//
//        [self takePhoto];
//       
//    }
//}
//-(void)takePhoto{
//    if (imageArr.count==9) {
//        [CCUtil showMBProgressHUDLabel:@"已经存在9张图片"];
//        return;
//    }
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
//        [CCUtil showMBProgressHUDLabel:@"提示" detailLabelText:@"您的设备不支持拍照"];
//        return;
//    }
//    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
//    picker.delegate=self;
//    picker.allowsEditing=YES;
//    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
//    [self presentViewController:picker animated:YES completion:nil];
//    
//}
//-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
//    UIImage *origin=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
//    UIImage *finalImage=[CCUtil imageWithImage:origin scaledToSize:CGSizeMake(320, 480)];
//    [imageArr addObject:finalImage];
//    //    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
//    [self dismissViewControllerAnimated:YES completion:^{
//        [self updateUI];
//    }];
//    
//}
//-(void)pickFromLib{
//    
//    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
//        return;
//    }
//    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
//    picker.assetsFilter         = [ALAssetsFilter allAssets];
//    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
//    picker.delegate             = self;
//    picker.assetsFilter = [ALAssetsFilter allPhotos];
//    picker.maximumNumberOfSelection=9-imageArr.count;
//    [self presentViewController:picker animated:YES completion:nil];
//    
//}
//-(void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
//    
//    if ([assets count]>0) {
//        [self performSelectorInBackground:@selector(addImages:) withObject:assets];
//        [picker dismissViewControllerAnimated:YES completion:nil];
//    }
//    
//}
//- (void)addImages:(NSArray *)info
//{
//    for(ALAsset *dict in info) {
//        
//        UIImage *image =[UIImage imageWithCGImage:dict.thumbnail];
//        image=[CCUtil imageWithImage:image scaledToSize:CGSizeMake(320, 480)];
//        
//        [imageArr addObject:image];
//    }
//    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
//}
//- (void)updateUI
//{
//    [table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
//}
//
#pragma mark--table delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}


//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"%d",indexPath.row);
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    if (indexPath.row == 0) {
//        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
//        UITextView *tf0=(UITextView *)[cell.contentView viewWithTag:3000];
//        [tf0 becomeFirstResponder];
//    }
//    if (indexPath.row == 1) {
//        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
//        UITextView *tf1=(UITextView *)[cell.contentView viewWithTag:3000+1];
//        [tf1 becomeFirstResponder];
//    }
//    if (indexPath.row == 3) {
//        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
//        UITextField *tf3=(UITextField *)[cell.contentView viewWithTag:3000+3];
//        [tf3 becomeFirstResponder];
//    }
//    if (indexPath.row == 4) {
//        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]];
//        UITextField *tf4=(UITextField *)[cell.contentView viewWithTag:3000+4];
//        [tf4 becomeFirstResponder];
//    }
//
//    if (indexPath.row==2) {
//        [self.view endEditing:YES];
//        backGroundView=[[UIView alloc]initWithFrame:self.view.bounds];
//        backGroundView.backgroundColor=[UIColor whiteColor];
//        [self.view addSubview:backGroundView];
//        if (datePickerView) {
//            [datePickerView removeFromSuperview];
//        }
//        if ([self.view viewWithTag:2090]) {
//            [[self.view viewWithTag:2090 ]removeFromSuperview];
//        }
//        
//        
//        datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
//        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
//        datePickerView.frame=CGRectMake(10, 200, 300, 200);
//        [backGroundView addSubview:datePickerView];
//        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
//        [button setFrame:CGRectMake(CGRectGetMinX(datePickerView.frame)+90, CGRectGetMaxY(datePickerView.frame)-5, 120, 30)];
//        button.tag=2090;
//        button.backgroundColor=[UIColor redColor];
//        [button setTitle:@"确定" forState:UIControlStateNormal];
//        [button addTarget:self action:@selector(suretime) forControlEvents:UIControlEventTouchUpInside];
//        [backGroundView addSubview:button];
//    }
//    
//}
//-(void)suretime{
//    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
//    UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
//    NSDate *select = [datePickerView date];
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSString *dateAndTime =  [dateFormatter stringFromDate:select];
//    text.text=dateAndTime;
//    //[[self.view viewWithTag:2090]removeFromSuperview];
//    [backGroundView removeFromSuperview];
//}


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
