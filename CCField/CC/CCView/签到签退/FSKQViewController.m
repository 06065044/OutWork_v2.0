//
//  FSKQViewController.m
//  FastSale
//
//  Created by 马伟恒 on 15/8/12.
//  Copyright (c) 2015年 马伟恒. All rights reserved.
//

#import "FSKQViewController.h"
#import "Util.h"
#import "ASIFormDataRequest.h"
#import "CCUtil.h"
#import "UIImageView+WebCache.h"
#import "UUDatePicker.h"
#import "NSObject+CC0utString.h"
#import <Photos/Photos.h>
#import "UIImage+STAddText.h"

@interface FSKQViewController ()<UIImagePickerControllerDelegate,UINavigationControllerDelegate,ASIHTTPRequestDelegate,UITextViewDelegate,UIAlertViewDelegate,UITableViewDelegate,UITableViewDataSource>
{
    UIButton *picButton;
    NSMutableArray *picArray;
    NSMutableData *dataF;
    CGRect origin1;
    UIImageView *currentSelectIgv;
    NSInteger currentIndexSelect;
    NSArray *titleArray;
    NSArray *keyArray;
    UITableView *table;
    UITextField *signContent;
    NSInteger OprateionFlag;
    UITextView *textField ;
    NSString *selectedTime;
    BOOL cameraType;//是否是拍照模式
    NSDateFormatter *dateFormatter;
    
}

@end
static const NSInteger BOOKMARK_WORD_LIMIT=50;
@implementation FSKQViewController

