//
//  CCKQJLViewController.m
//  CCField
//
//  Created by 马伟恒 on 14/10/20.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCKQJLViewController.h"
#import "CCUtil.h"
#import "ASIHTTPRequest.h"
#import "RDVExampleDayCell.h"
#import "RDVCalendarViewController.h"
#import "STKQView.h"
#import "STBaseControl.h"
#import "STTwoPerDay.h"
#import "STFourPerDay.h"

@interface CCKQJLViewController ()<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIAlertViewDelegate>

@end

@implementation CCKQJLViewController
{
    UIView *viewDown;
    NSArray *responseArr;
    NSArray *reverseArr;
    BOOL SHOULD_MOVE;
    BOOL move_six;
    STBaseControl *control;
    UIView *view;
    UIScrollView *scr;
    UITableView *tab;
    NSInteger daysOfMonth;
    NSInteger daysOfMonthPre;
    NSInteger year;
    NSInteger month;
    NSInteger day;
    NSInteger Hour;
    NSInteger minute;
    NSArray *signDays;//考勤日集合
    UILabel *monthLabel;
    NSArray *choseMonthArray;
    BOOL pre;
 }

@synthesize calendarView=_calendarView;
//刷新考勤列表
-(void)refreshKQ{
    NSDictionary *dic = @{@"month":monthLabel.text};
    [self getSignInfo:dic];
    [tab reloadData];
    
}
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(refreshKQ) name:@"refreshKQ" object:nil];
    
    self.lableNav.text=@"考勤记录";
    [self getCurrDay];
    
    [self getSignInfo:nil];
    [self createUI:0];
}
//scrolltable到昨天
-(void)viewWillAppear:(BOOL)animated{
    NSInteger cellCountToScroll = 0;
     if (day>=2) {
        cellCountToScroll = day-2;
    }
    
    if (responseArr.count==0) {
        return;
    }
    if (cellCountToScroll!=38) {
            [tab scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:cellCountToScroll inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:true];
    }
//    if (pre) {
//        if (cellCountToScroll>=daysOfMonthPre) {
//            return;
//        }
//    }
//    if (cellCountToScroll>=daysOfMonth) {
//        return;
//    }
  
}
-(void)getCurrDay{
    
    NSDate *Date =self.currDate;
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSRange range =[calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:Date];
    daysOfMonth = range.length;
    NSInteger unitFlags = NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute;
    NSDateComponents *comps = [calendar components:unitFlags fromDate:Date];
    year = [comps year];
    month = [comps month];
    day = [comps day];
    Hour = [comps hour];
    minute = [comps minute];
}
-(void)getSignInfo:(NSDictionary *)dic{
    
    NSString *final=[CCUtil basedString:signInfoURL withDic:dic];
    ASIHTTPRequest *Requset=[ASIHTTPRequest requestWithURL:[NSURL URLWithString:[final stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    [Requset setRequestMethod:@"GET"];
    [Requset startSynchronous];
    NSData *responData=[Requset responseData];
    if (responData.length==0) {
        [CCUtil showMBProgressHUDLabel:@"请求失败" detailLabelText:nil];
        return;
    }
    responseArr=[[NSJSONSerialization JSONObjectWithData:responData options:NSJSONReadingMutableLeaves error:nil] objectForKey:@"data"];
    
    NSString *signDaysString = responseArr[0][@"signDays"];
    signDays = [signDaysString componentsSeparatedByString:@","];
    NSMutableArray *arr_replace = [NSMutableArray array];
    [signDays enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [arr_replace addObject:@(obj.integerValue)];
    }];
    signDays = arr_replace.copy;
}
-(void)choseMonth{
    [self getCurrDay];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *adcomps = [[NSDateComponents alloc] init];
    
    [adcomps setYear:0];
    
    [adcomps setMonth:-1];
    
    [adcomps setDay:0];
    
    NSDate *date = [calendar dateByAddingComponents:adcomps toDate:[NSDate date] options:0];
    daysOfMonthPre = [calendar rangeOfUnit:NSCalendarUnitDay inUnit:NSCalendarUnitMonth forDate:date].length;
    
    NSDateFormatter *formtter = [[NSDateFormatter alloc]init];
    [formtter setDateFormat:@"yyyy-MM"];
    NSString *preString = [formtter stringFromDate:date];
    NSString *curString = [formtter stringFromDate:[NSDate date]];
    choseMonthArray = @[curString ,preString];
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:nil message:nil delegate:self cancelButtonTitle:@"取消" otherButtonTitles:choseMonthArray[0],choseMonthArray[1], nil];
    
    [alert show];
}
#pragma mark -alert点击
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=alertView.cancelButtonIndex) {
        //
        
        pre = NO;
        if (buttonIndex==2) {
            pre = YES;
            day=40;
        }
        if ([monthLabel.text isEqualToString:choseMonthArray[buttonIndex-1]]) {
            return;
        }
        NSDictionary *dic = @{@"month":choseMonthArray[buttonIndex-1]};
        month = [[[choseMonthArray[buttonIndex-1] componentsSeparatedByString:@"-"]lastObject]intValue];
        
        [monthLabel setText:choseMonthArray[buttonIndex-1]];
        [self getSignInfo:dic];
        [tab reloadData];
    }
}
-(void)createUI:(NSInteger)selectedSegmentIndex {
    [view setHidden:NO];
    [viewDown setHidden:YES];
    [_calendarView setHidden:YES];
    [self.view bringSubviewToFront:view];
    if (!view) {
        monthLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame), kFullScreenSizeWidth, 30)];
        monthLabel.backgroundColor = [UIColor whiteColor];
        NSString *StrMonth = [NSString stringWithFormat:@"%d-%d",year,month];
        if (month<10) {
            StrMonth = [NSString stringWithFormat:@"%d-0%d",year,month];
        }
        monthLabel.text = StrMonth;
        monthLabel.textAlignment = NSTextAlignmentCenter;
        monthLabel.font = [UIFont boldSystemFontOfSize:16];
        monthLabel.userInteractionEnabled = TRUE;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(choseMonth)];
        [monthLabel addGestureRecognizer:tap];
        tap.numberOfTapsRequired = 1;
        tap.numberOfTouchesRequired = 1;
        
        [self.view addSubview:monthLabel];
        
        UIImageView *igv = [[UIImageView alloc]initWithFrame:CGRectMake(kFullScreenSizeWidth/2.0+50, 2, 25, 25)];
        igv.image = [UIImage imageNamed:@"arrow_up"];
        igv.transform =CGAffineTransformMakeRotation(M_PI_2);
        [monthLabel addSubview:igv];
        
        
        view = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.imageNav.frame)+30, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(self.imageNav.frame))];
        view.backgroundColor = [UIColor lightGrayColor];
        [self.view addSubview:view];
        
        
        //填充数据
        UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, kFullScreenSizeWidth/3.0, 40)];
        lab.backgroundColor=[UIColor lightTextColor];
        lab.text=@"日期";
        lab.textAlignment=NSTextAlignmentCenter;
        [view addSubview:lab];
        
        
        UIImageView *igv1=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), 0, 1, 43)];
        igv1.backgroundColor=[UIColor lightGrayColor];
        [view addSubview:igv1];
        
        
        UILabel *lab1=[[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab.frame), CGRectGetMinY(lab.frame), kFullScreenSizeWidth/3.0, CGRectGetHeight(lab.frame))];
        lab1.backgroundColor=[UIColor lightTextColor];
        lab1.text=@"签到";
        lab1.textAlignment=NSTextAlignmentCenter;
        [view addSubview:lab1];
        
        
        UIImageView *igv11=[[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lab1.frame), 0, 1, 43)];
        igv11.backgroundColor=[UIColor lightGrayColor];
        [view addSubview:igv11];
        
        UILabel *lab2=[[UILabel alloc]initWithFrame:CGRectOffset(lab1.frame, kFullScreenSizeWidth/3.0, 0)];
        lab2.backgroundColor=[UIColor lightTextColor];
        lab2.text=@"签退";
        lab2.textAlignment=NSTextAlignmentCenter;
        [view addSubview:lab2];
        
        CGRect rectb = [self.view convertRect:lab.frame fromView:view];
        tab = [[UITableView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame), kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(rectb)) style:UITableViewStylePlain];
        tab.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
        tab.delegate=self;
        tab.dataSource=self;
        [view addSubview:tab];
        self.view.backgroundColor=[UIColor whiteColor];
    }
}
//else{
//        [view setHidden:YES];
//        [viewDown setHidden:NO];
//        [_calendarView setHidden:NO];
//        if (!_calendarView) {
//
//
//        //        //考勤日历
//        [[self calendarView]registerDayCellClass:[RDVExampleDayCell class]];
//        //
//        _calendarView = [[RDVCalendarView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(control.frame)-40,kFullScreenSizeWidth, 350)];
//        [_calendarView.backButton removeFromSuperview];
//        [_calendarView.forwardButton removeFromSuperview];
//        [_calendarView setAutoresizingMask:UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight];
//        _calendarView.monthLabel.textColor = [UIColor blackColor];
//        [_calendarView setSeparatorStyle:RDVCalendarViewDayCellSeparatorTypeHorizontal];
//        _calendarView.separatorColor = [UIColor colorWithWhite:0.8 alpha:0.8];
//        [_calendarView setBackgroundColor:[UIColor whiteColor]];
//        [_calendarView setContentMode:UIViewContentModeScaleToFill];
//        [_calendarView setDelegate:self];
//        [self.view addSubview: _calendarView];
//        [self.view sendSubviewToBack:_calendarView];
//        if ([self clearsSelectionOnViewWillAppear]) {
//            [[self calendarView] deselectDayCellAtIndex:[[self calendarView] indexForSelectedDayCell] animated:YES];
//        }
//
//
//        NSDate *Date = [NSDate date];
//        NSCalendar *calendar = [NSCalendar currentCalendar];
//        [calendar setFirstWeekday:1];
//        NSRange weekOfMonth =[calendar rangeOfUnit:NSWeekCalendarUnit inUnit:NSMonthCalendarUnit forDate:Date];
//
//        //        // add backgroud view
//        viewDown=[[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_calendarView.frame),kFullScreenSizeWidth-0, kFullScreenSizeHeght-CGRectGetMaxY(_calendarView.frame))];
//        if (weekOfMonth.length == 6) {
//            viewDown.frame = CGRectMake(0, CGRectGetMaxY(_calendarView.frame)+50, kFullScreenSizeWidth, kFullScreenSizeHeght-CGRectGetMaxY(_calendarView.frame)-50);
//        }
//        viewDown.backgroundColor=[UIColor clearColor];
//        viewDown.layer.borderColor= [UIColor colorWithWhite:0.8 alpha:0.8].CGColor;
//        viewDown.layer.borderWidth=1.0f;
//        [self.view addSubview:viewDown];
//
//        scr=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0, kFullScreenSizeWidth, CGRectGetHeight(viewDown.frame))];
//        scr.scrollEnabled = YES;
//        scr.delegate=self;
//        //
//        [viewDown addSubview:scr];
//
//        NSArray *arr;
//        int i=0;
//        for (NSDictionary *dic in arr) {
//            STKQView *KQ = [[STKQView alloc]initWithFrame:CGRectMake(0, 80*i, kFullScreenSizeWidth, 100) useDic:dic];
//            i++;
//            [scr addSubview:KQ];
//        }
//        scr.contentSize = CGSizeMake(kFullScreenSizeWidth, 100*(i+1));
//        }
//
//
//        // add label
//        //        NSArray *arrTitle=[NSArray arrayWithObjects:@"签到",@"签退", nil];
//        //        for (int i=0; i<2; i++) {
//        //            UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(0, 0+60*i, 100, 60)];
//        //            lab.text=arrTitle[i];
//        //            lab.textAlignment=NSTextAlignmentCenter;
//        //            lab.tag = 333+i;
//        //            [viewDown addSubview:lab];
//        //            if (i==0) {
//        //                UIImageView *igc=[[UIImageView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(lab.frame), kFullScreenSizeWidth, 1)];
//        //                igc.backgroundColor= [UIColor colorWithWhite:0.8 alpha:0.8];
//        //                [viewDown addSubview:igc];
//        //                UIImageView *igcup=[[UIImageView alloc]initWithFrame:CGRectOffset(igc.frame, 0, -60)];
//        //                igcup.backgroundColor=igc.backgroundColor;
//        //                [viewDown addSubview:igcup];
//        //                UIImageView *igcup1=[[UIImageView alloc]initWithFrame:CGRectMake(0, 120, kFullScreenSizeWidth, 1)];
//        //
//        //                igcup1.backgroundColor=igc.backgroundColor;
//        //                [viewDown addSubview:igcup1];
//        //            }
//        //        }
//        //        for (int i=0; i<4; i++){
//        //
//        //            CGFloat labWidt= CGRectGetWidth(viewDown.frame)-100;
//        //            if (i==0) {
//        //                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(100, 0, labWidt, 29)];
//        //                lab.font = [UIFont systemFontOfSize:12];
//        //                lab.tag=1024+i;
//        //                 [viewDown addSubview:lab];
//        //                UIImageView *igc=[[UIImageView alloc]initWithFrame:CGRectMake(100-1, 0, 1, 120)];
//        //                igc.backgroundColor= [UIColor colorWithWhite:0.8 alpha:0.8];
//        //                [viewDown addSubview:igc];
//        //            }else if(i == 1){
//        //                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(100, 30,labWidt, 30)];
//        //                lab.font = [UIFont systemFontOfSize:12];
//        //                lab.numberOfLines = 0;
//        //                lab.tag=1024+i;
//        //                  [viewDown addSubview:lab];
//        //                UIImageView *igc=[[UIImageView alloc]initWithFrame:CGRectMake(100,CGRectGetMinY(lab.frame), labWidt, 1)];
//        //                igc.backgroundColor= [UIColor colorWithWhite:0.8 alpha:0.8];
//        //                [viewDown addSubview:igc];
//        //
//        //             }else if (i == 2){
//        //                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(100, 60, labWidt, 29)];
//        //                lab.font = [UIFont systemFontOfSize:12];
//        //                lab.tag=1024+i;
//        //                UIImageView *igc=[[UIImageView alloc]initWithFrame:CGRectMake(100, 89, labWidt, 1)];
//        //                igc.backgroundColor= [UIColor colorWithWhite:0.8 alpha:0.8];
//        //                [viewDown addSubview:lab];
//        //
//        //                [viewDown addSubview:igc];
//        //            }else if (i == 3){
//        //                UILabel *lab=[[UILabel alloc]initWithFrame:CGRectMake(100, 90, labWidt, 30)];
//        //                lab.font = [UIFont systemFontOfSize:12];
//        //                lab.numberOfLines = 0;
//        //                lab.tag=1024+i;
//        //
//        //                [viewDown addSubview:lab];
//        //
//        //
//        //
//        //            }
//        //        }
//        //
//        //        NSDateFormatter *formater=[[NSDateFormatter alloc]init];
//        //        [formater setDateFormat:@"yyyy-mm-dd"];
//        //        NSString *str=[formater stringFromDate:Date];
//        //        int index=[[[str componentsSeparatedByString:@"-"]lastObject]intValue]-1;
//        //        [self calendarView:_calendarView didSelectCellAtIndex:index];
//    }


