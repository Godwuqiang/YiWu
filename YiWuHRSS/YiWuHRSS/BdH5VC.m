//
//  BdH5VC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/25.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "BdH5VC.h"
#import <WebKit/WebKit.h>
#import "JPUSHService.h"
#import "DDLoginVC.h"
#import "HttpHelper.h"
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>
#import "ShareView.h"

#define EXIT_URL                        @"/userServer/login_out.json"        // 退出登录

@interface BdH5VC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@property (nonatomic, strong)  UIImageView      *nodata;
@property (nonatomic, strong)  UILabel          *titlb;
@property (nonatomic, strong)  UIButton         *refreshbtn;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (nonatomic, strong)WKNavigation *backNavigation;

@end

@implementation BdH5VC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    if(kIsiPhoneX){
        topframe = CGRectMake(0, 0, SCREEN_WIDTH, 45);
    }
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    [self setUpUI];
    
    self.navigationItem.title = self.tit;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加右侧按钮
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self setupNavigationBarStyle];
    
    
    

}

- (void)viewDidAppear:(BOOL)animated{
    [self afn];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
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
    //    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.navigationController setNavigationBarHidden:YES animated:NO];
            [self setUpH5];
        }else{
            [self.navigationController setNavigationBarHidden:NO animated:NO];
            [self setUpNoNetUI];
        }
    }];
}

#pragma mark - 初始化界面布局
- (void)setUpUI{

    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    //注册方法
    [self.userContentController addScriptMessageHandler:self  name:@"FinishPageByJs"];
    [self.userContentController addScriptMessageHandler:self  name:@"login"];
    [self.userContentController addScriptMessageHandler:self  name:@"updateToken"];
    [self.userContentController addScriptMessageHandler:self  name:@"refreshHtml"];
    [self.userContentController addScriptMessageHandler:self  name:@"shareNews"];   // 咨询详情分享
    
    //声明全局变量，存储webview发生返回操作时的标识符
    self.backNavigation = [_webView goBack];
    
    
    CGRect rect = [[UIScreen mainScreen] bounds];
    CGSize size = rect.size;
    CGFloat width = size.width;
    CGFloat height = size.height;
    CGRect bounds = CGRectMake(0, 20, width, height-20);
    if(kIsiPhoneX){
        bounds = CGRectMake(0, 45, width, height-45);
    }
    self.webView = [[WKWebView alloc]initWithFrame:bounds configuration:configuration];
    [self.view addSubview:self.webView];
    self.webView.hidden = NO;
    
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.nodata = [[UIImageView alloc] init];
    [self.view addSubview:self.nodata];
    [self.nodata mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.centerY.equalTo(weakSelf.view.mas_centerY).offset(-30);
        make.width.equalTo(@200);
        make.height.equalTo(@170);
    }];
    self.nodata.image = [UIImage imageNamed:@"img_noweb"];
    self.nodata.hidden = YES;
    
    self.titlb = [[UILabel alloc]init];
    [self.view addSubview:self.titlb];
    [self.titlb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nodata.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(@245);
    }];
    self.titlb.numberOfLines = 0;
    self.titlb.text = @"当前网络不可用，请检查网络设置";
    self.titlb.textAlignment = NSTextAlignmentCenter;
    self.titlb.textColor = [UIColor colorWithHex:0x999999];
    self.titlb.font = [UIFont systemFontOfSize:15];
    self.titlb.hidden = YES;
    
    self.refreshbtn = [[UIButton alloc]init];
    [self.view addSubview:self.refreshbtn];
    [self.refreshbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titlb.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(@150);
        make.height.equalTo(@45);
    }];
    [self.refreshbtn setBackgroundImage:[UIImage imageNamed:@"btn_submit"] forState:UIControlStateNormal];
    [self.refreshbtn setTitle:@"重新刷新" forState:UIControlStateNormal];
    [self.refreshbtn addTarget:self action:@selector(refresh404) forControlEvents:UIControlEventTouchUpInside];
    [self.refreshbtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.refreshbtn.titleLabel.font = [UIFont systemFontOfSize:15.0];
    self.refreshbtn.hidden = YES;
}

