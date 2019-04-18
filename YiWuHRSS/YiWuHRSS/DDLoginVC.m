//
//  DDLoginVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/1/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DDLoginVC.h"
#import "ModifySMCardVC.h"
#import "ModifyHXCardVC.h"
#import "LoginHttpBL.h"
#import "FindPsdVC.h"
#import "UserBean.h"
#import "RegistSelectCardVC.h"
#import "SelectCardVC.h"
#import "LossAlertView.h"
#import "ModifyCardView.h"
#import "JPUSHService.h"


@interface DDLoginVC ()<LoginHttpBLDelegate>{
    BOOL                _showpass;
    BOOL                hasnet;
}

@end

@implementation DDLoginVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"登录";
    
    //自定义左边 的按钮
    UIButton *leftButton = [[UIButton alloc]init];
    leftButton.frame = CGRectMake(0, 10, 20, 20);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(doclickLeftButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItems = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    //解决按钮不靠左 靠右的问题.
    UIBarButtonItem *nagetiveSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    nagetiveSpacer.width = -12;//这个值可以根据自己需要自己调整
    self.navigationItem.leftBarButtonItems = @[nagetiveSpacer, leftBarButtonItems];
    
    UIBarButtonItem *RightButton = [[UIBarButtonItem alloc] initWithTitle:@"注册" style:UIBarButtonItemStylePlain target:self action:@selector(doClickRightAction)];
    RightButton.tintColor =[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = RightButton;
    
    // Do any additional setup after loading the view.
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    
    _showpass = NO;
    NSString *mobile = [CoreArchive strForKey:LOGIN_APP_MOBILE];
    if (![Util IsStringNil:mobile]) {
        self.AccountTextField.text = mobile;
    }
    [self.PasswordTextField setSecureTextEntry:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    [self afn];
}

-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self setupNavigationBarStyle];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
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

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"登录中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回按钮点击事件
- (IBAction)BackBtn:(id)sender {
    [self dismissViewControllerAnimated:NO completion:nil];
}

#pragma mark - 忘记密码点击事件
- (IBAction)RegisteBtn:(id)sender {
    FindPsdVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FindPsdVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 密码可见按钮事件
- (IBAction)IsSeeClicked:(id)sender {
    _showpass = !_showpass;
    if (_showpass) {
        [self.IsSeeBtn setImage:[UIImage imageNamed:@"icon_displayed"] forState:UIControlStateNormal];
        [self.PasswordTextField setSecureTextEntry:YES];
    }else{
        [self.PasswordTextField setSecureTextEntry:NO];
        [self.IsSeeBtn setImage:[UIImage imageNamed:@"icon_display"] forState:UIControlStateNormal];
    }
}

#pragma mark - 登录按钮点击事件
- (IBAction)LoginBtn:(id)sender {
    NSString * mobile = self.AccountTextField.text;
    NSString * pass =  self.PasswordTextField.text;
    NSString *mobilemsg = [Util IsPhone:mobile];
    if (![ mobilemsg isEqualToString:@"OK"]) {
        [MBProgressHUD showError:mobilemsg];
        return;
    }
    if (pass.length > 18 || pass.length < 6 ){
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"密码必须为6-18位数字+字母的组合，请重新输入";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    
    if (hasnet) {
        LoginHttpBL *bl = [LoginHttpBL sharedManager];
        bl.delegate = self;
        [self showLoadingUI];
        NSString *md5psd = [Util MD5:pass];
        [bl LoginRequest:mobile Password:md5psd];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 忘记密码点击事件
- (IBAction)ForgetBtn:(id)sender {
    FindPsdVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"FindPsdVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 登录接口回调
-(void)requestLoginFailed:(NSString *)error{
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = error;
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:2.0];
}

-(void)requestLoginSucceed:(UserBean *)bean{
    self.HUD.hidden = YES;
    NSString *kzt = bean.cardStatus;
    if ([kzt isEqualToString:@"1"]) {       // 卡状态--正常
        [CoreArchive setBool:YES key:LOGIN_STUTAS];
        [CoreArchive setStr:bean.id key:LOGIN_ID];
        [CoreArchive setStr:bean.name key:LOGIN_NAME];
        [CoreArchive setStr:bean.password key:LOGIN_USER_PSD];
        
        [CoreArchive setStr:bean.cardType key:LOGIN_CARD_TYPE];
        [CoreArchive setStr:bean.cardno key:LOGIN_CARD_NUM];
        [CoreArchive setStr:bean.shbzh key:LOGIN_SHBZH];
        [CoreArchive setStr:bean.bank key:LOGIN_BANK];
        
        [CoreArchive setStr:bean.bankCard key:LOGIN_BANK_CARD];
        [CoreArchive setStr:bean.userPng key:LOGIN_USER_PNG];
        [CoreArchive setStr:bean.cardMobile key:LOGIN_CARD_MOBILE];
        [CoreArchive setStr:bean.bankMobile key:LOGIN_BANK_MOBILE];
        
        [CoreArchive setStr:bean.appMobile key:LOGIN_APP_MOBILE];
        [CoreArchive setStr:bean.cardStatus key:LOGIN_CARD_STATUS];
        [CoreArchive setStr:bean.dzyx key:LOGIN_DZYX];
        [CoreArchive setStr:bean.yjdz key:LOGIN_YJDZ];
        
        [CoreArchive setStr:bean.updateTime key:LOGIN_UPDATE_TIME];
        [CoreArchive setStr:bean.createTime key:LOGIN_CREATE_TIME];
        [CoreArchive setStr:bean.access_token key:LOGIN_ACCESS_TOKEN];
        
        [CoreArchive setStr:bean.citCardNum key:LOGIN_CIT_CARDNUM];
        [CoreArchive setStr:bean.bankCode key:LOGIN_BANK_CODE];
        [CoreArchive setStr:bean.ydzf_status key:LOGIN_YDZF_STATUS];
        [CoreArchive setStr:bean.srrz_status key:LOGIN_SRRZ_STATUS];
        [CoreArchive setStr:bean.bankzf_status key:LOGIN_BANKZF_STATUS];
        
        [CoreArchive setStr:bean.birthDate key:LOGIN_BIRTHDATE];
        [CoreArchive setStr:bean.gender key:LOGIN_GENDER];
        [CoreArchive setStr:bean.push_alias key:JPUSH_ALIAS]; // 保存极光别名
        
        //删除极光推送的别名
        
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
            //DMLog(@"iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
        
            //设置个推的别名Alias--设置别名之前要清楚别名
            [JPUSHService setAlias:bean.push_alias completion:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                
                //DMLog(@"设置别名--iResCode--%li--iAlias--%@---seq--%li",iResCode,iAlias,seq);
                
            } seq:0];
        } seq:0];

        
        
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"isLogin" object:nil userInfo:nil];
                
        [self dismissViewControllerAnimated:NO completion:nil];

    }else if ([kzt isEqualToString:@"9"]){      // 卡状态--注销
//        NSString *bk = bean.bankCard;
//        NSString *account = [Util HeadStr:bk WithNum:0];
//        NSString *yhkh = [account substringFromIndex:account.length-4];
//        NSString *type = bean.cardType;
//        NSString *msg = [NSString stringWithFormat:@"   您绑定的市民卡（尾号%@）当前为失效状态，请补办新卡并修改市民卡信息后可继续登录。",yhkh];
//
//        [self showModifyCardView:msg andCard_Type:type andAccess_Token:bean.access_token];
    }else if ([kzt isEqualToString:@"2"]||[kzt isEqualToString:@"3"]){  // 卡状态--挂失、预挂失
//        ModifyCardView *vv = [ModifyCardView alterViewWithcontent:@"    您绑定的市民卡已预挂失/挂失，市民卡状态正常后方可登录操作！" sure:@"我知道了" sureBtClcik:^{
//            // 点击我知道了按钮
//            DMLog(@"我知道了！");
//        }];
//        [self.view addSubview:vv];
    }else{     // 卡状态--未启用
//        [MBProgressHUD showError:@"该卡处于未启用状态"];
    }
}

#pragma mark - 卡注销弹窗提示
-(void)showModifyCardView:(NSString *)msg andCard_Type:(NSString*)card_type andAccess_Token:(NSString*)access_token{
    LossAlertView *lll=[LossAlertView alterViewWithContent:msg cancel:@"取消" sure:@"修改" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
        
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"修改");
        if ([card_type isEqualToString:@"1"]) {
            ModifySMCardVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModifySMCardVC"];
            [VC setValue:access_token forKey:@"access_token"];
            [self.navigationController pushViewController:VC animated:YES];
        }else{
            ModifyHXCardVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ModifyHXCardVC"];
            [VC setValue:access_token forKey:@"access_token"];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }];
    [self.view addSubview:lll];
}

#pragma mark - 返回按钮
-(void)doclickLeftButton{
    [self dismissViewControllerAnimated:NO completion:nil];
}


#pragma mark -注册按钮
-(void)doClickRightAction{
    SelectCardVC *valueView = [self.storyboard instantiateViewControllerWithIdentifier:@"SelectCardVC"];
    [self.navigationController pushViewController:valueView animated:YES];
}

@end