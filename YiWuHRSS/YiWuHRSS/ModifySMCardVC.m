//
//  ModifySMCardVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ModifySMCardVC.h"
#import "LoginHttpBL.h"


@interface ModifySMCardVC ()<LoginHttpBLDelegate,UITextFieldDelegate>{
     BOOL                hasnet;
}

@property (nonatomic, strong)    LoginHttpBL     *loginBL;
@property (nonatomic, strong)   MBProgressHUD    *HUD;
@property (nonatomic, strong)   ChangeCardBean   *changcardbean;

@end

@implementation ModifySMCardVC

-(void)viewDidLoad{
    [super viewDidLoad];
    self.navigationItem.title = @"修改市民卡信息";
    HIDE_BACK_TITLE;
    self.loginBL = [LoginHttpBL sharedManager];
    self.loginBL.delegate = self;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    self.nametf.delegate = self;
    self.shbzhtf.delegate = self;
    self.cardnotf.delegate = self;
    self.banknumtf.delegate = self;
    [self afn];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

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
    self.HUD.labelText = @"信息修改中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    
    if ([Util IsStringNil:string])
    {
        return YES;
    }
    
    if (textField==self.cardnotf) {
        NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
            if (character==32) return NO;
            if (character==79 || character==111) return NO;
            if (character < 48) return NO; // 48 unichar for 0
            if (character > 57 && character < 65) return NO; //
            if (character > 90 && character < 97) return NO;
            if (character > 122) return NO;
        }
        
        char commitChar = [string characterAtIndex:0];
        
        if (commitChar > 96 && commitChar < 123)
        {
            //小写变成大写
            
            NSString * uppercaseString = string.uppercaseString;
            
            NSString * str1 = [textField.text substringToIndex:range.location];
            
            NSString * str2 = [textField.text substringFromIndex:range.location];
            
            textField.text = [NSString stringWithFormat:@"%@%@%@",str1,uppercaseString,str2];
            
            return NO;
        }
    }else if(textField==self.shbzhtf || textField==self.banknumtf){
        NSUInteger lengthOfString = string.length;  //lengthOfString的值始终为1
        for (NSInteger loopIndex = 0; loopIndex < lengthOfString; loopIndex++) {
            unichar character = [string characterAtIndex:loopIndex]; //将输入的值转化为ASCII值（即内部索引值），可以参考ASCII表
            // 48-57;{0,9};65-90;{A..Z};97-122:{a..z}
            if (character==32) return NO;
        }
    }else{
        return YES;
    }
    
    return YES;
    
}

#pragma mark - 修改卡状态按钮点击事件
- (IBAction)ModifySMBtnClicked:(id)sender {
    NSString *name  = self.nametf.text;
    NSString *nameStr = [name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    DMLog(@"nameStr=%@",nameStr);
    NSString *shbzh     = self.shbzhtf.text;
    NSString *cardno    = self.cardnotf.text;
    NSString *bankCard  = self.banknumtf.text;
    NSString *card_type = @"1";
    
    if ([Util IsStringNil:name]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:nameStr]) {
        [MBProgressHUD showError:@"请输入姓名"];
        return;
    }
    if ([Util IsStringNil:shbzh]) {
        [MBProgressHUD showError:@"请输入社会保障号"];
        return;
    }
    if ([Util IsStringNil:cardno]) {
        [MBProgressHUD showError:@"请输入市民卡上的卡号"];
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
    self.changcardbean = bean;
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
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = @"操作成功！请重新登录";
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:3.0];
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
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = @"操作成功！请重新登录";
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:3.0];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)NoticeChangStatusFailed:(NSString *)error{
    DMLog(@"通知本地服务端失败！");
    self.HUD.hidden = YES;
    MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
    HUD.mode = MBProgressHUDModeText;
    HUD.margin = 10.f;
    HUD.yOffset = 15.f;
    HUD.removeFromSuperViewOnHide = YES;
    HUD.detailsLabelText = @"操作成功！请重新登录";
    HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
    [HUD hide:YES afterDelay:3.0];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
