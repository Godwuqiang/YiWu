//
//  DTFHarmoCardInfoComfirmVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/10/19.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  实人认证-和谐卡信息确认

#import "DTFHarmoCardInfoComfirmVC.h"
#import "DTFAuthenticateVC.h"
#import "HttpHelper.h"
#import "MineWebVC.h"
#import "SettingWebVC.h"
#import "BdH5VC.h"
#import "DTFAuthFailVC.h"
#import "DTFAuthCannotFailVC.h"


#define SRRZ_INFOMATION_URL         @"/shebao/srrzInformation.json"
#define SRRZ_AUTH_ZHIMA_INIT_URL    @"/zhima/zhimaCertificationInitialize.json"
#define URL_ZHIMA_AUTH_RESULT       @"/zhima/zhimaAuthResult.json"  //查询芝麻认证结果
#define URL_ZHIMA_AUTH_RESULT_FINDZHIFUPSD       @"/zhima/zhimaRetrievePwdResult.json"  //查询芝麻认证结果(找回密码)
#define URL_ZHIMA_AUTH_INIT_FINDZHIFUPSD @"/zhima/zhimaRetrievePwd.json" //初始化芝麻认证(找回密码)

@interface DTFHarmoCardInfoComfirmVC ()

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *IDLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankCardNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *bankNameLabel;
@property (weak, nonatomic) IBOutlet UIButton *nextButton;

@property (nonatomic, strong)   MBProgressHUD       *HUD;
@property (nonatomic, strong)   NSString            *biz_no;
@property (nonatomic, strong)   NSString            *transaction_id;
@property (nonatomic, strong)   NSString            *serNum;//流水号



/**
 实人认证协议同意选中按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *selectedButton;
@property (weak, nonatomic) IBOutlet UIButton *agreementButton;

@end

@implementation DTFHarmoCardInfoComfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"实人认证";
    
    self.nameLabel.text = @"--";//[CoreArchive strForKey:LOGIN_NAME];
    self.IDLabel.text = @"--";//[Util HeadStr:[CoreArchive strForKey:LOGIN_SHBZH] WithNum:0];//截取|前面的字符串
    self.bankCardNumberLabel.text = @"--";// [Util HeadStr:[CoreArchive strForKey:LOGIN_BANK_CARD] WithNum:0];//截取|前面的字符串
    self.bankNameLabel.text = @"--";//[CoreArchive strForKey:LOGIN_BANK];
    self.nextButton.layer.cornerRadius = 8.0;
    self.nextButton.clipsToBounds = YES;
    self.selectedButton.selected = YES;
    
    [self  getUserInfo];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zhimaCertificateReal:) name:@"zhimaCertificateReal" object:@"1"];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}


/**
 去进行芝麻认证

 @param sender 下一步按钮
 */
- (IBAction)gotoAuthenticate:(UIButton *)sender {
    
    if(self.selectedButton.selected){
        
        if(self.isFromZhimaRetrievePwd){
            
            //获取芝麻认证跳转支付宝的地址--找回支付密码
            [self getUrlRetrievePwd];
        }else{
            
            //获取芝麻认证跳转支付宝的地址--实人认证或者社保待遇资格认证
            [self getUrl];
        }
    }else{
        
        [MBProgressHUD showError:@"请阅读并同意”实人认证用户许可协议“后进行认证操作！"];
    }
}


/**
 实人认证协议选择按钮

 @param sender 实人认证协议选择按钮
 */
- (IBAction)selectedButtonClick:(UIButton *)sender {
    
    self.selectedButton.selected = !self.selectedButton.selected;
    
}

/**
 实人认证协议按钮点击事件

 @param sender 实人认证协议按钮
 */
- (IBAction)agreementButtonClick:(UIButton *)sender {
    
    
    UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
    BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
    [VC setValue:@"/h5/certify_agreement.html?" forKey:@"url"];
    [VC setValue:@"实人认证用户许可协议" forKey:@"tit"];
    [self.navigationController pushViewController:VC animated:YES];
}


#pragma mark - 获取芝麻认证 跳转需要的URL

