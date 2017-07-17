//
//  MJHttpNetWorkRequest.h
//  Sales
//
//  Created by 李付 on 14/12/16.
//  Copyright (c) 2014年 com.sales. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^CompleteBlock_t)(NSData *data);
typedef void(^ErrorBlock_t)(NSError *error);

@interface MJHttpNetWorkRequest : NSObject

@property(nonatomic,strong)NSMutableData *resultData;
@property(nonatomic,strong)NSURLConnection *connection;

+ (id)request:(NSString *)requestUrl postDataArray:(NSMutableDictionary *)postdict completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock_;
+ (id)request:(NSString *)requestUrl postDataArray:(NSMutableDictionary *)postdict postImageArray:(NSMutableArray*)imageArray completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock_;

- (id)initWithRequest:(NSString *)requestUrl postDataArray:(NSMutableDictionary *)postdict completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock_;

@end
