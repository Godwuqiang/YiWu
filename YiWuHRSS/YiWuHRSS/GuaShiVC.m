//
//  GuaShiVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/15.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "GuaShiVC.h"
#import "GuaShiCell.h"
#import "GuaShiOneCell.h"
#import "GuaShiTwoCell.h"
#import "GuaShiCellThree.h"
#import "GSAlertView.h"
#import "CountDownService.h"
#import "RegistHttpBL.h"
#import "JieGuoVC.h"
#import "JPUSHService.h"

#define STR_TAIL_CELL_FORMAT    @"(%lds)重新发送"    // 提示行文字内容模版

@interface GuaShiVC ()<UITableViewDataSource,UITableViewDelegate,RegistHttpBLDelegate,CountDownServiceDelegate>

/**
 *  验证码
 */
@property(nonatomic, weak) UITextField *codeTextField;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (nonatomic, strong)    MBProgressHUD  *HUD;
@property (nonatomic, strong)     RegistHttpBL  *registHttpBL;
@property (nonatomic, strong)     SMKStatusBean *sbean;

@property        BOOL            hasnet;
@property (nonatomic, strong)     NSString      *tishi;
@property        BOOL    hasData;

@end

@implementation GuaShiVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"市民卡预挂失";
    HIDE_BACK_TITLE;
    [self afn];
    [self initView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    //    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            [self loadData];
            self.hasnet = YES;
        }else{
            self.hasnet = NO;
            self.tishi = @"noweb";
            self.hasData = NO;
            [self setupNoWeb];
        }
    }];
}

#pragma mark - 请求验证市民卡是否符合挂失条件
-(void)loadData{
    self.registHttpBL = [RegistHttpBL sharedManager];
    self.registHttpBL.delegate = self;
    NSString *accessToken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self.registHttpBL checkSMKstatusWith:accessToken];
    
    [self showLoadingUI];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

#pragma mark - 市民卡预挂失资格接口回调
-(void)checkSMKstatusSucess:(SMKStatusBean *)bean{
    self.HUD.hidden = YES;
    self.sbean = bean;
    self.hasData = YES;
    self.gstableview.hidden = NO;
    [self.gstableview reloadData];
    self.contentview.hidden = YES;
}

-(void)checkSMKstatusFail:(NSString *)error{
    self.HUD.hidden = YES;
    self.contentview.hidden = NO;
    
    long code = [error longLongValue];
    if (code == 5001 || code == 5002) {
        self.contentview.hidden = NO;
        self.TsImg.image = [UIImage imageNamed:@"img_busy"];
        self.TsLb.text = @"找不到您的登录信息，请重新登录试试~";
        self.TsBtn.hidden = YES;
        self.ReturnBtn.hidden = YES;
        
    }else {
        if ([error isEqualToString:@"服务暂不可用，请稍后重试"]) {
            self.TsImg.image = [UIImage imageNamed:@"img_busy"];
            self.TsLb.text = @"服务暂不可用，请稍后重试";
            self.TsBtn.hidden = NO;
            self.ReturnBtn.hidden = YES;
            [self.TsBtn addTarget:self action:@selector(Refresh) forControlEvents:UIControlEventTouchUpInside];
        }else{
            self.TsImg.image = [UIImage imageNamed:@"img_nopeople"];
            self.TsLb.text = @"您的市民卡不符合挂失条件！";
            self.TsBtn.hidden = YES;
            self.ReturnBtn.hidden = NO;
            [self.ReturnBtn addTarget:self action:@selector(Return) forControlEvents:UIControlEventTouchUpInside];
        }
    }
   
}

#pragma mark - 初始化界面UI
-(void)initView{
    self.gstableview.dataSource = self;
    self.gstableview.delegate = self;
    [self.gstableview registerNib:[UINib nibWithNibName:@"GuaShiCell" bundle:nil] forCellReuseIdentifier:@"GuaShiCell"];
    [self.gstableview registerNib:[UINib nibWithNibName:@"GuaShiOneCell" bundle:nil] forCellReuseIdentifier:@"GuaShiOneCell"];
    [self.gstableview registerNib:[UINib nibWithNibName:@"GuaShiTwoCell" bundle:nil] forCellReuseIdentifier:@"GuaShiTwoCell"];
    [self.gstableview registerNib:[UINib nibWithNibName:@"GuaShiCellThree" bundle:nil] forCellReuseIdentifier:@"GuaShiCellThree"];
    self.gstableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.gstableview.tableFooterView = [[UIView alloc] init];
    
    self.contentview.hidden = YES;
    self.gstableview.hidden = YES;
}

