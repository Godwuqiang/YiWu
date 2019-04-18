//
//  RegistHttpBL.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistHttpBL.h"
#import "HttpHelper.h"
#import "MJExtension.h"


#define   VALIDATE_CARD_URL     @"/userServer/validate_card.json?"
#define   REGIST_ACCOUNT_URL    @"/userServer/register.json?"
#define      SMS_CODE_URL       @"/shebao/sendMsg.json"
#define     VERIFY_ID_URL       @"/user/resetPassword/valid.json?"
#define  CHANGPSD_SMSCODE_URL   @"/shebao/sendMsgValidate?"
#define     SMK_STATUS_URL      @"/smk/smk_ygs_check.json?"
#define     VALIDE_CODE_URL     @"/smk/checkValid.json?"
#define     SMK_GUASHI_URL      @"/smk/smk_operate.json?"



@implementation RegistHttpBL


+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

//验证银行卡的接口
-(void)ValidateCardHttp:(NSString*)name shbzh:(NSString*)shbzh cardno:(NSString*)cardno bankCard:(NSString*)bankCard card_type:(NSString*)card_type{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:name forKey:@"name"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:cardno forKey:@"cardNo"];
    [param setValue:bankCard forKey:@"bankCard"];
    [param setValue:card_type forKey:@"cardType"];
    [param setValue:@"2" forKey:@"deviceType"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,VALIDATE_CARD_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardFail:)]){
            [[[RegistHttpBL sharedManager] delegate] ValidateCardFail:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] ValidateCardFail:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 200)
                    {
//                        NSDictionary *arrayInfo = [resultDict objectForKey:@"data"];
//                        ValidateCardBean *bean = [ValidateCardBean mj_objectWithKeyValues:arrayInfo];
                        // 成功
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardSucess:)]){
                            [[[RegistHttpBL sharedManager] delegate] ValidateCardSucess:@"验证通过"];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardFail:)]){
                            [[[RegistHttpBL sharedManager] delegate] ValidateCardFail:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] ValidateCardFail:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(ValidateCardFail:)]){
                [[[RegistHttpBL sharedManager] delegate] ValidateCardFail:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

//最后的注册账号接口
-(void)RegisterUserHttp:(NSString*)name password:(NSString*)password againpsd:(NSString*)againpsd cardType:(NSString*)cardType shbzh:(NSString*)shbzh bankCard:(NSString*)bankCard cardno:(NSString*)cardno appMobile:(NSString*)appMobile andvalidCode:(NSString*)validCode{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:name forKey:@"name"];
    [param setValue:password forKey:@"password"];
    [param setValue:againpsd forKey:@"password_again"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:cardno forKey:@"cardNo"];
    [param setValue:bankCard forKey:@"bankCard"];
    [param setValue:cardType forKey:@"cardType"];
    [param setValue:appMobile forKey:@"appMobile"];
    [param setValue:validCode forKey:@"validCode"];
    [param setValue:@"2" forKey:@"deviceType"];
    NSString *UUIDString = [[UIDevice currentDevice].identifierForVendor UUIDString];
    [param setValue:UUIDString forKey:@"imei"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,REGIST_ACCOUNT_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountFail:)]){
            [[[RegistHttpBL sharedManager] delegate] RegistAccountFail:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] RegistAccountFail:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES || iStatus == 200)
                    {
                        NSDictionary *arrayInfo = [resultDict objectForKey:@"data"];
                        UserBean *bean = [UserBean mj_objectWithKeyValues:arrayInfo];
                        // 成功
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountSucess:)]){
                            [[[RegistHttpBL sharedManager] delegate] RegistAccountSucess:bean];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountFail:)]){
                            [[[RegistHttpBL sharedManager] delegate] RegistAccountFail:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] RegistAccountFail:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(RegistAccountFail:)]){
                [[[RegistHttpBL sharedManager] delegate] RegistAccountFail:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 短信验证接口
-(void)requestSMSCode:(NSString*)mobile andmessage_type:(NSString*)message_type{
    // 1. 配置接口地址和参数
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobile forKey:@"mobileNo"];
    [param setValue:message_type forKey:@"message_type"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SMS_CODE_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeFail:)]){
            [[[RegistHttpBL sharedManager] delegate] requestSMSCodeFail:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] requestSMSCodeFail:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES || iStatus == 200)
                    {
                        NSArray *arrayInfo = [resultDict objectForKey:@"data"];
                        NSDictionary *dict = arrayInfo[0];
                        SMSCodeBean *bean = [SMSCodeBean mj_objectWithKeyValues:dict];
                        // 成功
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeSucess:)]){
                            [[[RegistHttpBL sharedManager] delegate] requestSMSCodeSucess:bean];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeFail:)]){
                            [[[RegistHttpBL sharedManager] delegate] requestSMSCodeFail:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] requestSMSCodeFail:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestSMSCodeFail:)]){
                [[[RegistHttpBL sharedManager] delegate] requestSMSCodeFail:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 找回密码验证身份接口
-(void)verifySFWith:(NSString*)app_mobile andSHBZH:(NSString*)shbzh{

    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:app_mobile forKey:@"app_mobile"];
    [param setValue:shbzh forKey:@"shbzh"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,VERIFY_ID_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFFail:)]){
            [[[RegistHttpBL sharedManager] delegate] verifySFFail:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] verifySFFail:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES || iStatus == 200)
                    {
                        NSString *temp = [resultDict objectForKey:@"message"];
                        // 成功
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFSucess:)]){
                            [[[RegistHttpBL sharedManager] delegate] verifySFSucess:temp];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFFail:)]){
                            [[[RegistHttpBL sharedManager] delegate] verifySFFail:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] verifySFFail:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(verifySFFail:)]){
                [[[RegistHttpBL sharedManager] delegate] verifySFFail:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 修改登录密码发送验证码接口
-(void)requestChangPsdSMSCode:(NSString*)mobile andmessage_type:(NSString*)message_type andold_psd:(NSString*)old_psd{
    // 1. 配置接口地址和参数
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobile forKey:@"mobileNo"];
    [param setValue:old_psd forKey:@"old_password"];
    [param setValue:message_type forKey:@"message_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,CHANGPSD_SMSCODE_URL];
    DMLog(@"changpsdurl=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeFail:)]){
            [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeFail:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeFail:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES || iStatus == 200)
                    {
                        NSArray *arrayInfo = [resultDict objectForKey:@"data"];
                        NSDictionary *dict = arrayInfo[0];
                        SMSCodeBean *bean = [SMSCodeBean mj_objectWithKeyValues:dict];
                        // 成功
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeSucess:)]){
                            [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeSucess:bean];
                        }
                    }else{
                        NSString *temp = [resultDict objectForKey:@"message"];
                        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeFail:)]){
                            [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeFail:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeFail:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            // 失败
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(requestChangPsdSMSCodeFail:)]){
                [[[RegistHttpBL sharedManager] delegate] requestChangPsdSMSCodeFail:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 市民卡预挂失资格查询接口
-(void)checkSMKstatusWith:(NSString*)accessToken{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:accessToken forKey:@"accessToken"];
    [param setValue:@"2" forKey:@"deviceType"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SMK_STATUS_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(checkSMKstatusFail:)]){
                [[[RegistHttpBL sharedManager] delegate] checkSMKstatusFail:@"服务暂不可用，请稍后重试"];
            }
        }else{
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 9999)
                {
                    NSArray *arrayInfo = [resultDict objectForKey:@"data"];
                    NSDictionary *dict = arrayInfo[0];
                    SMKStatusBean *bean = [SMKStatusBean mj_objectWithKeyValues:dict];
                    // 成功
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(checkSMKstatusSucess:)]){
                        [[[RegistHttpBL sharedManager] delegate] checkSMKstatusSucess:bean];
                    }
                }else{
                    NSString *msg;   
                    if (iStatus == 5001 || iStatus == 5002) {
                        msg = [resultDict objectForKey:@"resultCode"];
                    }else{
                        msg = @"失败";
                    }
                    
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(checkSMKstatusFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] checkSMKstatusFail:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(checkSMKstatusFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] checkSMKstatusFail:@"服务暂不可用，请稍后重试"];
                }
            }
        }
    } failure:^(NSError *error) {
        // 失败
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(checkSMKstatusFail:)]){
            [[[RegistHttpBL sharedManager] delegate] checkSMKstatusFail:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 市民卡预挂失中验证验证码是否有效接口
-(void)CheckYZMValidWith:(NSString*)mobileNo andvalidCode:(NSString*)validCode{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:mobileNo forKey:@"mobileNo"];
    [param setValue:validCode forKey:@"validCode"];
    [param setValue:@"2" forKey:@"deviceType"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,VALIDE_CODE_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(CheckYZMValidFail:)]){
                [[[RegistHttpBL sharedManager] delegate] CheckYZMValidFail:@"服务暂不可用，请稍后重试"];
            }
        }else{
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 9999)
                {
                    NSString *temp = [resultDict objectForKey:@"message"];
                    // 成功
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(CheckYZMValidSucess:)]){
                        [[[RegistHttpBL sharedManager] delegate] CheckYZMValidSucess:temp];
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(CheckYZMValidFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] CheckYZMValidFail:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(CheckYZMValidFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] CheckYZMValidFail:@"服务暂不可用，请稍后重试"];
                }
            }
        }
    } failure:^(NSError *error) {
        // 失败
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(CheckYZMValidFail:)]){
            [[[RegistHttpBL sharedManager] delegate] CheckYZMValidFail:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 市民卡预挂失业务发起接口
-(void)guashiSMKWith:(NSString*)accessToken andmobileNo:(NSString*)mobileNo andvalidCode:(NSString*)validCode{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:accessToken forKey:@"accessToken"];
    [param setValue:mobileNo forKey:@"mobileNo"];
    [param setValue:validCode forKey:@"validCode"];
    [param setValue:@"2" forKey:@"deviceType"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SMK_GUASHI_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(guashiSMKFail:)]){
                [[[RegistHttpBL sharedManager] delegate] guashiSMKFail:@"服务暂不可用，请稍后重试"];
            }
        }else{
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
//                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (iStatus == 9999)
                {
                    NSString *temp = [resultDict objectForKey:@"message"];
                    // 成功
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(guashiSMKSucess:)]){
                        [[[RegistHttpBL sharedManager] delegate] guashiSMKSucess:temp];
                    }
                }else{
                    NSString *msg;
                    if (iStatus==1000 || iStatus == 5001 || iStatus == 5002) {
                        msg = [resultDict objectForKey:@"resultCode"];
                    }else{
                        msg = [resultDict objectForKey:@"message"];
                    }
                    if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(guashiSMKFail:)]){
                        [[[RegistHttpBL sharedManager] delegate] guashiSMKFail:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(guashiSMKFail:)]){
                    [[[RegistHttpBL sharedManager] delegate] guashiSMKFail:@"服务暂不可用，请稍后重试"];
                }
            }
        }
    } failure:^(NSError *error) {
        // 失败
        if([[[RegistHttpBL sharedManager] delegate] respondsToSelector:@selector(guashiSMKFail:)]){
            [[[RegistHttpBL sharedManager] delegate] guashiSMKFail:@"服务暂不可用，请稍后重试"];
        }
    }];
}


/*
 1.当网络连接发生变化的时候，而你需要得到通知，那么就可以选择Reachability
 2.如果你只是想简单的知道网络连接情况，连接还是未连接，那么就可以用下面这个方法 需要用到SystemConfiguration.framework，记得在头文件中引入其库
 #import <SystemConfiguration/SystemConfiguration.h>
 */
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
