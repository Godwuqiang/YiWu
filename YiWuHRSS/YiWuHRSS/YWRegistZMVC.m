//
//  YWRegistZMVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWRegistZMVC.h"
#import "YWLoginVC.h"
#import "SettingWebVC.h"
#import "DTFAuthFailVC.h"
#import "DTFAuthCannotFailVC.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key

#define REGIST_ZHIMA_INIT   @"zhima/zhimaCertificationInitialize/new" //注册-实人认证-初始化
#define REGIST_ZHIMA_RESULT       @"zhima/zhimaAuthResult2"  //查询芝麻认证结果


@interface YWRegistZMVC ()

/** 注释 */
@property (nonatomic,strong) MBProgressHUD * HUD;

@end

@implementation YWRegistZMVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"实人认证";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zhimaRegist:) name:@"zhimaRegist" object:@"1"];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}
-(void)dealloc{

    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"zhimaRegist" object:nil];
}

#pragma mark - showLoadingUI
/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
    self.HUD.hidden = NO;
}


#pragma mark - 去芝麻认证-实人认证
- (IBAction)gotoZMRZ:(UIButton *)sender {
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"name"] = self.name;
    param[@"shbzh"] = self.shbzh;
    param[@"app_version"] = version;
    param[@"device_type"] = @"2";
    param[@"business_type"] = @"23";

    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,REGIST_ZHIMA_INIT];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"义乌2.3注册=resultDict==%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            
            self.biz_no = dictData[@"data"][@"bizNo"];
            self.transaction_id = dictData[@"data"][@"transactionId"];
            [self doVerify:dictData[@"data"][@"url"]];
            
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


- (void)doVerify:(NSString *)url {
    
    NSString *alipayUrl = [NSString stringWithFormat:@"alipays://platformapi/startapp?appId=20000067&url=%@", [self URLEncodedStringWithUrl:url]];
    if ([self canOpenAlipay]) {
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >=10.0) {
            // 针对 10.0 以上的iOS系统进行处理
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl] options:@{} completionHandler:nil];
        } else {
            // 针对 10.0 以下的iOS系统进行处理
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:alipayUrl]];
        }
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"" message:@"是否下载并安装支付宝完成认证?" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"好的", nil];
        [alertView show];
    }
}

-(NSString *)URLEncodedStringWithUrl:(NSString *)url {
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)url,NULL,(CFStringRef) @"!*'();:@&=+$,%#[]|",kCFStringEncodingUTF8));
    return encodedString;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *appstoreUrl = @"itms-apps://itunes.apple.com/app/id333206289";
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:appstoreUrl] options:@{} completionHandler:nil];
    }
}

- (BOOL)canOpenAlipay {
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"alipays://"]];
}

#pragma mark  - 芝麻认证完成 - 回调到本APP - 接收到APP的通知
-(void)zhimaRegist:(NSNotification *)notice{
    
    DMLog(@"DTFAuthenticateVC - 收到芝麻认证回调的通知 - 实人认证 -- %@",notice);
    
    //认证完成后回调服务端
    [self zhimaAuthFinished];
    
    if([notice.userInfo[@"passed"] boolValue]){
        
        DMLog(@"实人认证失败");
    }else{
        DMLog(@"实人认证失败");
    }
}

