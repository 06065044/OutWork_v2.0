//
//  MJRequestOpeation.m
//  Sales
//
//  Created by 李付 on 14/12/16.
//  Copyright (c) 2014年 com.sales. All rights reserved.
//

#import "MJRequestOpeation.h"

@interface MJRequestOpeation()<NSURLConnectionDelegate,NSURLConnectionDataDelegate>
{
      CompleteBlock_t completeBlock;//完成回调函数
      ErrorBlock_t errorBlock;//出错回调函数
}
@property(nonatomic,strong)NSURLConnection *connection;
@property (nonatomic) long long int expectedContentLength;
@property (nonatomic) BOOL isExecuting;
@property (nonatomic) BOOL isConcurrent;
@property (nonatomic) BOOL isFinished;
@end

@implementation MJRequestOpeation

-(id)initWithRequest:(NSURLRequest*)requset completeBlock:(CompleteBlock_t)compleBlock errorBlock:(ErrorBlock_t)errorBlock_
{
      self=[super init];
      if (self)
      {
        self.urlRequest=requset;
        completeBlock=[compleBlock  copy];
        errorBlock=[errorBlock_ copy];
        _resultData=[[NSMutableData alloc]init];
      }
      return self;
}
/*
 *开始请求
 */
-(void)start
{
      self.isExecuting=YES;
      self.isConcurrent=YES;
      self.isFinished=YES;
      [[NSOperationQueue mainQueue]addOperationWithBlock:^{
            self.connection=[NSURLConnection connectionWithRequest:_urlRequest delegate:self];
      }];
}

#pragma mark NSURLConnectionDelegate

- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)response {
      return request;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
      [_resultData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
      [_resultData appendData:data];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
      return cachedResponse;
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
      completeBlock(_resultData);
      self.isExecuting=NO;
      self.isFinished=YES;
}

-(void)setIsExecuing:(BOOL)isExecuing
{
      [self willChangeValueForKey:@"isExecuting"];
      _isExecuting=isExecuing;
      [self didChangeValueForKey:@"isExecuting"];
}

- (void)setIsFinished:(BOOL)isFinished
{
      [self willChangeValueForKey:@"isFinished"];
      _isFinished = isFinished;
      [self didChangeValueForKey:@"isFinished"];
}

-(void)cancel
{
      [super cancel];
      [self.connection cancel];
      self.isFinished = YES;
      self.isExecuting = NO;
}


@end
