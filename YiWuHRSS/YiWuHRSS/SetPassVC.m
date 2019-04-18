//
//  SetPassVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "SetPassVC.h"
#import "LoginVC.h"
#import "LoginHttpBL.h"


@interface SetPassVC()<LoginHttpBLDelegate>{
     BOOL                hasnet;
}

@property (nonatomic, strong) LoginHttpBL      *loginHttpBL;
@property (nonatomic, strong) MBProgressHUD    *HUD;
@property    BOOL  isshow;

@end


@implementation SetPassVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"重置密码";
    HIDE_BACK_TITLE;
    self.isshow = NO;
    self.loginHttpBL = [LoginHttpBL sharedManager];
    self.loginHttpBL.delegate = self;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    [self afn];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark -  监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            hasnet = YES;
        }else{
            hasnet = NO;
        }
    }];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"重置密码中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 密码是否可见按钮点击事件
- (IBAction)SeeBtnClicked:(id)sender {
    _isshow = !_isshow;
    if (_isshow) {
        [self.isSee setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        [self.psd setSecureTextEntry:NO];
    }else{
        [self.psd setSecureTextEntry:YES]; 
        [self.isSee setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
    }
}

#pragma mark - 重置密码按钮点击事件
- (IBAction)DonBtnClicked:(id)sender {
    NSString *pass   = self.psd.text;
    NSString *passmsg = [Util IsPassword:pass];
    if (pass.length==0) {
        [MBProgressHUD showError:@"请输入密码"];
        return ;
    }
    if (![passmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = passmsg;
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if (hasnet) {
        [self showLoadingUI];
        NSString *md5psd = [Util MD5:pass];
        [self.loginHttpBL resetLoginPsdWith:self.appmobile andnewpsd:md5psd andvalidCode:self.validCode];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark -  重置密码接口回调
-(void)resetLoginPsdSucceed:(NSString*)message{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:message];
    // 返回登录界面
    NSArray *temArray = self.navigationController.viewControllers;
    
    for(UIViewController *temVC in temArray)
        
    {
        if ([temVC isKindOfClass:[LoginVC class]])
            
        {
            [self.navigationController popToViewController:temVC animated:YES];
        }
    }
}

-(void)resetLoginPsdFailed:(NSString *)error{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:error];
}


@end
