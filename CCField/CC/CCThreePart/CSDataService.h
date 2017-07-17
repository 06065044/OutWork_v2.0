//网络请求

#import <Foundation/Foundation.h>
#import "AFNetworking.h"

typedef void(^CompletionLoadHandle)(id result);

@interface CSDataService : NSObject

//网络请求
+ (AFHTTPRequestOperation *)requestWithURL:(NSString *)urlstring
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                                     block:(CompletionLoadHandle)block;

//登陆
//+ (AFHTTPRequestOperation *)requestLogin:(NSString *)username
//                                password:(NSString *)password
//                                   block:(CompletionLoadHandle)block;


@end
