//
//  BankKTVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/26.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BankKTVC.h"
#import "CountDownService.h"
#import "BankBL.h"
#import "JFH5VC.h"
#import "GHH5VC.h"
#import "LoginVC.h"

#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版


@interface BankKTVC ()<CountDownServiceDelegate,BankBLDelegate>{
    BOOL   hasnet;
}

@property (nonatomic, strong)      BankBL        *bankBL;
@property (nonatomic, strong)   MBProgressHUD    *HUD;
@property (nonatomic, strong)      NSString      *serNum;


@end

@implementation BankKTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTitle];
    // 让title显示居中
    NSArray *viewControllerArray = [self.navigationController viewControllers];
    long previousViewControllerIndex = [viewControllerArray indexOfObject:self] - 1;
    UIViewController *previous;
    if (previousViewControllerIndex >= 0) {
        previous = [viewControllerArray objectAtIndex:previousViewControllerIndex];
        previous.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                     initWithTitle:@"xx"
                                                     style:UIBarButtonItemStylePlain
                                                     target:self
                                                     action:nil];
    }
    HIDE_BACK_TITLE;
    DMLog(@"lx=%@",self.lx);
    [self initView];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 初始化界面标题
-(void)initTitle{
    NSString *zfzt = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];
    if ([zfzt isEqualToString:@"1"]) {
        self.navigationItem.title = @"银行卡支付注销";
        [self.openbtn setTitle:@"注销" forState:UIControlStateNormal];
    }else{
        self.navigationItem.title = @"银行卡支付开通";
        [self.openbtn setTitle:@"开通" forState:UIControlStateNormal];
    }
}

#pragma mark - 初始化界面数据显示
-(void)initView{
    self.nametf.text = [CoreArchive strForKey:LOGIN_NAME];
    NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
    self.IDNumtf.text = [Util HeadStr:sbh WithNum:0];

    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    self.cardnotf.text = [Util HeadStr:kh WithNum:0];

    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    self.bankcardtf.text = [Util HeadStr:bk WithNum:0];

    self.banktf.text = [CoreArchive strForKey:LOGIN_BANK];
    self.bankmobile.hidden = YES;
    
    self.bankBL = [BankBL sharedManager];
    self.bankBL.delegate = self;
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

#pragma mark - 页面将要进入前台，开启定时器
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
    [self afn];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:21.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xF8AB26]];
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

#pragma mark - 页面消失，进入后台不显示该页面，关闭定时器
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 关闭定时器
    [[CountDownService sharedManager] countDownStop];
    self.codebtn.enabled = YES;
    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [self.codebtn setTitle:@"发送验证码" forState:UIControlStateNormal];
    self.codebtn.userInteractionEnabled = YES;
}

