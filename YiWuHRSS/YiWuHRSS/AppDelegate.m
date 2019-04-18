//
//  AppDelegate.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/11.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "AppDelegate.h"
#import "HttpHelper.h"
#import "DDLoginVC.h"
#import "LoginVC.h"
#import "ModifyCardView.h"
#import "LossAlertView.h"
#import "RzwtgView.h"
#import "LxModifyHXTVC.h"
#import "LxModifySMTVC.h"
#import <Bugly/Bugly.h>
#import <UMSocialCore/UMSocialCore.h>
#import "NoticeDetailVC.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "Device.h"
#import "MsgBean.h"
#import "ContextDetailVC.h"
#import "DTFPrivateMsgVC.h"
#import "JPUSHService.h"
#import "NSString+category.h"
#import "YKFPay.h"
#import "NSString+category.h"
#import <ZjEsscSDK/ZjEsscSDK.h>


#define  BUGLY_APP_ID       @"969cdfad25"
#define USHARE_APPKEY       @"58be4a5b1c5dd010fb001f99"  //



#define    CHANNEL          @"App Store"
#define   isProduction      1  // 0 (默认值)表示采用的是开发证书（真机测试），1 表示采用生产证书发布应用(发包)

#define SIZE_V_CONVERT(y)   ((y / 2226.0f) * self.window.bounds.size.height)
#define SIZE_H_CONVERT(x)   ((x / 1260.0f) * self.window.bounds.size.width)

//#define CHECK_ACCESS_TOKEN  @"user/judgeInvalid"          // 单点登录及ACCESS_TOKEN是否失效接口
#define CHECK_STATUS_URL    @"/complexServer/checkCardStatus.json"  // 卡状态查询接口
#define DOWNLOAD_RECORD_URL @"app/downLoadRecord.json"    // 用户首次打开APP采集设备信息
#define UPDATE_INSTALLATION_TIME_URL @"/app/installationTime.json"  // 用户安装APP采集安装时间
#define UPDATE_APP_URL      @"app/version.json"           // 检测版本更新
#define IGNORE_VERSION_URL  @"app/ignoreVersion.json"     // 忽略版本更新
#define APP_CHECKWHITELIST     @"app/checkWhiteList.json" // APP白名单设置
#define GET_DZSBK_PARAM   @"userServer/getUserInfo/basic.json"  //获取电子社保卡相关参数



@interface AppDelegate ()<EAIntroDelegate,JPUSHRegisterDelegate,CLLocationManagerDelegate>

@property (nonatomic,strong)  CLLocationManager      *manager;
@property (nonatomic, assign) CLLocationCoordinate2D userCoordinate;
@property (nonatomic, weak)AFNetworkReachabilityManager *afnManger;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UIViewController alloc]init];
    [self.window makeKeyAndVisible];
    [NSThread sleepForTimeInterval:3.0];//设置启动页面时间
    
    
    [EPTipsView sharedTipsView].leftButtonColor = [UIColor colorWithHex:0xFDB731];
    
    //部SDK初始化
    EPSDKConfig *config = [[EPSDKConfig alloc] init];
    config.channelNo = CHANNELNO; /** channelNo值是需要向省平台申请统一提供 */
    config.openDebug = true;  /** 环境变量  true是测试环境，false是正式环境。不传默认为false */
    config.navigationBackgroudColor = [UIColor colorWithHex:0xFDB731]; /** 设置sdk NavigationControler导航栏的的颜色值。 */
    config.navigationTextColor = [UIColor whiteColor]; /** 设置sdk NavigationControler的导航栏的的title字体颜色值。*/
    
    [EPSecurityManager setupWithConfig:config];
    
    [EPSecurityManager enableLogging:YES]; // 开启日志 YES:开启， NO:禁用
    
    
//   初始化Bugly 测试的时候就不要上传Bugly了
    [self configBugly];
    

    /* 高德地图 */
    [AMapServices sharedServices].apiKey = @"a8ad38dac6d266ff33a882ddedbd781c";
    [[AMapServices sharedServices] setEnableHTTPS:YES];
    
    
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:USHARE_APPKEY];
    
    //Required
    //notice: 3.0.0及以后版本注册可以这样写，也可以继续用之前的注册方式
    JPUSHRegisterEntity * entity = [[JPUSHRegisterEntity alloc] init];
    entity.types = JPAuthorizationOptionAlert|JPAuthorizationOptionBadge|JPAuthorizationOptionSound;
    [JPUSHService registerForRemoteNotificationConfig:entity delegate:self];
    
    // Optional
    // 获取IDFA
    // 如需使用IDFA功能请添加此代码并在初始化方法的advertisingIdentifier参数中填写对应值
    //    NSString *advertisingId = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    
    // Required
    // init Push
    // notice: 2.1.5版本的SDK新增的注册方法，改成可上报IDFA，如果没有使用IDFA直接传nil
    // 如需继续使用pushConfig.plist文件声明appKey等配置内容，请依旧使用[JPUSHService setupWithOption:launchOptions]方式初始化。
    [JPUSHService setupWithOption:launchOptions appKey:JPUSH_APPKEY
                          channel:CHANNEL
                 apsForProduction:isProduction
            advertisingIdentifier:nil];
    [JPUSHService resetBadge];//清空JPush服务器中存储的badge值
    
    //2.1.9版本新增获取registration id block接口。
    [JPUSHService registrationIDCompletionHandler:^(int resCode, NSString *registrationID) {
        if(resCode == 0){
            DMLog(@"registrationID获取成功：%@",registrationID);
            [CoreArchive setStr:registrationID key:REGISTRATION_ID];//保存极光推送ID
        }
        else{
            DMLog(@"registrationID获取失败，code：%d",resCode);
            [CoreArchive setStr:registrationID key:REGISTRATION_ID];//保存极光推送ID
        }
    }];
    
    NSDictionary *remoteDic = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
    //如果​remoteDic不为空，代表app未启动时有推送发过来
    if (remoteDic) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        [JPUSHService resetBadge];
    }
    
    [self configUSharePlatforms];
    [self confitUShareSettings];
    
    
    if ([CoreArchive boolForKey:IS_INTROVIEWREAD]) {
        [self showMainVC];
    }else{
        [self showIntroView];
    }
    
    [self startLocation];      // 开始定位
    [self UpdateApp];          // 检测版本更新
    //    [self StartTokenTimer];    // 单点登录
    [self StartCheckKStatus];  // 检查卡状态
    
    //发送设备信息
    [self sentDeviceInfo];
    //发送安装时间
    [self toUpdateInstallationTime];
    
    //极光推送--接受消息
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(networkDidReceiveMessage:) name:kJPFNetworkDidReceiveMessageNotification object:nil];
    
    
    if ([HOST_TEST isEqualToString:@"https://app.ywrl.gov.cn:8553/ywcitzencard"]) {
        // 生产环境
    }else {
        
        [self checkWhiteList]; // APP白名单设置, 请求失败时直接退出
    }
    
    if ([CoreArchive boolForKey:LOGIN_STUTAS]) {
        [self getUserInfo];
    }

    return YES;
}



