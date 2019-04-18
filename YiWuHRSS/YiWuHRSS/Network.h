//
//  Network.h
//  FMDBManger
//
//  Created by 魏子建 on 15/11/26.
//  Copyright © 2015年 lianhaiq. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AFSecurityPolicy;

typedef void(^success)(id objc);

typedef void(^fail)(NSError *error);

@interface Network : NSObject<UIAlertViewDelegate>

@property (nonatomic, strong) NSURLSessionDataTask *task;

+ (Network *)shareNetwork;

+ (void)getWithUrl:(NSString *)urlString success:(success)success fail:(fail)fail;

+ (void)postWithUrl:(NSString *)urlString parameter:(NSDictionary *)parameter success:(success)success fail:(fail)fail;

+ (void)updataImage:(NSDictionary *)parameter image:(UIImage *)image;

+ (void)queryOrder;

+ (void)sendAuthCode:(NSString *)phoneNumber type:(NSString *)type authCodeType:(NSString *)authCodeType success:(success)success fail:(fail)fail;

+ (AFSecurityPolicy *)httpsSecurityPolicy;


@end
