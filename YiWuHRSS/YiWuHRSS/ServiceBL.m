//
//  ServiceBL.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/9.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ServiceBL.h"
#import "HttpHelper.h"
#import "MJExtension.h"
#import "AESCipher.h"
#import "NSString+category.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key

#define CAN_BAO_URL   @"shebao/shebaoQueryAES.json?"

@implementation ServiceBL

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 参保信息查询
-(void)queryCanBaoInfoWith:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];//名称
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;
    
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryCanBaoInfoFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];
            
        
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==NULL) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryCanBaoInfoFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryCanBaoInfoSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                CanBaoInfoBean *bean = [CanBaoInfoBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryCanBaoInfoSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryCanBaoInfoFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryCanBaoInfoFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            DMLog(@"请求失败");
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryCanBaoInfoFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryCanBaoInfoFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 缴费记录查询
-(void)queryWuXianWithYear:(NSString*)year andshbzh:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"year\":\"%@\",",year];
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];//名称
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryWuXianFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
           
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryWuXianFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryWuXianSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                JiaoFeiInfoBean *bean = [JiaoFeiInfoBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryWuXianSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryWuXianFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryWuXianFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryWuXianFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryWuXianFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 养老金账户查询
-(void)queryYLAccountWithYear:(NSString*)year andshbzh:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"year\":\"%@\",",year];
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];//名称
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYLAccountFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYLAccountFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLAccountSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                YLAccountBean *bean = [YLAccountBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLAccountSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYLAccountFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYLAccountFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLAccountFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYLAccountFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 养老金发放查询
-(void)queryYLFFWith:(NSString*)shbzh andpageNo:(int)pageNo andpageSize:(int)pageSize andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYLFFFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];
            

            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYLFFFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLFFSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                TXdyBean *bean = [TXdyBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLFFSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                    
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYLFFFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYLFFFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLFFFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYLFFFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 养老金发放明细查询
-(void)queryYLMXWith:(NSString*)shbzh andmonth:(NSString*)month andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"month\":\"%@\",",month];
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYLMXFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYLMXFailed:@"服务暂不可用，请稍后重试 "];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLMXSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                TXdymxBean *bean = [TXdymxBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYLMXSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYLMXFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYLMXFailed:@"服务暂不可用，请稍后重试 "];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYLMXFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYLMXFailed:@"服务暂不可用，请稍后重试 "];
            }
        }];
    }
}