#pragma mark - APP白名单设置
- (void)checkWhiteList {
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    // 1. 配置接口地址和参数
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"]; // 设备类型 安卓:1 ios:2
    [param setValue:appCurVersion forKey:@"app_version"]; // app版本
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,APP_CHECKWHITELIST];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"APP白名单设置resultDict: %@", resultDict);

        NSString *data = resultDict[@"data"];
        
        [CoreArchive setStr:data key:ENVIROMENT_DATA];
        
    } failure:^(NSError *error) {
        DMLog(@"APP白名单设置error: %@",error);
    }];
}

#pragma mark - 极光推送-接受消息
/**
 极光推送--接受消息
 
 @param notification 消息
 */
- (void)networkDidReceiveMessage:(NSNotification *)notification {
    NSDictionary * userInfo = [notification userInfo];
    
    DMLog(@"收到极光下线消息notification = %@",notification);
    
    //收到下线的消息
    if([userInfo[@"content"] isEqualToString:@"下线"] && [userInfo[@"content_type"] integerValue] == 1){
        
        if([CoreArchive boolForKey:LOGIN_STUTAS]) {
            
            if (![userInfo[@"title"] isEqualToString:[CoreArchive strForKey:JPUSH_ALIAS]]) {
                
                DMLog(@"极光收到的别名和保存的别名不一样，发出下线通知");
                [[NSNotificationCenter defaultCenter] postNotificationName:@"token_invalid" object:nil userInfo:userInfo];
            }
        }
    }
}

#pragma mark - 配置Bugly
- (void)configBugly {
    //初始化 Bugly 异常上报
    [Bugly startWithAppId:BUGLY_APP_ID];
}

#pragma mark - 配置友盟分享
- (void)configUSharePlatforms
{
    /* 开启友盟分享调试log方法 */
//    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx0ed0a3b86709a625" appSecret:@"98c6dc0e97289cd68d3ae563b732f068" redirectURL:@"http://rsj.yw.gov.cn"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID 100424468
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1101694571"/*设置QQ平台的appID*/  appSecret:nil redirectURL:@"http://mobile.umeng.com/social"];
}

#pragma mark - 配置友盟是否强制验证https
- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    [UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

#pragma mark - 友盟分享配置--芝麻认证回调
// 支持所有iOS系统
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DMLog(@"271行");
    DMLog(@"第三方回调---:%@", url);
    
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
        
        //处理支付宝支付的回调
        if ([url.host isEqualToString:@"safepay"]){// 支付跳转支付宝钱包进行支付，处理支付结果
            NSLog(@"支付宝支付回调-@");
            [self alipayHandleWithUrl:url];
            return YES;
        }
        
        //处理微信支付的回调
        if ([url.host isEqualToString:@"pay"]){//微信支付，处理支付结果
            NSLog(@"微信支付回调-@");
            [[YKFPay shareYKFPay] handleURL:url withComplations:nil];
            return YES;
        }
        
        //判断是芝麻认证回调
        NSDictionary * backDict = [self getZimaBackDict:url];
        
        if ([url.absoluteString containsString:@"zhimaCertificateReal"]) {//跳转回---实人认证
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaCertificateReal" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调实人认证-296");
        }else if ([url.absoluteString containsString:@"zhimaQualifications"]){//跳转回---资格认证
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaQualifications" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调资格认证-299");
        }else if ([url.absoluteString containsString:@"zhimaLogin"]){//跳转回---登录
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaLogin" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调登录-302");
        }else if ([url.absoluteString containsString:@"zhimaRegist"]){//跳转回---注册
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaRegist" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调注册-305");
        }
        return YES;
    }
    return result;
}

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
    
    DMLog(@"315行");
    DMLog(@"第三方回调的地址--%@",url);
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url];
    if (!result) {
        // 其他如支付等SDK的回调
        
        DMLog(@"第三方回调---:%@", url);
        //处理支付宝支付的回调
        if ([url.host isEqualToString:@"safepay"]){// 支付跳转支付宝钱包进行支付，处理支付结果
            NSLog(@"支付宝支付回调-@");
            [self alipayHandleWithUrl:url];
            return YES;
        }
        
        if ([url.host isEqualToString:@"pay"]){//微信支付，处理支付结果
            
            [[YKFPay shareYKFPay] handleURL:url withComplations:nil];
            return YES;
        }
        //判断是芝麻认证回调
        NSDictionary * backDict = [self getZimaBackDict:url];
        
        if ([url.absoluteString containsString:@"zhimaCertificateReal"]) {//跳转回---实人认证
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaCertificateReal" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调实人认证-338");
        }else if ([url.absoluteString containsString:@"zhimaQualifications"]){//跳转回---资格认证
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaQualifications" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调资格认证-341");
        }else if ([url.absoluteString containsString:@"zhimaLogin"]){//跳转回---登录
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaLogin" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调登录-344");
        }else if ([url.absoluteString containsString:@"zhimaRegist"]){//跳转回---注册
            [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaRegist" object:@"1" userInfo:backDict];
            DMLog(@"从支付宝芝麻认证回调注册-347");
        }
        return YES;
    }
    return result;
}

