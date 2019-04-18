//
//  EPSecurityManager.h
//  ZjEsscSDK
//
//  Created by MacBook Pro on 2018/11/23.
//  Copyright © 2018年 HouXinbing. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EPSDKConfig.h"
#import "EPCardIssueView.h"

typedef void(^CompletionHandler)(NSDictionary *resultDict);

@protocol EPSecurityManagerDelegate <NSObject>

/**
  接受签发功能及独立服务回调结果

 @param responseResult 数据详情
 @param type 数据类型  1签发，2独立服务
 */
- (void)sdkCallbackSuccessResponseResult:(NSDictionary *)responseResult type:(int)type;

/**
 发生错误及异常接口定义

 @param responseResult 异常返回信息
 @param error 错误信息
 */
- (void)sdkCallbackErrorResponseResult:(id)responseResult error:(NSError *)error;


//部sdk 回调

//申领、重置、修改、解除签发回调
- (void)backResponseResult:(id)responseResult error:(NSError *)error ;

- (void)backSceneTypeResponseResult:(id)responseResult error:(NSError *)error ;


////原生回调返回人脸比对活体校验的结果 responseResult
//-(void)backFaceComparisonResult:(id)responseResult error:(NSError *)error __attribute__((deprecated("接口已废弃"))) ;
//

@optional
/**
 发卡地返回
 */
- (void)gobackCardIssueView;


@end



@interface EPSecurityManager : NSObject


/**代理1*/
@property (nonatomic,assign) id <EPSecurityManagerDelegate>delegate;

+ (instancetype)defaultManager;

@property (nonatomic, strong) EPCardIssueView *cardView;

/**
 初始化方法
 */
+ (void)setupWithConfig:(EPSDKConfig *)config;

@property (nonatomic, strong) UIActivityIndicatorView * activityIndicator;


/**
 渠道号需要向省平台申请统一提供
 */
@property (nonatomic, strong) NSString *channelNo;

/**
 版本号
 */
@property (nonatomic, strong) NSString *sdkDesc;

/** 设置sdk 的appHost*/
@property (nonatomic, strong) NSString *appHost;

@property (nonatomic, strong) NSString *host_name;

/** 社会保障号 */
@property (nonatomic, strong) NSString *cardNoStr;
    
/** 姓名 */
@property (nonatomic, strong) NSString *nameStr;

/** 发卡地 */
@property (nonatomic, strong) NSString *cardAdress;

/** 操作验证串（busiSeq） */
@property (nonatomic, strong) NSString *busiSeq;

/** 签发号（signNo） */
@property (nonatomic, strong) NSString *signNo;

/** 手机号 */
@property (nonatomic, strong) NSString *phone;

/**历史数据标记*/
@property (nonatomic, strong) NSString *historyFlag;

@property (nonatomic, strong) UIColor *themeColor;

@property (nonatomic, strong) UIColor *titleColor;

/**
 开启日志 YES:开启， NO:禁用
 */
+ (void)enableLogging:(BOOL)logging;
    



/**
 启动SDK

 @param pushVC 该方法适用于通过正常vc方式进行跳转
 @param idCard 用户的社会保障号码
 @param name 用户的真实姓名
 @param url 常量值-本方法取
 @param sign 签名串 按照省平台提供签名规则生成，详细获取签名串
 */
+ (void)startSdkWithPushVC:(UIViewController *)pushVC IdCard:(NSString *)idCard Name:(NSString *)name Url:(NSString *)url Sign:(NSString *)sign;


//// 收到部SDK回调方法后，调申领、解除关联接口
//+ (void)verificationOnResult:(NSDictionary *)OnResult;

/***退出sdk***/
+ (void)exitZjesscSdk;

@end
