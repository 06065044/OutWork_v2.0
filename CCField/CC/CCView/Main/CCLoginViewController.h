//
//  CCLoginViewController.h
//  CCField
//
//  Created by 李付 on 14-10-9.
//  Copyright (c) 2014年 Field. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CustTextField.h"
#import "ASIHTTPRequest.h"
#import "MBProgressHUD.h"

@interface CCLoginViewController : UIViewController<UITextFieldDelegate>
{
    NSDictionary *jsonDic;
}
@property (weak, nonatomic) IBOutlet UITextField *userName;
@property (weak, nonatomic) IBOutlet UITextField *passWord;

@end
