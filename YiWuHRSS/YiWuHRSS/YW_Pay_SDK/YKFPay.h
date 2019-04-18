//
//  YKFPay.h
//  YKFPay
//
//  Created by 魏子建 on 2016/10/25.
//  Copyright © 2016年 魏子建. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

//resultDic中 code=1 为网络请求成功  data里面为文档中返回的输出参数   code=0 为网络请求失败
typedef void(^callBack)(NSDictionary *resultDic);

@interface YKFPay : NSObject

//2.0支付APP传sdk的参数
@property (nonatomic, copy) NSDictionary *dataDic;

+ (YKFPay *)shareYKFPay;

//设置支付密码
- (void)setPassword:(NSDictionary *)parameter callBack:(callBack)callBack;

//修改支付密码
- (void)modifyPassword:(NSDictionary *)parameter viewController:(UIViewController *)currentVC  callBack:(callBack)callBack;

//开通服务
- (void)paymentServiceOpening:(NSDictionary *)parameter callBack:(callBack)callBack;

//关闭服务
- (void)paymentServiceClose:(NSDictionary *)parameter callBack:(callBack)callBack;

//获取authToken
- (void)obtainAuthToken:(NSDictionary *)parameter callBack:(callBack)callBack;

//验证authToken
- (void)validateAuthToken:(NSDictionary *)parameter callBack:(callBack)callBack;

//获取idCode
- (void)obtainIdCode:(NSDictionary *)parameter callBack:(callBack)callBack;

//获取认证结果
- (void)obtainAuthResult:(NSDictionary *)parameter callBack:(callBack)callBack;

//台州获取支付authToken
- (void)tz:(NSDictionary *)parameter callBack:(callBack)callBack;



#pragma mark - 2.0 账单支付

//账单支付
- (void)billPaymentWithDic:(NSDictionary *)dictionary viewController:(UIViewController *)vc callBack:(callBack)callBack;

//处理第三方支付回调
- (void)handleURL:(NSURL *)url withComplations:(NSDictionary *)options;

@end