#pragma mark - 实人认证完成后的回调服务端
-(void)zhimaAuthFinished{
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,REGIST_ZHIMA_RESULT];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"name"] = self.name;
    param[@"shbzh"] = self.shbzh;
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"biz_no"] = self.biz_no;
    param[@"business_type"] = @"23";
    param[@"serial_number"] = @"";//生存认证流水号
    param[@"device_type"] = @"2";//生存认证
    param[@"other_id"] = @"";
    
    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"实人认证完成后的回调服务端--返回结果---%@",dictData);
  
        
        if([dictData[@"resultCode"] integerValue] == 200){
            DMLog(@"回调服务端查询--实人认证成功");
            
            if([dictData[@"data"][@"cardType"] isEqualToString:@"100"]){
                [CoreArchive setStr:@"1" key:LOGIN_CARD_TYPE];//市民卡
            }else{
                [CoreArchive setStr:@"2" key:LOGIN_CARD_TYPE];
            }
            
            
            [CoreArchive setStr:dictData[@"data"][@"cardNum"] key:LOGIN_CARD_NUM];
            [CoreArchive setStr:dictData[@"data"][@"account"] key:LOGIN_BANK_CARD];
            [CoreArchive setStr:dictData[@"data"][@"certNum"] key:LOGIN_SHBZH];
            
            DMLog(@"LOGIN_CARD_TYPE==%@",[CoreArchive strForKey:LOGIN_CARD_TYPE]);
            DMLog(@"LOGIN_CARD_NUM==%@",[CoreArchive strForKey:LOGIN_CARD_NUM]);
            DMLog(@"LOGIN_BANK_CARD==%@",[CoreArchive strForKey:LOGIN_BANK_CARD]);
            DMLog(@"LOGIN_SHBZH==%@",[CoreArchive strForKey:LOGIN_SHBZH]);
          
            //有卡-进行注册操作
            [self registToServer];
            
            
        }else if([dictData[@"resultCode"] integerValue] == 102){ //认证失败
            
            if(dictData[@"data"] == nil){
                [MBProgressHUD showError:dictData[@"message"]];
                return ;
            }
            
            if(dictData[@"data"][@"srrzCheckFlag"]==nil){
                [MBProgressHUD showError:dictData[@"message"]];
                return ;
            }
            
            if([dictData[@"data"][@"srrzCheckFlag"] integerValue] == 1){//srrzCheckFlag ：实人认证开关状态:开启
                
                if([dictData[@"data"][@"lastSrrzCount"] integerValue] > 0){
                    
                    DTFAuthFailVC *vc = [[DTFAuthFailVC alloc]init];
                    vc.lastSrrzCount =  [dictData[@"data"][@"lastSrrzCount"] integerValue];//设置剩余实人认证的次数
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{
                    
                    DTFAuthCannotFailVC *vc = [[DTFAuthCannotFailVC alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }else{//srrzCheckFlag ：实人认证开关状态:关闭
                [MBProgressHUD showError:@"实人认证失败~"];
            }
            DMLog(@"服务端返回的失败原因--%@",dictData[@"message"]);
        }else if([dictData[@"resultCode"] integerValue] == 2018){
            
            //实人认证通过-且无卡
            [self registToServer];
            
            
            
        }else{
            
            
            
            [MBProgressHUD showError:dictData[@"message"]];
        }
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"实人认证完成后的回调服务端--请求失败--%@",error);
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}


/**
 芝麻认证完成后-成功-注册
 */
-(void)registToServer{
    
    NSString * shbzhAES = aesEncryptString(self.shbzh, AESEncryptKey);
    NSString * appMobileAES = aesEncryptString(self.appMobile, AESEncryptKey);
    NSString * passwordAES = aesEncryptString([Util MD5:self.password], AESEncryptKey);
    
    NSString *url = [NSString stringWithFormat:@"%@/userServer/register/New2/aes",HOST_TEST];
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"name"] = self.name;
    param[@"shbzh"] = shbzhAES;
    param[@"imei"] = [Util getuuid];
    param[@"appMobile"] = appMobileAES;
    param[@"password"] = passwordAES;
    param[@"device_type"] = @"2";
    
    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"芝麻认证完成后-成功-注册--返回结果---%@",dictData);
        
        
        if([dictData[@"resultCode"] integerValue] == 200){
            
            if([CoreArchive strForKey:LOGIN_BANK_CARD] != nil){//有卡
                
                self.serNum = @"";
                UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                SettingWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"SettingWebVC"];
                VC.isFromRegist = YES;
                VC.str = self.serNum;
                //注册-实人认证-之前没有设置过支付密码-这里的serNum传空
                [VC setValue:self.appMobile forKey:@"phone"];
                [self.navigationController pushViewController:VC animated:YES];
                
            }else{//无卡
                
                [MBProgressHUD showError:dictData[@"message"]];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(2.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    //注册成功-跳转登录页面
                    
                    //[CoreArchive setValue:_shbzh forKey:@"cache_shbzh"];
                    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
                    [center postNotificationName:@"regist_setPayPassword_finish" object:nil userInfo:nil];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                });
            }
        }else{
            
            //注册失败-清空缓存中的卡相关信息
            [CoreArchive setStr:nil key:LOGIN_CARD_NUM];
            [CoreArchive setStr:nil key:LOGIN_BANK_CARD];
            [CoreArchive setStr:nil key:LOGIN_SHBZH];
            [MBProgressHUD showError:dictData[@"message"]];
        }
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

@end
