//
//  MBProgressHUD+LX.h
//  Assurance
//
//  Created by 于良建 on 2017/6/29.
//  Copyright © 2017年 liuxing. All rights reserved.
//

#import "MBProgressHUD.h"

@interface MBProgressHUD (LX)


+ (void)showMessage:(NSString *)message;

+ (MBProgressHUD *)showLoading:(NSString *)message toView:(UIView *)view;
+ (MBProgressHUD *)showLoading:(NSString *)message;

+ (void)hideHUDForView:(UIView *)view;

+ (MBProgressHUD *)showNoData:(NSString *)msg toView:(UIView *)view;

@end
