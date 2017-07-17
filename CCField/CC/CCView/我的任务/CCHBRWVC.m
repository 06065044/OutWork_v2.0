//
//  CCHBRWVC.m
//  CCField
//
//  Created by 马伟恒 on 14-10-14.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCHBRWVC.h"
#import "UIPopoverListView.h"
#import "ASIFormDataRequest.h"
#import "CCUtil.h"
#import "UIImageView+WebCache.h"
#import "CTAssetsPickerController.h"
#import "CCMyTaskViewController.h"
#import <Photos/Photos.h>
#import "UIImage+STAddText.h"

@interface CCHBRWVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,UIPopoverListViewDataSource,UIPopoverListViewDelegate,ASIHTTPRequestDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,UIActionSheetDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate>
{
    NSArray *titleArray;
    NSMutableData *dataF;
    NSMutableArray *imageArr;
    UITableView *table;
    //    UITextField *textView;
    BOOL cameraType;//是否是拍照模式
    NSDateFormatter *dateFormatter;
    NSString *str;
    NSString *processSTR;
    ASIFormDataRequest *requset;
}
@end

@implementation CCHBRWVC

static NSString *cellIDENTI=@"cellid";
-(void)returnBack{
    requset.delegate = nil;
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    str = [self.HBDIC objectForKey:@"status"];
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    imageArr=[NSMutableArray array];
    NSString *text=@"规定完成时间:";
    NSString *taskStatus = self.HBDIC[@"status"];
    if ([taskStatus isEqualToString:@"4"]||[taskStatus isEqualToString:@"3"]) {
        text=@"实际完成时间:";
    }
    if (![[self.HBDIC objectForKey:@"picPath"]isKindOfClass:[NSNull class]]) {
        imageArr=[NSMutableArray arrayWithArray:[[self.HBDIC objectForKeyedSubscript:@"picPath"]componentsSeparatedByString:@";"]];
        [imageArr removeLastObject];
        for (int i=0; i<imageArr.count; i++) {
            if ([imageArr[i]hasSuffix:@"/1.jpg"]) {
                [imageArr removeObjectAtIndex:i];
            }
        }
    }
    
    if ([text isEqualToString:@"规定完成时间:"]) {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
        [button setTitle:@"提交" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(saveTask:) forControlEvents:UIControlEventTouchUpInside];
        [self.imageNav addSubview:button];
        
    }
    
    titleArray=[NSArray arrayWithObjects:@"任务状态:", text,@"任务进度:",@"添加图片",nil];
    // Do any additional setup after loading the view from its nib.
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.backgroundColor = [UIColor clearColor];
    
    table.dataSource=self;
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];
    self.lableNav.text = @"汇报任务";
    if (!self.canEdit) {
        self.lableNav.text = @"任务明细";
        
    }
}
-(void)swapToUser:(UIButton *)btn{
    [btn setUserInteractionEnabled:YES];
}
-(void)saveTask:(UIButton *)button{
    [self.view endEditing:YES];
    NSMutableArray *Arr=[NSMutableArray array];
    
    for (int i=0; i<2; i++) {
        UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UILabel *lab=(UILabel *)[cell.contentView viewWithTag:3000+i];
        [Arr addObject:lab.text];
    }
    
    if ([processSTR length]==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请填写任务进度"];
        return;
    }
    button.userInteractionEnabled=NO;
    [self performSelectorOnMainThread:@selector(swapToUser:) withObject:button waitUntilDone:NO];
    
    [Arr addObject:processSTR];
    
    str=@"2";
    if ([Arr[0] isEqualToString:@"已完成"]){
        str = @"3";
    }
    if ([self.HBDIC[@"isHave"]isEqualToString:@"Y"]&&imageArr.count==0&&[str isEqualToString:@"3"]) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"此任务需要上传图片，请上传图片"];
        return;
    }
    
    NSString *saveUrl=@"http://117.78.42.226:8081/outside/dispatcher/issTask/updateTaskReply";
    
    NSDictionary *dic=@{@"id":[self.HBDIC objectForKey:@"id"],@"replyContent":processSTR,@"status":str,@"finishTime":Arr[1]};
     requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:saveUrl]];
    [requset setTimeOutSeconds:40];
    for (int i=0; i<dic.allKeys.count; i++) {
        [requset setPostValue:[dic objectForKey:dic.allKeys[i]] forKey:dic.allKeys[i]];
    }
    for (int i=0; i<imageArr.count; i++) {
        UIImage *image=nil;
        if ([imageArr[i]isKindOfClass:[NSString class]]) {
            //             image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/outside" withString:@"http://117.78.42.226:8081/outside"]]]];
            
            NSString *str2=imageArr[i];
            
            if([str2 rangeOfString:@"/opt"].location!=NSNotFound){
                
                
                image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/opt" withString:@"http://117.78.42.226:8081"]]]];
                
            }
            else
                image=[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[imageArr[i]stringByReplacingOccurrencesOfString:@"/outside" withString:@"http://117.78.42.226:8081/outside"]]]];
        }
        else
            image=imageArr[i];
        NSData *imagedata=UIImageJPEGRepresentation(image, 0.5);
        NSString *name=[NSString stringWithFormat:@"%@.jpg",[CCUtil currentStamp]];
        NSString *key=[NSString stringWithFormat:@"%d",i];
        [requset addData:imagedata withFileName:name andContentType:@"multipart/form-data;boundary=*****" forKey:key];
    }
    requset.delegate=self;
    [requset startAsynchronous];
}
#pragma mark--ASI delegate
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    NSLog(@"%@",responseHeaders);
    dataF=[NSMutableData data];
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    [dataF appendData:data];
    
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    NSLog(@"%@",request.responseString);
    NSString *Str=[[NSString alloc]initWithData:dataF encoding:NSUTF8StringEncoding];
    if ([Str rangeOfString:@"true"].location!=NSNotFound) {
        [CCUtil showMBProgressHUDLabel:@"提交成功" detailLabelText:nil];
        [defaults setBool:YES forKey:TASK_REFRESH];
        NSArray *vcAr = self.navigationController.viewControllers;
        [self.navigationController popToViewController:vcAr[vcAr.count-3]  animated:YES];
    }
    else{
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:dataF options:NSJSONReadingMutableLeaves error:nil];
        NSString *Str = dic[@"message"];
        if ([Str isKindOfClass:[NSNull class]]||[Str length]<4) {
            Str=@"提交失败,请再试一次";
        }
        [CCUtil showMBProgressHUDLabel:Str detailLabelText:nil];
    }
}
-(void)requestFailed:(ASIHTTPRequest *)request{
    [CCUtil showMBProgressHUDLabel:@"提交失败" detailLabelText:nil];
}

