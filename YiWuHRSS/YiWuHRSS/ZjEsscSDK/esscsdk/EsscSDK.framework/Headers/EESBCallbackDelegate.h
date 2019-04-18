//
//  CallbackDelegate.h
//  EESBCardSDK
//
//  Created by wander on 2018/6/13.
//  Copyright © 2018年 wonder. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EESBCallbackDelegate <NSObject>
@optional

/***原生回调返回人脸比对活体校验的结果 responseResult 报文 error 错误信息***/
-(void)backFaceComparisonResult:(id)responseResult error:(NSError *)error __attribute__((deprecated("接口已废弃")));
@required
//API + h5 支付宝+微信、其他
//API + SDK  地方人社平台

/***返回结果签发号等参数 responseResult 报文事件定义标志号 1、2、3、单独调密码页新增  ***/
/***
 actionType  = 000 返回上一页
 actionType  = 111 退出
 
 actionType  = 001 电子社保卡申领完成
 actionType  = 002 密码重置 完成 暂不提供
 actionType  = 003 解除绑定完成
 actionType  = 004 部平台密码校验完成 暂不提供
 actionType  = 005 二级签发完成
 actionType  = 006 到卡面
 actionType  = 007 进入支付码页面
 actionType  = 008 获取到支付码页面
 
 参数解释:
 signSeq //领卡业务流水号
 signLevel //签发级别
 signNo //签发号
 validDate //合法日期
 aab301 //发卡地区行政区划代码
 signDate //签发日期
 actionType //触发功能号
 userName //姓名
 userID //人员身份证号
 ***/
//申领、重置、修改、解除签发回调
-(void)backResponseResult:(id)responseResult error:(NSError *)error;

//单独使用某一个功能的场景回调,如 /login 密码登陆
/***sceneType  = 001   /login 密码登陆
 
 sceneType  = 002   /step/setpwd 签发设置密码
 
 sceneType  = 003  /sign/checkcard 开通支付
 
 sceneType  = 004 /logout/pwd 密码解绑
 
 sceneType  = 005  /logout/otp 短信解绑
 
 sceneType  = 006 /changepwd 修改密码
 
 sceneType  = 007 /reset/otp 重置密码短信验证
 
 sceneType  = 008 /face/validate 人脸认证
 
 sceneType  = 010 /auth/login 授权登录
 
 sceneType  = 011  养老认证成功
 ***/


-(void)backSceneTypeResponseResult:(id)responseResult error:(NSError *)error;


@end
