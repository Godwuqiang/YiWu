//
//  SSCPublicHeader.h
//  SSCDemo
//
//  Created by wander on 2018/5/29.
//  Copyright © 2018年 wonder. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "SSCSDKConfig.h"
#import "EESBCallbackDelegate.h"
@interface SSCPublicHeader : NSObject

NS_ASSUME_NONNULL_BEGIN
@property (nonatomic, strong, readonly)SSCSDKConfig *sdkConfig;

#pragma mark - 主流程（实例、初始化、启动、更改、关闭）
// 提供1个类方法让外界访问唯一的实例
+ (instancetype)sharedSSCTool;

/**
 初始化SDK

 @param config 配置参数
 */
- (void)initSDKWithAppConfig:(SSCSDKConfig *)config;

/**
 启动SDK方法

 @param fromVC 从哪个控制器模态弹出 一般为self
 @param url webVC跳转的url
 @param delegate 接收回调的代理
 */
- (void)presentWebVCFrom:(UIViewController *)fromVC
                 esscUrl:(NSString *)url
            esscDelegate:(id<EESBCallbackDelegate>)delegate;

/**
 用于SDK已打开，但是需要人为更改url的情况
 比如：在SDK某个界面 因受到某种回调 需要打开新的界面 此时用此接口进行跳转操作
 
 @param urlString url
 */
- (void)changeWebVCUrl:(NSString *)urlString;

// 退出sdk
- (void)exitEESBCardSdk;


#pragma mark - 辅助功能
// SDK版本号
- (NSString *)sSDKVesrion;

// 返回SDK当前控制器
- (UIViewController *)sdkPresentController;

#pragma mark - 下个版本会被废弃
- (void)pushWebVC:(UIViewController*)pushVC bundleUrl:(NSString *)url __attribute__((deprecated("下个版本会被废弃,请使用presentWebVCFrom:esscUrl:esscDelegate:方法")));

-(void)pushWebParam:(UIViewController*)pushVC bundleUrl:(NSString *)url __attribute__((deprecated("下个版本会被废弃,请使用presentWebVCFrom:esscUrl:esscDelegate:方法")));

- (void)pushWebVC:(UIViewController*)pushVC bundleUrl:(NSString *)url withDelegate:(id)delegate __attribute__((deprecated("下个版本会被废弃,请使用presentWebVCFrom:esscUrl:esscDelegate:方法")));

- (void)pushWebParam:(UIViewController*)pushVC bundleUrl:(NSString *)url withDelegate:(id)delegate __attribute__((deprecated("下个版本会被废弃,请使用presentWebVCFrom:esscUrl:esscDelegate:方法")));

NS_ASSUME_NONNULL_END
@end
