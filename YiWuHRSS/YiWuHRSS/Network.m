
//
//  Network.m
//  FMDBManger
//
//  Created by 魏子建 on 15/11/26.
//  Copyright © 2015年 lianhaiq. All rights reserved.
//

#import "Network.h"
#import "AFNetworking.h"
#import <AliyunOSSiOS/OSSService.h>

@interface Network()<UIAlertViewDelegate> {
    NSInteger time;
}

@end

@implementation Network

+ (Network *)shareNetwork {
    static Network *network = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        network = [[Network alloc] init];
    });
    return network;
}

+ (void)getWithUrl:(NSString *)urlString success:(success)success fail:(fail)fail {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", nil];
    
    [manager GET:urlString parameters:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        
        success(responseObject);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
        fail(error);
        
    }];
}

+ (BOOL)extractIdentity:(SecIdentityRef *)outIdentity andTrust:(SecTrustRef*)outTrust fromPKCS12Data:(NSData *)inPKCS12Data
{
    OSStatus securityError = errSecSuccess;
    
    //  NSDictionary *optionsDictionary = [NSDictionary dictionaryWithObject:@"" forKey:(id)kSecImportExportPassphrase];
    
    CFStringRef password = CFSTR("123"); //证书密码
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(NULL, keys,values, 1,NULL, NULL);
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import((CFDataRef)inPKCS12Data,(CFDictionaryRef)optionsDictionary,&items);
    
    if (securityError == 0) {
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemIdentity);
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust);
        *outTrust = (SecTrustRef)tempTrust;
    } else {
        NSLog(@"Failed with error code %d",(int)securityError);
        return NO;
    }
    return YES;
}

+ (void)postWithUrl:(NSString *)urlString parameter:(NSDictionary *)parameter success:(success)success fail:(fail)fail {
    if ([urlString containsString:@"pres/queryResult"]) {
        DLog(@"++++++++++");
    }
    NSArray *keyArray = parameter.allKeys;
    if ([keyArray containsObject:@"sessionId"]) {
        NSString *login = [parameter valueForKey:@"sessionId"];
        if ([login isEqualToString:@""]) {
            [UserDefaults setBool:NO forKey:@"loginState"];
        }
    }
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:parameter];
    //参数加版本号
    [dic setObject:VersionNum forKey:@"v"];
    //参数加sessionId
    NSString *session = [NSString stringWithValue:[UserDefaults valueForKey:@"sessionId"] default:@""];
    [dic setObject:session forKey:@"s"];
    [[NSURLCache sharedURLCache] removeAllCachedResponses];
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/html", @"text/plain", nil];
    manager.requestSerializer.timeoutInterval = 30;
    [manager setSecurityPolicy:[Network httpsSecurityPolicy]];
    
//    manager.responseSerializer = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingAllowFragments];
//   DLog(@"参数%@", dic);
   [Network shareNetwork].task = [manager POST:urlString parameters:dic progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {

        ResponseData *responseDataModel = [ResponseData objectFromDictionary:responseObject];
       
       
        NSString *errorCode = responseDataModel.errCode;
        NSString *errorMsg = responseDataModel.msg;
        NSString *errorMessage = [NSString stringWithFormat:@"%@ [%@]", errorMsg, errorCode];
        if ([NullTool isNullOrBlank:responseDataModel.errCode]) {
            errorMessage = [NSString stringWithFormat:@"%@", responseDataModel.msg];
        }
       
        //单点登录
        if ([responseDataModel.code integerValue] == 2) {
            
            [UserDefaults setBool:NO forKey:@"loginState"];
            //if ([urlString containsString:@"/pres/queryResult"]) {
              //  [[NSNotificationCenter defaultCenter] postNotificationName:@"thirdagainLogin" object:responseObject];
            //} else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"againLogin" object:responseObject];
            //}
            [[NSNotificationCenter defaultCenter] postNotificationName:@"hiddenMBP" object:responseObject];

            return ;
        }
        success(responseObject);
        
        // 提示更新/强制更新
        if ([responseDataModel.code integerValue] == 0) {
            
            if ([errorCode isEqualToString:@"VERSION_ERROR_002"]) {
                [UserDefaults setObject:@"error" forKey:@"onlyKey"];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UserDefaults setObject:@"" forKey:@"onlyKey"];
                });
                //提醒更新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"RemindUpdate" object:errorMsg];
            } else if ([errorCode isEqualToString:@"VERSION_ERROR_001"]) {
                [Network heheHaHa];
                //强制更新
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ForcedUpdate" object:errorMsg];

            }
        }
        
        //业务异常
        if ([responseDataModel.code integerValue] == 1) {
            if ([errorMsg isEqualToString:@"请先登录"]) {
                if (LoginState == YES) {
                    [UserDefaults setBool:NO forKey:@"loginState"];
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"againLogin" object:responseObject];
                    return;
                } else {
                    return;
                }
            }
            if (![NullTool isNullOrBlank:onlyKey]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UserDefaults setObject:@"" forKey:@"onlyKey"];
                });
                
                return ;
            }
            DLog(@"code等于1：%@", urlString);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if ([NullTool isNullOrBlank:responseDataModel.msg]) {
                    if ([NullTool isNullOrBlank:responseDataModel.errCode]) {
                        [MBProgressHUD showError:@"系统繁忙，请稍后重试"];
                    } else {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"系统繁忙，请稍后重试 [%@]", responseDataModel.errCode]];
                    }
                } else {
                    [MBProgressHUD showError:errorMessage];
                }
            });
        }
        
        if ([responseDataModel.code integerValue] == -1) {
            if (![NullTool isNullOrBlank:onlyKey]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UserDefaults setObject:@"" forKey:@"onlyKey"];
                });                
                return ;
            }
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if ([NullTool isNullOrBlank:responseDataModel.msg]) {
                    if ([NullTool isNullOrBlank:responseDataModel.errCode]) {
                        [MBProgressHUD showError:@"系统繁忙，请稍后重试"];
                    } else {
                        [MBProgressHUD showError:[NSString stringWithFormat:@"系统繁忙，请稍后重试 [%@]", responseDataModel.errCode]];
                    }
                } else {
                    [MBProgressHUD showError:errorMessage];
                }
                
            });
            
            DLog(@"code等于-1：%@", urlString);
        }

        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        fail(error);
        DLog(@"网络连接失败%@", urlString);
    }];
    
}