//iOS9 之后
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary*)options {
    DMLog(@"iOS9系统以后：356行");

    //处理支付宝支付的回调
    if ([url.host isEqualToString:@"safepay"]){// 支付跳转支付宝钱包进行支付，处理支付结果
        NSLog(@"支付宝支付回调-@");
        [self alipayHandleWithUrl:url];
        return YES;
    }
    
    if ([url.host isEqualToString:@"pay"]){//微信支付，处理支付结果
        
        [[YKFPay shareYKFPay] handleURL:url withComplations:options];
        return YES;
    }
    //判断是芝麻认证回调
    NSDictionary * backDict = [self getZimaBackDict:url];
    
    if ([url.absoluteString containsString:@"zhimaCertificateReal"]) {//跳转回---实人认证
        [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaCertificateReal" object:@"1" userInfo:backDict];
        DMLog(@"从支付宝芝麻认证回调实人认证-374-发送通知");
    }else if ([url.absoluteString containsString:@"zhimaQualifications"]){//跳转回---资格认证
        [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaQualifications" object:@"1" userInfo:backDict];
        DMLog(@"从支付宝芝麻认证回调资格认证-377-发送通知");
    }else if ([url.absoluteString containsString:@"zhimaLogin"]){//跳转回---登录
        [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaLogin" object:@"1" userInfo:backDict];
        DMLog(@"从支付宝芝麻认证回调登录-380-发送通知");
    }else if ([url.absoluteString containsString:@"zhimaRegist"]){//跳转回---注册
        [[NSNotificationCenter defaultCenter] postNotificationName:@"zhimaRegist" object:@"1" userInfo:backDict];
        DMLog(@"从支付宝芝麻认证回调注册-383-发送通知");
    }
    return YES;
}


#pragma mark - AppDelegate
- (void)applicationWillResignActive:(UIApplication *)application {
    
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:0];
    [JPUSHService resetBadge];
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    
}

- (void)applicationWillTerminate:(UIApplication *)application {
    
}

#pragma mark - 引导页
- (void)showIntroView{
    const CGFloat pageCtrlHeight = 20.0f;
    const CGFloat descY = 508.0f + 84.0f + 60.0f + pageCtrlHeight;
    const CGFloat descConvertY = SIZE_V_CONVERT(descY);
    
    EAIntroPage *page1 = [EAIntroPage page];
    page1.titleColor = [UIColor blackColor];
    page1.titleFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(90.0f)];
    page1.descColor = [UIColor colorWithHex:0x0b80d0];
    page1.descFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(60.0f)];
    page1.descPositionY = descConvertY;
    page1.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_yingdao1"]];
    page1.titleIconView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);   // 783.0f  992.0f
    
    EAIntroPage *page2 = [EAIntroPage page];
    page2.titleColor = [UIColor blackColor];
    page2.titleFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(90.0f)];
    page2.descColor = [UIColor colorWithHex:0x0b80d0];
    page2.descFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(60.0f)];
    page2.descPositionY = descConvertY;
    page2.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_yingdao2"]];
    page2.titleIconView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    EAIntroPage *page3 = [EAIntroPage page];
    page3.titleColor = [UIColor blackColor];
    page3.titleFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(90.0f)];
    page3.descColor = [UIColor colorWithHex:0x0b80d0];
    page3.descFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(60.0f)];
    page3.descPositionY = descConvertY;
    page3.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_yingdao3"]];
    page3.titleIconView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    EAIntroPage *page4 = [EAIntroPage page];
    page4.titleColor = [UIColor blackColor];
    page4.titleFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(90.0f)];
    page4.descColor = [UIColor colorWithHex:0x0b80d0];
    page4.descFont = [UIFont systemFontOfSize:SIZE_V_CONVERT(60.0f)];
    page4.descPositionY = descConvertY;
    page4.titleIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_yingdao4"]];
    page4.titleIconView.frame = CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT);

    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.window.bounds andPages:@[page1,page2,page3,page4]];
    
    CGFloat pageCtrlY = SIZE_V_CONVERT(84.0f);
    intro.pageControlY = pageCtrlY;
    intro.pageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0x0b80d0];
    intro.pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xd8d8d8];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setFrame:CGRectMake(0, 0, SIZE_H_CONVERT(400.0f), SIZE_V_CONVERT(140.0f))];
    btn.layer.cornerRadius = 5.0;
    btn.layer.borderWidth =  1;
    btn.layer.borderColor = [[UIColor colorWithHex:0xfdb731] CGColor];
    [btn setTitle:@"立即体验" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
    intro.skipButton = btn;
    
    CGFloat skipBtnY = pageCtrlY + pageCtrlHeight + SIZE_V_CONVERT(67.0f) + SIZE_V_CONVERT(104.0f);
    intro.skipButtonY = skipBtnY;
    intro.showSkipButtonOnlyOnLastPage = YES;
    intro.skipButtonAlignment = EAViewAlignmentCenter;
    
    [intro setDelegate:self];
    [intro showInView:self.window.rootViewController.view animateDuration:0.3];
}

