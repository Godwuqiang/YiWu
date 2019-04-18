//
//  HttpHelper.m
//  NingBoHRSS
//
//  Created by 许芳芳 on 16/9/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "HttpHelper.h"
#import "AFNetworking.h"

/**
 *  是否开启https SSL 验证
 *
 *  @return YES为开启，NO为关闭
 */
#define openHttpsSSL YES
/**
 *  SSL 证书名称，仅支持cer格式。“app.bishe.com.cer”,则填“app.bishe.com”
 */
#define certificate @"*.dabay.cn"


@implementation HttpHelper

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSLog(@"url---%@  参数--%@",url,params);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.申明返回的结果是text/html类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 3.设置超时时间为30s
    manager.requestSerializer.timeoutInterval = 15;
    
    // 加上这行代码，https ssl 验证。
    if(openHttpsSSL)
    {
        [manager setSecurityPolicy:[self httpsSecurityPolicy]];
    }
    
    // 4.发送POST请求
    [manager POST:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        if (success) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
//            NSLog(@"httpHelper result: %@", resultDict);
            NSInteger resultCode = [resultDict[@"resultCode"] integerValue];
            if (resultCode == 5001) {
                // 5001代表token不存在， 弹出退出登录弹框
                [[NSNotificationCenter defaultCenter] postNotificationName:@"token_invalid" object:nil userInfo:nil];
            }else if (resultCode == 5002) {
                // 5002代表token超时，置换token
                [[NSNotificationCenter defaultCenter] postNotificationName:@"token_overtime" object:nil userInfo:resultDict];
            }
            success(responseObject);
        }else{
            failure(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DMLog(@"%@",task.error);
        DMLog(@"%@,%@",task,error);
        if (failure) {
            failure(task.error);
        }
    }];
    
}

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id))success failure:(void (^)(NSError *))failure
{
    NSLog(@"url---%@  参数--%@",url,params);
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    // 2.申明返回的结果是text/html类型
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    // 3.设置超时时间为30s
    manager.requestSerializer.timeoutInterval = 15;
    
    // 加上这行代码，https ssl 验证。
    if(openHttpsSSL)
    {
        [manager setSecurityPolicy:[self httpsSecurityPolicy]];
    }
    
    // 4.发送GET请求
    [manager GET:url parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        if (success) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObject options:kNilOptions error:nil];
            //            NSLog(@"httpHelper result: %@", resultDict);
            NSInteger resultCode = [resultDict[@"resultCode"] integerValue];
            if (resultCode == 5001) {
                // 5001代表token不存在， 弹出退出登录弹框
                [[NSNotificationCenter defaultCenter] postNotificationName:@"token_invalid" object:nil userInfo:nil];
            }else if (resultCode == 5002) {
                // 5002代表token超时，置换token
                [[NSNotificationCenter defaultCenter] postNotificationName:@"token_overtime" object:nil userInfo:resultDict];
            }
            success(responseObject);
        }else{
            failure(responseObject);
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        DMLog(@"%@",task.error);
        DMLog(@"%@,%@",task,error);
        if (failure) {
            failure(task.error);
        }
    }];
    
}

+ (AFSecurityPolicy*)httpsSecurityPolicy {
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificate ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithObject:cerData];
    return securityPolicy;
}


@end