+ (void)heheHaHa {
    [UserDefaults setObject:@"单点登录" forKey:@"onlyKey"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UserDefaults setObject:@"" forKey:@"onlyKey"];
    });
}

//https
+ (AFSecurityPolicy*)httpsSecurityPolicy {
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:@"DabaySSL3" ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithObject:cerData];
    return securityPolicy;
}

+ (void)updataImage:(NSDictionary *)parameter image:(UIImage *)image {
    image = [UIImage imageCompressForSizeImage:image targetSize:CGSizeMake(100, 100)];
    NSString *endpoint = [NSString stringWithValue:parameter[@"endpoint"] default:@""];
    id<OSSCredentialProvider> credential = [[OSSFederationCredentialProvider alloc] initWithFederationTokenGetter:^OSSFederationToken *{

        OSSTaskCompletionSource * tcs = [OSSTaskCompletionSource taskCompletionSource];
        [tcs setResult:parameter];
        
        
        if (tcs.task.error) {
            NSLog(@"get token error: %@", tcs.task.error);
            return nil;
        } else {
            // 返回数据是json格式,需要解析得到token的各个字段
            OSSFederationToken * token = [OSSFederationToken new];
            token.tAccessKey = [tcs.task.result objectForKey:@"accessKeyId"];
            token.tSecretKey = [tcs.task.result objectForKey:@"accessKeySecret"];
            token.tToken = [tcs.task.result objectForKey:@"securi tyToken"];
            token.expirationTimeInGMTFormat = [tcs.task.result objectForKey:@"expiration"];
            DLog(@"get token: %@", token);
            return token;
        }
        
    }];
    
    // 构造请求访问您的业务server
    OSSClient *client = [[OSSClient alloc] initWithEndpoint:endpoint credentialProvider:credential];
    
    OSSPutObjectRequest * put = [OSSPutObjectRequest new];
    CGFloat nowTime = [NSDate date].timeIntervalSince1970;
    NSString *key = [NSString stringWithFormat:@"%@%@%.0lf.png",[parameter valueForKey:@"uploadDir"],  [UserDefaults valueForKey:@"userName"],nowTime];
    // 必填字段
    put.bucketName = [NSString stringWithValue:parameter[@"bucketName"] default:@""];
    put.objectKey = key;
    
//    UIImage *image = [UIImage imageNamed:@"180"];
    NSData *data = UIImagePNGRepresentation(image);
    put.uploadingData = data; // 直接上传NSData
    
    // 设置Content-Type，可选
    put.contentType = @"application/octet-stream";
    
    // 设置MD5校验，可选
    put.contentMd5 = [OSSUtil base64Md5ForData:data]; // 如果是二进制数据
    
    // 进度设置，可选
    put.uploadProgress = ^(int64_t bytesSent, int64_t totalByteSent, int64_t totalBytesExpectedToSend) {
        // 当前上传段长度、当前已经上传总长度、一共需要上传的总长度
        NSLog(@"%lld, %lld, %lld", bytesSent, totalByteSent, totalBytesExpectedToSend);
    };
    
    OSSTask * putTask = [client putObject:put];
    [putTask continueWithBlock:^id(OSSTask *task) {
        if (!task.error) {
            NSLog(@"upload object success!");
            NSString *fileName = [NSString stringWithFormat:@"%@%.0lf.png", [UserDefaults valueForKey:@"userName"], nowTime];
            [Network upDateSuccess:fileName];
        } else {
            NSLog(@"upload object failed, error: %@" , task.error);
        }
        return nil;
    }];

}


