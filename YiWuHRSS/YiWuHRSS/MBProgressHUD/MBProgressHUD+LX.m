//
//  MBProgressHUD+LX.m
//  Assurance
//
//  Created by 于良建 on 2017/6/29.
//  Copyright © 2017年 liuxing. All rights reserved.
//

#import "MBProgressHUD+LX.h"

@implementation MBProgressHUD (LX)

#pragma mark 显示信息
+ (void)showMessage:(NSString *)text icon:(NSString *)icon view:(UIView *)view
{
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    // 快速显示一个提示信息
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
//    if ([MBProgressHUD isNullOrBlank:text]) {
//        text = @"";
//    }
    hud.detailsLabel.text = text;
    hud.detailsLabel.numberOfLines = 3;
    hud.detailsLabel.font = [UIFont systemFontOfSize:15];
    // 再设置模式
    hud.mode = MBProgressHUDModeText;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    
    hud.backgroundColor = [UIColor clearColor];
    
    // 1秒之后再消失
    if (text.length > 25) {
        [hud hideAnimated:YES afterDelay:3];
    } else {
        [hud hideAnimated:YES afterDelay:1];
    }
    
}

#pragma mark 显示信息
+ (void)showMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showMessage:[NSString stringWithFormat:@"%@",message] icon:nil view:nil];
    });
}

#pragma mark 显示一些信息

+ (MBProgressHUD *)showLoading:(NSString *)message toView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (![MBProgressHUD isNullOrBlank:message]) {
        hud.detailsLabel.text = message;
        hud.detailsLabel.font = [UIFont systemFontOfSize:12];
        hud.detailsLabel.textColor = [MBProgressHUD getColor:@"333333"];
    }
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
//    hud.dimBackground = NO;
    hud.backgroundColor = [UIColor clearColor];
    return hud;
}


+ (MBProgressHUD *)showLoading:(NSString *)message
{
    return [self showLoading:message toView:nil];
}

+ (void)hideHUDForView:(UIView *)view
{
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    [self hideHUDForView:view animated:YES];
    
}


+ (MBProgressHUD *)showNoData:(NSString *)msg toView:(UIView *)view {
    if (view == nil) {
        view = [UIApplication sharedApplication].keyWindow;
    }
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    if (![MBProgressHUD isNullOrBlank:msg]) {
        hud.detailsLabel.text = msg;
        hud.detailsLabel.font = [UIFont systemFontOfSize:14];
        hud.detailsLabel.textColor = [MBProgressHUD getColor:@"333333"];
    }
    hud.bezelView.backgroundColor = [UIColor clearColor];
    hud.mode = MBProgressHUDModeCustomView;
    UIImageView *noDataImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 77, 53)];
    noDataImage.center = view.center;
    noDataImage.image = [UIImage imageNamed:@"img_no_more"];
    hud.customView = noDataImage;
    
    // 隐藏时候从父控件中移除
    hud.removeFromSuperViewOnHide = YES;
    // YES代表需要蒙版效果
    //    hud.dimBackground = NO;
    hud.backgroundColor = [UIColor whiteColor];
    return hud;
    
    
}

// 判断一个对象是否为空
+ (BOOL)isNullOrBlank:(NSObject*)object {
    if([object isKindOfClass:[NSNull class]]){
        return YES;
    }
    if(object == nil){
        return YES;
    }
    if ([object isEqual:@"<null>"]) {
        return YES;
    }
    if([object isEqual:@""]){
        return YES;
    }
    if ([object isEqual:@"null"]) {
        return YES;
    }
    if ([object isEqual:@"(null)"]) {
        return YES;
    }
    
    return NO;
}

+ (UIColor *)getColor:(NSString *)hexColor {
    if (hexColor.length == 7) {
        hexColor = [hexColor substringFromIndex:1];
    }
    if (hexColor.length < 6) {
        return [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0];
    }
    
    unsigned int red, green, blue;
    NSRange range;
    range.length = 2 ;
    
    range.location = 0 ;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&red];
    
    range.location = 2 ;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&green];
    
    range.location = 4 ;
    [[NSScanner scannerWithString:[hexColor substringWithRange:range]] scanHexInt:&blue];
    
    return [UIColor colorWithRed:(float)(red/255.0f) green:(float)(green/255.0f) blue:(float)(blue/255.0f) alpha:1.0f];
    
}

@end
