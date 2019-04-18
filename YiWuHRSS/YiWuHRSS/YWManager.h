//
//  YWManager.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWManager : NSObject

/** 是否设置过支付密码 */
@property (nonatomic,assign) BOOL isSettedPayPassword;
/** 是否实人认证 */
@property (nonatomic,assign) BOOL isAuthentication;
/** 是否有卡*/
@property (nonatomic,assign) BOOL isHasCard;

+ (instancetype _Nonnull )sharedManager;

@end