//}
-(NSInteger)getCurTime{
    NSString *Str= [NSString stringWithFormat:@"%d%d",Hour,minute];
    return  [Str integerValue];
}
-(NSInteger)changeTimeStr:(NSString *)str{
    NSString *timeStr = [str stringByReplacingOccurrencesOfString:@":" withString:@""];
    return [timeStr integerValue];
}
#pragma mark--calendar delegate
- (void)calendarView:(RDVCalendarView *)calendarView configureDayCell:(RDVCalendarDayCell *)dayCell
             atIndex:(NSInteger)index {
    RDVExampleDayCell *exampleDayCell = (RDVExampleDayCell *)dayCell;
    exampleDayCell.textLabel.font = [UIFont systemFontOfSize:12];
    if (index<responseArr.count) {
        
        if (![responseArr[index][2] isKindOfClass:[NSNull class]]&&![responseArr[index][3] isKindOfClass:[NSNull class]]) {
            exampleDayCell.backgroundColor=[UIColor whiteColor];
        }
        
    }
    BOOL _SIX=[[NSUserDefaults standardUserDefaults]boolForKey:@"six"];
    if (_SIX&&!move_six) {
        move_six=YES;
        [UIView animateWithDuration:0.1 animations:^{
            //            self->viewDown.frame=CGRectOffset(self->viewDown.frame, 0, 50);
        }];
      }
 }