#pragma mark - 进入首页
- (void)showMainVC{
    [CoreArchive setBool:YES key:IS_INTROVIEWREAD];
    self.window.rootViewController = [[MainTabBarController alloc]init];
    [self.window makeKeyAndVisible];
}

#pragma mark - EAIntroDelegate
- (void)introDidFinish:(EAIntroView *)introView{
    [self showMainVC];
}

#pragma mark - 发送设备信息给服务器
/** 发送设备信息 */
-(void)sentDeviceInfo{
    
    //当前版本
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_CurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    //之前保存的版本
    NSString * app_version = [CoreArchive strForKey:@"app_version"];
    
    
    //如果之前保存的版本和现在的版本一致，直接返回
    if([app_CurVersion isEqualToString:app_version]){
    
        return ;
    }
    
    //如果之前保存的版本和现在的版本不一致，直接发送设备信息,设置版本为现在的版本
    [CoreArchive setStr:app_CurVersion key:@"app_version"];
    [self downLoadRecord];
}

#pragma mark - 用户首次打开APP采集设备信息
-(void)downLoadRecord{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    // 当前应用软件版本 比如：1.0.1
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    
    //地方型号 （国际化区域名称）  手机品牌 iphone
    NSString* localPhoneModel = [[UIDevice currentDevice] localizedModel];
    
    // 手机具体型号 6P 7 5s
    NSString *phoneModel = [Device deviceVersion];
    
    //手机系统版本 10.2.1
    NSString* phoneVersion = [[UIDevice currentDevice] systemVersion];
    
    NSString *identifierNumber = [Util getuuid];
    
    // 极光id
    NSString *registrationID = [CoreArchive strForKey:REGISTRATION_ID];
    
    // 1. 配置接口地址和参数
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"]; // 设备类型 安卓:1 ios:2
    [param setValue:appCurVersion forKey:@"app_version"]; // app版本
    [param setValue:localPhoneModel forKey:@"brand"]; // 手机品牌
    [param setValue:registrationID forKey:@"registration_id"]; // 极光id
    [param setValue:phoneModel forKey:@"type"]; // 手机型号
    [param setValue:phoneVersion forKey:@"version"]; // 手机版本号
    [param setValue:identifierNumber forKey:@"iemid"]; // 手机唯一标识码
//    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,DOWNLOAD_RECORD_URL];
//    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}


/**
 更新时间
 */
-(void)toUpdateInstallationTime{
    

    if([CoreArchive strForKey:@"isUpdateTimeSuccessed"]){//如果之前更新时间成功
    
        
        return ;
    
    }else{//如果之前更新时间失败
    
        [self updateInstallationTime];
    }
}


/** 用户安装APP采集安装时间 */
-(void)updateInstallationTime{
    
    NSString * urlString = [NSString stringWithFormat:@"%@%@",HOST_TEST,UPDATE_INSTALLATION_TIME_URL];
    NSMutableDictionary * params = [NSMutableDictionary dictionary];
    params[@"device_type"] = @"2";
    params[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    params[@"imei"]= [Util getuuid];
    
    NSLog(@"采集时间--%@",urlString);
    NSLog(@"采集时间--%@",params);
    
    [HttpHelper post:urlString params:params success:^(id responseObj) {
        
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"resultDict=%@",resultDict);
        if([resultDict[@"resultCode"] integerValue] == 200){
            
            [CoreArchive setBool:YES key:@"isUpdateTimeSuccessed"];
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}


#pragma mark - 检测版本更新
-(void)UpdateApp{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
//    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UPDATE_APP_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"检测版本更新 %@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES || iStatus == 200)
                {
                    NSDictionary *dict = [resultDict objectForKey:@"data"];
                    NSString *update = [dict objectForKey:@"isUpdate"];
                    NSString *description = [dict objectForKey:@"description"];
                    NSString *url = [dict objectForKey:@"abk_address"];
                    int value = update.intValue;
                    if (value==1) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"检查到有新的版本" message:description preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIView *subView1 = alert.view.subviews[0];
                        UIView *subView2 = subView1.subviews[0];
                        UIView *subView3 = subView2.subviews[0];
                        UIView *subView4 = subView3.subviews[0];
                        UIView *subView5 = subView4.subviews[0];
                        
                        UILabel *message = subView5.subviews[1];
                        message.textAlignment = NSTextAlignmentLeft;
                        
                        [alert addAction:[UIAlertAction actionWithTitle:@"忽略此版本" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            DMLog(@"点击了忽略此版本按钮");
                            NSString *stay_version = [dict objectForKey:@"version"];
                            [self IgnoreVersion:stay_version];
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            DMLog(@"点击了立即更新按钮");
                            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
                        }]];
                        //弹出提示框；
                        [self.window.rootViewController presentViewController:alert animated:true completion:nil];
                    }else if (value==2) {
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"检查到有新的版本" message:description preferredStyle:UIAlertControllerStyleAlert];
                        
                        UIView *subView1 = alert.view.subviews[0];
                        UIView *subView2 = subView1.subviews[0];
                        UIView *subView3 = subView2.subviews[0];
                        UIView *subView4 = subView3.subviews[0];
                        UIView *subView5 = subView4.subviews[0];
                        
                        UILabel *message = subView5.subviews[1];
                        message.textAlignment = NSTextAlignmentLeft;
                        
                        [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            DMLog(@"点击了取消按钮");
                            exit(0);
                        }]];
                        [alert addAction:[UIAlertAction actionWithTitle:@"立即更新" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            DMLog(@"点击了立即更新按钮");
                            [[UIApplication sharedApplication] openURL: [NSURL URLWithString:url]];
                            exit(0);
                        }]];
                        //弹出提示框；
                        [self.window.rootViewController presentViewController:alert animated:true completion:nil];
                    }else{
                       DMLog(@"没有检测到新版本。。。。。");
                    }
                }else{
                    DMLog(@"服务暂不可用，请稍后重试");
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

#pragma mark - 忽略版本更新接口
-(void)IgnoreVersion:(NSString*)stay_version{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:stay_version forKey:@"stay_version"];
    NSString *identifierNumber = [Util getuuid];
    [param setValue:identifierNumber forKey:@"imei"];
//    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,IGNORE_VERSION_URL];
//    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"忽略版本更新接口 %@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            @try {
                NSString *temp = [resultDict objectForKey:@"resultCode"];
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                int iStatus = temp.intValue;
                if (resultTag.boolValue==YES && iStatus == 200)
                {
                    DMLog(@"接口调用成功！");
                }else{
                    DMLog(@"服务暂不可用，请稍后重试");
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

#pragma mark - 创建定时器 检测token是否有效
//-(void)StartTokenTimer{
//    // 创建定时器
//    DMLog(@"\n检测TOKEN的定时器启动\n");
//    self.Tokentimer = [NSTimer timerWithTimeInterval:5 target:self selector:@selector(ValidToken) userInfo:nil repeats:YES];
//
//    // 将定时器添加到运行循环
//    [[NSRunLoop currentRunLoop] addTimer:self.Tokentimer forMode:NSRunLoopCommonModes];
//    // 启动定时器
//    [self.Tokentimer setFireDate:[NSDate distantPast]];
//    self.TokentimerRunning = YES;
//}

//#pragma mark - 验证token是否有效的方法
//-(void)ValidToken{
//    if([CoreArchive boolForKey:LOGIN_STUTAS]){ //登录
//        DMLog(@"正在检测Token是否有效。。。。。");
//        [self CheckTokenUsedAccessToken:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
//    }
//}

//验证token是否有效的方法
//- (void)CheckTokenUsedAccessToken:(NSString *)access_token{
//    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
//    [param setValue:access_token forKey:@"access_token"];
////    DMLog(@"param=%@",param);
//
//    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,CHECK_ACCESS_TOKEN];
////    DMLog(@"url=%@",url);
//
//    [HttpHelper post:url params:param success:^(id responseObj) {
//        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
////        DMLog(@"===============%@",resultDict);
//        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
//            DMLog(@"服务暂不可用，请稍后重试");
//        }else{
//            @try {
//                NSString *temp = [resultDict objectForKey:@"resultCode"];
//                NSNumber *resultTag = [resultDict objectForKey:@"success"];
//                int iStatus = temp.intValue;
//                if (resultTag.boolValue==YES && iStatus == 1000)
//                {
////                    DMLog(@"Token没有失效。。。。。");
//                }else{
//                    if (iStatus==5001) {
//                        [CoreArchive setBool:NO key:LOGIN_STUTAS];
//                        //删除极光推送的别名
//                        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//
//                        } seq:0];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Exit" object:nil userInfo:nil];
//                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"你的账号已在其他设备登录，如非本人操作，登录密码可能已泄露，请修改密码，建议密码与你的其他网站密码不同" preferredStyle:UIAlertControllerStyleAlert];
//                        [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                            DMLog(@"点击了立即登录按钮");
//                            UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//                            DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//                            UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//                            [self.window.rootViewController presentViewController:listnav animated:YES completion:nil];
//                        }]];
//
//                        //弹出提示框；
//                        [self.window.rootViewController presentViewController:alert animated:true completion:nil];
//                    }else if (iStatus==5002) {
//                        [CoreArchive setBool:NO key:LOGIN_STUTAS];
//                        //删除极光推送的别名
//                        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
//
//                        } seq:0];
//                        [[NSNotificationCenter defaultCenter] postNotificationName:@"Exit" object:nil userInfo:nil];
//                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:@"您的登录信息已失效，请重新登录" preferredStyle:UIAlertControllerStyleAlert];
//                        [alert addAction:[UIAlertAction actionWithTitle:@"立即登录" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//                            DMLog(@"点击了立即登录按钮");
//                            UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//                            DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//                            UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//                            [self.window.rootViewController presentViewController:listnav animated:YES completion:nil];
//                        }]];
//
//                        //弹出提示框；
//                        [self.window.rootViewController presentViewController:alert animated:true completion:nil];
//                    }
//                }
//            } @catch (NSException *exception) {
//                DMLog(@"%@",exception);
//            }
//        }
//    } failure:^(NSError *error) {
//        DMLog(@"%@",error);
//    }];
//}

#pragma mark - 启动定时器 检查卡状态
-(void)StartCheckKStatus{

    // 创建定时器 1800
    DMLog(@"\n检测TOKEN的定时器启动\n");
    self.Statustimer = [NSTimer timerWithTimeInterval:1800 target:self selector:@selector(CheckStatus) userInfo:nil repeats:YES];
    
    // 将定时器添加到运行循环
    [[NSRunLoop currentRunLoop] addTimer:self.Statustimer forMode:NSRunLoopCommonModes];
    // 启动定时器
    [self.Statustimer setFireDate:[NSDate distantPast]];
    self.StatustimerRunning = YES;
    
}

#pragma mark - 检查卡状态接口
-(void)CheckStatus{
    if([CoreArchive boolForKey:LOGIN_STUTAS]){  //登录
        DMLog(@"正在检测卡状态是否有效。。。。。");
        //义乌2.3版本注册体系改造-删除卡状态相关问题
        //[self CheckStatusUsedAccessToken:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
    }
}

-(void)CheckStatusUsedAccessToken:(NSString *)access_token{
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
//    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,CHECK_STATUS_URL];
//    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"卡状态查询接口: %@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            @try {
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                if (resultTag.boolValue==YES)
                {
                    NSArray *arr = [resultDict objectForKey:@"data"];
                    NSDictionary *dict = arr[0];
                    NSString *kzt = [dict objectForKey:@"cardStatus"];
                    int cardStatus = [kzt intValue];
                    if (cardStatus==9) {    // 注销 9
                        [CoreArchive setBool:NO key:LOGIN_STUTAS];
                        //删除极光推送的别名
                        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                            
                        } seq:0];
                        NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
                        NSString *account = [Util HeadStr:bk WithNum:0];
                        NSString *yhkh = [account substringFromIndex:account.length-4];
                        NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
                        NSString *msg = [NSString stringWithFormat:@"   您绑定的市民卡（尾号%@）当前为失效状态，请补办新卡并修改市民卡信息后可继续登录。",yhkh];
                        [self showModifyCardView:msg andCard_Type:type andAccess_Token:access_token];
                    }else if (cardStatus==2||cardStatus==3){   // 挂失、预挂失
                        [CoreArchive setBool:NO key:LOGIN_STUTAS];
                        //删除极光推送的别名
                        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
                            
                        } seq:0];
                        ModifyCardView *vv = [ModifyCardView alterViewWithcontent:@"    您绑定的市民卡已预挂失/挂失，市民卡状态正常后方可登录操作！" sure:@"我知道了" sureBtClcik:^{
                            // 点击我知道了按钮
                            DMLog(@"我知道了！");
                        }];
                        //弹出提示框；
                        [self.window.rootViewController.view addSubview:vv];
                    }else{      // 其他状态
                        DMLog(@"不用弹窗");
                    }
                }else{
                    DMLog(@"接口调用出现错误！");
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

#pragma mark - 卡注销状态弹窗提示
-(void)showModifyCardView:(NSString *)msg andCard_Type:(NSString*)card_type andAccess_Token:(NSString*)access_token{
    
    LossAlertView *lll=[LossAlertView alterViewWithContent:msg cancel:@"取消" sure:@"修改" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"修改");
        [CoreArchive setBool:NO key:LOGIN_STUTAS];
        //删除极光推送的别名
        [JPUSHService deleteAlias:^(NSInteger iResCode, NSString *iAlias, NSInteger seq) {
            
        } seq:0];
            if ([card_type isEqualToString:@"1"]) {
                UIStoryboard *hb = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
                LxModifySMTVC *VC = [hb instantiateViewControllerWithIdentifier:@"LxModifySMTVC"];
                [VC setValue:access_token forKey:@"access_token"];
                UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
                [self.window.rootViewController presentViewController:listnav animated:YES completion:nil];
            }else{
                UIStoryboard *hb = [UIStoryboard storyboardWithName:@"HomePage" bundle:nil];
                LxModifyHXTVC *VC = [hb instantiateViewControllerWithIdentifier:@"LxModifyHXTVC"];
                [VC setValue:access_token forKey:@"access_token"];
                UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
                [self.window.rootViewController presentViewController:listnav animated:YES completion:nil];
            }
    }];
    [self.window.rootViewController.view addSubview:lll];
}


