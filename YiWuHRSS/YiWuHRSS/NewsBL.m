//
//  NewsBL.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "NewsBL.h"

#define NEWS_LIST_URL         @"news/news_list_query.json?"
#define BANNERS_LIST_URL      @"index/banner.json?"
#define MSG_LIST_URL          @"news/getPushMsgAll.json?"
#define NOTICE_INFO_URL       @"news/queryNoticeInfo.json"
#define UNREAD_INFO_URL       @"news/queryUnReadInfo.json"
#define NEWS_ALLREAD_URL      @"news/updatePushAllRead.json"
#define NEWS_ONEREAD_URL      @"news/updateAllOneRead.json"
#define DELETE_NEWS_URL       @"news/deletePushAllList.json"
#define DELETE_ALLNEWS_URL    @"news/deletePushAll.json"


@implementation NewsBL

+ (id)sharedManager
{
    static id sharedManager = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;
}

// 新闻列表查询
-(void)requestNewsListWithType:(NSString*)news_type andpageNum:(int)page_num andpagesize:(int)page_size{

    NSString *no = [NSString stringWithFormat:@"%d",page_num];
    NSString *size = [NSString stringWithFormat:@"%d",page_size];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:news_type forKey:@"news_type"];
    [param setValue:no forKey:@"page_num"];
    [param setValue:size forKey:@"page_size"];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NEWS_LIST_URL];
    
    if (![self isConnectionAvailable]) {
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListFailed:)]){
            [[[NewsBL sharedManager] delegate] requestNewsListFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"新闻列表查询： %@",dictData);
            @try {
                NSString *temp = [dictData objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 200)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [dictData objectForKey:@"data"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestNewsListSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
//                            NewsBean *bean = [NewsBean entityWithDict:dict];
                            NewsBean *bean = [NewsBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestNewsListSucceed:models];
                        }
                    }
                }else{
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [dictData objectForKey:@"resultCode"];
                    }else{
                        temp = [dictData objectForKey:@"message"];
                    }
                    if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListFailed:)]){
                        [[[NewsBL sharedManager] delegate] requestNewsListFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListFailed:)]){
                    [[[NewsBL sharedManager] delegate] requestNewsListFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            DMLog(@"新闻列表查询error：%@",error);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestNewsListFailed:)]){
                [[[NewsBL sharedManager] delegate] requestNewsListFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}


// 首页轮播图查询
-(void)requestBannersList{
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,BANNERS_LIST_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListFailed:)]){
            [[[NewsBL sharedManager] delegate] requestBannersListFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:nil success:^(id responseObj) {
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"轮播图： %@",dictData);
            @try {
                NSString *temp = [dictData objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 200)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [dictData objectForKey:@"data"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestBannersListSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            BannerBean *bean = [BannerBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestBannersListSucceed:models];
                        }
                    }
                    
                }else{
                    
                    NSString *temp;
                    if (iStatus == 2000) {
                        temp = [dictData objectForKey:@"resultCode"];
                    }else{
                        temp = [dictData objectForKey:@"message"];
                    }
                    if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListFailed:)]){
                        [[[NewsBL sharedManager] delegate] requestBannersListFailed:temp];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListFailed:)]){
                    [[[NewsBL sharedManager] delegate] requestBannersListFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error];
            DMLog(@"%@",error);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestBannersListFailed:)]){
                [[[NewsBL sharedManager] delegate] requestBannersListFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
}

// 群推消息列表查询
-(void)requestMsgListWithpageNum:(int)page_num andpagesize:(int)page_size andaccesstoken:(NSString*)accesstoken {
    NSString *no = [NSString stringWithFormat:@"%d",page_num];
    NSString *size = [NSString stringWithFormat:@"%d",page_size];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:no forKey:@"page_num"];
    [param setValue:size forKey:@"page_size"];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,MSG_LIST_URL];
    DMLog(@"url=%@",url);
    
    if (![self isConnectionAvailable]) {
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListFailed:)]){
            [[[NewsBL sharedManager] delegate] requestMsgListFailed:@"当前网络不可用，请检查网络设置"];
        }
    }else{
        [HttpHelper post:url params:param success:^(id responseObj) {
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            DMLog(@"===============%@",dictData);
            @try {
                NSString *temp = [dictData objectForKey:@"resultCode"];
                int iStatus = temp.intValue;
                if (iStatus == 200)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [dictData objectForKey:@"data"];
                    NSMutableArray *models = [NSMutableArray arrayWithCapacity:arrTemp.count];
                    if (arrTemp.count==0||arrTemp==NULL) {
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestMsgListSucceed:models];
                        }
                    }else{
                        for (NSDictionary *dict in arrTemp) {
                            MsgBean *bean = [MsgBean mj_objectWithKeyValues:dict];
                            [models addObject:bean];
                        }
                        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListSucceed:)]){
                            [[[NewsBL sharedManager] delegate] requestMsgListSucceed:models];
                        }
                    }
                }else{
                    NSString *msg;
                    if (iStatus == 5001 || iStatus == 5002) {
                        msg = [dictData objectForKey:@"resultCode"];
                    }else{
                        msg = @"服务暂不可用，请稍后重试";
                    }
                    if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListFailed:)]){
                        [[[NewsBL sharedManager] delegate] requestMsgListFailed:msg];
                    }
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListFailed:)]){
                    [[[NewsBL sharedManager] delegate] requestMsgListFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } failure:^(NSError *error) {
            //        NSString *msg = [NSString stringWithFormat:@"%@",error];
            DMLog(@"%@",error);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(requestMsgListFailed:)]){
                [[[NewsBL sharedManager] delegate] requestMsgListFailed:@"服务暂不可用，请稍后重试"];
            }
        }];
    }
    
}