#pragma mark - 加载H5界面
- (void)setUpH5{
    self.webView.hidden = NO;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.bouncesZoom = NO;
    self.nodata.hidden = YES;
    self.titlb.hidden = YES;
    self.refreshbtn.hidden = YES;
    
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *URL;
    if ([self.tit isEqualToString:@"家庭账户授权"]) {
        NSString *name = [CoreArchive strForKey:LOGIN_NAME];
        URL = [NSString stringWithFormat:@"%@%@token=%@&authName=%@&version=%@",HOST,self.url,access_token,name,version];
    }else if([self.tit isEqualToString:@"交易记录"]){
        URL = [NSString stringWithFormat:@"%@%@token=%@&version=%@",HOST,self.url,access_token,version];
    }else if ([self.tit isEqualToString:@"疑难解答"]){
        URL = [NSString stringWithFormat:@"%@%@version=%@",HOST,self.url,version];
    }else if ([self.tit isEqualToString:@"通知公告"]){
        URL = [NSString stringWithFormat:@"%@%@version=%@",HOST,self.url,version];
    }else if ([self.tit isEqualToString:@"详情"]) {
        URL = self.url;
    }else if ([self.tit isEqualToString:@"充值记录"]) {
        URL = [NSString stringWithFormat:@"%@%@token=%@&version=%@&type=rechargeRecord",HOST,self.url,access_token,version];
    }else{
        URL = [NSString stringWithFormat:@"%@%@token=%@&version=%@",HOST,self.url,access_token,version];
    }
    URL = [URL stringByReplacingOccurrencesOfString:@" " withString:@""]; //字符串去空
    URL = [URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];  //转码成UTF-8  否则可能会出现错误
    NSURL *Url = [NSURL URLWithString:URL];
    DMLog(@"url=%@",URL);
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
    [self showLoadingUI];
}

#pragma mark - 显示无网界面
- (void)setUpNoNetUI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_noweb"];
    self.titlb.hidden = NO;
    self.titlb.text = @"当前网络不可用，请检查网络设置";
    self.refreshbtn.hidden = YES;
    self.HUD.hidden = YES;
}

#pragma mark - 显示404界面
-(void)setup404UI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_404"];
    self.titlb.hidden = NO;
    self.titlb.text = @"页面走丢了，请稍后重试~";
    self.refreshbtn.hidden = NO;
    self.HUD.hidden = YES;
}