+ (void)upDateSuccess:(NSString *)fileName {

    NSDictionary *dic = @{@"fileName" : fileName};
    [Network postWithUrl:PATH(URL_UploadImg) parameter:dic success:^(id objc) {
        if ([objc[@"code"] integerValue] == 0) {
            [MBProgressHUD showError:@"上传成功"];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"updataImage" object:objc[@"data"] ];
        }
    } fail:^(NSError *error) {
        [MBProgressHUD showError:@"上传失败"];
    }];
}


//查询处方单
+ (void)queryOrder {
    NSString *sessionId = [NSString stringWithValue:[UserDefaults valueForKey:@"sessionId"] default:nil];
    NSDictionary *dic = @{@"sessionId" : sessionId, @"hosId" : @""};
    [Network postWithUrl:PATH(@"/order/queryOrder") parameter:dic success:^(id objc) {
        
        if ([objc[@"code"] integerValue] == 0) {
//            [Network sync:objc[@"data"]];
        } else {
        
        }
        
    } fail:^(NSError *error) {
        
    }];
}

- (void)sync:(NSString *)syncId {
    NSDictionary *dic = @{@"syncId" : [NSString stringWithValue:syncId default:@""]};
    
    [Network postWithUrl:PATH(URL_Sync) parameter:dic success:^(id objc) {
        if ([objc[@"code"] integerValue] == 0) {
            if ([[objc valueForKeyPath:@"data.syncStatus"] integerValue] == 0) {
                if (time < 15) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [self sync:syncId];
                    });
                    time++;

                } else {
                    time = 0;
                }
                
            } else if ([[objc valueForKeyPath:@"data.syncStatus"] integerValue] == 1) {
                [self getTabBarMessageData];
            }
            
        } else {

        }
        
    } fail:^(NSError *error) {

    }];
}




//获取tabBar上的消息
- (void)getTabBarMessageData {
     EKPTabBarC *tabbarC = [[EKPTabBarC alloc] init];
    if (!LoginState) {
        UITabBarItem *item = [[tabbarC.tabBar items] objectAtIndex:3];
        item.badge.hidden = YES;
        return;
    }
    NSDictionary *dic = @{};
    [Network postWithUrl:PATH(URL_TabBarMessage) parameter:dic success:^(id objc) {
        if ([objc[@"code"] integerValue] == 0) {
            TabBarModel *tabModel = [TabBarModel objectFromDictionary:objc[@"data"]];
            
            UITabBarItem *item = [[tabbarC.tabBar items] objectAtIndex:3];
            if ([tabModel.redStatus integerValue] == 0) {
                item.badge.hidden = YES;
            } else {
                [item showBadge];
                item.badgeCenterOffset = CGPointMake(-30, 7);
            }
        }
        
        
    } fail:^(NSError *error) {
        DLog(@"tabBar消息获取失败");
    }];
    
    
}
//(authCodeType:短信/语音验证码  0：短信， 1：语音)
+ (void)sendAuthCode:(NSString *)phoneNumber type:(NSString *)type authCodeType:(NSString *)authCodeType success:(success)success fail:(fail)fail {
    if ([authCodeType integerValue] == 1) { //语音验证码
        NSDictionary *dic = @{@"mobile" : phoneNumber, @"type":type};
        [Network postWithUrl:PATH(URL_VoiceAuthCode) parameter:dic success:^(id objc) {
            success(objc);
        } fail:^(NSError *error) {
            DLog(@"%@", error);
            fail(error);
        }];
    } else {//短信验证码
        NSDictionary *dic = @{@"mobile" : phoneNumber, @"type" : type};
        [Network postWithUrl:PATH(URL_AuthCode) parameter:dic success:^(id objc) {
            success(objc);
        
        } fail:^(NSError *error) {
            DLog(@"%@", error);
            fail(error);
        }];
    
    }
}


//- (AFHTTPRequestOperation *)getServer:(NSString *)path
//                           parameters:(NSDictionary *)parameters
//                              success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
//                              failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
//{
//    NSURLRequest *request = [self requestWithMethod:@"GET" path:path parameters:parameters];
//    AFHTTPRequestOperation *operation = [self HTTPRequestOperationWithRequest:request success:success failure:failure];
//    [self enqueueHTTPRequestOperation:operation];
//    
//    return operation;
//}

@end
