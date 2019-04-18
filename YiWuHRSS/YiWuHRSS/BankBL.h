//
//  BankBL.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/10.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BankBLDelegate <NSObject>
@optional

#pragma mark - 银行卡支付开通----短信发送接口回调
-(void)requestBankOpenSMSCodeSucceed:(NSString *)serNum;
-(void)requestBankOpenSMSCodeFailed:(NSString *)error;

#pragma mark - 银行卡支付开通-----短信验证
-(void)requestBankOpenSucceed:(NSString *)dictList;
-(void)requestBankOpenFailed:(NSString *)error;

#pragma mark - 银行卡支付注销-----短信发送
-(void)requestBankCloseSMSCodeSucceed:(NSString *)serNum;
-(void)requestBankCloseSMSCodeFailed:(NSString *)error;

#pragma mark - 银行卡支付注销-----短信验证
-(void)requestBankCloseSucceed:(NSString *)dictList;
-(void)requestBankCloseFailed:(NSString *)error;

@end

@interface BankBL : NSObject

@property (nonatomic,weak) id<BankBLDelegate>delegate;

#pragma mark - 管理类的单例
+ (id)sharedManager;

#pragma mark - 银行卡支付开通----短信发送接口回调
/**
 银行卡支付开通----短信发送接口回调

 @param name 姓名
 @param shbzh 社会保障号
 @param cardno 卡号
 @param bankcard 银行卡号
 @param card_type 卡类型
 @param access_token token
 */
-(void)requestBankOpenSMSCodeWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andAccess_Token:(NSString *)access_token;

#pragma mark - 银行卡支付开通-----短信验证
/**
 银行卡支付开通----短信发送接口回调

 @param name 姓名
 @param shbzh 社会保障
 @param cardno 卡号
 @param bankcard 银行卡号
 @param card_type 卡类型
 @param verCode 验证码
 @param access_token token
 */
-(void)requestBankOpenWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andverCode:(NSString*)verCode andAccess_Token:(NSString *)access_token;

#pragma mark - 银行卡支付注销-----短信发送
/**
 银行卡支付注销-----短信发送

 @param name 姓名
 @param shbzh 社会保障号
 @param cardno 卡号
 @param bankcard 银行卡号
 @param card_type 卡类型
 */
-(void)requestBankCloseSMSCodeWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type;

#pragma mark - 银行卡支付注销-----短信验证
/**
 银行卡支付注销-----短信验证

 @param name 姓名
 @param shbzh 社会保障号
 @param cardno 卡号
 @param bankcard 银行卡号
 @param card_type 卡类型
 @param access_token token
 */
-(void)requestBankCloseWithName:(NSString*)name andSHBZH:(NSString*)shbzh andCardNo:(NSString*)cardno andBankCard:(NSString*)bankcard andCard_type:(NSString*)card_type andAccess_Token:(NSString *)access_token;

@end
