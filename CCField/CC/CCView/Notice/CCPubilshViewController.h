//
//  CCPubilshViewController.h
//  CCField
//
//  Created by 李付 on 14/10/17.
//  Copyright (c) 2014年 Field. All rights reserved.
//
typedef void(^AlertClick)(NSInteger index);

#import "CCRootViewController.h"
#import "ASIHTTPRequest.h"
@interface CCPubilshViewController : CCRootViewController<ASIHTTPRequestDelegate>{
    AlertClick alertC;
}
@property(strong,nonatomic)NSDictionary *dataDic;
@end
