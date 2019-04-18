//
//  BankBL.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/10.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BankBL.h"
#import "HttpHelper.h"

#define BANK_OPEN_SMS_URL     @"user/yhkzf_opsend.json?"
#define BANK_OPEN_URL         @"user/yhkzf_opverify.json?"
#define BANK_CLOSE_SMS_URL    @"user/yhkzf_closend.json?"
#define BANK_CLOSE_URL        @"user/yhkzf_cloverify.json?"


@implementation BankBL

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 银行卡支付开通----短信发送接口回调
-(void)requestBankOpenSMSCodeWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andAccess_Token:(NSString *)access_token{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:name forKey:@"name"];
//    [param setValue:shbzh forKey:@"shbzh"];
//    [param setValue:cardno forKey:@"cardno"];
//    [param setValue:bankcard forKey:@"bankCard"];
//    [param setValue:card_type forKey:@"card_type"];
    
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,BANK_OPEN_SMS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSMSCodeFailed:)]){
            [[[BankBL sharedManager] delegate] requestBankOpenSMSCodeFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES && iStatus == 200)
                {
                    NSString *serNum = [resultDict objectForKey:@"data"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSMSCodeSucceed:)]){
                        [[[BankBL sharedManager] delegate] requestBankOpenSMSCodeSucceed:serNum];
                    }
                }else{
                    //                NSString *temp;
                    //                if (iStatus==5001 || iStatus == 5002) {
                    //                    temp = [resultDict objectForKey:@"resultCode"];
                    //                }else{
                    //                    temp = [resultDict objectForKey:@"message"];
                    //                }
                    NSString *temp = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSMSCodeFailed:)]){
                        [[[BankBL sharedManager] delegate] requestBankOpenSMSCodeFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSMSCodeFailed:)]){
                    [[[BankBL sharedManager] delegate] requestBankOpenSMSCodeFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSMSCodeFailed:)]){
                [[[BankBL sharedManager] delegate] requestBankOpenSMSCodeFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 银行卡支付开通-----短信验证
-(void)requestBankOpenWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andverCode:(NSString*)verCode andAccess_Token:(NSString *)access_token{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:name forKey:@"name"];
//    [param setValue:shbzh forKey:@"shbzh"];
//    [param setValue:cardno forKey:@"cardno"];
//    [param setValue:bankcard forKey:@"bankCard"];
//    [param setValue:card_type forKey:@"card_type"];
//    [param setValue:serNum forKey:@"serNum"];
    [param setValue:verCode forKey:@"verCode"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,BANK_OPEN_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenFailed:)]){
            [[[BankBL sharedManager] delegate] requestBankOpenFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES && iStatus == 200)
                {
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenSucceed:)]){
                        [[[BankBL sharedManager] delegate] requestBankOpenSucceed:msg];
                    }
                }else{
                    //                NSString *temp;
                    //                if (iStatus==5001 || iStatus == 5002) {
                    //                    temp = [resultDict objectForKey:@"resultCode"];
                    //                }else{
                    //                    temp = [resultDict objectForKey:@"message"];
                    //                }
                    NSString *temp = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenFailed:)]){
                        [[[BankBL sharedManager] delegate] requestBankOpenFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenFailed:)]){
                    [[[BankBL sharedManager] delegate] requestBankOpenFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankOpenFailed:)]){
                [[[BankBL sharedManager] delegate] requestBankOpenFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 银行卡支付注销-----短信发送
-(void)requestBankCloseSMSCodeWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:name forKey:@"name"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:cardno forKey:@"cardno"];
    [param setValue:bankcard forKey:@"bankCard"];
    [param setValue:card_type forKey:@"card_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,BANK_CLOSE_SMS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSMSCodeFailed:)]){
            [[[BankBL sharedManager] delegate] requestBankCloseSMSCodeFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 200)
                {
                    NSString *serNum = [resultDict objectForKey:@"data"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSMSCodeSucceed:)]){
                        [[[BankBL sharedManager] delegate] requestBankCloseSMSCodeSucceed:serNum];
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSMSCodeFailed:)]){
                        [[[BankBL sharedManager] delegate] requestBankCloseSMSCodeFailed:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSMSCodeFailed:)]){
                    [[[BankBL sharedManager] delegate] requestBankCloseSMSCodeFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSMSCodeFailed:)]){
                [[[BankBL sharedManager] delegate] requestBankCloseSMSCodeFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 银行卡支付注销-----短信验证
-(void)requestBankCloseWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andAccess_Token:(NSString *)access_token{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:name forKey:@"name"];
//    [param setValue:shbzh forKey:@"shbzh"];
//    [param setValue:cardno forKey:@"cardno"];
//    [param setValue:bankcard forKey:@"bankCard"];
//    [param setValue:card_type forKey:@"card_type"];
//    [param setValue:serNum forKey:@"serNum"];
//    [param setValue:verCode forKey:@"verCode"];
    
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,BANK_CLOSE_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseFailed:)]){
            [[[BankBL sharedManager] delegate] requestBankCloseFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES && iStatus == 200)
                {
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseSucceed:)]){
                        [[[BankBL sharedManager] delegate] requestBankCloseSucceed:msg];
                    }
                }else{
                    //                NSString *temp;
                    //                if (iStatus==5001 || iStatus == 5002) {
                    //                    temp = [resultDict objectForKey:@"resultCode"];
                    //                }else{
                    //                    temp = [resultDict objectForKey:@"message"];
                    //                }
                    NSString *temp = [resultDict objectForKey:@"message"];
                    if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseFailed:)]){
                        [[[BankBL sharedManager] delegate] requestBankCloseFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseFailed:)]){
                    [[[BankBL sharedManager] delegate] requestBankCloseFailed:@"服务暂不可用，请稍后重试 "];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[BankBL sharedManager] delegate] respondsToSelector:@selector(requestBankCloseFailed:)]){
                [[[BankBL sharedManager] delegate] requestBankCloseFailed:@"服务暂不可用，请稍后重试 "];
            }
        }];
    }
}

- (BOOL) isConnectionAvailable
{
    SCNetworkReachabilityFlags flags;
    BOOL receivedFlags;
    
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(CFAllocatorGetDefault(), [@"dipinkrishna.com" UTF8String]);
    receivedFlags = SCNetworkReachabilityGetFlags(reachability, &flags);
    CFRelease(reachability);
    
    if (!receivedFlags || (flags == 0) )
    {
        return FALSE;
    } else {
        return TRUE;
    }
}

@end
