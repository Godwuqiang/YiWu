//
//  YWManager.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWManager.h"

@implementation YWManager

/** YWManager总的管理者 */
+ (YWManager *)sharedManager {
    
    static dispatch_once_t  onceToken;
    static YWManager * setSharedInstance;
    dispatch_once(&onceToken, ^{//线程锁
        setSharedInstance = [[YWManager alloc] init];
    });
    return setSharedInstance;
}


/**
 是否有卡

 @return 是否有市民卡或者和谐卡
 */
-(BOOL)isHasCard{
    
    if([CoreArchive strForKey:LOGIN_ISHaveCard] == nil){
        DMLog(@"nil无卡");
        return NO;
    }else{
        if([[CoreArchive strForKey:LOGIN_ISHaveCard] isEqualToString:@""]){
            DMLog(@"空无卡");
            return NO;
        }else{
            if([[CoreArchive strForKey:LOGIN_ISHaveCard] isEqualToString:@"0"]){
                DMLog(@"0无卡");
                return NO;
            }else if ([[CoreArchive strForKey:LOGIN_ISHaveCard] isEqualToString:@"1"]){
                DMLog(@"1有卡");
                return YES;
            }else{
                DMLog(@"无卡");
                return NO;
            }
        }
    }
}


/**
 是否实人认证

 @return 是否实人认证
 */
-(BOOL)isAuthentication{
    
    DMLog(@"获取实人认证状态-%@",[CoreArchive strForKey:LOGIN_SRRZ_STATUS]);
    if([CoreArchive strForKey:LOGIN_SRRZ_STATUS] == nil){
        DMLog(@"实人认证未通过");
        return NO;
    }else{
        if([[CoreArchive strForKey:LOGIN_SRRZ_STATUS] isEqualToString:@"1"]){
            DMLog(@"实人认证通过");
            return YES;
        }else{
            DMLog(@"实人认证未通过");
            return NO;
        }
    }
}


/**
 是否设置过支付密码

 @return 是否设置过支付密码
 */
-(BOOL)isSettedPayPassword{
    
    if([CoreArchive strForKey:LOGIN_SET_PAY_PSW] == nil){
        return NO;
    }else{
        if([[CoreArchive strForKey:LOGIN_SET_PAY_PSW] isEqualToString:@"0"]){
            return NO;
        }else if([[CoreArchive strForKey:LOGIN_SET_PAY_PSW] isEqualToString:@"1"]){
            return YES;
        }else{
            return NO;
        }
    }
}

@end
