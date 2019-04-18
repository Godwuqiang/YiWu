//
//  YWLoginVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWLoginVC : UIViewController

/** 是否来自注册*/
@property (nonatomic,assign) BOOL isFromRegist;
/** 是否为密码登录*/
@property (nonatomic,assign) BOOL isPswLogin;
/** 密码登录或者刷脸登录的内容的ScrollView */
@property (nonatomic,strong) UIScrollView * scrollView;
/** 密码登录*/
@property (weak, nonatomic) IBOutlet UIButton *pswLoginButton;
/** 刷脸登录*/
@property (weak, nonatomic) IBOutlet UIButton *slLoginButton;
/** 指示器距离左边的约束*/
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *indicaterLeadingConstraint;
/** 密码登录或者刷脸登录的内容View*/
@property (weak, nonatomic) IBOutlet UIView *pswOrslView;
/** 登录按钮*/
@property (weak, nonatomic) IBOutlet UIButton *loginButton;



/** 姓名 */
@property (nonatomic,strong) NSString * name;
/** 社会保障号 */
@property (nonatomic,strong) NSString * shbzh;
/** 认证类型21：iOS实人认证 */
@property (nonatomic,strong) NSString * business_types;

/** biz_no */
@property (nonatomic,strong) NSString * biz_no;
/** transaction_id */
@property (nonatomic,strong) NSString * transaction_id;
/** serNum */
@property (nonatomic,strong) NSString * serNum;
/** access_token */
@property (nonatomic,strong) NSString * access_token;

@end