#pragma mark - 刷新404界面
-(void)refresh404{
    [self afn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

#pragma mark - WKNavigationDelegate
- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error{
    self.HUD.hidden = YES;
}



/**
 解决回退不会对页面再次刷新

 @param webView webView
 @param navigation navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    
    
    
//    if ([self.backNavigation isEqual:navigation]) {
//
//        // 这次的加载是点击返回产生的，刷新
//
//        [self.webView reload];
//
//        self.backNavigation = nil;
//
//    }
    

    self.HUD.hidden = YES;
}

-(void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation
{
    NSLog(@"页面开始加载");
    
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    if (((NSHTTPURLResponse *)navigationResponse.response).statusCode == 200) {
        decisionHandler (WKNavigationResponsePolicyAllow);
        [self.navigationController setNavigationBarHidden:YES animated:NO];
    }else {
        [self.navigationController setNavigationBarHidden:NO animated:NO];
        [self setup404UI];
        decisionHandler(WKNavigationResponsePolicyCancel);
    }
}



#pragma mark - 注册H5与原生交互函数
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    DMLog(@"NSStringFromSelector: %@",NSStringFromSelector(_cmd));
    DMLog(@"message.name: %@",message.name);
    DMLog(@"message.body: %@",message.body);
    
    if([message.name isEqualToString:@"refreshHtml"]){
        NSLog(@"refreshHtml");
        [self.webView goBack];
        [self.webView evaluateJavaScript:@"window.location.reload();" completionHandler:nil];
        return ;
    }

    if ([message.name isEqualToString:@"FinishPageByJs"]) {
        [self back];
        return;
    }
    
    if ([message.name isEqualToString:@"login"]) {
        
        // 调用登录方法
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的登录信息已失效，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            DMLog(@"点击了立即登录按钮");
            [self queryExit];
//            UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//            DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//            UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//            [self presentViewController:listnav animated:YES completion:nil];
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];


            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        
        return;
    }
    
    if ([message.name isEqualToString:@"updateToken"]) {
        
//        [CoreArchive setStr:message.body key:LOGIN_ACCESS_TOKEN];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:message.body preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            DMLog(@"点击了立即登录按钮");
            [self queryExit];
//            UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//            DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//            UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//            [self presentViewController:listnav animated:YES completion:nil];
            
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];

            
            [self.navigationController popToRootViewControllerAnimated:YES];
        }]];
        
        //弹出提示框；
        [self presentViewController:alert animated:true completion:nil];
        return;
    }
    
    if ([message.name isEqualToString:@"shareNews"]) {
        
        DMLog(@"咨询详情页分享...");
        NSDictionary *body = message.body;
        NSString *img = [body valueForKey:@"img"];
        NSString *title = [body valueForKey:@"title"];
        NSString *url = [body valueForKey:@"url"];
        NSString *summary = [body valueForKey:@"summary"];
        
        [self ShareWithImg:img andTitle:title andUrl:url andSummary:summary];
        
        return;
    }
}

#pragma mark - 返回函数
-(void)back{
    dispatch_async(dispatch_get_main_queue(), ^{
        // 销毁自身
        [self.navigationController popViewControllerAnimated:NO];
    });
}

#pragma mark - 退出登录接口
-(void)queryExit {
    
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,EXIT_URL];
    DMLog(@"url=%@",url);
    
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
    
    //[CoreArchive setStr:nil key:LOGIN_APP_MOBILE];
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
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"Exit" object:nil userInfo:nil];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"退出登录：=%@",resultDict);
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

- (void)webView:(WKWebView *)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition disposition, NSURLCredential *credential))completionHandler {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        
        if ([challenge previousFailureCount] == 0) {
            
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            
            completionHandler(NSURLSessionAuthChallengeUseCredential, credential);
            
        } else {
            
            completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
            
        }
        
    } else {
        
        completionHandler(NSURLSessionAuthChallengeCancelAuthenticationChallenge, nil);
    }
}

#pragma mark - 分享功能
-(void)ShareWithImg:(NSString*)img andTitle:(NSString*)title andUrl:(NSString*)url andSummary:(NSString*)summary{
    
    
    ShareView *sv=[ShareView shareViewWithTitle:@"请选择分享平台" cancel:@"取消分享" cancelBtClcik:^{
        //取消分享按钮点击事件
        DMLog(@"取消分享");
    } WechatSessionBtClcik:^{
        //微信好友按钮点击事件
        DMLog(@"微信好友分享");
        [self ShareWithPlatformType:UMSocialPlatformType_WechatSession Img:img andTitle:title andUrl:url andsummary:summary];
    } WechatTimeLineBtClcik:^{
        //微信朋友圈按钮点击事件
        DMLog(@"微信朋友圈分享");
        [self ShareWithPlatformType:UMSocialPlatformType_WechatTimeLine Img:img andTitle:title andUrl:url andsummary:summary];
    }];
    [[UIApplication sharedApplication].keyWindow addSubview:sv];
}

#pragma mark - 友盟分享
-(void)ShareWithPlatformType:(UMSocialPlatformType)platformType Img:(NSString*)img andTitle:(NSString*)title andUrl:(NSString*)url andsummary:(NSString*)summary{
    // 根据获取的platformType确定所选平台进行下一步操作
    //创建分享消息对象
    UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
    
    //创建网页内容对象
    NSString* thumbURL =  img;
    UMShareWebpageObject *shareObject = [UMShareWebpageObject shareObjectWithTitle:title descr:summary thumImage:thumbURL];
    
    shareObject.webpageUrl = url;
    
    //分享消息对象设置分享内容对象
    messageObject.shareObject = shareObject;
    
    //调用分享接口
    [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
        if (error) {
            UMSocialLogInfo(@"************Share fail with error %@*********",error);
        }else{
            if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                UMSocialShareResponse *resp = data;
                [MBProgressHUD showError:@"分享成功"];
                //分享结果消息
                UMSocialLogInfo(@"response message is %@",resp.message);
                //第三方原始返回的数据
                UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);
                
            }else{
                UMSocialLogInfo(@"response data is %@",data);
            }
        }
    }];
}



- (void)dealloc{
    [self.userContentController removeScriptMessageHandlerForName:@"FinishPageByJs"];
    [self.userContentController removeScriptMessageHandlerForName:@"login"];
    [self.userContentController removeScriptMessageHandlerForName:@"updateToken"];
    [self.userContentController removeScriptMessageHandlerForName:@"refreshHtml"];
    [self.userContentController removeScriptMessageHandlerForName:@"shareNews"];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}


@end