-(void)changeColor:(UILabel *)lab{
    NSString *text=[lab text];
    NSMutableAttributedString *attri=[[NSMutableAttributedString alloc]initWithString:text];
    NSRange range=[text rangeOfString:@"*"];
    [attri addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    [lab setAttributedText:attri];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    OprateionFlag = 374;
    picArray=[NSMutableArray array];
    // Do any additional setup after loading the view.
    self.lableNav.text=@"原因说明";
    titleArray = @[@"打卡时间:",@"打卡地点:",@"异常说明:"];
    if (self.normal) {
        //正常查看
        self.lableNav.text = @"考勤信息查看";
        titleArray=@[@"打卡时间:",@"打卡地点:"];
    }
    //主ui
    table = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self
                                                                                                                                                         .imageNav.frame)) style:UITableViewStylePlain];
    table.delegate = self;
    table.dataSource = self;
    table.backgroundColor = [UIColor clearColor];
    [self.view addSubview:table];
    table.tableFooterView = [[UIView alloc]initWithFrame:CGRectZero];
    if (self.infoDic) {
        NSDictionary *dic=@{@"0":@"审核中",@"1":@"通过",@"2":@"拒绝"};
        table.tableFooterView = ({
            UIView *view= [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 30)];
            view.backgroundColor = [UIColor whiteColor];
            UIView *upLine = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth, 1)];
            upLine.backgroundColor = [UIColor lightGrayColor];
            [view addSubview:upLine];
            
            UILabel *lab = [[UILabel alloc]initWithFrame:CGRectMake(20, 1, kFullScreenSizeWidth-40, 29)];
            [view addSubview:lab];
            lab.text = dic[self.infoDic[@"confirmFlag"]];
            view;
        });
    }
    
    UIButton *setButton=[UIButton buttonWithType:UIButtonTypeCustom];
    setButton.frame=CGRectMake(20, kFullScreenSizeHeght-60, kFullScreenSizeWidth-40, 30);
    [setButton setTitle:@"提交" forState:UIControlStateNormal];
    setButton.layer.cornerRadius = 5;
    [setButton setBackgroundColor:self.imageNav.backgroundColor];
    [setButton addTarget:self action:@selector(submit:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:setButton];
    if (self.normal) {
        [setButton removeFromSuperview];
    }
    
    NSArray *titleAr = @[@"缺勤",@"早退",@"迟到"];
    if (![titleAr containsObject:self.btnString]) {
        [setButton removeFromSuperview];
        if (![self.btnString isEqualToString:@"审核中"]) {
            return;
        }
        UIButton *more = [UIButton buttonWithType:UIButtonTypeCustom];
        more.frame = CGRectMake(kFullScreenSizeWidth-60, 30, 40, 30);
        [more setTitle:@"更多" forState:UIControlStateNormal];
        [self.view addSubview:more];
        [more addTarget:self action:@selector(morechoice) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
}
#pragma mark - 显示日历
-(void)showDatePicker{
    UITableViewCell *Cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextField *timeTF = (UITextField*)[Cell.contentView viewWithTag:333];
      
    UUDatePicker *datePicker = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, kFullScreenSizeWidth, 200) PickerStyle:UUDateStyle_HourMinute didSelected:^(NSString *year, NSString *month, NSString *day, NSString *hour, NSString *minute, NSString *weekDay) {
        //返回的时间
        self->selectedTime = [NSString stringWithFormat:@"%@ %@:%@:00",[[NSUserDefaults standardUserDefaults] objectForKey:@"timeTitle"],hour,minute];
        timeTF.text = self->selectedTime;
    }];
    timeTF.inputView = datePicker;
}
//TODO: 更多包括删除和修改
-(void)morechoice{
    NSString *idStr = self.singRecordId;
       UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    //action我的
    UIAlertAction *carMine = [UIAlertAction actionWithTitle:@"提交" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSString *location = self->textField.text;
        NSDictionary *dic =@{@"type":@"0",@"id":idStr,@"signContent":self->signContent.text,@"time":self->selectedTime,@"location":location};
        
        NSString *urlStr = signExplainUpdate;
        if ([self.infoDic[@"addFlag"]intValue]==1) {
            //添加
            urlStr=signInOrOutUrl;
            NSString *sign_checkType=self.btnIndex%2==0?@"1":@"0";
            NSString *times = self.btnIndex>2?@"2":@"1";
            NSString *location = self->textField.text;
            dic= @{@"type":@"1",@"checkType":sign_checkType,@"location":location?location:@"北京市海淀区",@"times":times,@"time":self->selectedTime,@"signContent":self->signContent.text};
        }
        ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:urlStr  ]];
        //[requset setTimeOutSeconds:20];
        [requset setTimeOutSeconds:10];
         for (NSString *key in dic.allKeys) {
            [requset setPostValue:dic[key] forKey:key];
        }
        for (int i=0; i<self->picArray.count; i++) {
            NSData *imagedata;
            if ([self->picArray[i] isKindOfClass:[UIImage class]]) {
                UIImage *image=self->picArray[i];
                imagedata=UIImageJPEGRepresentation(image, 0.5);
                
            }
            else if ([self->picArray[i]isKindOfClass:[NSString class]]){
                NSString *string_url = [@"http://117.78.42.226:8081" stringByAppendingString:self->picArray[i]];
                imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:string_url]];
            }
            
            NSString *name=[NSString stringWithFormat:@"%@.jpg",[CCUtil currentStamp]];
            NSString *key=[NSString stringWithFormat:@"%d",i];
            [requset addData:imagedata withFileName:name andContentType:@"multipart/form-data;boundary=*****" forKey:key];
        }
        requset.delegate=self;
        [requset startAsynchronous];
    }];
    UIAlertAction *actionTeam = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
       
       //addFlag =1 补签删除， add = 0   异常删除
         NSDictionary *dic =@{@"id":idStr};
        NSString *urlStr = [[CCUtil basedString:singDeleteUrl withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        if ([self.infoDic[@"addFlag"] intValue]==0) {
            dic= @{@"type":@"1",@"id":idStr};
            urlStr = [[CCUtil basedString:signExplainUpdate withDic:dic]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
         }
        ASIHTTPRequest *request = [ASIHTTPRequest requestWithURL:[NSURL URLWithString:urlStr]];
        [request setTimeOutSeconds:20];
        [request setRequestMethod:@"GET"];
          [request startSynchronous];
        NSString *responString = request.responseString;
        if ([responString rangeOfString:@"true"].location!=NSNotFound) {
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"删除成功"];
            [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshKQ" object:nil];
            [self.navigationController popViewControllerAnimated:YES];
        }
        else{
            [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请求失败"];
        }
     }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:carMine];
    [alertVC addAction:actionTeam];
    [alertVC addAction:cancel];
    
    [self presentViewController:alertVC animated:YES completion:^{
        
    }];
    
}
#pragma mark == table
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (self.normal) {
        return 2;
    }
    return 4;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row<3) {
        return 40;
    }
    return 120 + MIN(2, (picArray.count/3))*80;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *Cell  = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TWO"];
    
    for (UIView *viewA in Cell.contentView.subviews) {
        [viewA removeFromSuperview];
    }
    if (indexPath.row<3) {
        UILabel *labTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 70, 40)];
        labTitle.text = titleArray[indexPath.row];
        labTitle.font = [UIFont systemFontOfSize:14];
        [Cell.contentView addSubview:labTitle];
        
        if (indexPath.row!=1) {
            UITextField *tf= [[UITextField alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame), 0, kFullScreenSizeWidth-100, 40)];
            tf.delegate=self;
            tf.tag = 333+indexPath.row;
            tf.font = labTitle.font;
            [Cell.contentView addSubview:tf];
            if (self.infoDic) {
                //存在值
                if (indexPath.row==0) {
                    tf.text = [self.infoDic[@"signTime"]outString];
                    selectedTime = [tf.text stringByAppendingString:@":00"];
                    tf.userInteractionEnabled = false;
                    if ([self.infoDic[@"addFlag"] intValue]==1) {
                        tf.userInteractionEnabled   = YES;
                    }

                }
                if (indexPath.row==2) {
                    tf.text = [self.infoDic[@"signContent"]outString];
                
                }
            }
            if (indexPath.row==2) {
                signContent = tf;
            }
            
        }else{
            
            textField  = [[UITextView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(labTitle.frame), 0, kFullScreenSizeWidth-100, 40)];
            textField.delegate = self;
            textField.tag = 333+indexPath.row;
            textField.font = labTitle.font;
            [Cell.contentView addSubview:textField];
            if (self.infoDic) {
                textField.text= self.infoDic[@"location"];
                textField.userInteractionEnabled  = false;
                if ([self.infoDic[@"addFlag"] intValue]==1) {
                    textField.userInteractionEnabled   = YES;
                }
            }
            
        }
    }
    if (indexPath.row==3) {
        for (UIView *igv in Cell.contentView.subviews) {
                 [igv removeFromSuperview];
            
        }
         UILabel *   labTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 40)];
            labTitle.text = @"上传图片";
            labTitle.font = [UIFont systemFontOfSize:14];
            labTitle.tag = 373;
            [Cell.contentView addSubview:labTitle];
     
   
       
            picButton = [UIButton buttonWithType:UIButtonTypeCustom];
            picButton.frame = CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), 80, 60);
            origin1=CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), 80, 60);
            [Cell.contentView addSubview:picButton];
            [picButton setImage:[UIImage imageNamed:@"图片添加"] forState:UIControlStateNormal];
            [picButton addTarget:self action:@selector(takePic) forControlEvents:UIControlEventTouchUpInside];

        
        if ([self.infoDic[@"picPath"]respondsToSelector:@selector(componentsSeparatedByString:)]) {
            if (picArray.count==0) {
                picArray = [[self.infoDic[@"picPath"] componentsSeparatedByString:@";"]mutableCopy];
                [picArray removeLastObject];
            }
         
            
        }
        [self updateUI];
    }
    
    return Cell;
}
#pragma mark -- textfiled
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    if (textField.tag==333) {
        [self showDatePicker];
       
    }
    return YES;
}

