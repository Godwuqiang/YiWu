//
//  YWPswLoginView.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWPswLoginView : UIView

/** 导航控制器 */
@property (nonatomic,strong) UINavigationController * navVC;
@property (weak, nonatomic) IBOutlet UIView *identifyView;
@property (weak, nonatomic) IBOutlet UIView *pswView;
@property (weak, nonatomic) IBOutlet UITextField *identifyTextField;
@property (weak, nonatomic) IBOutlet UITextField *pswTextField;
@property (weak, nonatomic) IBOutlet UIButton *seePswButton;

/**
 创建密码登录的View

 @return 密码登录的View
 */
+(instancetype)pswLoginView;

@end
