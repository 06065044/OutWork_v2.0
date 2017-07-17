//
//  MJRequestManager.m
//  Sales
//
//  Created by 李付 on 14/12/16.
//  Copyright (c) 2014年 com.sales. All rights reserved.
//

#import "MJRequestManager.h"

@implementation MJRequestManager

+(MJRequestManager*)shareManager
{
      static  MJRequestManager  *manager=nil;
      static dispatch_once_t token;
      dispatch_once(&token, ^{
            manager=[[MJRequestManager alloc]init];
      });
      return manager;
}

-(id)init
{
      self=[super init];
      if (self)
      {
        self.queue=[[NSOperationQueue alloc]init];
      }
      return self;
}

-(void)cancelOperationQueue
{
      /*
      for (NSOperation *op in self.queue.operations) {
            [op cancel];
      }
       */
      [self.queue cancelAllOperations];
}


@end