#pragma mark - 注册APNs成功并上报DeviceToken
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    /// Required - 注册 DeviceToken
    DMLog(@"极光推送 Device Token:%@",deviceToken);
    [JPUSHService registerDeviceToken:deviceToken];
}

#pragma mark - 实现注册APNs失败接口（可选
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    //Optional
    DMLog(@"did Fail To Register For Remote Notifications With Error: %@", error);
}

#pragma mark - 添加处理APNs通知回调方法
// iOS 10 Support
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(NSInteger))completionHandler {
    NSDictionary * userInfo = notification.request.content.userInfo;
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"JPUSH" object:nil userInfo:nil];
    }
    completionHandler(UNNotificationPresentationOptionBadge|UNNotificationPresentationOptionSound|UNNotificationPresentationOptionAlert); // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
}

// iOS 10 Support
// 推送的用户的点击事件
- (void)jpushNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    NSDictionary * userInfo = response.notification.request.content.userInfo;
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        [JPUSHService handleRemoteNotification:userInfo];
        
        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
        [center postNotificationName:@"JPUSH" object:nil userInfo:nil];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
    [self NotifyGoNoticeDetail:userInfo];
    completionHandler();  // 系统要求执行这个方法
}

//非IOS 10 的系统的用户的点击事件
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    
    // Required, iOS 7 Support
    [JPUSHService handleRemoteNotification:userInfo];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    [JPUSHService resetBadge];
    [self NotifyGoNoticeDetail:userInfo];
    completionHandler(UIBackgroundFetchResultNewData);
}

