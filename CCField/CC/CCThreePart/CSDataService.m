//网络请求


#import "CSDataService.h"
#import "CCUtil.h"
@implementation CSDataService

+ (AFHTTPRequestOperation *)requestWithURL:(NSString *)urlstring
                                    params:(NSMutableDictionary *)params
                                httpMethod:(NSString *)httpMethod
                                     block:(CompletionLoadHandle)block {
    
    if (params == nil) {
        params = [NSMutableDictionary dictionary];
    }
    
    //1.拼接URL
    NSMutableString *url = [NSMutableString stringWithFormat:@"%@",urlstring];
    //3.创建请求管理对象
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    AFHTTPRequestOperation *operation = nil;
 //    [CCUtil showMBProgressHUDLabel:@"请稍等..." detailLabelText:nil];
    if ([httpMethod isEqualToString:@"GET"]) {
        
        //4.发送GET请求
        operation = [manager GET:url
                      parameters:params
                         success:^(AFHTTPRequestOperation *operation, id responseObject) {
                             if (block != nil) {
                                 block(responseObject);
                             }
                         }
                         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                             NSLog(@"请求网络失败：%@",error);
                         }];
        
    }else if([httpMethod isEqualToString:@"POST"]){
        //4.发送POST请求
        
        BOOL isFile = NO;
        for (NSString *key in params) {
            id value = params[key];
            //判断请求参数是否是文件数据
            if ([value isKindOfClass:[NSData class]]) {
                isFile = YES;
                break;
            }
        }
        
        if (!isFile) {
            //如果参数中没有文件，使用以下方法发送网络请求
            [manager POST:url parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                if (block != nil) {
                    block(responseObject);
                }
                
                NSLog(@"%@",operation.request.allHTTPHeaderFields);
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"请求网络失败：%@",error);
            }];
        } else {
            
            //如果参数中带有文件，使用如下POST方法请求网络
             operation = [manager POST:url
                            parameters:params
             constructingBodyWithBlock:^(id<AFMultipartFormData> formData)
             {
                 for (NSString *key in params) {
                     id value = params[key];
                     
                     //判断请求参数是否是文件数据
                     if ([value isKindOfClass:[NSData class]]) {
                         
                         //将文件数据添加到formData中
                         [formData appendPartWithFileData:value
                                                     name:key
                                                 fileName:key
                                                 mimeType:@"image/jpeg"];
                     
                     }
                 }
             }
             success:^(AFHTTPRequestOperation *operation, id responseObject) {
                 if (block != nil) {
                     block(responseObject);
                 }
                 
                 NSLog(@"response:%@",operation.response.allHeaderFields);
             }
             failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                 NSLog(@"请求网络失败：%@",error);
             }];
        }
    }
    
    //5.设置返回数据的解析方式
    operation.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    return operation;
}

//登陆
/*
+ (AFHTTPRequestOperation *)requestLogin:(NSString *)username
                                password:(NSString *)password
                                   block:(CompletionLoadHandle)block {
    
    NSDictionary *params = @{
                             @"client_id":kAppKey,
                             @"client_secret":kAppSecret,
                             @"grant_type": @"password",
                             @"username":username,
                             @"password":password
                          };
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    //添加一项请求头
    [manager.requestSerializer setValue:@"6bfe9156-0760-4e95-93a1-3c68897da5b0"
                     forHTTPHeaderField:@"devid"];
    
    AFHTTPRequestOperation *operation = [manager POST:Login_URL parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (block != nil) {
            block(responseObject);
        }
        
        NSLog(@"request:%@",operation.request.allHTTPHeaderFields);
        NSLog(@"response:%@",operation.response.allHeaderFields);
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"请求网络失败：%@",error);
        
        NSLog(@"response:%@",operation.response.allHeaderFields);
    }];
    
    //设置返回数据的解析方式
    operation.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
    
    return operation;
}
*/

@end
