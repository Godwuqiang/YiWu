//
//  MBProgressHUD+MJ.m
//
//  Created by mj on 13-4-18.
//  Copyright (c) 2013年 itcast. All rights reserved.
//

#import "MBProgressHUD+MJ.h"

@implementation MBProgressHUD (MJ)
#pragma mark 显示信息
+ (void)show:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if([Util IsStringNil:text]){
        DMLog(@"/n日志报告：出现提示信息为 系统错误  的原因是后台返回的错误信息message == nil 请联系后台检查错误信息/n");
        text = @"服务暂不可用，请稍后重试";
    }
    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
    
    //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
    for (NSObject * window in [UIApplication sharedApplication].windows) {
        if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
            view = (UIView *)window;
        }
    }
    
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = @"";
    hud.detailsLabel.text = text;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15.0];
    
    
    // 设置图片
    hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@""]];
    // 再设置模式
    hud.mode = MBProgressHUDModeCustomView;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    // 1秒之后再消失
    [hud hideAnimated:YES afterDelay:1.5];
}

#pragma mark 显示错误信息
+ (void)showError:(NSString *)error toView:(UIView *)view{
    [self show:error icon:@"error.png" view:view];
}

+ (void)showSuccess:(NSString *)success toView:(UIView *)view
{
    [self show:success icon:@"success.png" view:view];
}

//#pragma mark 显示一些信息
//+ (MBProgressHUD *)showMessage:(NSString *)message toView:(UIView *)view {
//    if (view == nil) view = [[UIApplication sharedApplication].windows lastObject];
//
//    //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
//    for (NSObject * window in [UIApplication sharedApplication].windows) {
//        if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
//            view = (UIView *)window;
//        }
//    }
//
//    // 快速显示一个提示信息
//    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    hud.labelText = message;
//    hud.labelText = @"";
//    hud.detailsLabelText = message;
//    hud.detailsLabelFont = [UIFont systemFontOfSize:15.0];
//
//    // 隐藏时候从父控件中移除
//    hud.removeFromSuperViewOnHide = YES;
//    // YES代表需要蒙版效果
//    hud.dimBackground = YES;
//    [hud hide:YES afterDelay:3.0];
//    return hud;
//}

+ (void)showSuccess:(NSString *)success
{
    [self showSuccess:success toView:nil];
}

+ (void)showError:(NSString *)error
{
    [self showError:error toView:nil];
}

//+ (MBProgressHUD *)showMessage:(NSString *)message
//{
//    return [self showMessage:message toView:nil];
//}

+ (void)hideHUDForView:(UIView *)view
{
    [self hideHUDForView:view animated:YES];
}

+ (void)hideHUD
{
    [self hideHUDForView:nil];
}




@end
