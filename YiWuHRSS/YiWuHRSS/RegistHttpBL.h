//
//  RegistHttpBL.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ValidateCardBean.h"
#import "UserBean.h"
#import "SMSCodeBean.h"
#import "SMKStatusBean.h"


@protocol RegistHttpBLDelegate <NSObject>
@optional

#pragma mark - 验证银行卡的接口回调
-(void)ValidateCardSucess:(NSString *)success;
-(void)ValidateCardFail:(NSString *)error;

#pragma mark - 最后的注册账号接口回调
-(void)RegistAccountSucess:(UserBean *)bean;
-(void)RegistAccountFail:(NSString *)error;

#pragma mark -  短信验证接口回调
-(void)requestSMSCodeSucess:(SMSCodeBean *)bean;
-(void)requestSMSCodeFail:(NSString *)error;

#pragma mark - 找回密码验证身份接口
-(void)verifySFSucess:(NSString*)message;
-(void)verifySFFail:(NSString *)error;

#pragma mark -  修改登录密码发送验证码接口
-(void)requestChangPsdSMSCodeSucess:(SMSCodeBean *)bean;
-(void)requestChangPsdSMSCodeFail:(NSString *)error;

#pragma mark - 市民卡预挂失资格接口回调
-(void)checkSMKstatusSucess:(SMKStatusBean *)bean;
-(void)checkSMKstatusFail:(NSString *)error;

#pragma mark - 市民卡预挂失中验证验证码是否有效接口回调
-(void)CheckYZMValidSucess:(NSString*)message;
-(void)CheckYZMValidFail:(NSString *)error;

#pragma mark -  市民卡预挂失业务接口回调
-(void)guashiSMKSucess:(NSString*)message;
-(void)guashiSMKFail:(NSString *)error;

@end


@interface RegistHttpBL : NSObject

@property (nonatomic,weak) id<RegistHttpBLDelegate>delegate;
#pragma mark - 管理类的单例
+ (id)sharedManager;

#pragma mark - 验证银行卡的接口
/**
 验证银行卡的接口

 @param name 姓名
 @param shbzh 社会保障号
 @param cardno 卡号
 @param bankCard 银行卡号
 @param card_type 卡类型
 */
-(void)ValidateCardHttp:(NSString*)name shbzh:(NSString*)shbzh cardno:(NSString*)cardno bankCard:(NSString*)bankCard card_type:(NSString*)card_type;


#pragma mark - 最后的注册账号接口
/**
 最后的注册账号接口

 @param name 姓名
 @param password 密码
 @param againpsd 确认密码
 @param cardType 卡类型
 @param shbzh 社会保障号
 @param bankCard 银行卡号
 @param cardno 卡号
 @param appMobile 手机号码
 @param validCode 验证码
 */
-(void)RegisterUserHttp:(NSString*)name password:(NSString*)password againpsd:(NSString*)againpsd cardType:(NSString*)cardType shbzh:(NSString*)shbzh bankCard:(NSString*)bankCard cardno:(NSString*)cardno appMobile:(NSString*)appMobile andvalidCode:(NSString*)validCode;

#pragma mark -  短信验证接口
/**
 短信验证接口

 @param mobile 手机号码
 @param message_type 验证码类型
 */
-(void)requestSMSCode:(NSString*)mobile andmessage_type:(NSString*)message_type;

#pragma mark -  找回密码验证身份接口

/**
 找回密码验证身份接口

 @param app_mobile 注册手机号
 @param shbzh 社会保障号
 */
-(void)verifySFWith:(NSString*)app_mobile andSHBZH:(NSString*)shbzh;

#pragma mark -  修改登录密码发送验证码接口

/**
 修改登录密码发送验证码接口

 @param mobile 手机号码
 @param message_type 验证码
 @param old_psd 旧密码
 */
-(void)requestChangPsdSMSCode:(NSString*)mobile andmessage_type:(NSString*)message_type andold_psd:(NSString*)old_psd;

#pragma mark -  市民卡预挂失资格查询接口

/**
 市民卡预挂失资格查询接口

 @param accessToken token
 */
-(void)checkSMKstatusWith:(NSString*)accessToken;

#pragma mark -  市民卡预挂失中验证验证码是否有效接口

/**
 市民卡预挂失中验证验证码是否有效接口

 @param mobileNo 手机号码
 @param validCode 验证码
 */
-(void)CheckYZMValidWith:(NSString*)mobileNo andvalidCode:(NSString*)validCode;

#pragma mark -  市民卡预挂失业务发起接口

/**
 市民卡预挂失业务发起接口

 @param accessToken token
 @param mobileNo 手机号码
 @param validCode 验证码
 */
-(void)guashiSMKWith:(NSString*)accessToken andmobileNo:(NSString*)mobileNo andvalidCode:(NSString*)validCode;

@end