// 在 iOS8 系统中，还需要添加这个方法。通过新的 API 注册推送服务
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings
{
    [application registerForRemoteNotifications];
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    // Required,For systems with less than or equal to iOS6
    [JPUSHService handleRemoteNotification:userInfo];
}


#pragma mark - 推送跳转新闻详情界面
-(void)NotifyGoNoticeDetail:(NSDictionary *)UserInfo{
    
    DMLog(@"userinfo=%@",UserInfo);
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
//        UIStoryboard * UB = [UIStoryboard storyboardWithName:@"LoginAndRegist" bundle:nil];
//        DDLoginVC * VC = [UB instantiateViewControllerWithIdentifier:@"DDLoginVC"];
//        UINavigationController *listnav = [[UINavigationController alloc]initWithRootViewController:VC];
//        [self.window.rootViewController presentViewController:listnav animated:YES completion:nil];
        
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self.window.rootViewController presentViewController:navVC animated:YES completion:nil];
        
    }else{
        NSString *content = [UserInfo objectForKey:@"content"];
        NSString *type = [UserInfo objectForKey:@"type"];
        NSString *url = [UserInfo objectForKey:@"url"];
        NSString *sendTime = [UserInfo objectForKey:@"sendTime"];
        NSString *msgTitle = [UserInfo objectForKey:@"msgTitle"];
        NSString *msgid = [UserInfo objectForKey:@"id"];
        if ([type isEqualToString:@"1"]) {    // 跳转H5链接
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
            NoticeDetailVC *VC = [SB instantiateViewControllerWithIdentifier:@"NoticeDetailVC"];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
            [VC setValue:url forKey:@"xqurl"];
            [VC setValue:msgid forKey:@"msgid"];
            VC.hidesBottomBarWhenPushed = YES;
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }else if ([type isEqualToString:@"2"]) {     // 纯文本内容显示
            MsgBean *msgbean = [[MsgBean alloc] init];
            msgbean.url = url;
            msgbean.content = content;
            msgbean.type = type;
            msgbean.sendTime = sendTime;
            msgbean.msgTitle = msgTitle;
            msgbean.msgId = msgid;
            UIStoryboard *MB = [UIStoryboard storyboardWithName:@"Mine" bundle: nil];
            ContextDetailVC *VC = [MB instantiateViewControllerWithIdentifier:@"ContextDetailVC"];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
            [VC setValue:msgbean forKey:@"bean"];
            [VC setValue:@"tuisong" forKey:@"LX"];
            VC.hidesBottomBarWhenPushed = YES;
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }else if ([type isEqualToString:@"3"]) {   // 我的私信
            DTFPrivateMsgVC *VC = [[DTFPrivateMsgVC alloc] init];
            UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:VC];
            [VC setValue:@"推送" forKey:@"type"];
            VC.hidesBottomBarWhenPushed = YES;
            [self.window.rootViewController presentViewController:nav animated:YES completion:nil];
        }
    }
}

