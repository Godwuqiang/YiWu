//
//  YW_DZSBK_SDK.h
//  YW_Demo
//
//  Created by 于良建 on 2018/4/24.
//  Copyright © 2018年 LiuXing. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface YW_DZSBK_SDK : NSObject

//初始化
+ (void)initSDKWithDictionary:(NSDictionary *)dictionary callBack:(void(^)(NSDictionary *dic))callBack;

//使用电子社保卡
+ (void)businessProcessWithDictionary:(NSDictionary *)dictionary viewController:(UIViewController *)vc;

//查询电子社保卡开通结果
+ (void)openStatusWithDictionary:(NSDictionary *)dictionary viewController:(UIViewController *)vc callBack:(void(^)(NSDictionary *dic))callBack;



@end
