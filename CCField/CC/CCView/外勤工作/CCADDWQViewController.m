//
//  CCADDWQViewController.m
//  CCField
//
//  Created by 马伟恒 on 14-10-16.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCADDWQViewController.h"
#import "ASIHTTPRequest.h"
#import "CCUtil.h"
#import "ASIFormDataRequest.h"
#import "CTAssetsPickerController.h"
#import "MBProgressHUD.h"
#import <ImageIO/ImageIO.h>
#import <Photos/Photos.h>
#import "UIImage+STAddText.h"
@interface CCADDWQViewController ()<UITableViewDelegate,UITableViewDataSource,ASIHTTPRequestDelegate,CTAssetsPickerControllerDelegate,UINavigationControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UITextViewDelegate>
{
    NSMutableData *dataF;
    NSMutableArray *imageArr;
    NSArray *titleArr;
    UITableView *table;
    UIDatePicker *datePickerView;
    UIView *backGroundView;
    CGPoint center;
    NSString *fristStr;
    NSMutableArray *Arr;
    UITextField * tf0;
    UITextView * tf1;
    UITextField * tf2;
    UITextField * tf3;
    UITextField * tf4;
    BOOL cameraType;//是否是拍照模式
    NSArray *placeHolderArray;
    NSDateFormatter *dateFormatter;
    UIButton *buttonPicSelect;
}
@end
static NSString *cellIDENTI=@"cellid";

static const int  IMAGECOUNT=9;
@implementation CCADDWQViewController
//const void *imageTimekey = "imageTimeKey";

