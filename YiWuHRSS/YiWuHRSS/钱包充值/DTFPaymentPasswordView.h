//
//  DTFPaymentPasswordView.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/11/13.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFPaymentPasswordView : UIView

//输入完成后回调 password为保存的密码
@property (nonatomic, copy) void(^completeBlock)(NSString *password);

@property (nonatomic ,strong) UINavigationController * nav;

@end
