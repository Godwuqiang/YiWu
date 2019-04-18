//
//  NewsDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/15.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "NewsDetailVC.h"
#import <WebKit/WebKit.h>
#import <UMSocialCore/UMSocialCore.h>
#import <UShareUI/UShareUI.h>
#import "ShareView.h"


@interface NewsDetailVC ()<WKNavigationDelegate,WKUIDelegate,WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) WKUserContentController* userContentController;

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@property (nonatomic, strong)  UIImageView      *nodata;
@property (nonatomic, strong)  UILabel          *tit;
@property (nonatomic, strong)  UIButton         *refreshbtn;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation NewsDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,45);
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    [self setUpUI];
    
    self.navigationItem.title = @"详情";
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加右侧按钮
    
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

#pragma mark - 初始化界面UI布局
- (void)setUpUI{
    WKWebViewConfiguration * configuration = [[WKWebViewConfiguration alloc]init];
    self.userContentController =[[WKUserContentController alloc]init];
    configuration.userContentController = self.userContentController;
    
    //注册方法
    [self.userContentController addScriptMessageHandler:self  name:@"shareNews"];
    [self.userContentController addScriptMessageHandler:self  name:@"FinishPageByJs"];
    
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
    
    self.tit = [[UILabel alloc]init];
    [self.view addSubview:self.tit];
    [self.tit mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nodata.mas_bottom).offset(20);
        make.centerX.equalTo(weakSelf.view.mas_centerX);
        make.width.equalTo(@245);
        //        make.height.equalTo(@15);
    }];
    self.tit.numberOfLines = 0;
    self.tit.text = @"当前网络不可用，请检查网络设置";
    self.tit.textAlignment = NSTextAlignmentCenter;
    self.tit.textColor = [UIColor colorWithHex:0x999999];
    self.tit.font = [UIFont systemFontOfSize:15];
    self.tit.hidden = YES;
    
    self.refreshbtn = [[UIButton alloc]init];
    [self.view addSubview:self.refreshbtn];
    [self.refreshbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.tit.mas_bottom).offset(20);
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

#pragma mark - 请求资讯详情H5
- (void)setUpH5{
    self.webView.hidden = NO;
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    self.webView.scrollView.bounces = NO;
    self.webView.scrollView.bouncesZoom = NO;
    self.nodata.hidden = YES;
    self.tit.hidden = YES;
    self.refreshbtn.hidden = YES;
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *url = [NSString stringWithFormat:@"%@/h5/news_detail.html?id=%@&type=100&comefrom=1&app_version=%@",HOST,self.ID,version];
    NSURL *Url = [NSURL URLWithString:url];
    DMLog(@"url=%@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:Url];
    [self.webView loadRequest:request];
    [self showLoadingUI];
}

#pragma mark - 显示无网界面
- (void)setUpNoNetUI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_noweb"];
    self.tit.hidden = NO;
    self.tit.text = @"当前网络不可用，请检查网络设置";
    self.refreshbtn.hidden = YES;
    self.HUD.hidden = YES;
}

#pragma mark - 显示404界面
-(void)setup404UI{
    self.webView.hidden = YES;
    self.nodata.hidden = NO;
    self.nodata.image = [UIImage imageNamed:@"img_404"];
    self.tit.hidden = NO;
    self.tit.text = @"页面走丢了，请稍后重试~";
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

- (void)webView:(WKWebView *)webView didFinishNavigation:(null_unspecified WKNavigation *)navigation{
    self.HUD.hidden = YES;
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
    DMLog(@"%@",NSStringFromSelector(_cmd));
    DMLog(@"%@",message.name);
    DMLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"shareNews"]) {
        NSDictionary *body = message.body;
        NSString *img = [body valueForKey:@"img"];
        NSString *title = [body valueForKey:@"title"];
        NSString *url = [body valueForKey:@"url"];
        NSString *summary = [body valueForKey:@"summary"];
        [self ShareWithImg:img andTitle:title andUrl:url andSummary:summary];
    }
    
    if ([message.name isEqualToString:@"FinishPageByJs"]) {
        [self back];
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

#pragma mark - 分享函数
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
    
    [self.view addSubview:sv];
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

- (void)dealloc{
    [self.userContentController removeScriptMessageHandlerForName:@"shareNews"];
    [self.userContentController removeScriptMessageHandlerForName:@"FinishPageByJs"];
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}


@end
