//
//  ModifyHXCardVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ModifyHXCardVC.h"
#import "LoginHttpBL.h"


@interface ModifyHXCardVC ()<LoginHttpBLDelegate,UITextFieldDelegate>{
     BOOL       hasnet;
}

@property (nonatomic, strong)    LoginHttpBL     *loginBL;
@property (nonatomic, strong)   MBProgressHUD    *HUD;
@property (nonatomic, strong)   ChangeCardBean   *changcardbean;

@end

@implementation ModifyHXCardVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"修改和谐卡信息";
    HIDE_BACK_TITLE;
    
    self.nametf.delegate = self;
    self.idnumtf.delegate = self;
    self.banknotf.delegate = self;
    
    self.loginBL = [LoginHttpBL sharedManager];
    self.loginBL.delegate = self;
    
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
//    [self afn];
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

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if ([Util IsStringNil:string])
    {
        return YES;
    }
    
    NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
    for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
        unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
        // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
        if (character==32) return NO;
    }
    
    return YES;
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"信息修改中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 修改卡状态按钮点击事件
- (IBAction)ModifyHXBtnClicked:(id)sender {
    NSString *name      = self.nametf.text;
    NSString *nameStr = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    DMLog(@"nameStr=%@",nameStr);
    NSString *shbzh     = self.idnumtf.text;
    NSString *cardno    = @"";
    NSString *bankCard  = self.banknotf.text;
    NSString *card_type = @"2";//和谐卡
    
    if ([Util IsStringNil:name]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:nameStr]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入身份证号码"];
        return;
    }
    if ([Util IsStringNil:bankCard]) {
        [MBProgressHUD showError:@"请输入银行卡号"];
        return;
    }
    if (hasnet) {
        [self showLoadingUI];
        [self.loginBL ChangCardStatusWithName:nameStr andSHBZH:shbzh andCardno:cardno andBankCard:bankCard andCard_Type:card_type andAccess_Token:self.access_token];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return ;
    }
}

#pragma mark - 修改市民卡状态接口回调
-(void)ChangCardStatusSucceed:(ChangeCardBean*)bean{
    self.HUD.hidden = YES;
    self.changcardbean = bean;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = @"操作成功！请重新登录";
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:3.0];
    
    // 调用杭州接口调整医快付平台更新卡信息，之后再通知服务端修改卡
    if (hasnet) {
        [self.loginBL ConnetYKFWithBean:bean];
    }else{
        DMLog(@"当前网络不可用，请检查网络设置");
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }
}

-(void)ChangCardStatusFailed:(NSString *)error{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:error];
}

#pragma mark - 通知杭州医快付云平台接口回调
-(void)ConnetYKFSucceed:(NSString*)message{
    DMLog(@"调用杭州接口成功，接着通知本地服务端");
    [self NoticeChangCardStatus];
}

-(void)ConnetYKFFailed:(NSString *)error{
    DMLog(@"调用杭州接口失败");
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 修改卡的通知状态接口
-(void)NoticeChangCardStatus{
    if (hasnet) {
        [self.loginBL NoticeChangStatusWithCardno:self.changcardbean.oldSiCard andShbzh:self.changcardbean.cardNum andcard_type:self.changcardbean.flag andbankCard:self.changcardbean.bankNum];
    }else{
        DMLog(@"当前网络不可用，请检查网络设置");
        [self.navigationController popViewControllerAnimated:YES];
        return ;
    }
}

#pragma mark - 修改卡的通知状态接口回调
-(void)NoticeChangStatusSucceed:(NSString*)message{
    DMLog(@"通知本地服务端成功！");
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)NoticeChangStatusFailed:(NSString *)error{
    DMLog(@"通知本地服务端失败！");
    [self.navigationController popViewControllerAnimated:YES];
}

@end
