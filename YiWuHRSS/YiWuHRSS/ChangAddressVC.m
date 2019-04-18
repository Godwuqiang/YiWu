//
//  ChangAddressVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ChangAddressVC.h"
#import "WebBL.h"
#import "LoginVC.h"

#define    CHANGE_HOME_ADDRESS_URL   @"user/add_address.json?"

@interface ChangAddressVC ()<WebBLDelegate>{
    BOOL  hasnet;
}
@property (nonatomic, strong)      WebBL        *webBL;
@property (nonatomic, strong)    MBProgressHUD  *HUD;
@end

@implementation ChangAddressVC

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:tap];
    [tap setCancelsTouchesInView:NO];
    
    HIDE_BACK_TITLE;
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
}

#pragma mark - 取消编辑状态
-(void)dismissKeyboard {
    [self.view endEditing:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [self initTitle];
    [self afn];
}

#pragma mark - 初始化标题显示
-(void)initTitle{
    NSString *address = [CoreArchive strForKey:LOGIN_YJDZ];
    if ([Util IsStringNil:address]) {
        self.navigationItem.title = @"添加家庭住址";
        self.address.placeholder = @"添加家庭住址";
        [self.btn setTitle:@"添加" forState:UIControlStateNormal];
    }else{
        self.navigationItem.title = @"修改家庭住址";
        self.address.text = address;
        [self.btn setTitle:@"修改" forState:UIControlStateNormal];
    }
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
            [self HomeAddress];
        }else{
            hasnet = NO;
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 获取用户家庭地址
-(void)HomeAddress{
    if (hasnet) {
        NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        [self showLoadingUI];
        [self.webBL queryHomeAddressWithAccessToken:accesstoken];
    }
}

#pragma mark - 获取用户家庭地址接口回调
-(void)queryHomeAddressSucceed:(UserBean *)bean{
    self.HUD.hidden = YES;
    if (![Util IsStringNil:bean.yjdz]) {
        self.address.text = bean.yjdz;
    }
    [CoreArchive setStr:bean.yjdz key:LOGIN_YJDZ];
}

-(void)queryHomeAddressFailed:(NSString*)error{
    self.HUD.hidden = YES;
}

#pragma mark - 修改按钮
- (IBAction)BtnClicked:(id)sender {
    NSString *address = self.address.text;
    if (address.length==0) {
        [MBProgressHUD showError:@"请输入家庭地址"];
        return;
    }
    if (![Util IsCorrectAddress:address]) {
        MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
        HUD.mode = MBProgressHUDModeText;
        HUD.margin = 10.f;
        HUD.yOffset = 15.f;
        HUD.removeFromSuperViewOnHide = YES;
        HUD.detailsLabelText = @"家庭住址只能由中文、字母或数字组成";
        HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
        [HUD hide:YES afterDelay:1.5];
        return;
    }
    if (hasnet) {
        NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        [self showLoadingUI];
        [self.webBL ChangHomeAddressWithAccessToken:accesstoken andDeviceType:@"2" andAddress:address];
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return;
    }
    
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

#pragma mark -  添加/修改用户家庭住址接口回调
-(void)ChangHomeAddressSucceed:(NSString*)message{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:@"操作成功！"];
    [CoreArchive setStr:self.address.text key:LOGIN_YJDZ];
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)ChangHomeAddressFailed:(NSString*)error{
    self.HUD.hidden = YES;
    [MBProgressHUD showError:error];
}


@end