-(void)setBlock:(addSuccess)add{
    _addSuccessBlock = add;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.lableNav.text=@"外勤工作添加";
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    fristStr=@"";
    placeHolderArray=@[@"必填",@"必填",@"必填",@"必填(请输入所在城市)",@"必填(请输入详细地址)"];
    UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(kFullScreenSizeWidth-50, 22, 40, 40)];
    [button setTitle:@"提交" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(savePlan) forControlEvents:UIControlEventTouchUpInside];
    [self.imageNav addSubview:button];
    Arr=[NSMutableArray arrayWithObjects:@"",@"",@"",@"",@"",@"",nil];
    imageArr=[NSMutableArray array];
    titleArr=[NSArray arrayWithObjects:@"工作名称:",@"工作内容:",@"工作时间:",@"工作地点:",@"工作位置:",@"添加图片", nil];
    
    table=[[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame)) style:UITableViewStylePlain];
    [table registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIDENTI];
    table.delegate=self;
    table.dataSource=self;
    center=table.center;
    table.backgroundColor = [UIColor clearColor];
    
    table.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    table.tableFooterView=[[UIView alloc]initWithFrame:CGRectZero];
    [self.view addSubview:table];
    
}
-(void)savePlan{
    //    [datePickerView removeFromSuperview];
    //    [backGroundView removeFromSuperview];
    [self.view endEditing:YES];
    [UIView animateWithDuration:0.25 animations:^{
        self->table.center=self->center;
        self->table.contentOffset=CGPointZero;
        
    }];
    if (imageArr.count==0) {
        [CCUtil showMBProgressHUDLabel:@"请选择图片" detailLabelText:nil];
        return;
    }
    else{
        [CCUtil showMBLoading:@"正在提交" detailText:@"请稍候..."];
        NSDictionary *dic=@{@"workContent":tf1.text,@"workTime":Arr[2],@"workLocation":Arr[3],@"location":Arr[4],@"workTitle":Arr[0]};
        ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[workRecordAddUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
        [requset setTimeOutSeconds:20];
        NSArray *Array=[dic allKeys];
        for (int i=0; i<Array.count; i++) {
            [requset setPostValue:[dic objectForKey:Array[i]] forKey:Array[i]];
        }
        for (int i=0; i<imageArr.count; i++) {
            UIImage *image=imageArr[i];
            NSData *imagedata=UIImageJPEGRepresentation(image, 0.5);
            NSString *name=[NSString stringWithFormat:@"%@.jpg",[CCUtil currentStamp]];
            NSString *key=[NSString stringWithFormat:@"%d",i];
            [requset addData:imagedata withFileName:name andContentType:@"multipart/form-data;boundary=*****" forKey:key];
        }
        requset.delegate=self;
        [requset startAsynchronous];
        
    }
}
#pragma mark--ASI delegate
-(void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders{
    dataF=[NSMutableData data];
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    [dataF appendData:data];
    
}
-(void)requestFinished:(ASIHTTPRequest *)request{
    [CCUtil hideMBLoading];
    NSString *Str=[[NSString alloc]initWithData:dataF encoding:NSUTF8StringEncoding];
    if ([Str rangeOfString:@"true"].location!=NSNotFound) {
        [CCUtil showMBProgressHUDLabel:@"提交成功" detailLabelText:nil];
        if (_addSuccessBlock) {
            _addSuccessBlock();
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        [CCUtil showMBProgressHUDLabel:@"提交失败" detailLabelText:nil];
    }
    
}

-(void)requestFailed:(ASIHTTPRequest *)request{
    [CCUtil hideMBLoading];
    [CCUtil showMBProgressHUDLabel:@"提交失败" detailLabelText:nil];
    
}


#pragma mark--table
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==5) {
        return MIN(240, (imageArr.count/3+1)*70+30);
    }
    return 40;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell=[table dequeueReusableCellWithIdentifier:cellIDENTI forIndexPath:indexPath];
    cell.selectionStyle=UITableViewCellSelectionStyleNone;
    UILabel *labTitle=(UILabel *)[cell.contentView viewWithTag:333];
    if (!labTitle) {
        labTitle=[[UILabel alloc]initWithFrame:CGRectMake(20, 10, 120, 30)];
        labTitle.font=[UIFont boldSystemFontOfSize:14];
        labTitle.tag = 333;
        [cell.contentView addSubview:labTitle];
    }
  
    labTitle.text=titleArr[indexPath.row];
    [labTitle sizeToFit];
    CGRect rightRect =CGRectMake(CGRectGetMaxX(labTitle.frame)+5, CGRectGetMinY(labTitle.frame)-5, kFullScreenSizeWidth-120, 30);
    switch (indexPath.row) {
        case 0:
            if (!tf0) {
                tf0=[[UITextField alloc]initWithFrame:rightRect];
                tf0.font=[UIFont systemFontOfSize:14];
                tf0.tag=indexPath.row+3000;
                tf0.returnKeyType=UIReturnKeyDone;
                tf0.delegate=self;
                [cell.contentView addSubview:tf0];

            }
            tf0.placeholder = placeHolderArray[0];

            tf0.text = Arr[indexPath.row];
            if (fristStr.length>0) {
                tf0.text=fristStr;
            }
            
            break;
        case 1:
            if (!tf1) {
                tf1=[[UITextView alloc]initWithFrame:rightRect];
                tf1.font=[UIFont systemFontOfSize:14];
                tf1.tag=indexPath.row+3000;
                tf1.returnKeyType=UIReturnKeyDone;
                tf1.delegate=self;
                [cell.contentView addSubview:tf1];

            }
            tf1.text = placeHolderArray[1];
            tf1.textColor = [UIColor lightGrayColor];
            if ([Arr[indexPath.row]length]>0) {
                tf1.text = Arr[indexPath.row];
            }
            break;
        case 2:
        {
            // tf0.placeholder=@"工作时间(点击选择时间)";
            if (!tf2) {
                tf2=[[UITextField alloc]initWithFrame:rightRect];
                tf2.font=[UIFont systemFontOfSize:14];
                tf2.tag=indexPath.row+3000;
                tf2.returnKeyType=UIReturnKeyDone;
                tf2.delegate=self;
                [cell.contentView addSubview:tf2];

            }
            
            tf2.placeholder = placeHolderArray[2];
            if ([Arr[indexPath.row]length]>0) {
                tf2.text = Arr[indexPath.row];
            }
            tf2.userInteractionEnabled=NO;
            
        }
            break;
        case 3:
            tf3=[[UITextField alloc]initWithFrame:rightRect];
            tf3.font=[UIFont systemFontOfSize:14];
            tf3.tag=indexPath.row+3000;
            tf3.returnKeyType=UIReturnKeyDone;
            tf3.delegate=self;
            
            tf3.placeholder = placeHolderArray[3];
            if ([Arr[indexPath.row]length]>0) {
                tf3.text = Arr[indexPath.row];
            }
            
            [cell.contentView addSubview:tf3];
            
            break;
        case 4:{
            tf4=[[UITextField alloc]initWithFrame:rightRect];
            tf4.font=[UIFont systemFontOfSize:14];
            tf4.tag=indexPath.row+3000;
            tf4.returnKeyType=UIReturnKeyDone;
            tf4.delegate=self;
            
            tf4.placeholder = placeHolderArray[4];
            if ([Arr[indexPath.row]length]>0) {
                tf4.text = Arr[indexPath.row];
            }
            
            [cell.contentView addSubview:tf4];
            
        }
            break;
        case 5:
        {
//            for (UIView *view in cell.contentView.subviews) {
//                if ([view isKindOfClass:[UIImageView class]]) {
//                    [view removeFromSuperview];
//                 }
//            }
            
            for (int i=0; i<imageArr.count; i++) {
                UIImageView *igv=[[UIImageView alloc]initWithFrame:CGRectMake(20+(i%3)*100, 30+(i/3)*60, 80, 50)];
                igv.image = imageArr[i];
                igv.tag = 345+i;
                [cell.contentView addSubview:igv];
                UILongPressGestureRecognizer *delGes = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(delePic:)];
                igv.userInteractionEnabled = YES;
                [igv addGestureRecognizer:delGes];
             }
                 buttonPicSelect=[UIButton buttonWithType:UIButtonTypeCustom];
                [buttonPicSelect setImage:[UIImage imageNamed:@"选择"] forState:UIControlStateNormal];
                [buttonPicSelect addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:buttonPicSelect];
 
            buttonPicSelect.frame=CGRectMake(20+(imageArr.count%3)*100, 40+(imageArr.count/3)*60, 160/2,64/2);;
            if (imageArr.count==9) {
                buttonPicSelect.hidden=YES;
            }
            
        }
            break;
        default:
            break;
    }
 
    return cell;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 1) {
        [tf1 becomeFirstResponder];
    }
    if (indexPath.row == 0) {
        [tf0 becomeFirstResponder];
    }
    
    if (indexPath.row==2) {
        [self.view endEditing:YES];
        backGroundView=[[UIView alloc]initWithFrame:self.view.bounds];
        backGroundView.backgroundColor=[UIColor whiteColor];
        [self.view addSubview:backGroundView];
        
        
        datePickerView =[[UIDatePicker alloc] initWithFrame:CGRectZero];
        datePickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        datePickerView.datePickerMode = UIDatePickerModeDateAndTime;
        datePickerView.frame=CGRectMake(10, 150, 300, 200);
        [backGroundView addSubview:datePickerView];
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(CGRectGetMinX(datePickerView.frame)+30, CGRectGetMaxY(datePickerView.frame)+20, 120, 30)];
        button.tag=2090;
        button.backgroundColor=[UIColor redColor];
        [button setTitle:@"确定" forState:UIControlStateNormal];
        [button addTarget:self action:@selector(suretime) forControlEvents:UIControlEventTouchUpInside];
        [backGroundView addSubview:button];
    
        UIButton *button_cancel=[UIButton buttonWithType:UIButtonTypeCustom];
        [button_cancel setFrame:CGRectOffset(button.frame, 140, 0)];
        button_cancel.tag=2091;
        button_cancel.backgroundColor=[UIColor redColor];
        [button_cancel setTitle:@"取消" forState:UIControlStateNormal];
        [button_cancel addTarget:self action:@selector(cancelView) forControlEvents:UIControlEventTouchUpInside];
        [backGroundView addSubview:button_cancel];
    }
}
#pragma mark -- 删除图片
-(void)delePic:(UIGestureRecognizer *)regonize{
    if (imageArr.count==0) {
        return;
    }
    UIImageView *igv = (UIImageView *)regonize.view;
    NSInteger tagIndex = igv.tag - 345;
    [CCUtil shakeAnimationForView:igv];
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"确定删除这张图片？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
     
        [self->imageArr removeObjectAtIndex:tagIndex];
        [self updateUI];
    }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:sureAction];
    [alertController addAction:cancel];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark =other
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    //删除工作地点限制位数
    
    //    if (textField.tag == 3003) {
    //        if (textField.text.length > 16) {
    //            textField.text = [textField.text substringToIndex:16];
    //        }
    //    }
    //    return YES;
    id superview=[textField superview];
    while (![superview isKindOfClass:[UITableViewCell class]]) {
        superview=[superview superview];
    }
    UITableViewCell *cell=(UITableViewCell *)superview;
    NSIndexPath *index=[table indexPathForCell:cell];
    if (index.row==0) {
        if (textField.text.length==30) {
            return NO;
        }
    }
    NSArray *Arr1=@[@"➋",@"➌",@"➍",@"➎",@"➏",@"➐",@"➑",@"➒"];
    if ([Arr1 containsObject:string]) {
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



-(BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    [textField resignFirstResponder];
    id superview=[textField superview];
    while (![superview isKindOfClass:[UITableViewCell class]]) {
        superview=[superview superview];
    }
    UITableViewCell *cell=(UITableViewCell *)superview;
    NSIndexPath *index=[table indexPathForCell:cell];
    [Arr replaceObjectAtIndex:index.row withObject:textField.text];
    if (index.row<4) {
        if (index.row==0) {
            fristStr=textField.text;
        }
        return YES;
    }
    if (iPhone5) {
        return YES;
    }
    
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [UIView animateWithDuration:0.25 animations:^{
        self->table.center=self->center;
        self->table.contentOffset=CGPointZero;
    }];
    [textField resignFirstResponder];
    return YES;
}
#pragma mark - textFieldDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"必填"]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }

}
-(void)suretime{
    //    UITableViewCell *cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    //    UITextField *text=(UITextField *)[cell.contentView viewWithTag:3000+table.indexPathForSelectedRow.row];
    NSDate *select = [datePickerView date];
     NSString *dateAndTime =  [dateFormatter stringFromDate:select];
    tf2.text=dateAndTime;
    [Arr replaceObjectAtIndex:2 withObject:dateAndTime];
    //[[self.view viewWithTag:2090]removeFromSuperview];
    [backGroundView removeFromSuperview];
    
}
-(void)cancelView{
    [backGroundView removeFromSuperview];

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
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        self->cameraType = false;
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
    UIImage *origin=[info objectForKey:UIImagePickerControllerOriginalImage];
    UIImage *finalImage=[CCUtil imageWithImage:origin scaledToSize:CGSizeMake(kFullScreenSizeWidth, kFullScreenSizeHeght)];
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
      //    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self updateUI];
    }];
    
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
        image=[CCUtil imageWithImage:image scaledToSize:CGSizeMake(kFullScreenSizeWidth, kFullScreenSizeHeght)];
        [self getMetaByImage:image];
        
        
        [imageArr addObject:image];
        
    }
    //        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[self pictureSavedPath] atomically:YES];
    //        //Add the file path to the array, and insert a cell at the end of the tableview.
    //        [self.listData addObject:self.filePath];
    //    }
     [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
}
- (void)updateUI
{
    [table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:5 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
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
-(NSString *)getMetaByImage:(UIImage *)image{
    NSData *data = UIImageJPEGRepresentation(image, 1);
    CGImageSourceRef source = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    CFDictionaryRef imageMeta = CGImageSourceCopyPropertiesAtIndex(source, 0, NULL);
//    NSDictionary *metaDataInfo = CFBridgingRelease(imageMeta);
    
    CFDictionaryRef exif = CFDictionaryGetValue(imageMeta, kCGImagePropertyExifDictionary);
    
    //GPS dic
 //   CFDictionaryRef GPSDic = CFDictionaryGetValue(imageMeta, kCGImagePropertyGPSDictionary);
    
    
    CFRelease(source);
//    NSString *lat = (__bridge NSString*)CFDictionaryGetValue(GPSDic, kCGImagePropertyGPSLatitude);
//    NSString *lon = (__bridge NSString*)CFDictionaryGetValue(GPSDic, kCGImagePropertyGPSLongitude);
    
    
        //日期
        NSString *date = (__bridge NSString*)(CFDictionaryGetValue(exif, kCGImagePropertyExifDateTimeDigitized));
    
    return date;
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