#pragma mark--data source
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    //    for (UIView *view in cell.contentView.subviews) {
    //        [view removeFromSuperview];
    //    }
    UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(10, 8,100 , 25)];
    lab.text=titleArray[indexPath.row];
    lab.font = [UIFont boldSystemFontOfSize:14];
    [cell.contentView addSubview:lab];
    CGRect rightRect =  CGRectMake(CGRectGetMaxX(lab.frame), CGRectGetMinY(lab.frame)-3, kFullScreenSizeWidth-CGRectGetMaxX(lab.frame), 30);
    if (indexPath.row==0) {
        UILabel *la1b=[[UILabel alloc]initWithFrame:rightRect];
        la1b.font = [UIFont boldSystemFontOfSize:14];
        la1b.textColor = [UIColor grayColor];
        
        la1b.text=@"进行中";
        if ([[self.HBDIC objectForKey:@"status"]intValue]-3>=0) {
            la1b.text=@"已完成";
        }
        if ([[self.HBDIC objectForKey:@"status"]intValue]==-1) {
            la1b.text=@"延时";
            
        }
        la1b.tag=3000+indexPath.row;
        [cell.contentView addSubview:la1b];
        
        
        
    }
    else if (indexPath.row==1) {
        UILabel *la1b=[[UILabel alloc]initWithFrame:rightRect];
        la1b.text=[[self.HBDIC objectForKey:@"setTime"] outString];
        //        la1b.font = [UIFont systemFontOfSize:14];
        la1b.font = [UIFont boldSystemFontOfSize:14];
        la1b.textColor = [UIColor grayColor];
        
        if ([[self.HBDIC objectForKey:@"status"]intValue]-3>=0) {
            [[self.HBDIC objectForKey:@"finishTime"] outString];
        }
        la1b.tag=3000+indexPath.row;
        [cell.contentView addSubview:la1b];
    }
    else if (indexPath.row==2){
        
        UITextField *textView=[[UITextField alloc]initWithFrame:rightRect];
        textView.borderStyle=UITextBorderStyleNone;
        textView.tag=3000+indexPath.row;
        textView.returnKeyType=UIReturnKeyDone;
        textView.delegate=self;
        textView.font = [UIFont boldSystemFontOfSize:14];
        textView.text=[[self.HBDIC objectForKey:@"replyContent"]outString];
        processSTR = textView.text;
        [cell.contentView addSubview:textView];
        
        
    }
    else{
        
        for (int i=0; i<imageArr.count; i++) {
            UIImageView *igv=[[UIImageView alloc]initWithFrame:CGRectMake(10+(i%3)*100, 30+(i/3)*60, 80, 50)];
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
            if ([[self.HBDIC objectForKey:@"status"]intValue]<3) {
                //未完成，添加删除手势
                UILongPressGestureRecognizer *delGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(delePic:)];
                igv.userInteractionEnabled = YES;
                [igv addGestureRecognizer:delGes];
            }
        }
        
        if ([[self.HBDIC objectForKey:@"status"]intValue]<3) {//表示未完成
            UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
            //  [button setTitle:@"选择" forState:UIControlStateNormal];
            [button setImage:[UIImage imageNamed:@"选择"] forState:UIControlStateNormal];
            //  button.backgroundColor=[UIColor redColor];
            button.frame=CGRectMake(10+(imageArr.count%3)*100, 40+(imageArr.count/3)*60, 160/2,64/2);;
            [button addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
            if (imageArr.count==9) {
                button.hidden=YES;
            }
            [cell.contentView addSubview:button];
            
        }
    }
    return cell;
}
#pragma mark -- 删除图片