#pragma mark - 无网界面
-(void)setupNoWeb{
    self.gstableview.hidden = YES;
    self.contentview.hidden = NO;
    self.TsImg.image = [UIImage imageNamed:@"img_noweb"];
    self.TsLb.text = @"当前网络不可用，请检查网络设置";
    self.TsBtn.hidden = NO;
    self.ReturnBtn.hidden = YES;
    [self.TsBtn addTarget:self action:@selector(Refresh) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

#pragma mark - 页面消失，进入后台不显示该页面，关闭定时器 清空验证码信息
-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    // 关闭定时器
    [[CountDownService sharedManager] countDownStop];
    
    UIButton *sender = (UIButton *)[self.view viewWithTag:992];
    sender.enabled = YES;
    sender.titleLabel.font = [UIFont systemFontOfSize:15];
    [sender setTitle:@"发送验证码" forState:UIControlStateNormal];
    sender.userInteractionEnabled = YES;
    self.codeTextField.text = @"";
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

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
        if ([type isEqualToString:@"1"]) {     // 市民卡
            return 5;
        }else{
            return 4;
        }
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    int gao1,gao2;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
        gao1 = 80;
        gao2 = 50;      //
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        gao1 = 75;
        gao2 = 45;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        gao1 = 65;
        gao2 = 40;
    }
    else //3.5寸屏幕
    {
        gao1 = 60;
        gao2 = 35;
    }
    
    if (indexPath.section==0) {
        NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
        if ([type isEqualToString:@"1"]) {     // 市民卡
            if (indexPath.row==0||indexPath.row==4) {
                return gao1;
            }else{
                return gao2;
            }
        }else{
            if (indexPath.row==0||indexPath.row==3) {
                return gao1;
            }else{
                return gao2;
            }
        }
    }else{
        return 270;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0&&indexPath.row==0) {
        GuaShiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiCell"];
        if ( nil == cell ){
            cell = [[GuaShiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiCell"];
        }
        cell.Name.text = @"姓          名";
        cell.Neirong.text = [Util decryptUseDES:self.sbean.name key:desKey];
        
        return cell;
    }else{
        if (indexPath.section==0) {
            NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
            if ([type isEqualToString:@"1"]) {     // 市民卡
                if (indexPath.row==1){
                    GuaShiOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiOneCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiOneCell"];
                    }
                    cell.Lname.text = @"社会保障号";
                    cell.Ltext.text = [Util decryptUseDES:self.sbean.shbzh key:desKey];
                    return cell;
                }else if (indexPath.row==2){
                    GuaShiOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiOneCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiOneCell"];
                    }
                    cell.Lname.text = @"卡           号";
                    cell.Ltext.text = [Util decryptUseDES:self.sbean.cardNo key:desKey];
                    return cell;
                }else if (indexPath.row==3){
                    GuaShiOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiOneCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiOneCell"];
                    }
                    cell.Lname.text = @"银 行 卡 号";
                    cell.Ltext.text = [Util decryptUseDES:self.sbean.bankNo key:desKey];
                    return cell;
                }else{
                    GuaShiTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiTwoCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiTwoCell"];
                    }
                    cell.Telnum.text = [CoreArchive strForKey:LOGIN_APP_MOBILE];
                    return cell;
                }
            }else{          // 和谐卡
                if (indexPath.row==1){
                    GuaShiOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiOneCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiOneCell"];
                    }
                    cell.Lname.text = @"身 份 证 号";
                    cell.Ltext.text = [Util decryptUseDES:self.sbean.shbzh key:desKey];
                    return cell;
                }else if (indexPath.row==2){
                    GuaShiOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiOneCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiOneCell"];
                    }
                    cell.Lname.text = @"银 行 卡 号";
                    cell.Ltext.text = [Util decryptUseDES:self.sbean.bankNo key:desKey];
                    return cell;
                }else{
                    GuaShiTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiTwoCell"];
                    if ( nil == cell ){
                        cell = [[GuaShiTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiTwoCell"];
                    }
                    cell.Telnum.text = [CoreArchive strForKey:LOGIN_APP_MOBILE];
                    return cell;
                }
            }
        }else{
            GuaShiCellThree *cell = [tableView dequeueReusableCellWithIdentifier:@"GuaShiCellThree"];
            if ( nil == cell ){
                cell = [[GuaShiCellThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GuaShiCellThree"];
            }
            self.codeTextField = cell.Inputcode;
            cell.sendbtn.tag = 992;
            [cell.sendbtn addTarget:self action:@selector(countDownBtnAction:) forControlEvents:UIControlEventTouchUpInside];
            [cell.gsbtn addTarget:self action:@selector(GsBtnAction) forControlEvents:UIControlEventTouchUpInside];
            
            NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"1、在预挂失成功后，您将被退出登录。市民卡状态正常后，方可登录，请谨慎操作！"];
            [str1 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(2,15)];
            
            
            NSMutableAttributedString *str2 = [[NSMutableAttributedString alloc] initWithString:@"1、市民卡预挂失自受理之日起5个自然日内应及时携带有效身份证原件前往开卡银行网点进行书面挂失，否则过期自动解除预挂失。"];
            [str2 addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:NSMakeRange(14,5)];
            
            cell.bz1.attributedText = str2;
            cell.bz2.hidden = YES;
            
            return cell;
        }
    }
}

