//
//  CCRootViewController.m
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import "CCRootViewController.h"
#import "CCUtil.h"
#import "UIColor+STHxString.h"
@interface CCRootViewController ()

@end

@implementation CCRootViewController

@synthesize imageNav=_imageNav;
@synthesize lableNav=_lableNav;
@synthesize buttonNav=_buttonNav;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.view.backgroundColor = RGBA(245, 245, 245, 1);
    self.view.backgroundColor = [UIColor colorWithHexString:@"#f5f5f5"];
    //导航
    _imageNav=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 320, 44)];
    _imageNav.userInteractionEnabled=YES;
//    _imageNav.backgroundColor=RGBA(212, 10, 29, 1);
    _imageNav.backgroundColor = [UIColor colorWithHexString:@"#f6f7f8"];
    [self.view addSubview:_imageNav];
    
    if (CCIOS7)
    {
        [self.view setBounds:CGRectMake(0, 0, kFullScreenSizeWidth,kFullScreenSizeHeght)];
        [self.view setBackgroundColor:[UIColor colorWithWhite:0.9f alpha:200.0f]];
        _imageNav.frame=CGRectMake(0, 0, 320, 44+20);
    }
    
    //标题
    _lableNav=[[UILabel alloc]initWithFrame:CGRectMake(0, 20, 320, 44)];
    _lableNav.textColor=[UIColor whiteColor];
    _lableNav.backgroundColor=[UIColor clearColor];
    _lableNav.textAlignment=NSTextAlignmentCenter;
    _lableNav.font=[UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
    [_imageNav addSubview:_lableNav];
    
    //返回
    _buttonNav=[UIButton buttonWithType:0];
    [_buttonNav setFrame:CGRectMake(15, 25,30,30)];
    [_buttonNav setImage:[UIImage imageNamed:@"Return"] forState:UIControlStateNormal];
    [_buttonNav addTarget:self action:@selector(returnBack) forControlEvents:UIControlEventTouchUpInside];
    [_imageNav addSubview:_buttonNav];
}

-(void)returnBack{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark --textfield
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}
//-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
//    if (![self stringContainsEmoji:string]||string.length==0) {
//        return YES;
//    }
//    return NO;
//
//}
//- (BOOL)stringContainsEmoji:(NSString *)string {
//    __block BOOL returnValue = NO;
//    [string enumerateSubstringsInRange:NSMakeRange(0, [string length]) options:NSStringEnumerationByComposedCharacterSequences usingBlock:
//     ^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
//
//         const unichar hs = [substring characterAtIndex:0];
//         // surrogate pair
//         if (0xd800 <= hs && hs <= 0xdbff) {
//             if (substring.length > 1) {
//                 const unichar ls = [substring characterAtIndex:1];
//                 const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
//                 if (0x1d000 <= uc && uc <= 0x1f77f) {
//                     returnValue = YES;
//                 }
//             }
//         } else if (substring.length > 1) {
//             const unichar ls = [substring characterAtIndex:1];
//             if (ls == 0x20e3) {
//                 returnValue = YES;
//             }
//
//         } else {
//             // non surrogate
//             if (0x2100 <= hs && hs <= 0x27ff) {
//                 returnValue = YES;
//             } else if (0x2B05 <= hs && hs <= 0x2b07) {
//                 returnValue = YES;
//             } else if (0x2934 <= hs && hs <= 0x2935) {
//                 returnValue = YES;
//             } else if (0x3297 <= hs && hs <= 0x3299) {
//                 returnValue = YES;
//             } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
//                 returnValue = YES;
//             }
//         }
//     }];
//
//    return returnValue;
//}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    NSArray *Arr=@[@"➋",@"➌",@"➍",@"➎",@"➏",@"➐",@"➑",@"➒",@"."];
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
- (NSString *)disable_emoji:(NSString *)text
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]" options:NSRegularExpressionCaseInsensitive error:nil];
    NSString *modifiedString = [regex stringByReplacingMatchesInString:text
                                                               options:0
                                                                 range:NSMakeRange(0, [text length])
                                                          withTemplate:@""];
    return modifiedString;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
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
