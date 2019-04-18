//
//  LoginHttpBL.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "LoginHttpBL.h"
#import "HttpHelper.h"
#import "UserBean.h"
#import "MJExtension.h"
#import "AESCipher.h"
#import "NSString+category.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key


#define             LoginURL              @"/userServer/loginSystem.json?" // 登录接口
#define      CHANGE_CARD_STATUS_URL       @"/cardServer/update_cardInfo.json?"
#define         CONNECT_YKF_URL           @"user/updateSiCard?"
#define      NOTICE_CARD_STATUS_URL       @"/cardServer/update_SicardIssendStatus.json"
#define        RESET_LOGIN_PSD_URL        @"/user/reset_password.json?"


@implementation LoginHttpBL

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

-(void)LoginRequest:(NSString*)mobile Password:(NSString*)password{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    
    NSString * aesPswString =aesEncryptString(password, AESEncryptKey);
    // 当前应用软件版本 比如：1.2.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:mobile forKey:@"mobile"];
    [param setValue:aesPswString forKey:@"password"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:appCurVersion forKey:@"app_version"]; // app版本
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
    


    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,LoginURL];
    
    if (![self isConnectionAvailable]) {
        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginFailed:)]){
            [[[LoginHttpBL sharedManager] delegate] requestLoginFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"登录login resultDict: %@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginFailed:)]){
                    [[[LoginHttpBL sharedManager] delegate] requestLoginFailed:@"服务暂不可用，请稍后重试 "];
                }
            }else{
                @try {
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    if(resultTag.boolValue==YES){
                        NSDictionary *arrayInfo = [resultDict objectForKey:@"data"];
                        UserBean *bean = [UserBean mj_objectWithKeyValues:arrayInfo];
                        // 成功
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginSucceed:)]){
                            [[[LoginHttpBL sharedManager] delegate] requestLoginSucceed:bean];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginFailed:)]){
                            [[[LoginHttpBL sharedManager] delegate] requestLoginFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginFailed:)]){
                        [[[LoginHttpBL sharedManager] delegate] requestLoginFailed:@"服务暂不可用，请稍后重试 "];
                    }
                }
            }
        } failure:^(NSError *error) {
            // 失败
            if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(requestLoginFailed:)]){
                [[[LoginHttpBL sharedManager] delegate] requestLoginFailed:@"服务暂不可用，请稍后重试 "];
            }
        }];
    }
}

