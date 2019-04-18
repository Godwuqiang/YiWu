//
//  NewsBL.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NewsBean.h"
#import "BannerBean.h"
#import "MsgBean.h"
#import "NoticeBean.h"
#import "HttpHelper.h"
#import "MJExtension.h"

@protocol NewsBLDelegate <NSObject>
@optional

#pragma mark - 新闻列表回调
-(void)requestNewsListSucceed:(NSMutableArray *)dictList;
-(void)requestNewsListFailed:(NSString *)error;

#pragma mark - 首页轮播图回调
-(void)requestBannersListSucceed:(NSMutableArray *)dictList;
-(void)requestBannersListFailed:(NSString *)error;

#pragma mark - 群推消息列表回调
-(void)requestMsgListSucceed:(NSMutableArray *)dictList;
-(void)requestMsgListFailed:(NSString *)error;

#pragma mark - 获取通知公告信息回调
-(void)queryNoticeInfoSucceed:(NoticeBean *)noticebean;
-(void)queryNoticeInfoFailed:(NSString *)error;

#pragma mark - 获取未读消息回调
-(void)queryUnreadInfoSucceed:(NSDictionary *)dict;
-(void)queryUnreadInfoFailed:(NSString *)error;

#pragma mark - 修改群推列表全部已读回调
-(void)updateNewsAllReadSucceed:(NSString*)success;
-(void)updateNewsAllReadFailed:(NSString *)error;

#pragma mark - 修改单个群推消息已读回调
-(void)updateNewsOneReadSucceed:(NSString*)success;
-(void)updateNewsOneReadFailed:(NSString *)error;

#pragma mark - 批量/单个删除群推消息回调
-(void)deleteNewsListSucceed:(NSString*)success;
-(void)deleteNewsListFailed:(NSString *)error;

#pragma mark - 删除全部群推消息回调
-(void)deleteAllNewsSucceed:(NSString*)success;
-(void)deleteAllNewsFailed:(NSString *)error;

@end


@interface NewsBL : NSObject

@property (nonatomic,weak) id<NewsBLDelegate>delegate;

#pragma mark - 管理类的单例
+ (id)sharedManager;

#pragma mark - 首页新闻列表查询
/**
 首页新闻列表查询

 @param news_type 新闻类型
 @param page_num 页数
 @param page_size 每页数量
 */
-(void)requestNewsListWithType:(NSString*)news_type andpageNum:(int)page_num andpagesize:(int)page_size;

#pragma mark - 首页轮播图查询
-(void)requestBannersList;

#pragma mark - 群推消息列表查询
/**
 消息中心查询

 @param page_num 页数
 @param page_size 每页数量
 */
-(void)requestMsgListWithpageNum:(int)page_num andpagesize:(int)page_size andaccesstoken:(NSString*)accesstoken;

#pragma mark - 获取通知公告
-(void)queryNoticeInfo;

#pragma mark - 获取未读消息个数

/**
 获取未读消息个数

 @param accesstoken access_token
 */
-(void)queryUnreadInfo:(NSString*)accesstoken;

#pragma mark - 修改群推列表全部已读

/**
 修改群推列表全部已读

 @param accesstoken
 */
-(void)updateNewsAllRead:(NSString*)accesstoken;

#pragma mark - 修改单个群推消息已读
/**
 修改单个群推消息已读

 @param accesstoken
 @param msgid 消息ID
 */
-(void)updateNewsOneRead:(NSString*)accesstoken andmsgId:(NSString*)msgid;

#pragma mark - 批量/单个删除群推消息
/**
 批量/单个删除群推消息

 @param accesstoken
 @param msgidlist 消息ID列表
 */
-(void)deleteNewsList:(NSString*)accesstoken andmsgIdlist:(NSString*)msgidlist;

#pragma mark - 删除全部群推消息
/**
 批量/单个删除群推消息
 
 @param accesstoken
 @param msgidlist 消息ID列表
 */
-(void)deleteAllNews:(NSString*)accesstoken;

@end
