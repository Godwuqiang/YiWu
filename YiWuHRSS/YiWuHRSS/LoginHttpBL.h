//
//  LoginHttpBL.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "UserBean.h"
#import <Foundation/Foundation.h>
#import "ChangeCardBean.h"


@protocol LoginHttpBLDelegate <NSObject>
@optional

#pragma mark - 登录接口回调
-(void)requestLoginSucceed:(UserBean *)bean;
-(void)requestLoginFailed:(NSString *)error;

#pragma mark - 修改市民卡状态接口回调
-(void)ChangCardStatusSucceed:(ChangeCardBean*)bean;
-(void)ChangCardStatusFailed:(NSString *)error;

#pragma mark - 通知杭州医快付云平台接口回调
-(void)ConnetYKFSucceed:(NSString*)message;
-(void)ConnetYKFFailed:(NSString *)error;

#pragma mark - 修改卡的通知状态接口回调
-(void)NoticeChangStatusSucceed:(NSString*)message;
-(void)NoticeChangStatusFailed:(NSString *)error;

#pragma mark - 重置密码接口回调
-(void)resetLoginPsdSucceed:(NSString*)message;
-(void)resetLoginPsdFailed:(NSString *)error;

@end


@interface LoginHttpBL : NSObject

@property (nonatomic,weak) id<LoginHttpBLDelegate>delegate;

#pragma mark -  管理类的单例
+ (id)sharedManager;

#pragma mark - 登录接口查询
/**
 登录接口查询

 @param mobile 手机号
 @param password 密码
 */
-(void)LoginRequest:(NSString*)mobile Password:(NSString*)password;

#pragma mark - 修改市民卡状态接口
/**
 修改市民卡状态接口

 @param name 姓名
 @param shbzh 社会保障号
 @param cardno 卡号
 @param bankCard 银行卡号
 @param card_type 卡类型
 @param access_token token
 */
-(void)ChangCardStatusWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardno:(NSString*)cardno andBankCard:(NSString*)bankCard andCard_Type:(NSString*)card_type andAccess_Token:(NSString*)access_token;

#pragma mark - 通知杭州医快付云平台接口
/**
 通知杭州医快付云平台接口

 @param bean 换卡返回的信息类
 */
-(void)ConnetYKFWithBean:(ChangeCardBean*)bean;

#pragma mark -  修改卡的通知状态接口
/**
 修改卡的通知状态接口

 @param cardno 卡号
 @param shbzh 社会保障号
 @param card_type 卡类型
 @param bankCard 银行卡号
 */
-(void)NoticeChangStatusWithCardno:(NSString*)cardno andShbzh:(NSString*)shbzh andcard_type:(NSString*)card_type andbankCard:(NSString*)bankCard;

#pragma mark -  重置密码接口
/**
 重置密码接口

 @param app_mobile 手机号码
 @param new_password 新密码
 @param validCode 验证码
 */
-(void)resetLoginPsdWith:(NSString*)app_mobile andnewpsd:(NSString*)new_password andvalidCode:(NSString*)validCode;

@end