// 医保账户余额查询
-(void)queryYiBaoYeWith:(NSString*)shbzh andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYiBaoYeFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYiBaoYeFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYiBaoYeSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                YiBaoYeBean *bean = [YiBaoYeBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYiBaoYeSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYiBaoYeFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYiBaoYeFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYiBaoYeFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYiBaoYeFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 医保消费记录查询
-(void)queryYBCostListWith:(NSString*)shbzh andyear:(NSString*)year andpageNo:(int)pageNo andpageSize:(int)pageSize andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"shbzh\":\"%@\",",shbzh];
    strParams = [strParams stringByAppendingFormat:@"\"year\":\"%@\",",year];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYBCostFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
     
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYBCostFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYBCostSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                YiBaoCostBean *bean = [YiBaoCostBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryYBCostSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYBCostFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYBCostFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYBCostFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYBCostFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 门诊详情查询
-(void)queryMZWith:(NSString*)xfCode andxfType:(NSString*)xfType andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"xfCode\":\"%@\",",xfCode];
    strParams = [strParams stringByAppendingFormat:@"\"xfType\":\"%@\",",xfType];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryMZFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryMZFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryMZSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                MZBean *bean = [MZBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryMZSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryMZFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryMZFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryMZFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryMZFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 住院详情查询
-(void)queryZYWith:(NSString*)xfCode andxfType:(NSString*)xfType andAccess_Token:(NSString *)access_token andTradeCode:(NSString*)TradeCode andJSCXH:(NSString*)jscxh{

    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"xfCode\":\"%@\",",xfCode];
    strParams = [strParams stringByAppendingFormat:@"\"xfType\":\"%@\",",xfType];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\",",TradeCode];
    strParams = [strParams stringByAppendingFormat:@"\"jscxh\":\"%@\"",jscxh];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryZYFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryZYFailed:@"服务暂不可用，请稍后重试"];
                }
            }else{
                @try {
                    NSString *temp = [resultDict objectForKey:@"resultCode"];
                    NSNumber *resultTag = [resultDict objectForKey:@"success"];
                    int iStatus = temp.intValue;
                    if (resultTag.boolValue==YES && iStatus == 1000)
                    {
                        NSArray *arrTemp = [[NSArray alloc] init];
                        arrTemp = [resultDict objectForKey:@"resultlist"];
                        NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                        if (arrTemp.count==0||arrTemp==NULL) {
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryZYSucceed:models];
                            }
                        }else{
                            for (NSDictionary *dict in arrTemp) {
                                ZYBean *bean = [ZYBean mj_objectWithKeyValues:dict];
                                [models addObject:bean];
                            }
                            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYSucceed:)]){
                                [[[ServiceBL sharedManager] delegate] queryZYSucceed:models];
                            }
                        }
                    }else{
                        NSString *temp;
                        
                        if (iStatus == 1001 || iStatus == 5001 || iStatus == 5002) {
                            temp = [resultDict objectForKey:@"resultCode"];
                        }else{
                            temp = [resultDict objectForKey:@"message"];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYFailed:)]){
                            [[[ServiceBL sharedManager] delegate] queryZYFailed:temp];
                        }
                    }
                } @catch (NSException *exception) {
                    DMLog(@"%@",exception);
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryZYFailed:@"服务暂不可用，请稍后重试"];
                    }
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZYFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryZYFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 两定机构查询 定点医院
-(void)queryDingDianJiGouWith:(NSString*)ddyljgmc andtype:(NSString*)type andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode{

    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LAT]?@"":[CoreArchive strForKey:CURRENT_LAT];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LON]?@"": [CoreArchive strForKey:CURRENT_LON];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"ddyljgmc\":\"%@\",",ddyljgmc];
    strParams = [strParams stringByAppendingFormat:@"\"type\":\"%@\",",type];
    strParams = [strParams stringByAppendingFormat:@"\"injd\":\"%@\",",lat];
    strParams = [strParams stringByAppendingFormat:@"\"inwd\":\"%@\",",lng];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingString:@"\"TradeCode\":\"30014\""];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"两定机构查询param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryDingDianJiGouFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            DMLog(@"量订==%@",resultDict);
            
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"resultlist"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryDingDianJiGouSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            DDJGBean *bean = [DDJGBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryDingDianJiGouSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [resultDict objectForKey:@"resultCode"];
                    }else{
                        temp = [resultDict objectForKey:@"message"];
                    }
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryDingDianJiGouFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryDingDianJiGouFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianJiGouFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryDingDianJiGouFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 两定机构查询  定点药店
-(void)queryDingDianYaoWith:(NSString*)ddyljgmc andtype:(NSString*)type andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode{
    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LAT]?@"":[CoreArchive strForKey:CURRENT_LAT];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LON]?@"": [CoreArchive strForKey:CURRENT_LON];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"ddyljgmc\":\"%@\",",ddyljgmc];
    strParams = [strParams stringByAppendingFormat:@"\"type\":\"%@\",",type];
    strParams = [strParams stringByAppendingFormat:@"\"injd\":\"%@\",",lat];
    strParams = [strParams stringByAppendingFormat:@"\"inwd\":\"%@\",",lng];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingString:@"\"TradeCode\":\"30014\""];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryDingDianYaoFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];
            
            DMLog(@"paramDict=%@ \n resultDict = %@",paramDict,resultDict);

            
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"resultlist"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryDingDianYaoSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            DDJGBean *bean = [DDJGBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryDingDianYaoSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [resultDict objectForKey:@"resultCode"];
                    }else{
                        temp = [resultDict objectForKey:@"message"];
                    }
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryDingDianYaoFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryDingDianYaoFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryDingDianYaoFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryDingDianYaoFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 药品目录查询
-(void)queryYaoPinListWith:(NSString*)mlmc andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode{

    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"mlmc\":\"%@\",",mlmc];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryYaoPinListFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"resultlist"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYaoPinListSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            DrugBean *bean = [DrugBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryYaoPinListSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [resultDict objectForKey:@"resultCode"];
                    }else{
                        temp = [resultDict objectForKey:@"message"];
                    }
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryYaoPinListFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryYaoPinListFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryYaoPinListFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryYaoPinListFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 诊疗目录查询
-(void)queryZhenLiaoListWith:(NSString*)zlmlmc andpageNo:(int)pageNo andpageSize:(int)pageSize andTradeCode:(NSString*)TradeCode{

    NSString *no = [NSString stringWithFormat:@"%d",pageNo];
    NSString *size = [NSString stringWithFormat:@"%d",pageSize];
    //json排序
    NSString *strParams = @"{";
    strParams = [strParams stringByAppendingFormat:@"\"zlmlmc\":\"%@\",",zlmlmc];
    strParams = [strParams stringByAppendingFormat:@"\"pageNo\":\"%@\",",no];
    strParams = [strParams stringByAppendingFormat:@"\"pageSize\":\"%@\",",size];
    strParams = [strParams stringByAppendingFormat:@"\"TradeCode\":\"%@\"",TradeCode];
    strParams = [strParams stringByAppendingString:@"}"];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:strParams forKey:@"paramStr"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CAN_BAO_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListFailed:)]){
            [[[ServiceBL sharedManager] delegate] queryZhenLiaoListFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:paramDict success:^(id responseObj) {
            
            NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            NSString * dataBackString = aesDecryptString(resultDict[@"dataBack"], AESEncryptKey);
            resultDict = [NSString db_dictionaryWithJsonString:dataBackString];

            
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"resultlist"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryZhenLiaoListSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            ZLBean *bean = [ZLBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListSucceed:)]){
                            [[[ServiceBL sharedManager] delegate] queryZhenLiaoListSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [resultDict objectForKey:@"resultCode"];
                    }else{
                        temp = [resultDict objectForKey:@"message"];
                    }
                    if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListFailed:)]){
                        [[[ServiceBL sharedManager] delegate] queryZhenLiaoListFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListFailed:)]){
                    [[[ServiceBL sharedManager] delegate] queryZhenLiaoListFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error.localizedDescription];
            DMLog(@"%@",error);
            if([[[ServiceBL sharedManager] delegate] respondsToSelector:@selector(queryZhenLiaoListFailed:)]){
                [[[ServiceBL sharedManager] delegate] queryZhenLiaoListFailed:@"服务暂不可用，请稍后重试"];
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
