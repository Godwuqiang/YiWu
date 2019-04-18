//
//  WebBL.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "WebBL.h"
#import "HttpHelper.h"
#import "MJExtension.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key
#define    PicURL             @"/nameAuth/uploadImages.do?"
#define    NET_POINT_URL          @"news/netServicePoint.json?"
#define    CHANGE_LOGIN_PSD_URL      @"userServer/password/update/aes"
#define    QUERY_HOME_ADDRESS_URL   @"userServer/get_userAddress.json"
#define    CHANGE_HOME_ADDRESS_URL   @"user/add_address.json?"
#define    QUERY_PUBLIC_PARK_URL     @"public/getPublicCarList.json" // 获取公共汽车停车位信息（无搜索）
#define    QUERY_PARK_INFO_URL      @"public/getPublicCarInfo.json"
#define    GETPUBLICCARSEARCHLIST   @"public/getPublicCarSearchList.json"  // 获取公共汽车停车位信息（含搜索版）



@implementation WebBL

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 服务网点接口
-(void)queryNetWorkPointWithKeyWords:(NSString*)keywords andbankMark:(NSString*)bankMark andpageNum:(int)pageNum andpageSize:(int)pageSize isMaked:(NSString *)isMaked isResetPassword:(NSString *)isResetPassword {

    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LAT]?@"":[CoreArchive strForKey:CURRENT_LAT];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LON]?@"": [CoreArchive strForKey:CURRENT_LON];
    NSString *no = [NSString stringWithFormat:@"%d",pageNum];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:isMaked forKey:@"isMaked"];
    [param setValue:isResetPassword forKey:@"isResetPassword"];
    [param setValue:bankMark forKey:@"bank_mark"];
    [param setValue:lat forKey:@"jingdu"];
    [param setValue:lng forKey:@"weidu"];
    [param setValue:keywords forKey:@"key_words"];
    [param setValue:no forKey:@"page_num"];
    [param setValue:size forKey:@"page_size"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);

    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NET_POINT_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointFailed:)]){
            [[[WebBL sharedManager] delegate] queryNetWorkPointFailed:@"当前网络不可用，请检查网络设置"];
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
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"data"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointSucceed:)]){
                            [[[WebBL sharedManager] delegate] queryNetWorkPointSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            NetPointBean *bean = [NetPointBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointSucceed:)]){
                            [[[WebBL sharedManager] delegate] queryNetWorkPointSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [resultDict objectForKey:@"resultCode"];
                    }else{
                        temp = [resultDict objectForKey:@"message"];
                    }
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointFailed:)]){
                        [[[WebBL sharedManager] delegate] queryNetWorkPointFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointFailed:)]){
                    [[[WebBL sharedManager] delegate] queryNetWorkPointFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryNetWorkPointFailed:)]){
                [[[WebBL sharedManager] delegate] queryNetWorkPointFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 修改登录密码接口
-(void)ChangLoginPsdWithMobile:(NSString*)mobile andOldPsd:(NSString*)oldpsd andNewPsd:(NSString*)newpsd andAgainPsd:(NSString*)againpsd andvalidCode:(NSString*)validCode andaccessToken:(NSString*)token{
    
    
    NSString * old_passwordAES = aesEncryptString(oldpsd, AESEncryptKey);
    NSString * new_passwordAES = aesEncryptString(newpsd, AESEncryptKey);
    NSString * new_password_againAES = aesEncryptString(againpsd, AESEncryptKey);


    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:mobile forKey:@"app_mobile"];
    [param setValue:old_passwordAES forKey:@"old_password"];
    [param setValue:new_passwordAES forKey:@"new_password"];
    [param setValue:new_password_againAES forKey:@"new_password_again"];
//    [param setValue:validCode forKey:@"validCode"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:token forKey:@"access_token"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CHANGE_LOGIN_PSD_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangLoginPsdFailed:)]){
            [[[WebBL sharedManager] delegate] ChangLoginPsdFailed:@"当前网络不可用，请检查网络设置"];
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
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangLoginPsdSucceed:)]){
                        [[[WebBL sharedManager] delegate] ChangLoginPsdSucceed:msg];
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangLoginPsdFailed:)]){
                        [[[WebBL sharedManager] delegate] ChangLoginPsdFailed:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangLoginPsdFailed:)]){
                    [[[WebBL sharedManager] delegate] ChangLoginPsdFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangLoginPsdFailed:)]){
                [[[WebBL sharedManager] delegate] ChangLoginPsdFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 获取家庭地址
-(void)queryHomeAddressWithAccessToken:(NSString*)access_token{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,QUERY_HOME_ADDRESS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressFailed:)]){
            [[[WebBL sharedManager] delegate] ChangHomeAddressFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                if(resultTag.boolValue==YES){
                    NSDictionary *arrayInfo = [resultDict objectForKey:@"data"];
                    UserBean *bean = [UserBean mj_objectWithKeyValues:arrayInfo];
                    
                    // 成功
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryHomeAddressSucceed:)]){
                        [[[WebBL sharedManager] delegate] queryHomeAddressSucceed:bean];
                    }
                }else{
                    NSString *temp = [resultDict objectForKey:@"message"];
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryHomeAddressFailed:)]){
                        [[[WebBL sharedManager] delegate] queryHomeAddressFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryHomeAddressFailed:)]){
                    [[[WebBL sharedManager] delegate] queryHomeAddressFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryHomeAddressFailed:)]){
                [[[WebBL sharedManager] delegate] queryHomeAddressFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
    
}

// 添加/修改用户家庭住址
-(void)ChangHomeAddressWithAccessToken:(NSString*)access_token andDeviceType:(NSString*)devicetype andAddress:(NSString*)address{

    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:devicetype forKey:@"device_type"];
    [param setValue:address forKey:@"address"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CHANGE_HOME_ADDRESS_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressFailed:)]){
            [[[WebBL sharedManager] delegate] ChangHomeAddressFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",resultDict);
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES && iStatus == 1000)
                {
                    NSString *msg = [resultDict objectForKey:@"message"];
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressSucceed:)]){
                        [[[WebBL sharedManager] delegate] ChangHomeAddressSucceed:msg];
                    }
                }else{
                    NSString *temp = [resultDict objectForKey:@"message"];
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressFailed:)]){
                        [[[WebBL sharedManager] delegate] ChangHomeAddressFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressFailed:)]){
                    [[[WebBL sharedManager] delegate] ChangHomeAddressFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            DMLog(@"%@",error);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(ChangHomeAddressFailed:)]){
                [[[WebBL sharedManager] delegate] ChangHomeAddressFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 获取公共汽车停车位信息
-(void)queryPublicParksWithLongitude:(NSString *)lon andLatitude:(NSString *)lat andType:(NSString *)type andpageNo:(int)pageNo andpageSize:(int)pageSize {

//    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
//    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:lon forKey:@"longitude"];
    [param setValue:lat forKey:@"latitude"];
    [param setValue:type forKey:@"type"];
    [param setValue:@(pageNo) forKey:@"page_no"];
    [param setValue:@(pageSize) forKey:@"page_size"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,QUERY_PUBLIC_PARK_URL];
//    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"获取公共汽车停车位信息（无搜索）：%@",resultDict);
        @try {
            NSString *code = [resultDict objectForKey:@"resultCode"];
//            NSNumber *resultTag = [resultDict objectForKey:@"success"];
            if (code.intValue == 200)
            {
                NSArray *arrTemp = [[NSArray alloc] init];
                arrTemp = [resultDict objectForKey:@"data"];
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                if (arrTemp.count==0||arrTemp==NULL) {
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksSucceed:)]){
                        [[[WebBL sharedManager] delegate] queryPublicParksSucceed:models];
                    }
                }else{
                    for (NSDictionary *dict in arrTemp) {
                        ParkBean *bean = [ParkBean mj_objectWithKeyValues:dict];
                        [models addObject:bean];
                    }
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksSucceed:)]){
                        [[[WebBL sharedManager] delegate] queryPublicParksSucceed:models];
                    }
                }
            }else{
                NSString *temp = [resultDict objectForKey:@"message"];
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
                    [[[WebBL sharedManager] delegate] queryPublicParksFailed:temp];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
                [[[WebBL sharedManager] delegate] queryPublicParksFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
        DMLog(@"%@",error);
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
            [[[WebBL sharedManager] delegate] queryPublicParksFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
    
}

// 获取公共汽车停车位信息（含搜索版）
- (void)getPublicCarSearchListWithLongitude:(NSString *)log andLatitude:(NSString *)lat andKeywords:(NSString *)keywords andType:(NSString *)type andpageNo:(int)pageNo andpageSize:(int)pageSize {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:log forKey:@"longitude"];
    [param setValue:lat forKey:@"latitude"];
    [param setValue:keywords forKey:@"key_word"];
    [param setValue:type forKey:@"type"];
    [param setValue:@(pageNo) forKey:@"page_no"];
    [param setValue:@(pageSize) forKey:@"page_size"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,GETPUBLICCARSEARCHLIST];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"获取公共汽车停车位信息（含搜索版: %@",resultDict);
        @try {
            NSString *code = [resultDict objectForKey:@"resultCode"];
            //            NSNumber *resultTag = [resultDict objectForKey:@"success"];
            if (code.intValue == 200)
            {
                NSArray *arrTemp = [[NSArray alloc] init];
                arrTemp = [resultDict objectForKey:@"data"];
                NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                if (arrTemp.count==0||arrTemp==NULL) {
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksSucceed:)]){
                        [[[WebBL sharedManager] delegate] queryPublicParksSucceed:models];
                    }
                }else{
                    for (NSDictionary *dict in arrTemp) {
                        ParkBean *bean = [ParkBean mj_objectWithKeyValues:dict];
                        [models addObject:bean];
                    }
                    if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksSucceed:)]){
                        [[[WebBL sharedManager] delegate] queryPublicParksSucceed:models];
                    }
                }
            }else{
                NSString *temp = [resultDict objectForKey:@"message"];
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
                    [[[WebBL sharedManager] delegate] queryPublicParksFailed:temp];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
                [[[WebBL sharedManager] delegate] queryPublicParksFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
        DMLog(@"%@",error);
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryPublicParksFailed:)]){
            [[[WebBL sharedManager] delegate] queryPublicParksFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 获取公共汽车停车位单个站点信息
-(void)queryParkInfoWithLongitude:(NSString*)lon andLatitude:(NSString*)lat andId:(NSString*)Id {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:lon forKey:@"longitude"];
    [param setValue:lat forKey:@"latitude"];
    [param setValue:Id forKey:@"id"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,QUERY_PARK_INFO_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        @try {
            NSString *code = [resultDict objectForKey:@"resultCode"];
            if (code.intValue == 200)
            {
                
                NSDictionary *dict = [resultDict objectForKey:@"data"];
                ParkBean *bean = [ParkBean mj_objectWithKeyValues:dict];
                
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryParkInfoSucceed:)]){
                    [[[WebBL sharedManager] delegate] queryParkInfoSucceed:bean];
                }
                
            }else{
                NSString *temp = [resultDict objectForKey:@"message"];
                if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryParkInfoFailed:)]){
                    [[[WebBL sharedManager] delegate] queryParkInfoFailed:temp];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryParkInfoFailed:)]){
                [[[WebBL sharedManager] delegate] queryParkInfoFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[WebBL sharedManager] delegate] respondsToSelector:@selector(queryParkInfoFailed:)]){
            [[[WebBL sharedManager] delegate] queryParkInfoFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
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
