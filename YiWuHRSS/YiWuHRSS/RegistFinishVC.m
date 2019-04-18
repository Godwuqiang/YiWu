//
//  RegistFinishVC.m
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RegistFinishVC.h"
#import "LoginVC.h"
#import "MineWebVC.h"
#import "LoginHttpBL.h"
#import "JPUSHService.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"


@interface RegistFinishVC()<LoginHttpBLDelegate>

@property     BOOL       hasnet;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation RegistFinishVC


-(void)viewDidLoad{
    [super viewDidLoad];
    if(![Util IsStringNil:self.Label_title]){
        self.Label_Tile.text = self.Label_title;
    }
    self.navigationItem.title = @"注册";
    HIDE_BACK_TITLE;
    
    UIBarButtonItem *litem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStyleDone target:self action:@selector(navBack)];
    self.navigationItem.leftBarButtonItem = litem;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    NSString *message =  [NSString stringWithFormat:@"账户%@注册成功",self.mobile];
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:message];
    [str addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0xFDB731] range:NSMakeRange(2,self.mobile.length)];
    
    self.Label_Account.attributedText = str;
//    [self.Icon_regist setImage:[UIImage imageNamed:@"icon_fail"]];
    
    [self afn];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [self.manger stopMonitoring];
    self.manger = nil;
}

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            self.hasnet = YES;
            [self AutoLogin];
        }else{
            self.hasnet = NO;
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
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

#pragma mark - 返回登录界面
- (void)navBack{
    // 返回登录界面
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark - 自动登录事件
-(void)AutoLogin{
    LoginHttpBL *loginBL = [LoginHttpBL sharedManager];
    loginBL.delegate = self;
    NSString *md5psd = [Util MD5:self.psd];
    [loginBL LoginRequest:self.mobile Password:md5psd];
}


#pragma mark - 实人认证的点击事件
- (IBAction)OnClickDeAction:(id)sender {
    if (self.hasnet) {
        NSString *cardstatus = [CoreArchive strForKey:LOGIN_SRRZ_STATUS];
        if ([cardstatus isEqualToString:@"1"]) {
            [MBProgressHUD showError:@"您已进行实人认证！"];
        }else{
            //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
            //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
            //[self.navigationController pushViewController:VC animated:YES];
            
            if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
                
            }else{//实人认证-和谐卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
            
        }
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
    }
}

#pragma mark - 登录成功接口回调函数
-(void)requestLoginSucceed:(UserBean *)bean{
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
}

-(void)requestLoginFailed:(NSString *)error{
    [MBProgressHUD showError:error];
}


@end
