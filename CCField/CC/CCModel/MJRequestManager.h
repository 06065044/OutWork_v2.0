//
//  MJRequestManager.h
//  Sales
//
//  Created by 李付 on 14/12/16.
//  Copyright (c) 2014年 com.sales. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MJRequestManager : NSObject

@property(nonatomic,strong)NSOperationQueue *queue;

+(MJRequestManager*)shareManager;
-(void)cancelOperationQueue;

@end