-(void)delePic:(UIGestureRecognizer *)reco{
    
    if (imageArr.count==0) {
        return;
    }
    UIImageView *igv=(UIImageView *)reco.view;
    NSInteger index =igv.tag-109;
    [CCUtil shakeAnimationForView:igv];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除这张图片？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self->imageArr removeObjectAtIndex:index];
        [self updateUI];
        
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
    
}
#pragma mark -- 展示大图
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
    UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
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
    
    [UIView animateWithDuration:0.2 animations:^{
        igv1.frame=final;
    } completion:^(BOOL finished) {
        [igv1 removeFromSuperview];
    }];
    // [igv1 removeFromSuperview];
}

#pragma mark--pick delegate
-(void)takePhoto{
    [self.view endEditing:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.allowsEditing = NO;
    picker.delegate  = self;
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //action我的
    UIAlertAction *carMine = [UIAlertAction actionWithTitle:@"相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            //
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"您的设备不支持拍照"];
            return ;
        }
        self->cameraType = true;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
        
    }];
    UIAlertAction *actionTeam = [UIAlertAction actionWithTitle:@"相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        self->cameraType = false;
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:picker animated:YES completion:nil];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:carMine];
    [alertVC addAction:actionTeam];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    UIImage *origin=[info objectForKey:@"UIImagePickerControllerOriginalImage"];
    UIImage *finalImage=[CCUtil imageWithImage:origin scaledToSize:CGSizeMake(320, 480)];
    //    [imageArr addObject:finalImage];
    if (cameraType) {
        //相机
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        UIImage *result = [finalImage watermarkImage:date];
        [imageArr addObject:result];
    }
    else{
        //相册
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        NSString *createTime = [dateFormatter stringFromDate:asset.creationDate];
        UIImage *result = [finalImage watermarkImage:createTime];
        [imageArr addObject:result];
    }
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateUI];
    }];
    
}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=actionSheet.cancelButtonIndex) {
        switch (buttonIndex) {
            case 0:
                [self takeCamera];
                break;
            case 1:
                [self pickPhoto];
                break;
            default:
                break;
        }
    }
}
-(void)pickPhoto{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        return;
    }
    
    CTAssetsPickerController *picker = [[CTAssetsPickerController alloc] init];
    picker.assetsFilter         = [ALAssetsFilter allAssets];
    picker.showsCancelButton    = (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad);
    picker.delegate             = self;
    picker.assetsFilter = [ALAssetsFilter allPhotos];
    picker.maximumNumberOfSelection=9-imageArr.count;
    [self presentViewController:picker animated:YES completion:nil];
}
-(void)assetsPickerController:(CTAssetsPickerController *)picker didFinishPickingAssets:(NSArray *)assets{
    
    if ([assets count]>0) {
        [self performSelectorInBackground:@selector(addImages:) withObject:assets];
        [picker dismissViewControllerAnimated:YES completion:nil];
    }
    
}
- (void)addImages:(NSArray *)info
{
    for(ALAsset *dict in info) {
        
        UIImage *image =[UIImage imageWithCGImage:dict.thumbnail];
        image=[CCUtil imageWithImage:image scaledToSize:CGSizeMake(320, 480)];
        
        [imageArr addObject:image];
        
    }
    
    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}