- (void)dealloc{
    DMLog(@"销毁定时器");
    [[CountDownService sharedManager] countDownStop];
    
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 9;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    NSString *status = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];
    if ([type isEqualToString:@"1"]) {
        if ([status isEqualToString:@"1"]) {
            if (cell==self.SMSCodeCell) {
                return 0;
            }else if (cell==self.BlankCell) {
                return 0;
            }else if (cell==self.cardnocell) {
                return 50;
            }else{
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }else{
            if(cell == self.cardnocell) {
                return 50;
            }else if (cell==self.BlankCell) {
                return 10;
            }else if (cell==self.SMSCodeCell) {
                return 50;
            }else{
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }
    }else{
        if ([status isEqualToString:@"1"]) {
            if (cell==self.SMSCodeCell) {
                return 0;
            }else if (cell==self.BlankCell) {
                return 0;
            }else if (cell==self.cardnocell) {
                return 0;
            }else{
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }else{
            if(cell == self.cardnocell) {
                return 0;
            }else if (cell==self.BlankCell) {
                return 10;
            }else if (cell==self.SMSCodeCell) {
                return 50;
            }else{
                return [super tableView:tableView heightForRowAtIndexPath:indexPath];
            }
        }
    }
    
}

#pragma mark - 发送验证码点击事件
- (IBAction)CodeBtnClicked:(id)sender {
    if (hasnet) {
        [self showLoadingUI];
        // 检查数据录入
        NSString *zfzt = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];
        if (![zfzt isEqualToString:@"1"]) {
            [self.bankBL requestBankOpenSMSCodeWithName:[CoreArchive strForKey:LOGIN_NAME] andSHBZH:[CoreArchive strForKey:LOGIN_SHBZH] andCardNo:[CoreArchive strForKey:LOGIN_CARD_NUM] andBankCard:[CoreArchive strForKey:LOGIN_BANK_CARD] andCard_type:[CoreArchive strForKey:LOGIN_CARD_TYPE] andAccess_Token:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
        }
        // 发送验证码按钮灰显
        self.codebtn.enabled = NO;
        self.codebtn.userInteractionEnabled = NO;
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 开通/关闭按钮点击事件
- (IBAction)OpenBtnClicked:(id)sender {
    if (hasnet) {
        
        NSString *zfzt = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];
        if ([zfzt isEqualToString:@"1"]) {
            [self.bankBL requestBankCloseWithName:[CoreArchive strForKey:LOGIN_NAME] andSHBZH:[CoreArchive strForKey:LOGIN_SHBZH] andCardNo:[CoreArchive strForKey:LOGIN_CARD_NUM] andBankCard:[CoreArchive strForKey:LOGIN_BANK_CARD] andCard_type:[CoreArchive strForKey:LOGIN_CARD_TYPE] andAccess_Token:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
            [self showLoadingUI];
        }else{
            NSString *verCode = self.smscodetf.text;
            if ([Util IsStringNil:verCode]) {
                [MBProgressHUD showError:@"请输入验证码"];
                return;
            }
            
            [self.bankBL requestBankOpenWithName:[CoreArchive strForKey:LOGIN_NAME] andSHBZH:[CoreArchive strForKey:LOGIN_SHBZH] andCardNo:[CoreArchive strForKey:LOGIN_CARD_NUM] andBankCard:[CoreArchive strForKey:LOGIN_BANK_CARD] andCard_type:[CoreArchive strForKey:LOGIN_CARD_TYPE] andverCode:verCode andAccess_Token:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
            [self showLoadingUI];
        }
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 计时器监听
// 倒计时回调
- (void)onTimeTick:(NSInteger)hasSeconds{
    CGFloat ziti;
    if ( SCREEN_HEIGHT > 667) //6p
    {
        ziti = 13;      //
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        ziti = 12;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        ziti = 11;
    }
    else //3.5寸屏幕
    {
        ziti = 10;
    }

    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:ziti];
    [self.codebtn setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
    
    self.codebtn.enabled = NO;
    self.codebtn.userInteractionEnabled = NO;
}

// 倒计时结束时回调
- (void)onTimeFinish{
    self.codebtn.enabled = YES;
    self.codebtn.titleLabel.font = [UIFont systemFontOfSize:15];
    self.codebtn.userInteractionEnabled = YES;
}

#pragma mark - 银行卡支付开通----短信发送接口回调
-(void)requestBankOpenSMSCodeSucceed:(NSString *)serNum{
    self.HUD.hidden = YES;
    DMLog(@"请求验证码成功！");
    // 提示用户已发送短信
    [MBProgressHUD showSuccess:@"验证码已发送"];
    // 执行倒计时处理
    [[CountDownService sharedManager] countDownStart:self];
    
    self.bankmobile.hidden = NO;
    self.serNum = serNum;
    if ([Util IsStringNil:serNum]) {
        self.bankmobile.text = @"短信验证码发送至银行预留手机号码中";//短信验证码发送至银行预留的136*****112，如该号码非本人当前使用的有效号码，请至**银行变更。
    }else{
        NSString *banktel = [Util StrngForStar:self.serNum NumForHead:3 NumForEnd:3];
        self.bankmobile.text = [NSString stringWithFormat:@"短信验证码发送至银行预留的%@，如该号码非本人当前使用的有效号码，请至%@变更。",banktel,[CoreArchive strForKey:LOGIN_BANK]];
    }
}

-(void)requestBankOpenSMSCodeFailed:(NSString *)error{
    self.HUD.hidden = YES;
    DMLog(@"短信失败的提示：%@", error);
    [MBProgressHUD showError:error];
    // 发送验证码按钮正常
    self.codebtn.enabled = YES;
    self.codebtn.userInteractionEnabled = YES;
}

#pragma mark - 银行卡支付开通-----短信验证
-(void)requestBankOpenSucceed:(NSString *)dictList{
    self.HUD.hidden = YES;
    DMLog(@"银行卡支付开通成功！");
    [CoreArchive setStr:@"1" key:LOGIN_BANKZF_STATUS];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"isLogin" object:nil userInfo:nil];
    // 提示用户已发送短信
    [MBProgressHUD showSuccess:dictList];
    
    NSArray *temArray = self.navigationController.viewControllers;
    
    if ([self.lx isEqualToString:@"gh"]) {
        
        for(UIViewController *temVC in temArray)
        {
            if ([temVC isKindOfClass:[GHH5VC class]])
            {
                [self.navigationController popToViewController:temVC animated:YES];
            }
        }
    }else if ([self.lx isEqualToString:@"jf"]) {
        for(UIViewController *temVC in temArray)
        {
            if ([temVC isKindOfClass:[JFH5VC class]])
            {
                [self.navigationController popToViewController:temVC animated:YES];
            }
        }
    }else{
        [self.navigationController popToRootViewControllerAnimated:YES];
    }

}

-(void)requestBankOpenFailed:(NSString *)error{
    self.HUD.hidden = YES;
    DMLog(@"短信失败的提示：%@", error);
    [MBProgressHUD showError:error];
    // 发送验证码按钮灰显
    self.codebtn.enabled = YES;
    self.codebtn.userInteractionEnabled = YES;
}

#pragma mark - 银行卡支付注销-----短信发送
-(void)requestBankCloseSMSCodeSucceed:(NSString *)serNum{
    self.HUD.hidden = YES;
    DMLog(@"请求验证码成功！");
    // 提示用户已发送短信
    [MBProgressHUD showSuccess:@"验证码已发送"];
    // 执行倒计时处理
    [[CountDownService sharedManager] countDownStart:self];
    self.serNum = serNum;
}

-(void)requestBankCloseSMSCodeFailed:(NSString *)error{
    self.HUD.hidden = YES;
    DMLog(@"短信失败的提示：%@", error);
    // 提示用户
    [MBProgressHUD showError:error];
}

#pragma mark - 银行卡支付注销-----短信验证
-(void)requestBankCloseSucceed:(NSString *)dictList{
    self.HUD.hidden = YES;
    DMLog(@"银行卡支付注销成功！");
    [CoreArchive setStr:@"0" key:LOGIN_BANKZF_STATUS];
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"isLogin" object:nil userInfo:nil];
    // 提示用户已发送短信
    [MBProgressHUD showSuccess:dictList];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)requestBankCloseFailed:(NSString *)error{
    self.HUD.hidden = YES;
    DMLog(@"短信失败的提示：%@", error);
    [MBProgressHUD showError:error];
    // 发送验证码按钮灰显
    self.codebtn.enabled = YES;
    self.codebtn.userInteractionEnabled = YES;
}

@end
