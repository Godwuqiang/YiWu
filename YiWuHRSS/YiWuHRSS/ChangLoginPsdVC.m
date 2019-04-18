//
//  ChangLoginPsdVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ChangLoginPsdVC.h"
#import "WebBL.h"
#import "RegistHttpBL.h"


@interface ChangLoginPsdVC ()<WebBLDelegate,RegistHttpBLDelegate,UITextFieldDelegate>{
    BOOL   hasnet;
}

@property (nonatomic, strong)        WebBL      *webBL;
@property (nonatomic, strong)    MBProgressHUD  *HUD;

@property(nonatomic, strong)     NSString       *phone;

@property  BOOL  isee1;
@property  BOOL  isee2;
@property  BOOL  isee3;

@end

@implementation ChangLoginPsdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"修改登录密码";
    HIDE_BACK_TITLE;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    [self initData];
    [self afn];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 监听网络状态
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化数据
- (void)initData{
//    self.account.text = [CoreArchive strForKey:DZSBK_ID_CARD];
    
    NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
    NSString *sbh2 = [sbh substringToIndex:12];
    NSString *sbh3 = [NSString stringWithFormat:@"%@******",sbh2];
    self.account.text = [Util HeadStr:sbh3 WithNum:0];
    
    self.isee1 = NO;
    self.isee2 = NO;
    self.isee3 = NO;
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
}

#pragma mark - 原密码可见否
- (IBAction)btnoneClicked:(id)sender {
    self.isee1 = !self.isee1;
    [self.oldpsd becomeFirstResponder];
    if (self.isee1) {
        [self.btnone  setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        self.oldpsd.secureTextEntry = NO;
    }else{
        [self.btnone  setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        self.oldpsd.secureTextEntry = YES;
    }
}

#pragma mark - 新密码可见否
- (IBAction)btntwoClicked:(id)sender {
    self.isee2 = !self.isee2;
    [self.newpsd becomeFirstResponder];
    if (self.isee2) {
        [self.btntwo  setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        self.newpsd.secureTextEntry = NO;
    }else{
        [self.btntwo  setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        self.newpsd.secureTextEntry = YES;
    }
}

#pragma mark - 确认密码可见否
- (IBAction)btnthreeClicked:(id)sender {
    self.isee3 = !self.isee3;
    [self.confirmpsd becomeFirstResponder];
    if (self.isee3) {
        [self.btnthree  setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
        self.confirmpsd.secureTextEntry = NO;
    }else{
        [self.btnthree  setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        self.confirmpsd.secureTextEntry = YES;
    }
}

#pragma mark - 确定按钮
- (IBAction)YesBtnClicked:(id)sender {
//    NSString *mobile = [CoreArchive strForKey:LOGIN_APP_MOBILE];
    NSString *oldpsd = self.oldpsd.text;
    NSString *newpsd = self.newpsd.text;
    NSString *confirmpsd = self.confirmpsd.text;
    NSString *passmsg = [Util IsPassword:newpsd];
    NSString *confirmmsg = [Util IsPassword:confirmpsd];
    
    if (oldpsd.length==0) {
        [MBProgressHUD showError:@"请输入原密码"];
        return;
    }
    if (newpsd.length==0) {
        [MBProgressHUD showError:@"请输入新密码"];
        return;
    }
    if (confirmpsd.length==0) {
        [MBProgressHUD showError:@"请再输入一次新密码"];
        return;
    }
    
    if ([oldpsd isEqualToString:newpsd]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"您修改的密码与原密码相同，请重新输入";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if (![passmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"新密码必须为6-18位数字+字母的组合，请重新输入";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if (![confirmmsg isEqualToString:@"OK"]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"确认密码必须为6-18位数字+字母的组合，请重新输入";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if (hasnet) {
        [self showLoadingUIwithStr:@"修改密码中"];
        NSString *token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        NSString *md5oldpsd = [Util MD5:oldpsd];
        NSString *md5newpsd = [Util MD5:newpsd];
        NSString *md5confirmpsd = [Util MD5:confirmpsd];
        [self.webBL ChangLoginPsdWithMobile:@"" andOldPsd:md5oldpsd andNewPsd:md5newpsd andAgainPsd:md5confirmpsd andvalidCode:@"" andaccessToken:token];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return;
    }
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUIwithStr:(NSString*)str{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = str;
}

- (void)dealloc{
    DMLog(@"销毁定时器");
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 修改登录密码接口回调
-(void)ChangLoginPsdSucceed:(NSString*)message{
    self.HUD.hidden = YES;
    self.oldpsd.text = @"";
    self.newpsd.text = @"";
    self.confirmpsd.text = @"";
    [MBProgressHUD showError:@"操作成功！"];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)ChangLoginPsdFailed:(NSString*)error{
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = error;
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:1.5];
}


@end