#pragma mark ==textview


-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    if (textView.text.length>=BOOKMARK_WORD_LIMIT) {
        if ([text isEqualToString:@""]) {
            return YES;
        }
        return NO;
    }
    return YES;
}
-(void)textViewDidChange:(UITextView *)textView{
    
    if (textView.text.length>=BOOKMARK_WORD_LIMIT) {
        textView.text=[textView.text substringToIndex:BOOKMARK_WORD_LIMIT];
    }
    
}
-(void)textViewDidBeginEditing:(UITextView *)textView{
    if ([textView.text isEqualToString:@"原因说明"]) {
        [textView setText:@""];
    }
    textView.textColor=[UIColor blackColor];
    
}

-(void)takePic{
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
        self->cameraType =false;
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
    UIImage *finalImage=[CCUtil imageWithImage:origin scaledToSize:CGSizeMake(kFullScreenSizeWidth, kFullScreenSizeHeght)];
//    [picArray addObject:finalImage];
    
    if (cameraType) {
        //相机
        NSString *date = [dateFormatter stringFromDate:[NSDate date]];
        UIImage *result = [finalImage watermarkImage:date];
        [picArray addObject:result];
    }
    else{
        //相册
        NSURL *url = [info objectForKey:UIImagePickerControllerReferenceURL];
        PHFetchResult *fetchResult = [PHAsset fetchAssetsWithALAssetURLs:@[url] options:nil];
        PHAsset *asset = fetchResult.firstObject;
        NSString *createTime = [dateFormatter stringFromDate:asset.creationDate];
        UIImage *result = [finalImage watermarkImage:createTime];
        [picArray addObject:result];
    }

    //    [self performSelectorOnMainThread:@selector(updateUI) withObject:nil waitUntilDone:YES];
    [self dismissViewControllerAnimated:YES completion:^{
        [self->table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:3 inSection:0]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
}
- (void)updateUI
{
    picButton.hidden=NO;
 
    CGFloat originX=CGRectGetMinX(origin1);
    CGFloat originY=CGRectGetMinY(origin1);
    for (int li=0; li<picArray.count; li++) {
        UIImageView *igv=[[UIImageView alloc]initWithFrame: CGRectMake(originX+100*(li%3), originY+80*(li/3), 80, 60)];
         if ([picArray[li] isKindOfClass:[UIImage class]]) {
            igv.image=picArray[li];
        }
        else if ([picArray[li] isKindOfClass:[NSString class]]){
            if ([picArray[li] length]<3) {
                continue;
            }
            NSString *string_url = [@"http://117.78.42.226:8081" stringByAppendingString:picArray[li]];
            [igv setImageWithURL:[NSURL URLWithString:string_url] placeholderImage:nil];
        }
       // if ([self.lableNav.text isEqualToString: @"原因说明"]) {
            //可以删除
            UILongPressGestureRecognizer *dele=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(dele:)];
            [igv addGestureRecognizer:dele];
//        }
//        else{
            //可以查看
             UITapGestureRecognizer *single=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showImage:)];
            [igv addGestureRecognizer:single];
       // }
        igv.userInteractionEnabled=YES;
        igv.tag=9000+li;
        [picButton.superview addSubview:igv];
    }
    if (picArray.count==9) {
        picButton.hidden=YES;
    }else
        [picButton setFrame:CGRectMake(originX+100*(picArray.count%3),originY+80*(picArray.count/3), 80, 60)];
}
#pragma mark -- 展示大图
-(void)showImage:(UIGestureRecognizer *)recog{
    
    UIImageView *igv=(UIImageView *)recog.view;
    int l=igv.tag-9000;
    UIView *view=[[UIView alloc]initWithFrame:[UIApplication sharedApplication].keyWindow.bounds];
    view.backgroundColor=[UIColor blackColor];
    view.tag=2901;
    [[UIApplication sharedApplication].keyWindow addSubview:view];
    UIScrollView *scr=[[UIScrollView alloc]initWithFrame:CGRectMake(0,40, kFullScreenSizeWidth, kFullScreenSizeHeght-80)];
    scr.pagingEnabled=YES;
    [scr setContentOffset:CGPointMake(kFullScreenSizeWidth*l, 0)];
    scr.contentSize=CGSizeMake(kFullScreenSizeWidth*picArray.count, kFullScreenSizeHeght-80);
    scr.tag=2902;
    [[UIApplication sharedApplication].keyWindow addSubview:scr];
    UITableViewCell *Cell=[table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
    
    for (int i=0; i<picArray.count; i++) {
        
        UIImageView *image=[[UIImageView alloc]initWithFrame:CGRectMake(0+kFullScreenSizeWidth*i, 0,kFullScreenSizeWidth,CGRectGetHeight(scr.frame))];
        UIImageView *ig=(UIImageView *)[Cell.contentView viewWithTag:9000+i];
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
    
    UIImageView *  igv=(UIImageView *)[Cell.contentView viewWithTag:closeIndex+9000];
    
    
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

#pragma mark -- 删除图片
-(void)dele:(UIGestureRecognizer *)ges{
    if (picArray.count==0) {
        return;
    }
    currentSelectIgv=(UIImageView *)ges.view;
    [CCUtil shakeAnimationForView:currentSelectIgv];
    currentIndexSelect=currentSelectIgv.tag-9000;
    [currentSelectIgv addSubview:({
        UIButton *igv=[UIButton buttonWithType:UIButtonTypeCustom];
        [igv setImage:[UIImage imageNamed:@"deBack"] forState:UIControlStateNormal];
        [igv setFrame:CGRectMake(-5, -5, 20, 20)];
        igv.tag=1111;
        //        igv.backgroundColor=[UIColor lightGrayColor];
        //        igv.layer.cornerRadius=20/2.;
        [igv addTarget:self action:@selector(alertShow:) forControlEvents:UIControlEventTouchUpInside];
        igv;
    })];
    
}
-(void)alertShow:(UIButton *)btn{
    currentSelectIgv=(UIImageView *)[btn superview];
    currentIndexSelect=currentSelectIgv.tag-9000;
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"提示" message:@"确认删除该图片" delegate:self  cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    alert.tag=3773;
    [alert show];
    
}
#pragma mark == uialertview
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (OprateionFlag == alertView.tag) {
        //右上角的操作按钮
        if (buttonIndex!=alertView.cancelButtonIndex) {
            if (buttonIndex == 0) {
                //更多
            }
        }
        
        
        
        return;
    }
    
    
    
    if (buttonIndex!=alertView.cancelButtonIndex) {
        if (alertView.tag==3773) {
            //表示图片
            [picArray removeObjectAtIndex:currentIndexSelect];
            UITableViewCell *Cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]];
            for (UIView *igv in Cell.contentView.subviews) {
                [igv removeFromSuperview];
                
            }
            UILabel *   labTitle = [[UILabel alloc]initWithFrame:CGRectMake(20, 0, 80, 40)];
            labTitle.text = @"上传图片";
            labTitle.font = [UIFont systemFontOfSize:14];
            labTitle.tag = 373;
            [Cell.contentView addSubview:labTitle];
            
            
            
            picButton = [UIButton buttonWithType:UIButtonTypeCustom];
            picButton.frame = CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), 80, 60);
            origin1=CGRectMake(CGRectGetMinX(labTitle.frame), CGRectGetMaxY(labTitle.frame), 80, 60);
            [Cell.contentView addSubview:picButton];
            [picButton setImage:[UIImage imageNamed:@"图片添加"] forState:UIControlStateNormal];
            [picButton addTarget:self action:@selector(takePic) forControlEvents:UIControlEventTouchUpInside];

            [self updateUI];
            return;
        }
    }
    else{
        while ([currentSelectIgv viewWithTag:1111]) {
            [[currentSelectIgv viewWithTag:1111]removeFromSuperview];
            
        }
    }
}
-(void)submit:(UIButton *)btm{
    
    [self.view endEditing:YES];
    UITableViewCell *Cell = [table cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    UITextField *tf= (UITextField *)[Cell.contentView viewWithTag:333+2];
    NSString *text=tf.text;
    if (selectedTime.length == 0 ) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请选择时间"];
        return;
    }
    if (textField.text.length==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请输入地点"];
        return;
    }
    if ([text isEqualToString:@"原因说明"]||[text length]==0) {
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:@"请说明异常考勤的原因"];
        return;
    }
 
    btm.userInteractionEnabled=NO;
    [btm performSelector:@selector(setUserInteractionEnabled:) withObject:[NSNumber numberWithBool:YES] afterDelay:2];
 
    NSString *saveUrl=KQ_EXNORMAL_SIGN;
    if (!self.singRecordId) {
        saveUrl=signInOrOutUrl;
    }
  
    [CCUtil showMBLoading:nil detailText:@"请稍候..."];
    //    NSDictionary *dic1=@{@"lng":@(self.lng),@"lat":@(self.lat),@"location":[self.Address length]>0?self.Address:@"",@"signContent":text};
    NSDictionary *dic1=nil;
    if (!self.singRecordId) {
        //
        NSString *sign_checkType=self.btnIndex%2==0?@"1":@"0";
        NSString *times = self.btnIndex>2?@"2":@"1";
        NSString *location = textField.text;
        dic1= @{@"type":@"1",@"checkType":sign_checkType,@"location":location?location:@"北京市海淀区",@"times":times,@"time":selectedTime,@"signContent":signContent.text};
    }
    else
        dic1= @{@"signContent":text,@"signRecordId":self.singRecordId};
    ASIFormDataRequest *requset=[ASIFormDataRequest requestWithURL:[NSURL URLWithString:[saveUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    //[requset setTimeOutSeconds:20];
    [requset setTimeOutSeconds:10];
    [requset setPostValue:text forKey:@"content"];
    for (NSString *key in dic1.allKeys) {
        [requset setPostValue:dic1[key] forKey:key];
    }
    for (int i=0; i<picArray.count; i++) {
        NSData *imagedata;
        if ([picArray[i] isKindOfClass:[UIImage class]]) {
            UIImage *image=picArray[i];
            imagedata=UIImageJPEGRepresentation(image, 0.5);
            
        }
        else if ([picArray[i]isKindOfClass:[NSString class]]){
            NSString *string_url = [@"http://117.78.42.226:8081" stringByAppendingString:picArray[i]];
            imagedata=[NSData dataWithContentsOfURL:[NSURL URLWithString:string_url]];
        }
        
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
    [CCUtil hideMBLoading];
    //    NSString *Str=[[NSString alloc]initWithData:dataF encoding:NSUTF8StringEncoding];
    NSDictionary *dic=[NSJSONSerialization JSONObjectWithData:dataF options:NSJSONReadingMutableLeaves error:nil];
    if ([dic[@"success"]intValue]==1) {
        if (self.type==GO_DOWN_GO) {
            [CCUtil showMBProgressHUDLabel:@"提交成功" detailLabelText:nil];
        }
        else
            [CCUtil showMBProgressHUDLabel:@"提交成功" detailLabelText:nil];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"refreshKQ" object:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{
        NSString *message=dic[@"message"];
        //NSString *showMes=@"未打卡成功";
//        if ([message isEqualToString:@"一"]) {
//            showMes=@"没有找到相应的考勤设置";
//        }
//        if ([message isEqualToString:@"二"]) {
//            showMes=@"考勤模式未启用，请联系管理员";
//        }
//        if ([message isEqualToString:@"三"]) {
//            showMes=@"当前考勤模式下面不存在用户";
//        }
//        if ([message isEqualToString:@"四"]) {
//            showMes=@"本月没有设置工作日，不可签到（签退）";
//        }
//        if ([message isEqualToString:@"五"]) {
//            showMes=@"今天不是工作日";
//        }
//        if ([message isEqualToString:@"六"]) {
//            showMes=@"今天还没有签到，请先签到";
//        }
        [CCUtil showMBProgressHUDLabel:nil detailLabelText:message];
        
    }
    
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