#pragma mark - 定位
-(void)startLocation
{
    // 实例化对象
    _manager = [[CLLocationManager alloc] init];
    
    _manager.delegate = self;
    
    // 请求授权，记得修改的infoplist，NSLocationAlwaysUsageDescription（描述）
    [_manager requestWhenInUseAuthorization];
    
    //获取当前位置
    CLLocation *location = _manager.location;
    //获取坐标
    CLLocationCoordinate2D corrdinate = location.coordinate;
    
    //打印地址
    DMLog(@"latitude = %f longtude = %f",corrdinate.latitude,corrdinate.longitude);
    NSString *lat = [NSString stringWithFormat:@"%3.5f",corrdinate.latitude];   // 纬度
    NSString *lon = [NSString stringWithFormat:@"%3.5f",corrdinate.longitude];  // 经度
    [CoreArchive setStr:lat key:CURRENT_LON];
    [CoreArchive setStr:lon key:CURRENT_LAT];
    DMLog(@"定位：%@",lat);
    DMLog(@"定位：%@",lon);
}

#pragma mark - 代理方法，当授权改变时调用
- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    // 获取授权后，通过
    if (status == kCLAuthorizationStatusAuthorizedWhenInUse) {
        //开始定位(具体位置要通过代理获得)
        [_manager startUpdatingLocation];
        
        //设置精确度
        _manager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
        
        //设置过滤距离
        _manager.distanceFilter = 1000;
        
        //开始定位方向
        [_manager startUpdatingHeading];
    }
}

#pragma mark - 定位代理
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    //获取当前位置
    CLLocation *location = manager.location;
    //获取坐标
    CLLocationCoordinate2D corrdinate = location.coordinate;
    
    //打印地址
    DMLog(@"latitude = %f longtude = %f",corrdinate.latitude,corrdinate.longitude);
    NSString *lat = [NSString stringWithFormat:@"%3.5f",corrdinate.latitude];   // 纬度
    NSString *lon = [NSString stringWithFormat:@"%3.5f",corrdinate.longitude];  // 经度
    [CoreArchive setStr:lat key:CURRENT_LON];
    [CoreArchive setStr:lon key:CURRENT_LAT];
    DMLog(@"定位：%@",lat);
    DMLog(@"定位：%@",lon);
    // 地址的编码通过经纬度得到具体的地址
    CLGeocoder *gecoder = [[CLGeocoder alloc] init];
    
    [gecoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        
        CLPlacemark *placemark = [placemarks firstObject];
        //打印地址
        DMLog(@"定位的地址:%@",placemark.name);
    }];
    
    //停止定位
    [_manager stopUpdatingLocation];
    
}