- (void)updateUI
{
    [table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
}
-(void)takeCamera{
    if (imageArr.count==9) {
        [CCUtil showMBProgressHUDLabel:@"已经存在9张图片"];
        return;
    }
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [CCUtil showMBProgressHUDLabel:@"提示" detailLabelText:@"您的设备不支持拍照"];
        return;
    }
    UIImagePickerController *picker=[[UIImagePickerController alloc]init];
    picker.delegate=self;
    picker.allowsEditing=YES;
    picker.sourceType=UIImagePickerControllerSourceTypeCamera;
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark--table delegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==3) {
        return MIN(240, (imageArr.count/3+1)*70+30);
    }
    return 40;
    
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //取消选中效果
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (!self.canEdit) {
        return;
    }
    //当在第一行并且显示为非超时时，才可以弹框选择完成未完成
    if (indexPath.row == 0) {
        if ([[self.HBDIC objectForKey:@"status"]intValue]!=3) {
            [self showList];
        }
    }
    //    if (indexPath.row==2) {
    //        [textView becomeFirstResponder];
    //        table.contentOffset = CGPointMake(0, );
    //    }
}
//-(void)textFieldDidBeginEditing:(UITextField *)textField{
//    CGRect frame = textField.frame;
//
//
//    NSTimeInterval animationDuration = 0.30f;
//
//    [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
//
//    [UIView setAnimationDuration:animationDuration];
//
//    int offset = frame.origin.y+60- (self.view.frame.size.height - 216.0);//求出键盘顶部与textfield底部大小的距离
//    table.contentOffset = CGPointMake(0, -offset);
//
//    [UIView commitAnimations];
//}

-(void)showList{
    CGFloat xWidth = self.view.bounds.size.width - 20.0f;
    CGFloat yHeight = 150;
    CGFloat yOffset = (self.view.bounds.size.height - yHeight)/2.0f;
    UIPopoverListView *poplistview = [[UIPopoverListView alloc] initWithFrame:CGRectMake(10, yOffset, xWidth, yHeight)];
    poplistview.delegate = self;
    poplistview.datasource = self;
    poplistview.listView.scrollEnabled = FALSE;
    [poplistview setTitle:@"状态选择"];
    [poplistview show];
    
}
#pragma mark ---textfiled
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    return self.canEdit;
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    table.contentOffset = CGPointMake(0, 0);
    [textField resignFirstResponder];
    return YES;
}
-(void)textFieldDidEndEditing:(UITextField *)textField{
    processSTR = textField.text;
}

//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//
//
//    [textField setText:[self disable_emoji:string]];
//    return YES;
//}

- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}
#pragma mark-fieldend
#pragma mark--poplistdatasource
-(UITableViewCell *)popoverListView:(UIPopoverListView *)popoverListView cellForIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier=@"cell";
    UITableViewCell *cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    if (indexPath.row==0) {
        cell.textLabel.text=@"未完成";
    }
    if (indexPath.row==1) {
        cell.textLabel.text=@"已完成";
    }
    return cell;
}
-(NSInteger)popoverListView:(UIPopoverListView *)popoverListView numberOfRowsInSection:(NSInteger)section{
    return 2;
}
#pragma mark--delegate
-(CGFloat)popoverListView:(UIPopoverListView *)popoverListView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60.0f;
}
-(void)popoverListView:(UIPopoverListView *)popoverListView didSelectIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"%s",__func__);
    
    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    if (indexPath.row==0) {
        [((UILabel *)[cell.contentView viewWithTag:3000]) setText:@"未完成"];
        
    }
    else
        [((UILabel *)[cell.contentView viewWithTag:3000]) setText:@"已完成"];
    
    
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
