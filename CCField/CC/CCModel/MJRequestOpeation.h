//
//  MJRequestOpeation.h
//  Sales
//
//  Created by 李付 on 14/12/16.
//  Copyright (c) 2014年 com.sales. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^CompleteBlock_t)(NSData *data);
typedef void(^ErrorBlock_t)(NSError *error);

@interface MJRequestOpeation : NSOperation

@property(nonatomic,strong)NSURLRequest *urlRequest;
@property(nonatomic,strong)NSMutableData *resultData;

-(id)initWithRequest:(NSURLRequest*)requset completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock_;

@end