-(NSDictionary *)getZimaBackDict:(NSURL *)url{
    
    
    //芝麻认证回调的URL转换为字符串
    NSString * absoluteString = [url absoluteString];

    //对字符串进行URL Decode
    NSString * decodeString = [absoluteString URLDecodedString:absoluteString];
    
    //获取到？后面的参数
    NSArray * arrayString = [decodeString componentsSeparatedByString:@"?"];

    //获取&前面的字符串
    NSArray * arrayString2 = [[arrayString lastObject] componentsSeparatedByString:@"&"];
    
    //获取biz_content=后的字符串
    NSArray * arrayString3 = [[arrayString2 firstObject] componentsSeparatedByString:@"biz_content="];
    
    //将获取的biz_content中的数据转换为字典
    NSDictionary * dict = [NSString db_dictionaryWithJsonString:[arrayString3 lastObject]];
    
    //DMLog(@"芝麻认证回调 **** %@ **** %@ **** %@",dict[@"biz_no"],dict[@"failed_reason"],dict[@"passed"]);
    
    if([dict[@"passed"] boolValue]){
        //DMLog(@"芝麻认证--成功");
    }else{
        //DMLog(@"芝麻认证--失败");
    }
    return dict;
}




#pragma mark - 获取电子社保卡所需相关参数
/** 获取电子社保卡所需相关参数 */
-(void)getUserInfo{
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,GET_DZSBK_PARAM];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        //对AES加密结果进行解密
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSString * dataBack = dictData[@"dataBack"];
        NSString * decodeString = aesDecryptString(dataBack, AESEncryptKey);
        dictData = [NSDictionary ep_dictionaryWithJsonString:decodeString];
        DMLog(@"获取电子社保卡所需相关参数===============%@",dictData);
        NSDictionary * dataDic = dictData[@"data"];
        NSString * resultCode = dictData[@"resultCode"];
        if([resultCode integerValue] ==200){
            

            [CoreArchive setStr:dataDic[@"bank"] key:DZSBK_BANK_NAME];          //电子社保卡-银行名称
            [CoreArchive setStr:dataDic[@"bankCode"] key:DZSBK_BANK_CODE];          //电子社保卡-银行编码
            [CoreArchive setStr:dataDic[@"bankNo"] key:DZSBK_BANK_CARD];          //电子社保卡-银行卡号
            [CoreArchive setStr:dataDic[@"cardNum"] key:DZSBK_INSURE_CARD_NUM];    //电子社保卡-社保卡号
            [CoreArchive setStr:dataDic[@"cardType"] key:DZSBK_INSURE_CARD_TYPE];   //电子社保卡-社保卡类型
            [CoreArchive setStr:dataDic[@"idCard"] key:DZSBK_ID_CARD];            //电子社保卡-身份证号
            [CoreArchive setStr:dataDic[@"name"] key:DZSBK_USER_NAME];          //电子社保卡-用户姓名
            [CoreArchive setStr:dataDic[@"sex"] key:DZSBK_USER_SEX];           //电子社保卡-用户性别
            

            DMLog(@"电子社保卡-银行名称-%@",[CoreArchive strForKey:DZSBK_BANK_NAME]);
            DMLog(@"电子社保卡-银行编码-%@",[CoreArchive strForKey:DZSBK_BANK_CODE]);
            DMLog(@"电子社保卡-银行卡号-%@",[CoreArchive strForKey:DZSBK_BANK_CARD]);
            DMLog(@"电子社保卡-社保卡号-%@",[CoreArchive strForKey:DZSBK_INSURE_CARD_NUM]);
            DMLog(@"电子社保卡-社保卡类型-%@",[CoreArchive strForKey:DZSBK_INSURE_CARD_TYPE]);
            DMLog(@"电子社保卡-身份证号-%@",[CoreArchive strForKey:DZSBK_ID_CARD]);
            DMLog(@"电子社保卡-用户姓名-%@",[CoreArchive strForKey:DZSBK_USER_NAME]);
            DMLog(@"电子社保卡-用户性别-%@",[CoreArchive strForKey:DZSBK_USER_SEX]);
            
            DMLog(@"电子社保卡使用--参数--%@",param);
            
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
    
}



/**
 处理支付宝支付的回调

 @param url 回调的URL
 */
-(void)alipayHandleWithUrl:(NSURL *)url{
    
    
    
    [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
        NSLog(@"result taofei= %@",resultDic);
        NSLog(@"支付宝支付回调处理字符串-resultDic=%@",resultDic);
        
        
        NSString * resultStatus = resultDic[@"resultStatus"];
        NSString * resultString = resultDic[@"result"] ;
        NSString * reason = resultDic[@"memo"];
        NSDictionary * result = [NSString db_dictionaryWithJsonString:resultString];
        NSString * out_trade_no= result[@"alipay_trade_app_pay_response"][@"out_trade_no"];
        NSString * tradeNum = [CoreArchive strForKey:YW_ALIPAY_TRADE_NUM];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"paymentFinished" object:@"1" userInfo:result];
        DMLog(@"支付宝支付完成后的回调-发送通知");
        
        if([resultStatus isEqualToString:@"9000"]){
            
            if([out_trade_no isEqualToString:tradeNum]){//流水号一直需要发送通知
                DMLog(@"支付宝支付完成-发送通知进行处理");
            }else{////流水号不一致，交给医快付SDK进行处理
                DMLog(@"支付宝支付完成-调用医快付SDK进行处理");
                [[YKFPay shareYKFPay] handleURL:url withComplations:nil];
            }
        }else{
            NSLog(@"支付失败---");
            [CoreArchive setStr:reason key:YW_ALIPAY_FAILED_REASON];
            [[YKFPay shareYKFPay] handleURL:url withComplations:nil];
        }
        return ;
    }];
}



@end