#pragma mark - 倒计时点击事件
- (void)countDownBtnAction:(UIButton *)button{
    if (_hasnet) {
        self.registHttpBL = [RegistHttpBL sharedManager];
        self.registHttpBL.delegate = self;
        
        NSString *mobileNum = [CoreArchive strForKey:LOGIN_APP_MOBILE];
        [self.registHttpBL requestSMSCode:mobileNum andmessage_type:@"3"];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 申请挂失按钮点击事件
-(void)GsBtnAction{
    NSString *code = self.codeTextField.text;
    if (code.length==0) {
        [MBProgressHUD showError:@"请输入手机验证码"];
        return;
    }
    if (_hasnet) {
        NSString *mobileNo = [CoreArchive strForKey:LOGIN_APP_MOBILE];
        [self.registHttpBL CheckYZMValidWith:mobileNo andvalidCode:code];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 获取验证码回调
-(void)requestSMSCodeSucess:(SMSCodeBean*)bean{
    DMLog(@"请求验证码成功！");
    // 提示用户已发送短信
    [MBProgressHUD showError:@"验证码已发送"];
    // 执行倒计时处理
    [[CountDownService sharedManager] countDownStart:self];
    
    // 发送验证码按钮灰显
    UIButton *sender = (UIButton *)[self.view viewWithTag:992];
    sender.enabled = NO;
    sender.userInteractionEnabled = NO;
}

- (void)requestSMSCodeFail:(NSString *)error{
    DMLog(@"短信失败的提示：%@", error);
    // 提示用户
    [MBProgressHUD showError:error];
    
    // 发送验证码按钮正常显示
    UIButton *sender = (UIButton *)[self.view viewWithTag:992];
    sender.enabled = YES;
    sender.userInteractionEnabled = YES;
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
    
    UIButton *sender = (UIButton *)[self.view viewWithTag:992];
    sender.titleLabel.font = [UIFont systemFontOfSize:ziti];
    //    [self.BtnSendCode setTitleColor:[UIColor colorWithHex:0x999999] forState:UIControlStateDisabled];
    [sender setTitle:[NSString stringWithFormat:STR_TAIL_CELL_FORMAT, (long)hasSeconds] forState:UIControlStateDisabled];
    
    sender.enabled = NO;
    sender.userInteractionEnabled = NO;
}

#pragma mark - 倒计时结束时回调
- (void)onTimeFinish{
    UIButton *sender = (UIButton *)[self.view viewWithTag:992];
    sender.enabled = YES;
    sender.titleLabel.font = [UIFont systemFontOfSize:15];
    [sender setTitle:@"发送验证码" forState:UIControlStateNormal];
    sender.userInteractionEnabled = YES;
}

#pragma mark - 市民卡预挂失中验证验证码是否有效接口回调
-(void)CheckYZMValidSucess:(NSString*)message{
    GSAlertView *lll=[GSAlertView alterViewWithContent:@"   为保障您的信息安全，预挂失成功后，您将被退出登录。您的卡状态正常后，方可登录，请谨慎操作，是否继续？" cancel:@"取消" sure:@"继续" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
        // 关闭定时器
        [[CountDownService sharedManager] countDownStop];
        
        UIButton *sender = (UIButton *)[self.view viewWithTag:992];
        sender.enabled = YES;
        sender.titleLabel.font = [UIFont systemFontOfSize:15];
        [sender setTitle:@"发送验证码" forState:UIControlStateNormal];
        sender.userInteractionEnabled = YES;
        self.codeTextField.text = @"";
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"继续");
        NSString *accessToken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        NSString *mobileNo = [CoreArchive strForKey:LOGIN_APP_MOBILE];
        NSString *validCode = self.codeTextField.text;
        if (validCode.length==0) {
            [MBProgressHUD showError:@"请输入手机验证码"];
            return;
        }
        if (_hasnet) {
            [self.registHttpBL guashiSMKWith:accessToken andmobileNo:mobileNo andvalidCode:validCode];
            [self showLoadingUI];
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            return ;
        }
    }];
    
    [self.view addSubview:lll];
}

-(void)CheckYZMValidFail:(NSString *)error{
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = error;
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:2.0];
}

#pragma mark - 市民卡预挂失业务接口回调
-(void)guashiSMKSucess:(NSString*)message{
    self.HUD.hidden = YES;
    
    [CoreArchive setBool:NO key:LOGIN_STUTAS];
    [CoreArchive setStr:nil key:LOGIN_ID];
    [CoreArchive setStr:nil key:LOGIN_NAME];
    [CoreArchive setStr:nil key:LOGIN_USER_PSD];
    
    [CoreArchive setStr:nil key:LOGIN_CARD_TYPE];
    [CoreArchive setStr:nil key:LOGIN_CARD_NUM];
    [CoreArchive setStr:nil key:LOGIN_SHBZH];
    [CoreArchive setStr:nil key:LOGIN_BANK];
    
    [CoreArchive setStr:nil key:LOGIN_BANK_CARD];
    [CoreArchive setStr:nil key:LOGIN_USER_PNG];
    [CoreArchive setStr:nil key:LOGIN_CARD_MOBILE];
    [CoreArchive setStr:nil key:LOGIN_BANK_MOBILE];
    
    // [CoreArchive setStr:nil key:LOGIN_APP_MOBILE];
    [CoreArchive setStr:nil key:LOGIN_CARD_STATUS];
    [CoreArchive setStr:nil key:LOGIN_DZYX];
    [CoreArchive setStr:nil key:LOGIN_YJDZ];
    
    [CoreArchive setStr:nil key:LOGIN_CIT_CARDNUM];
    [CoreArchive setStr:nil key:LOGIN_UPDATE_TIME];
    [CoreArchive setStr:nil key:LOGIN_CREATE_TIME];
    [CoreArchive setStr:nil key:LOGIN_ACCESS_TOKEN];
    
    //删除极光推送的别名
    [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
        
    } seq:0];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center postNotificationName:@"Exit" object:nil userInfo:nil];
    
    JieGuoVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JieGuoVC"];
    [vc setValue:@(YES) forKey:@"jg"];
    [self.navigationController pushViewController:vc animated:NO];
}

-(void)guashiSMKFail:(NSString *)error{
    self.HUD.hidden = YES;
    long value = [error longLongValue];
    if (value==1000) {
        JieGuoVC *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JieGuoVC"];
        [vc setValue:@(NO) forKey:@"jg"];
        [self.navigationController pushViewController:vc animated:NO];
    }else if (value==5001 || value==5002) {

        self.gstableview.hidden = YES;
        self.contentview.hidden = NO;
        self.TsImg.image = [UIImage imageNamed:@"img_busy"];
        self.TsLb.text = @"找不到您的登录信息，请重新登录试试~";
        self.TsBtn.hidden = YES;
        self.ReturnBtn.hidden = YES;
    }else{
        [MBProgressHUD showError:error];
    }
}

#pragma mark - 返回按钮事件
-(void)Return{
    [self.navigationController popViewControllerAnimated:NO];
}

#pragma mark - 重新刷新按钮事件
-(void)Refresh{
    [self afn];
}

@end