// 修改市民卡状态接口
-(void)ChangCardStatusWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardno:(NSString*)cardno andBankCard:(NSString*)bankCard andCard_Type:(NSString*)card_type andAccess_Token:(NSString*)access_token{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:name forKey:@"name"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:cardno forKey:@"cardno"];
    [param setValue:bankCard forKey:@"bankCard"];
    [param setValue:card_type forKey:@"card_type"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,CHANGE_CARD_STATUS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusFailed:)]){
            [[[LoginHttpBL sharedManager] delegate] ChangCardStatusFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusFailed:)]){
                    [[[LoginHttpBL sharedManager] delegate] ChangCardStatusFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    int iStatus = temp.intValue;
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    if (resultTag.boolValue==YES || iStatus == 1000)
                    {
                        NSArray *arrayInfo = [resultDict objectForKey:@"data"];
                        NSDictionary *dict = arrayInfo[0];
                        ChangeCardBean *bean = [ChangeCardBean mj_objectWithKeyValues:dict];
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusSucceed:)]){
                            [[[LoginHttpBL sharedManager] delegate] ChangCardStatusSucceed:bean];
                        }
                    }else{
                        NSString *msg = [resultDict objectForKey:@"message"];
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusFailed:)]){
                            [[[LoginHttpBL sharedManager] delegate] ChangCardStatusFailed:msg];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusFailed:)]){
                        [[[LoginHttpBL sharedManager] delegate] ChangCardStatusFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            // 失败
            if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ChangCardStatusFailed:)]){
                [[[LoginHttpBL sharedManager] delegate] ChangCardStatusFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 通知杭州医快付云平台接口
-(void)ConnetYKFWithBean:(ChangeCardBean*)bean{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *cardtype = [Util IsStringNil:bean.cardType]?@"":bean.cardType;
    [param setValue:cardtype forKey:@"cardType"];
    NSString *sourceuserid = [Util IsStringNil:bean.sourceUserId]?@"":bean.sourceUserId;
    [param setValue:sourceuserid forKey:@"sourceUserId"];
    NSString *oldcardnum = [Util IsStringNil:bean.oldCardNum]?@"":bean.oldCardNum;
    [param setValue:oldcardnum forKey:@"oldCardNum"];
    NSString *oldsicard = [Util IsStringNil:bean.oldSiCard]?@"":bean.oldSiCard;
    [param setValue:oldsicard forKey:@"oldSiCard"];
    NSString *oldidcard = [Util IsStringNil:bean.oldIdCard]?@"":bean.oldIdCard;
    [param setValue:oldidcard forKey:@"oldIdCard"];
    NSString *oldidcode = [Util IsStringNil:bean.oldIdCode]?@"":bean.oldIdCode;
    [param setValue:oldidcode forKey:@"oldIdCode"];
    NSString *username = [Util IsStringNil:bean.userName]?@"":bean.userName;
    [param setValue:username forKey:@"userName"];
    NSString *mobile = [Util IsStringNil:bean.mobile]?@"":bean.mobile;
    [param setValue:mobile forKey:@"mobile"];
    NSString *idcard = [Util IsStringNil:bean.idCard]?@"":bean.idCard;
    [param setValue:idcard forKey:@"idCard"];
    NSString *cardnum = [Util IsStringNil:bean.cardNum]?@"":bean.cardNum;
    [param setValue:cardnum forKey:@"cardNum"];
    NSString *sicard = [Util IsStringNil:bean.siCard]?@"":bean.siCard;
    [param setValue:sicard forKey:@"siCard"];
    NSString *idcode = [Util IsStringNil:bean.idCode]?@"":bean.idCode;
    [param setValue:idcode forKey:@"idCode"];
    NSString *banknum = [Util IsStringNil:bean.bankNum]?@"":bean.bankNum;
    [param setValue:banknum forKey:@"bankNum"];
    NSString *bankcode = [Util IsStringNil:bean.bankCode]?@"":bean.bankCode;
    [param setValue:bankcode forKey:@"bankCode"];
    NSString *flag = [Util IsStringNil:bean.flag]?@"":bean.flag;
    [param setValue:flag forKey:@"flag"];
    NSString *exp = [Util IsStringNil:bean.exp]?@"":bean.exp;
    [param setValue:exp forKey:@"exp"];
    NSString *sign = [Util IsStringNil:bean.sign]?@"":bean.sign;
    [param setValue:sign forKey:@"sign"];
    NSString *source = [Util IsStringNil:bean.source]?@"":bean.source;
    [param setValue:source forKey:@"source"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",YKF_HOST,CONNECT_YKF_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFFailed:)]){
            [[[LoginHttpBL sharedManager] delegate] ConnetYKFFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFFailed:)]){
                    [[[LoginHttpBL sharedManager] delegate] ConnetYKFFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"code"];
                    int iStatus = temp.intValue;
                    if (iStatus == 0)
                    {
                        NSString *msg = [resultDict objectForKey:@"message"];
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFSucceed:)]){
                            [[[LoginHttpBL sharedManager] delegate] ConnetYKFSucceed:msg];
                        }
                    }else{
                        NSString *msg = [resultDict objectForKey:@"message"];
                        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFFailed:)]){
                            [[[LoginHttpBL sharedManager] delegate] ConnetYKFFailed:msg];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFFailed:)]){
                        [[[LoginHttpBL sharedManager] delegate] ConnetYKFFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            // 失败
            if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(ConnetYKFFailed:)]){
                [[[LoginHttpBL sharedManager] delegate] ConnetYKFFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 修改卡的通知状态接口
-(void)NoticeChangStatusWithCardno:(NSString*)cardno andShbzh:(NSString*)shbzh andcard_type:(NSString*)card_type andbankCard:(NSString*)bankCard{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:cardno forKey:@"cardno"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:card_type forKey:@"card_type"];
    [param setValue:bankCard forKey:@"bankCard"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,NOTICE_CARD_STATUS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdFailed:)]){
            [[[LoginHttpBL sharedManager] delegate] resetLoginPsdFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
//                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
//                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES)
                {
//                    NSString *msg = [resultDict objectForKey:@"message"];
                    NSString *msg = @"已通知本地服务";
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(NoticeChangStatusSucceed:)]){
                        [[[LoginHttpBL sharedManager] delegate] NoticeChangStatusSucceed:msg];
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(NoticeChangStatusFailed:)]){
                        [[[LoginHttpBL sharedManager] delegate] NoticeChangStatusFailed:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(NoticeChangStatusFailed:)]){
                    [[[LoginHttpBL sharedManager] delegate] NoticeChangStatusFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            // 失败
            if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(NoticeChangStatusFailed:)]){
                [[[LoginHttpBL sharedManager] delegate] NoticeChangStatusFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 重置密码接口
-(void)resetLoginPsdWith:(NSString*)app_mobile andnewpsd:(NSString*)new_password andvalidCode:(NSString*)validCode{
    
    NSString * shbzhAES = aesEncryptString(app_mobile, AESEncryptKey);
    NSString * new_passwordAES = aesEncryptString(new_password, AESEncryptKey);
    


    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:shbzhAES forKey:@"shbzh"];
    [param setValue:new_passwordAES forKey:@"new_password"];
    [param setValue:validCode forKey:@"validCode"];
    [param setValue:@"2" forKey:@"device_type"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/userServer/password/reset/aes",HOST_TEST];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdFailed:)]){
            [[[LoginHttpBL sharedManager] delegate] resetLoginPsdFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES || iStatus == 200)
                {
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdSucceed:)]){
                        [[[LoginHttpBL sharedManager] delegate] resetLoginPsdSucceed:msg];
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdFailed:)]){
                        [[[LoginHttpBL sharedManager] delegate] resetLoginPsdFailed:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdFailed:)]){
                    [[[LoginHttpBL sharedManager] delegate] resetLoginPsdFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[LoginHttpBL sharedManager] delegate] respondsToSelector:@selector(resetLoginPsdFailed:)]){
                [[[LoginHttpBL sharedManager] delegate] resetLoginPsdFailed:@"服务暂不可用，请稍后重试"];
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
