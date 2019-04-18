//
//  SetPayPsdVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/12.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "SetPayPsdVC.h"
#import "FindPsdH5VC.h"
#import "YKFPay.h"
#import "FindZFPsdView.h"
#import "SZKAlterView.h"
#import "MineWebVC.h"
#import "HttpHelper.h"
#import "SrrzBean.h"
#import "MJExtension.h"
#import "ModifyCardView.h"
#import "RzwtgView.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"

#define SRRZ_STATUS_URL   @"/complexServer/checkSrrzStatus.json" // 实人认证状态


@interface SetPayPsdVC ()<UIGestureRecognizerDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property    BOOL   hasnet;

@end

@implementation SetPayPsdVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"支付密码设置";
    HIDE_BACK_TITLE;
    [self setModifyGuesture];
    [self setFindGuesture];
    [self afn];
    
    if(kIsiPhoneX){
        self.topConstrains.constant +=20;
    }
}

#pragma mark - 修改支付密码VIEW添加手势
-(void)setModifyGuesture{
    //添加手势
    UITapGestureRecognizer * ModifytapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ModifyPayPsd)];
    ModifytapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [ModifytapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.ModifyPayPsdView addGestureRecognizer:ModifytapGesture];
}

#pragma mark - 找回支付密码VIEW添加手势
-(void)setFindGuesture{
    UITapGestureRecognizer * FindtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(FindPayPsd)];
    FindtapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [FindtapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.FindPayPsdView addGestureRecognizer:FindtapGesture];
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
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            _hasnet = YES;
        }else{
            _hasnet = NO;
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
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
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 支付密码修改
-(void)ModifyPayPsd{
    if (_hasnet) {
        [self CheckSrrzStatusWithTag:1];  // 先检查实人认证状态，再决定跳不跳转
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
    }
}

#pragma mark - 支付密码找回
-(void)FindPayPsd{
    if (_hasnet) {
        [self CheckSrrzStatusWithTag:2];  // 先检查实人认证状态，再决定跳不跳转
    }else{
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
    }
}

#pragma mark - 实人认证状态查询接口
-(void)CheckSrrzStatusWithTag:(NSUInteger)tag{
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_STATUS_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            @try {
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                if (resultTag.boolValue==YES)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"data"];
                    //NSDictionary *dict = arrTemp[0];
                    SrrzBean *bean = [SrrzBean mj_objectWithKeyValues:arrTemp];
                    BOOL  isblack = [bean.blackFlag isEqualToString:@"1"];
                    if (isblack) {  // 社保黑名单
                        ModifyCardView *vv = [ModifyCardView alterViewWithcontent:@"    您已被拉入实人认证黑名单，不能进行实人认证！" sure:@"我知道了" sureBtClcik:^{
                            // 点击我知道了按钮
                            DMLog(@"我知道了！");
                        }];
                        //弹出提示框；
                        [self.view addSubview:vv];
                    }else{
                        if ([bean.renzhengStatus isEqualToString:@"1"]) {    // 实人认证通过
                            if (tag==1) {     // 支付密码修改
                                [self showWindow];
                            }else {           // 找回支付密码
                                if (_hasnet) {
                                    [self GoFindPayPsd];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }
                        }else if ([bean.renzhengStatus isEqualToString:@"5"]) {  // 无认证信息
                            if (_hasnet) {
                                [self showSRRZView];
                            }else{
                                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                            }
                        }else{     // 实人认证未通过
                            NSString *msg = @"   因您上传照片不符合实人认证要求，无法继续使用该功能，请重新进行实人认证。";
                            RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"重新认证" cancelBtClcik:^{
                                //取消按钮点击事件
                                DMLog(@"取消");
                            } sureBtClcik:^{
                                //重新认证点击事件
                                DMLog(@"重新认证");
                                if (_hasnet) {
                                    //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                    //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
                                    //[self.navigationController pushViewController:VC animated:YES];
                                    
                                    if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                                        
                                        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                                        DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                                        VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                                        VC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                        
                                    }else{//实人认证-和谐卡-信息核对
                                        
                                        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                                        DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                                        VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                                        VC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                    }
                                    
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }];
                            [self.view addSubview:lll];
                        }
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    [MBProgressHUD showError:msg];
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

#pragma mark - 修改支付密码弹窗
-(void)showWindow{
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSDictionary *dict = @{@"platform":platform,
                           @"apikey":apikey,
                           @"cardType":cardtype,
                           @"comTime":comTime,
                           @"cardNum":cardnum,
                           @"account":account};
    DMLog(@"dict==%@",dict);
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @try {
            [[YKFPay shareYKFPay] modifyPassword:dict viewController:self callBack:^(NSDictionary *resultDic){
                DMLog(@"resultDic:%@", resultDic);
                NSDictionary  *data = [resultDic objectForKey:@"data"];
                NSInteger CODE = [[data objectForKey:@"code"] integerValue];
                NSString *msg = [data objectForKey:@"msg"];
                dispatch_async(dispatch_get_main_queue(), ^{
                    switch (CODE) {
                        case 1000:
                        {
                            [MBProgressHUD showError:@"密码修改成功！"];
                        }
                            break;
                        default:
                        {
                            MBProgressHUD * HUD = [MBProgressHUD showHUDAddedTo:[UIApplication sharedApplication].keyWindow animated:YES];
                            HUD.mode = MBProgressHUDModeText;
                            HUD.margin = 10.f;
                            HUD.yOffset = 15.f;
                            HUD.removeFromSuperViewOnHide = YES;
                            HUD.detailsLabelText = msg;
                            HUD.detailsLabelFont = [UIFont systemFontOfSize:16]; //Johnkui - added
                            [HUD hide:YES afterDelay:2.0];
                        }
                            break;
                    }
                });
            }];
        } @catch (NSException *exception) {
            NSString *msg = [NSString stringWithFormat:@"%@",exception];
            [MBProgressHUD showError:msg];
        }
    });
}

#pragma mark - 找回支付密码弹窗
-(void)GoFindPayPsd{
    FindZFPsdView *lll=[FindZFPsdView alterViewWithTitle:@"找回支付密码，需要您重新进行" content:@"实人认证。" cancel:@"关闭" sure:@"找回支付密码" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"关闭");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"找回支付密码");
        if (_hasnet) {
//            UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
//            FindPsdH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"FindPsdH5VC"];
//            [self.navigationController pushViewController:VC animated:YES];
            
            if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
                
            }else{//实人认证-和谐卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
            
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }];
    [self.view addSubview:lll];
}

#pragma mark - 需要实人认证弹窗
-(void)showSRRZView{
    SZKAlterView *vvv=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"认证");
        if (_hasnet) {
            //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
            //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
            //VC.hidesBottomBarWhenPushed=YES;
            //[self.navigationController pushViewController:VC animated:YES];
            
        
            
            
            if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
                
            }else{//实人认证-和谐卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                VC.isFromZhimaRetrievePwd = YES;//来自找回支付密码
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }];
//    [self.view addSubview:vvv];
    
    __block UIView * blockView = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
        
        //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
        for (NSObject * window in [UIApplication sharedApplication].windows) {
            if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                blockView = (UIView *)window;
            }
        }
        
        [blockView addSubview:vvv];
       
    });
    
    
    
}

#pragma mark - 判断堆栈中有无ViewController类名的
-(int)checkPushOrPop:(UIViewController*)uiViewController{
    NSString *classname = NSStringFromClass([uiViewController class]);
    NSArray *temArray = self.navigationController.viewControllers;
    for(UIViewController *temVC in temArray)
    {
        NSString *temVCname = NSStringFromClass([temVC class]);
        if ([temVCname isEqualToString:classname]) {
            return 1;
        }
    }
    
    return -1;
}

@end