-(void)calendarView:(RDVCalendarView *)calendarView didSelectCellAtIndex:(NSInteger)index{
    UILabel *lab0=(UILabel *)[viewDown viewWithTag:1024];
    UILabel *lab1=(UILabel *)[viewDown viewWithTag:1025];
    UILabel *lab2=(UILabel *)[viewDown viewWithTag:1026];
    UILabel *lab3=(UILabel *)[viewDown viewWithTag:1027];
    lab0.text=@"";
    lab1.text=@"";
    lab2.text=@"";
    lab3.text=@"";
    
    
    if (responseArr.count<=index) {
        return;
    }
    
    if (![responseArr[index][2]isKindOfClass:[NSNull class]]) {
        lab0.text=[responseArr[index][0] substringToIndex:19];
        lab1.text=responseArr[index][6];
    }
    if (![responseArr[index][3]isKindOfClass:[NSNull class]]) {
        lab2.text=[responseArr[index][1] substringToIndex:19];
        lab3.text=responseArr[index][9];
    }
    
    
    
    
}


#pragma mark -table delagate
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(__kindof UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *TWO_REUSER = @"two_reuser";
    STTwoPerDay *two_cell = nil;
    STFourPerDay *four_cell = nil;
    
    if ([responseArr[0][@"signTimes"]intValue]==2) {
        two_cell = [tableView dequeueReusableCellWithIdentifier:TWO_REUSER];
        if (!two_cell) {
            two_cell =  [[STTwoPerDay alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:TWO_REUSER];
        }
    }
    else{
        four_cell = [tableView dequeueReusableCellWithIdentifier:@"FOUR"];
        if (!four_cell) {
            four_cell=[[STFourPerDay alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FOUR"];
        }
    }
    if (two_cell) {
        [two_cell resetButtonTitle];
        two_cell.indexRow = indexPath.row+1;
        two_cell.dayNow = day;
        NSArray *sign_dic= @[responseArr[0][@"signInfoRsp"][0][@"signInfo"][indexPath.row],responseArr[0][@"signInfoRsp"][1][@"signInfo"][indexPath.row]];
        
        if ([signDays containsObject:@(indexPath.row+1)]) {
            //工作
            if (indexPath.row+1>day) {
                sign_dic=@[@"工作",@"工作"];
            }
            if (indexPath.row+1==day) {
                //今天的
                NSMutableArray *arr = [NSMutableArray arrayWithArray:sign_dic];

                if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[0]]) {
                    //第一次之前
                   sign_dic=@[@"工作",@"工作"];
                    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[NSDictionary class]]) {
                            
                            [arr replaceObjectAtIndex:idx withObject:@"工作"];
                        }
                    }];
                    sign_dic = [arr copy];
                }
                else if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[1]]){
                    //中间
                     if (![arr[1] isKindOfClass:[NSDictionary class]]) {
                         [arr replaceObjectAtIndex:1 withObject:@"工作"];
                    }
                    sign_dic = arr.copy;
                 }
            }
        }
        else{
            //  休息
            sign_dic=@[@"休息",@"休息"];
        }
        [two_cell confirmWIthDIc:sign_dic];
        
        two_cell.timeTitle.text = [NSString stringWithFormat:@"%d-%d-%d",year,month,indexPath.row+1];
        if (pre) {
            two_cell.timeTitle.text = [NSString stringWithFormat:@"%@-%d",choseMonthArray[1],indexPath.row+1];
        }
         return two_cell;
    }
    else{
        [four_cell resetButtonTitle];
        four_cell.indexRow = indexPath.row+1;
        four_cell.dayNow = day;
        NSArray *sign_dic= @[responseArr[0][@"signInfoRsp"][0][@"signInfo"][indexPath.row],responseArr[0][@"signInfoRsp"][1][@"signInfo"][indexPath.row],responseArr[0][@"signInfoRsp"][2][@"signInfo"][indexPath.row],responseArr[0][@"signInfoRsp"][3][@"signInfo"][indexPath.row]];
        
        if ([signDays containsObject:@(indexPath.row+1)]) {
            //工作
            NSMutableArray *arr = [NSMutableArray arrayWithArray:sign_dic];

            if (indexPath.row+1>day) {
                sign_dic=@[@"工作",@"工作",@"工作",@"工作"];
            }
            if (indexPath.row+1==day) {
                //今天的
                  if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[0]]) {
                    //第一次之前
                      [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                         if (![obj isKindOfClass:[NSDictionary class]]) {
                             [arr replaceObjectAtIndex:idx withObject:@"工作"];
                         }
                     }];
                     sign_dic = [arr copy];
                }
                else if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[1]]){
                    //第二次之前
                     [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[NSDictionary class]]&&idx>0) {
                            [arr replaceObjectAtIndex:idx withObject:@"工作"];
                        }
                    }];

                    sign_dic = [arr copy];
                }
                else if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[2]]){
                    //第3次之前
                    [arr enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        if (![obj isKindOfClass:[NSDictionary class]]&&idx>1) {
                            [arr replaceObjectAtIndex:idx withObject:@"工作"];
                        }
                    }];

                     sign_dic = [arr copy];
                }
                else if ([self getCurTime]<[self changeTimeStr:self.signTimeArray[3] ]){
                    //第二次之前
                    if (![arr[3] isKindOfClass:[NSDictionary class]]) {
                        [arr replaceObjectAtIndex:3 withObject:@"工作"];
                    }
                     sign_dic = [arr copy];
                }
             }
        }
        else{
            //  休息
            sign_dic=@[@"休息",@"休息",@"休息",@"休息"];
        }
        [four_cell confirmWIthDIc:sign_dic];
        //        }
        
        four_cell.timeTitle.text = [NSString stringWithFormat:@"%d-%d-%d",year,month,indexPath.row+1];
        if (pre) {
            four_cell.timeTitle.text = [NSString stringWithFormat:@"%@-%d",choseMonthArray[1],indexPath.row+1];
        }
        return four_cell;
    }
    return nil;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (responseArr.count==0) {
        return 0;
    }
    if (pre) {
        return daysOfMonthPre;
    }
    return daysOfMonth;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([responseArr[0][@"signTimes"] integerValue]==2) {
        return  40;
    }
    else{
        return 80;
    }
    
}
#pragma MARK -SCOLL DELEGATE

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
