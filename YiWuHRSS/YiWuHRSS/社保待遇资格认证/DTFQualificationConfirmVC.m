//
//  DTFQualificationConfirmVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/22.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFQualificationConfirmVC.h"
#import "HttpHelper.h"
#import "DTFQualificationSuccessVC.h"
#import "DTFQualificationFailVC.h"
#import "DTFAuthCannotFailVC.h"

#define URL_IS_ABLE_TO_QUALIFER     @"/shebao/attestInformation.json" //判断是否可以进行资格认证
#define URL_ZHIMA_AUTH_INIT         @"/zhima/zhimaCertificationInitialize.json"  //芝麻认证初始化地址
#define URL_ZHIMA_AUTH_RESULT       @"/zhima/zhimaAuthResult.json"  //查询芝麻认证结果

@interface DTFQualificationConfirmVC ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *insureNumberLabel;
@property(nonatomic ,strong) MBProgressHUD * HUD;

@property (nonatomic, strong)   NSString            *biz_no;
@property (nonatomic, strong)   NSString            *transaction_id;

@end

@implementation DTFQualificationConfirmVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"社保待遇资格认证";
    self.nameLabel.text = self.name;
    self.insureNumberLabel.text = self.shbzh;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(zhimaQualifications:) name:@"zhimaQualifications" object:@"1"];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮
}


-(void)back{
    [self.navigationController popViewControllerAnimated:YES];
}



/**
 确认进行资格认证按钮点击事件

 @param sender 确认进行资格认证
 */
- (IBAction)comfirmButtonClick:(UIButton *)sender {
    
    DMLog(@"确认进行资格认证按钮点击事件");
    //获取芝麻认证跳转支付宝的地址
    [self getUrl];
}


/**
 如果是来自其他社保待遇资格认证需要在本页面获取用户的信息
 */
-(void)getQualiferInfo{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"other_id"] = [NSString stringWithFormat:@"%li",self.ID];
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_IS_ABLE_TO_QUALIFER];
    
    DMLog(@"本人认证资格--URL--%@",url);
    DMLog(@"本人认证资格--param--%@",param);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"添加其他资格认证人员-网络请求返回-%@",dictData);
        NSLog(@"message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            

            self.nameLabel.text = dictData[@"data"][@"name"];
            self.insureNumberLabel.text = dictData[@"data"][@"shbzh"];
            self.serialNumber = dictData[@"data"][@"serialNumber"];

        }else{//本人认证资格
            
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----本人认证资格--请求失败--%@",error);
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
-(void)zhimaQualifications:(NSNotification *)notice{
    
    DMLog(@"DTFAuthenticateVC - 收到芝麻认证回调的通知 - 实人认证 -- %@",notice);
    
    //认证完成后回调服务端
    [self zhimaAuthFinished];
    
    if([notice.userInfo[@"passed"] boolValue]){
        
        DMLog(@"实人认证失败");
    }else{
        DMLog(@"实人认证失败");
    }
}

#pragma mark - 获取芝麻认证 跳转需要的URL

-(void)getUrl{
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"business_type"] = @"22";//21:ios实人认证;22:ios生存认证


    if(self.isFromOtherQualiferList){
        param[@"other_id"] = [NSString stringWithFormat:@"%li",self.ID];//非本人
    }else{
        param[@"other_id"] = @"";//本人
    }

    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_ZHIMA_AUTH_INIT];

    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);

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
        DMLog(@"DTF----实人认证--请求失败--%@",error);
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
    param[@"serial_number"] = self.serialNumber;//生存认证流水号
    param[@"business_type"] = @"1";//生存认证
    if(self.isFromOtherQualiferList){//非本人
        param[@"other_id"] = [NSString stringWithFormat:@"%li",self.ID];
    }else{//本人
        param[@"other_id"] = @"";
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_ZHIMA_AUTH_RESULT];
    DMLog(@"param--%@",param);
    DMLog(@"url--%@",url);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"实人认证完成后的回调服务端--返回结果---%@",dictData);
        
        if([dictData[@"resultCode"] integerValue] == 200){
            DMLog(@"回调服务端查询--实人认证成功");
            DTFQualificationSuccessVC *vc = [[DTFQualificationSuccessVC alloc]init];
            [self.navigationController pushViewController:vc animated:YES];
            
        }else{
            
            DMLog(@"服务端返回的失败原因--%@",dictData[@"message"]);
            DTFQualificationFailVC *vc = [[DTFQualificationFailVC alloc]init];
            vc.failedReason = dictData[@"message"];
            vc.warnTips = dictData[@"data"][@"WARN_TIPS"];
            [self.navigationController pushViewController:vc animated:YES];
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