-(void)getUrl{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"business_type"] = @"21";//21:ios实人认证;22:ios生存认证
    param[@"other_id"] = @"";
    
    DMLog(@"param--%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_AUTH_ZHIMA_INIT_URL];
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){
            
            self.biz_no = dictData[@"data"][@"bizNo"];
            self.transaction_id = dictData[@"data"][@"transactionId"];
            [self doVerify:dictData[@"data"][@"url"]];
            
        }else if([dictData[@"resultCode"] integerValue] == 302){
            
            DTFAuthCannotFailVC *VC = [[DTFAuthCannotFailVC alloc]init];
            [self.navigationController pushViewController:VC animated:YES];
            
        }else{
            
            [MBProgressHUD showError:dictData[@"message"]];
        }
        
        DMLog(@"获取芝麻认证 跳转需要的URL--返回结果---%@",dictData);
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

#pragma mark - 获取芝麻认证 跳转需要的URL  - 找回支付密码

-(void)getUrlRetrievePwd{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"business_type"] = @"21";//21:ios找回密码
    
    
    DMLog(@"param--%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_ZHIMA_AUTH_INIT_FINDZHIFUPSD];
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){
            
            self.biz_no = dictData[@"data"][@"bizNo"];
            self.transaction_id = dictData[@"data"][@"transactionId"];
            [self doVerify:dictData[@"data"][@"url"]];
            
        }else if([dictData[@"resultCode"] integerValue] == 302){//实人认证次数已达上限;
            
            DTFAuthCannotFailVC *VC = [[DTFAuthCannotFailVC alloc]init];
            [self.navigationController pushViewController:VC animated:YES];
            
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
        DMLog(@"获取芝麻认证 跳转需要的URL--返回结果---%@",dictData);
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
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
        if (version.doubleValue >= 10.0) {
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
-(void)zhimaCertificateReal:(NSNotification *)notice{
    
    DMLog(@"DTFAuthenticateVC - 收到芝麻认证回调的通知 - 实人认证 -- %@",notice);
    
    [self zhimaAuthFinished];
    
    if([notice.userInfo[@"passed"] boolValue]){
        
        DMLog(@"和谐卡--实人认证成功");
    }else{
        DMLog(@"和谐卡--实人认证失败");
    }
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



#pragma mark - 获取实人认证人员信息

-(void)getUserInfo{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_INFOMATION_URL];
    
    DMLog(@"获取实人认证人员信息--URL--%@",url);
    DMLog(@"获取实人认证人员信息--param--%@",param);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"获取实人认证人员信息-网络请求返回-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            
            self.nameLabel.text = dictData[@"data"][@"name"];
            self.IDLabel.text = dictData[@"data"][@"shbzh"];
            self.bankCardNumberLabel.text = dictData[@"data"][@"bankNo"];
            self.bankNameLabel.text = dictData[@"data"][@"bankName"];
            
        }else{//本人认证资格
            
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

#pragma mark - 实人认证完成后的回调服务端
-(void)zhimaAuthFinished{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"biz_no"] = self.biz_no;
    
    NSString *url = @"";
    if(!self.isFromZhimaRetrievePwd){//找回密码的回调
        
        param[@"serial_number"] = @"";//生存认证流水号
        param[@"business_type"] = @"2";//生存认证
        param[@"other_id"] = @"";
        url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_ZHIMA_AUTH_RESULT];
    }else{
        url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_ZHIMA_AUTH_RESULT_FINDZHIFUPSD];
    }
    
    
    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"实人认证完成后的回调服务端--返回结果---%@",dictData);
        
        if([dictData[@"resultCode"] integerValue] == 200){
            DMLog(@"回调服务端查询--实人认证成功");
            
            NSString * serNum = dictData[@"data"][@"serNum"];
            if(![serNum isEqualToString:@""]){//没有返回serNum
                self.serNum = dictData[@"data"][@"serNum"];
            }else{
                self.serNum = @"";
            }
            UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
            SettingWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"SettingWebVC"];
            
            if(![serNum isEqualToString:@""]){////没有返回serNum
                VC.str = self.serNum;
            }else{//第一次实人认证
                VC.str = @"";//芝麻认证-现在不传图片
            }
            
            [VC setValue:[CoreArchive strForKey:LOGIN_APP_MOBILE] forKey:@"phone"];
            [self.navigationController pushViewController:VC animated:YES];
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




@end