// 获取通知公告
-(void)queryNoticeInfo {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NOTICE_INFO_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            if (iStatus == 200)
            {
                NSDictionary *dict = [dictData objectForKey:@"data"];
                NoticeBean *bean = [NoticeBean mj_objectWithKeyValues:dict];
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryNoticeInfoSucceed:)]){
                    [[[NewsBL sharedManager] delegate] queryNoticeInfoSucceed:bean];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryNoticeInfoFailed:)]){
                    [[[NewsBL sharedManager] delegate] queryNoticeInfoFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryNoticeInfoFailed:)]){
                [[[NewsBL sharedManager] delegate] queryNoticeInfoFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryNoticeInfoFailed:)]){
            [[[NewsBL sharedManager] delegate] queryNoticeInfoFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 获取未读消息
-(void)queryUnreadInfo:(NSString*)accesstoken {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UNREAD_INFO_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            if (iStatus == 200)
            {
                NSDictionary *dict = [dictData objectForKey:@"data"];
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryUnreadInfoSucceed:)]){
                    [[[NewsBL sharedManager] delegate] queryUnreadInfoSucceed:dict];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryUnreadInfoFailed:)]){
                    [[[NewsBL sharedManager] delegate] queryUnreadInfoFailed:@"服务暂不可用，请稍后重试"];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryUnreadInfoFailed:)]){
                [[[NewsBL sharedManager] delegate] queryUnreadInfoFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(queryUnreadInfoFailed:)]){
            [[[NewsBL sharedManager] delegate] queryUnreadInfoFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 修改群推列表全部已读
-(void)updateNewsAllRead:(NSString*)accesstoken {
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NEWS_ALLREAD_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            NSString *msg = [dictData objectForKey:@"message"];
            if (iStatus == 200)
            {
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsAllReadSucceed:)]){
                    [[[NewsBL sharedManager] delegate] updateNewsAllReadSucceed:msg];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsAllReadFailed:)]){
                    [[[NewsBL sharedManager] delegate] updateNewsAllReadFailed:msg];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsAllReadFailed:)]){
                [[[NewsBL sharedManager] delegate] updateNewsAllReadFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsAllReadFailed:)]){
            [[[NewsBL sharedManager] delegate] updateNewsAllReadFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 修改单个群推消息已读
-(void)updateNewsOneRead:(NSString*)accesstoken andmsgId:(NSString*)msgid {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:msgid forKey:@"msg_id"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NEWS_ONEREAD_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            NSString *msg = [dictData objectForKey:@"message"];
            if (iStatus == 200)
            {
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsOneReadSucceed:)]){
                    [[[NewsBL sharedManager] delegate] updateNewsOneReadSucceed:msg];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsOneReadFailed:)]){
                    [[[NewsBL sharedManager] delegate] updateNewsOneReadFailed:msg];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsOneReadFailed:)]){
                [[[NewsBL sharedManager] delegate] updateNewsOneReadFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(updateNewsOneReadFailed:)]){
            [[[NewsBL sharedManager] delegate] updateNewsOneReadFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 批量/单个删除群推消息
-(void)deleteNewsList:(NSString*)accesstoken andmsgIdlist:(NSString*)msgidlist {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:msgidlist forKey:@"msg_id_list"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,DELETE_NEWS_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            NSString *msg = [dictData objectForKey:@"message"];
            if (iStatus == 200)
            {
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteNewsListSucceed:)]){
                    [[[NewsBL sharedManager] delegate] deleteNewsListSucceed:msg];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteNewsListFailed:)]){
                    [[[NewsBL sharedManager] delegate] deleteNewsListFailed:msg];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteNewsListFailed:)]){
                [[[NewsBL sharedManager] delegate] deleteNewsListFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteNewsListFailed:)]){
            [[[NewsBL sharedManager] delegate] deleteNewsListFailed:@"服务暂不可用，请稍后重试"];
        }
    }];
}

// 删除全部群推消息
-(void)deleteAllNews:(NSString*)accesstoken {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,DELETE_ALLNEWS_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            NSString *msg = [dictData objectForKey:@"message"];
            if (iStatus == 200)
            {
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteAllNewsSucceed:)]){
                    [[[NewsBL sharedManager] delegate] deleteAllNewsSucceed:msg];
                }
                
            }else{
                if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteAllNewsFailed:)]){
                    [[[NewsBL sharedManager] delegate] deleteAllNewsFailed:msg];
                }
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
            if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteAllNewsFailed:)]){
                [[[NewsBL sharedManager] delegate] deleteAllNewsFailed:@"服务暂不可用，请稍后重试"];
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        if([[[NewsBL sharedManager] delegate] respondsToSelector:@selector(deleteAllNewsFailed:)]){
            [[[NewsBL sharedManager] delegate] deleteAllNewsFailed:@"服务暂不可用，请稍后重试"];
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
