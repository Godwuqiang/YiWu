//
//  MyCenterVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/11.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "MyCenterVC.h"
#import "LoginVC.h"
#import "LoginVC.h"
#import "SettingVC.h"
#import "ServerCenterVC.h"
#import "MineWebVC.h"
#import "YBydH5VC.h"
#import "YBzxH5VC.h"
#import "FindPsdH5VC.h"
#import "BankXYVC.h"
#import "BankKTVC.h"
#import "YKFPay.h"
#import "HttpHelper.h"
#import "SrrzBean.h"
#import "MJExtension.h"
#import "SZKAlterView.h"
#import "FindZFPsdView.h"
#import "RealPersonVC.h"
#import "MineCenterOne.h"
#import "MineCenterTwo.h"
#import "MineCenterThree.h"
#import "MineCellThree.h"
#import "MsgCenterVC.h"
#import "NoticeVC.h"
#import "SetPayPsdVC.h"
#import "InfoDetailTVC.h"
#import "ModifyCardView.h"
#import "RzwtgView.h"
#import "NewsBL.h"
#import "JPUSHService.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"
#import "SettingWebVC.h"

#define SRRZ_STATUS_URL   @"/complexServer/checkSrrzStatus.json" // 实人认证状态
#define EXIT_URL          @"/userServer/login_out.json"   // 退出登录
#define UNREAD_INFO_URL   @"news/queryUnReadInfo.json"    // 获取未读消息个数
#define GET_DZSBK_PARAM   @"userServer/getUserInfo/basic.json"  //获取电子社保码相关参数

#define BUTTON_TAG1 0x101 //电子社保码 --实人认证
#define BUTTON_TAG2 0x102 //实人认证 --医保移动支付
#define BUTTON_TAG3 0x103 //医保移动支付  --银行卡支付
#define BUTTON_TAG4 0x104 //银行卡支付  --支付密码设置
#define BUTTON_TAG5 0x105 //支付密码设置 --账户设置
#define BUTTON_TAG6 0x106 //账户设置 --服务中心
#define BUTTON_TAG7 0x107 //服务中心


@interface MyCenterVC ()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (nonatomic, strong)    MBProgressHUD  *HUD;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;
@property BOOL  hasnet;

@end

@implementation MyCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //self.automaticallyAdjustsScrollViewInsets = NO;

    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,20);

    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:topframe];
    bgImg.image = [UIImage imageNamed:@"bg_my_top"];
//    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [topview addSubview:bgImg];
    [self.view addSubview:topview];
    
    [self  initView];
    [self registerSerive];
    
}

#pragma mark - 初始化界面
- (void)initView{
    
    self.centertableview.delegate = self;
    self.centertableview.dataSource = self;
    self.centertableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    self.centertableview.separatorStyle = NO;
    if(kIsiPhoneX){
        self.topConstrains.constant -=45;
    }else{
        self.topConstrains.constant -=20;
    }

    
    [self.centertableview registerNib:[UINib nibWithNibName:@"MineCenterOne" bundle:nil] forCellReuseIdentifier:@"MineCenterOne"];
    [self.centertableview registerNib:[UINib nibWithNibName:@"MineCenterTwo" bundle:nil] forCellReuseIdentifier:@"MineCenterTwo"];
    [self.centertableview registerNib:[UINib nibWithNibName:@"MineCenterThree" bundle:nil] forCellReuseIdentifier:@"MineCenterThree"];
    [self.centertableview registerNib:[UINib nibWithNibName:@"MineCellThree" bundle:nil] forCellReuseIdentifier:@"MineCellThree"];
}

#pragma mark - 注册通知
-(void)registerSerive{
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(isLogin:) name:@"isLogin" object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(Exit:) name:@"Exit" object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(JPush:) name:@"JPUSH" object:nil];
}

- (void)isLogin:(NSNotification*) notification{
    [self.centertableview reloadData];
}

- (void)Exit:(NSNotification*) notification{
    [self.centertableview reloadData];
}

-(void)JPush:(NSNotification*) notification{

    [self QueryUnreadInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self setupNavigationBarStyle];
    [self loadNet];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat minAlphaOffset = 0;
    //- 64;
    CGFloat maxAlphaOffset = 100;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    NSLog(@"scrollViewDidScroll: %f", scrollView.contentOffset.y);
    NSLog(@"888888: %f", alpha);

    if(kIsiPhoneX){
        if(scrollView.contentOffset.y<-44.0){//禁止下拉
            scrollView.contentOffset = CGPointMake(0, -44.0);
        }
    }else{
        if(scrollView.contentOffset.y<-20.0){//禁止下拉
            scrollView.contentOffset = CGPointMake(0, -20.0);
        }
    }
}

#pragma mark - 监听网络状态
-(void)loadNet {
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            self.hasnet = YES;
            if ([CoreArchive boolForKey:LOGIN_STUTAS]) {  //已经登录
                [self QueryUnreadInfo];
            }
        }else{
            self.hasnet = NO;
        }
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
}

- (void)dealloc{
    
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
    
    [self unRegisterSerive];
}

#pragma mark - 清除通知
-(void)unRegisterSerive{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"isLogin" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"Exit" object:nil];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"JPUSH" object:nil];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    }else if (section==1) {
        return 1;
    }else{
        return 2;
    }
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section==0) {
        return 220;
    }else if (indexPath.section==2&&indexPath.row==1){
        return 120;
    }else{
        return 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return 0.1;
    }else{
        return 40.0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0||section==2) {
        return 0.1;
    }else{
        return 10.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int ziti,bgao;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
        ziti = 15;      //
        bgao = 85;
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        ziti = 14;
        bgao = 75;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        ziti = 13;
        bgao = 70;
    }
    else //3.5寸屏幕
    {
        ziti = 12;
        bgao = 65;
    }
    
    if (indexPath.section==0) {
        MineCenterOne *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCenterOne"];
        if ( nil == cell ){
            cell = [[MineCenterOne alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCenterOne"];
        }
        [cell.msgBtn addTarget:self action:@selector(GoMsgCenterClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        if ([CoreArchive boolForKey:LOGIN_STUTAS]) {  //已经登录
            
            cell.msgBtn.hidden = NO;
            cell.ViewUnload.hidden = YES;   // 隐藏未登录界面
            cell.ViewLoad.hidden = NO;       // 显示登录界面
            
            
            if(![YWManager sharedManager].isHasCard){//无卡用户
                
                cell.titImg.hidden = YES;
                cell.titlb.hidden = YES;
                
                cell.name.text = @"欢迎您，";
                cell.identifyLabel.hidden = NO;
                NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
                NSString *sbh2 = [sbh substringToIndex:12];
                NSString *sbh3 = [NSString stringWithFormat:@"%@******",sbh2];
                cell.identifyLabel.text = [Util HeadStr:sbh3 WithNum:0];
                cell.shbzh.hidden = YES;
                cell.shbzhlb.hidden = YES;
                cell.khImg.hidden = YES;
                cell.khlb.hidden = YES;
                cell.kh.hidden = YES;
                cell.shbzhImg.hidden = YES;
                cell.detailBtn.hidden = YES;
                cell.loadImg.image = [UIImage imageNamed:@"bg_my_k"];
                DMLog(@"我的-详情-显示-无卡用户");
                
            }else{//有卡用户
                cell.titImg.hidden = NO;
                cell.titlb.hidden = NO;
                cell.identifyLabel.hidden = YES;
                
                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {
                    cell.titlb.text = @"义乌市社会保障·市民卡";
                }else{
                    cell.titlb.text = @"义乌市社会保障·和谐卡";
                }
                
                cell.name.text = [CoreArchive strForKey:LOGIN_NAME];
                NSString *sbh = [CoreArchive strForKey:LOGIN_SHBZH];
                cell.shbzh.text = [Util HeadStr:sbh WithNum:0];
                
                NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
                if ([type isEqualToString:@"1"]) {     // 市民卡
                    cell.shbzhlb.text = @"社会保障号";
                    cell.khImg.hidden = NO;
                    cell.khlb.hidden = NO;
                    cell.kh.hidden = NO;
                    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
                    cell.kh.text = [Util HeadStr:kh WithNum:0];
                }else{     // 和谐卡
                    cell.shbzhlb.text = @"身 份 证 号";
                    cell.khImg.hidden = YES;
                    cell.khlb.hidden = YES;
                    cell.kh.hidden = YES;
                }
                DMLog(@"我的-详情-显示-有卡用户");
            }
            
            
            
            int num1 = [[CoreArchive strForKey:PERSONAL_UNREADNUM] intValue];
            int num2 = [[CoreArchive strForKey:NEWS_UNREADNUM] intValue];
            int num = num1 + num2 ;
            if (num == 0) {
                cell.msgdot.hidden = YES;
                cell.msgnum.hidden = YES;
            }else if (num > 9) {
                cell.msgdot.hidden = NO;
                cell.msgnum.hidden = NO;
                cell.msgnum.text = @"...";
                cell.numrightconstrains.constant = 17;
                cell.numtopconstrains.constant = 0;
            }else{
                cell.msgdot.hidden = NO;
                cell.msgnum.hidden = NO;
                cell.msgnum.text = [NSString stringWithFormat:@"%d",num];
                cell.numrightconstrains.constant = 19;
                cell.numtopconstrains.constant = 3;
            }
            
            
            cell.mybgImg.image = [UIImage imageNamed:@"bg_my_login"];  // 更改整个大背景图片
            
            [cell.detailBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(cell.ViewLoad.mas_bottom).offset(-9);
                make.right.equalTo(cell.ViewLoad.mas_right).offset(-5);
                make.width.equalTo(@(bgao));
                make.height.equalTo(@30);
            }];
            cell.detailBtn.titleLabel.font = [UIFont systemFontOfSize:ziti-1];
            [cell.detailBtn addTarget:self action:@selector(PersonInfoClicked) forControlEvents:UIControlEventTouchUpInside];
            
            NSString *encodedImageStr = [CoreArchive strForKey:LOGIN_USER_PNG];
            if ([Util IsStringNil:encodedImageStr]) {
                cell.loadtouxiang.image = [UIImage imageNamed:@"img_touxiang"];
            }else{
                @try {
                    NSData *encodeddata = [NSData dataFromBase64String:encodedImageStr];
                    UIImage *encodedimage = [UIImage imageWithData:encodeddata];
                    cell.loadtouxiang.image = [Util circleImage:encodedimage withParam:0];
                } @catch (NSException *exception) {
                    cell.loadtouxiang.image = [UIImage imageNamed:@"img_touxiang"];
                }
            }
            
            if ([YWManager sharedManager].isAuthentication) {
                cell.authenImg.image = [UIImage imageNamed:@"icon_authen"];
            }else{
                cell.authenImg.image = [UIImage imageNamed:@"icon_unauthen"];
            }
            
        }else{        // 未登录 bg_my_login_no
            cell.msgBtn.hidden = YES;
            cell.ViewUnload.hidden = NO;
            cell.ViewLoad.hidden = YES;
            
            cell.mybgImg.image = [UIImage imageNamed:@"bg_my_login_no"];  // 更改整个大背景图片
            cell.titImg.hidden = YES;
            cell.titlb.hidden = YES;
            cell.msgdot.hidden = YES;
            cell.msgnum.hidden = YES;
            
            //添加手势
            UITapGestureRecognizer * UnloadtapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(OnclickUnload)];
            UnloadtapGesture.delegate = self;
            
            //选择触发事件的方式（默认单机触发）
            [UnloadtapGesture setNumberOfTapsRequired:1];
            //将手势添加到需要相应的view中去
            [cell.ViewUnload addGestureRecognizer:UnloadtapGesture];
        }
        return cell;
    }else if (indexPath.section==1){  // 我的业务
        if ([CoreArchive boolForKey:LOGIN_STUTAS]) {  //已经登录
            if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {  // 市民卡
                MineCenterTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCenterTwo"];
                if ( nil == cell ){
                    cell = [[MineCenterTwo alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCenterTwo"];
                }
                
                [cell.Btn1 setTag:BUTTON_TAG1];
                [cell.Btn1 setImage:[UIImage imageNamed:@"icon_ecard"] forState:UIControlStateNormal];
                cell.Lb1.font = [UIFont systemFontOfSize:ziti];
                cell.Lb1.text = @"电子社保码";//电子电子电子社保码-实人认证
                [cell.Btn1 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [cell.Btn2 setTag:BUTTON_TAG2];
                [cell.Btn2 setImage:[UIImage imageNamed:@"icon_mymenu1"] forState:UIControlStateNormal];
                cell.Lb2.font = [UIFont systemFontOfSize:ziti];
                cell.Lb2.text = @"实人认证";//实人认证-医保移动支付
                [cell.Btn2 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [cell.Btn3 setTag:BUTTON_TAG3];
                [cell.Btn3 setImage:[UIImage imageNamed:@"icon_mymenu2"] forState:UIControlStateNormal];
                cell.Lb3.font = [UIFont systemFontOfSize:ziti];
                cell.Lb3.text = @"医保移动支付";//医保移动支付-银行卡支付
                [cell.Btn3 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                
                [cell.Btn4 setTag:BUTTON_TAG4];
                [cell.Btn4 setImage:[UIImage imageNamed:@"icon_mymenu3"] forState:UIControlStateNormal];
                cell.Lb4.font = [UIFont systemFontOfSize:ziti];
                cell.Lb4.text = @"银行卡支付";//银行卡支付-支付密码设置
                [cell.Btn4 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }else{      // 和谐卡
                MineCenterThree *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCenterThree"];
                if ( nil == cell ){
                    cell = [[MineCenterThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCenterThree"];
                }
                [cell.BTN1 setTag:BUTTON_TAG1];
                [cell.BTN1 setImage:[UIImage imageNamed:@"icon_ecard"] forState:UIControlStateNormal];
                cell.LB1.font = [UIFont systemFontOfSize:ziti];
                cell.LB1.text = @"电子社保码";//电子社保码-实人认证
                [cell.BTN1 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.BTN2 setTag:BUTTON_TAG3];
                [cell.BTN2 setImage:[UIImage imageNamed:@"icon_mymenu1"] forState:UIControlStateNormal];
                cell.LB2.font = [UIFont systemFontOfSize:ziti];
                cell.LB2.text = @"实人认证";//实人认证-银行卡支付
                [cell.BTN2 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                [cell.BTN3 setTag:BUTTON_TAG4];
                [cell.BTN3 setImage:[UIImage imageNamed:@"icon_mymenu3"] forState:UIControlStateNormal];
                cell.LB3.font = [UIFont systemFontOfSize:ziti];
                cell.LB3.text = @"银行卡支付";//银行卡支付-支付密码设置
                [cell.BTN3 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
        }else{      // 未登录
            MineCenterTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCenterTwo"];
            if ( nil == cell ){
                cell = [[MineCenterTwo alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCenterTwo"];
            }
            
            [cell.Btn1 setTag:BUTTON_TAG1];
            [cell.Btn1 setImage:[UIImage imageNamed:@"icon_ecard"] forState:UIControlStateNormal];
            cell.Lb1.font = [UIFont systemFontOfSize:ziti];
            cell.Lb1.text = @"电子社保码";//电子电子电子社保码icon_ecard-实人认证
            [cell.Btn1 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.Btn2 setTag:BUTTON_TAG2];
            [cell.Btn2 setImage:[UIImage imageNamed:@"icon_mymenu1"] forState:UIControlStateNormal];
            cell.Lb2.font = [UIFont systemFontOfSize:ziti];
            cell.Lb2.text = @"实人认证";//实人认证-医保移动支付
            [cell.Btn2 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.Btn3 setTag:BUTTON_TAG3];
            [cell.Btn3 setImage:[UIImage imageNamed:@"icon_mymenu2"] forState:UIControlStateNormal];
            cell.Lb3.font = [UIFont systemFontOfSize:ziti];
            cell.Lb3.text = @"医保移动支付";//医保移动支付-银行卡支付
            [cell.Btn3 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
            
            
            [cell.Btn4 setTag:BUTTON_TAG4];
            [cell.Btn4 setImage:[UIImage imageNamed:@"icon_mymenu3"] forState:UIControlStateNormal];
            cell.Lb4.font = [UIFont systemFontOfSize:ziti];
            cell.Lb4.text = @"银行卡支付";//银行卡支付-支付密码设置
            [cell.Btn4 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
            
            return cell;
        }
    }else if (indexPath.section==2&&indexPath.row==1) {
        MineCellThree *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCellThree"];
        if ( nil == cell ){
            cell = [[MineCellThree alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCellThree"];
        }
        if ([CoreArchive boolForKey:LOGIN_STUTAS]) {//已经登录
            cell.ExitBtn.hidden = NO;
            cell.ExitBtn.userInteractionEnabled = YES;
            [cell.ExitBtn addTarget:self action:@selector(OnClickExitLogin:) forControlEvents:UIControlEventTouchUpInside];
        }else{
            cell.ExitBtn.hidden = YES;
            cell.ExitBtn.userInteractionEnabled = NO;
        }
        return cell;
    }else{      // 系统设置
        MineCenterTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"MineCenterTwo"];
        if ( nil == cell ){
            cell = [[MineCenterTwo alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MineCenterTwo"];
        }
        
        [cell.Btn1 setTag:BUTTON_TAG5];
        [cell.Btn1 setImage:[UIImage imageNamed:@"icon_mymenu4"] forState:UIControlStateNormal];
        cell.Lb1.font = [UIFont systemFontOfSize:ziti];
        cell.Lb1.text = @"支付密码设置";//支付密码设置-账户设置
        [cell.Btn1 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.Btn2 setTag:BUTTON_TAG6];
        [cell.Btn2 setImage:[UIImage imageNamed:@"icon_mymenu5"] forState:UIControlStateNormal];
        cell.Lb2.font = [UIFont systemFontOfSize:ziti];
        cell.Lb2.text = @"账户设置";//账户设置-服务中心
        [cell.Btn2 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
        [cell.Btn3 setImage:[UIImage imageNamed:@"icon_mymenu9"] forState:UIControlStateNormal];
        cell.Lb3.font = [UIFont systemFontOfSize:ziti];
        [cell.Btn3 setTag:BUTTON_TAG7];
        cell.Lb3.text = @"服务中心";//@""服务中心
        [cell.Btn3 addTarget:self action:@selector(GoPage:) forControlEvents:UIControlEventTouchUpInside];
        
        [cell.Btn4 setImage:[UIImage imageNamed:@"icon_blank"] forState:UIControlStateNormal];
        cell.Lb4.font = [UIFont systemFontOfSize:ziti];
        cell.Lb4.text = @"";//@""
        
        return cell;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section==1||section==2) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
        headerView.backgroundColor = [UIColor whiteColor];
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 100, 20)];
        headerLab.font = [UIFont systemFontOfSize:15];
        if (section==1) {
            headerLab.text = @"我的业务";
        }else{
            headerLab.text = @"系统设置";
        }
        headerLab.textColor = [UIColor colorWithHex:0x666666];

        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 39, SCREEN_WIDTH, 1)];
        line.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        UIView *head = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 1)];
        head.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        [headerView  addSubview:headerLab];
        [headerView addSubview:line];
        if (section==1) {
            [headerView addSubview:head];
        }
        return headerView;
    }else{
        return nil;
    }
}

#pragma mark - 未登录点击事件
-(void)OnclickUnload{

    YWLoginVC * loginVC = [[YWLoginVC alloc]init];
    loginVC.isFromRegist = YES;
    DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
    [self presentViewController:navVC animated:YES completion:nil];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    // 取消选中状态
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 按钮点击事件
- (void)GoPage:(UIButton *) button{
    NSUInteger BtnTag = [button tag];
    
    if(BtnTag == BUTTON_TAG1){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
            return;
        }
        
        //无卡权限拦截
        if(![YWManager sharedManager].isHasCard){
            
            [self showNoCardTips];
            return ;
        }
        
        //实人认证状态
        if(![[CoreArchive strForKey:LOGIN_SRRZ_STATUS] isEqualToString:@"1"]){
            [self showSRRZView];
            return ;
        }
        [self dzsbkButtonClick];
        return;
    }
    
    
    if(BtnTag == BUTTON_TAG4){//银行卡支付
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
            return;
        }
        
        //无卡权限拦截
        if(![YWManager sharedManager].isHasCard){
            
            [self showNoCardTips];
            return ;
        }
        
        //实人认证状态
        if(![[CoreArchive strForKey:LOGIN_SRRZ_STATUS] isEqualToString:@"1"]){
            [self showSRRZView];
            return ;
        }
        
        if (![[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {//市民卡
            [MBProgressHUD showError:@"抱歉，和谐卡暂不支持该功能~"];
            return;
        }
        
        //医保移动支付开通状态
        if (![[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {// 未开通
            
            NSString *msg = @"您没有开通医保移动支付，请开通";
            RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"开通" cancelBtClcik:^{
                //取消按钮点击事件
                DMLog(@"取消");
            } sureBtClcik:^{
                //开通医保移动支付
                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {//市民卡
                    if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {
                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                        YBzxH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBzxH5VC"];
                        VC.hidesBottomBarWhenPushed=YES;
                        [self.navigationController pushViewController:VC animated:YES];
                    }else{
                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                        YBydH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBydH5VC"];
                        VC.hidesBottomBarWhenPushed=YES;
                        [self.navigationController pushViewController:VC animated:YES];
                    }
                    
                }else{//和谐卡
                    [MBProgressHUD showError:@"抱歉，和谐卡暂不支持该功能~"];
                }
            }];
            [self.view addSubview:lll];
            return ;
            
        }
        
        //医保卡状态
        if(![[CoreArchive strForKey:LOGIN_CARD_STATUS] isEqualToString:@"1"]){
            
            [MBProgressHUD showError:@"医保卡状态异常"];
            return ;
        }
    
        
    }
    
    
    
    
    
    if (BtnTag==BUTTON_TAG7) {  // 服务中心
        UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
        ServerCenterVC * VC = [SB instantiateViewControllerWithIdentifier:@"ServerCenterVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
        
        
        return;
    }
    
    if (BtnTag==BUTTON_TAG5){     // 支付密码设置
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            
            
            //是否设置过支付密码
            if(![YWManager sharedManager].isSettedPayPassword){//未设置过支付密码
                
                UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                SettingWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"SettingWebVC"];
                VC.isFromRegist = YES;
                VC.str = @"";
                //注册-实人认证-之前没有设置过支付密码-这里的serNum传空
                [VC setValue:[CoreArchive strForKey:LOGIN_APP_MOBILE] forKey:@"phone"];
                [self.navigationController pushViewController:VC animated:YES];
                return ;
            }
            
            UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            SetPayPsdVC * VC = [MB instantiateViewControllerWithIdentifier:@"SetPayPsdVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        return;
    }
    

    if (BtnTag==BUTTON_TAG6){     // 账户设置
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard * UB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
            SettingVC * VC = [UB instantiateViewControllerWithIdentifier:@"SettingVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
            
            
            
        }
        return;
    }
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) { // 未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        if (self.hasnet) {
            [self CheckSrrzStatusWithTag:BtnTag];  // 先检查实人认证状态，再决定跳不跳转
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }
}

#pragma mark - 退出按钮点击事件
- (IBAction)OnClickExitLogin:(id)sender {
    [self showQuitView];
}

#pragma mark - 退出操作
-(void)showQuitView{
    FindZFPsdView *qq=[FindZFPsdView alterViewWithTitle:@"提示信息"content:@"是否确定退出登录？" cancel:@"取消" sure:@"确定退出" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"关闭");
    } sureBtClcik:^{
        //确定按钮点击事件
        if (_hasnet) {
            [self queryExit];
        }else{
            [self queryExit];//无论有网还是无网都进行退出登录
            //[MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
        
    }];
    [self.tabBarController.view addSubview:qq];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

#pragma mark - 消息中心
-(IBAction)GoMsgCenterClicked:(id)sender{
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
        NoticeVC * VC = [MB instantiateViewControllerWithIdentifier:@"NoticeVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 个人信息详情
-(void)PersonInfoClicked{
    UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    InfoDetailTVC * VC = [MB instantiateViewControllerWithIdentifier:@"InfoDetailTVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 实人认证状态查询接口
-(void)CheckSrrzStatusWithTag:(NSUInteger)tag{
    
    if(![YWManager sharedManager].isHasCard){//无卡的时候
        
        [self hasNoCardActionWithTag:tag];
        return;
    }
    

    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_STATUS_URL];
    DMLog(@"url=%@",url);
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
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
                        if ([bean.renzhengStatus isEqualToString:@"1"]) {  // 认证成功
                            if (tag==BUTTON_TAG2) {   // 实人认证
                                [MBProgressHUD showError:@"您已经实人认证！"];
                            }else if (tag==BUTTON_TAG3) {     // 医保移动支付
                                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {
                                    if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {
                                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                        YBzxH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBzxH5VC"];
                                        VC.hidesBottomBarWhenPushed=YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                    }else{
                                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                        YBydH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBydH5VC"];
                                        VC.hidesBottomBarWhenPushed=YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                    }
                                }else{
                                    //无卡权限拦截
                                    if(![YWManager sharedManager].isHasCard){
                                        
                                        [self showNoCardTips];
                                        return ;
                                    }
                                    [MBProgressHUD showError:@"和谐卡未开通此项功能"];
                                }
                            }else if (tag ==BUTTON_TAG1){//电子社保码
                                
                                //[self getDZSBKParam];--改回实人认证
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
                                
                            }else if (tag ==BUTTON_TAG4){   // 银行卡支付
                                if ([[CoreArchive strForKey:LOGIN_BANKZF_STATUS] isEqualToString:@"1"]){
                                    UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
                                    BankKTVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankKTVC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
                                    BankXYVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankXYVC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }
                            }
//                            else{      // 支付密码设置
//                                UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
//                                SetPayPsdVC * VC = [MB instantiateViewControllerWithIdentifier:@"SetPayPsdVC"];
//                                VC.hidesBottomBarWhenPushed=YES;
//                                [self.navigationController pushViewController:VC animated:YES];
//                            }
                        }else if ([bean.renzhengStatus isEqualToString:@"5"]){   // 未认证
                            if (tag==BUTTON_TAG2) {   // 实人认证
                                
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
                                
                                
                            }else{
                                [self showSRRZView];
                            }
                        }else{              // 认证不通过
                            NSString *msg = @"   因您上传照片不符合实人认证要求，无法继续使用该功能，请重新进行实人认证。";
                            RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"重新认证" cancelBtClcik:^{
                                //取消按钮点击事件
                                DMLog(@"取消");
                            } sureBtClcik:^{
                                //重新认证点击事件
                                DMLog(@"重新认证");
                                //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
                                //VC.hidesBottomBarWhenPushed=YES;
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
        self.HUD.hidden = YES;
    }];
}

#pragma mark - 显示实人认证弹窗
-(void)showSRRZView{
    SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"认证");
        //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
        //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
        //VC.hidesBottomBarWhenPushed=YES;
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
        
    }];
    //[self.view addSubview:lll];
    __block UIView * blockView = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
        
        //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
        for (NSObject * window in [UIApplication sharedApplication].windows) {
            if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                blockView = (UIView *)window;
            }
        }
        
        [blockView addSubview:lll];
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
    
    [self.centertableview reloadData];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

#pragma mark - 获取未读消息个数接口
-(void)QueryUnreadInfo {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    [param setValue:accesstoken forKey:@"access_token"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UNREAD_INFO_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            if (iStatus == 200)
            {
                NSDictionary *dict = [dictData objectForKey:@"data"];
                NSString *personnum = [dict objectForKey:@"personUnReadNum"];
                [CoreArchive setStr:personnum key:@"personUnReadNum"];
                NSString *newsnum = [dict objectForKey:@"newsUnReadNum"];
                [CoreArchive setStr:newsnum key:@"newsUnReadNum"];
                
                NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:0];
                [self.centertableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}


#pragma mark - 获取电子电子电子社保码所需相关参数
/** 获取电子电子电子社保码所需相关参数 */
-(void)getDZSBKParam{
    
    //无卡权限拦截
    if(![YWManager sharedManager].isHasCard){
        
        [self showNoCardTips];
        return ;
    }
    
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
        DMLog(@"获取电子社保码所需相关参数===============%@",dictData);
        NSDictionary * dataDic = dictData[@"data"];
        NSString * resultCode = dictData[@"resultCode"];
        if([resultCode integerValue] ==200){
            
            DMLog(@"%@",dictData);
            
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:currentDate];
            DMLog(@"dateString:%@",dateString);
            NSString *comTime = dateString;
            
            NSMutableDictionary * param = [NSMutableDictionary dictionary];
            param[@"idCard"] = dataDic[@"idCard"];
            param[@"userName"] = dataDic[@"name"];
            param[@"sourceUserId"] = [CoreArchive strForKey:LOGIN_ID];
            param[@"cardType"] = dataDic[@"cardType"];
            param[@"cardNum"] = dataDic[@"cardNum"];
            param[@"mobile"] = [CoreArchive strForKey:LOGIN_APP_MOBILE];
            param[@"sex"] = dataDic[@"sex"];
            param[@"pic"] = [CoreArchive strForKey:LOGIN_USER_PNG];//@"";
            param[@"bankNum"] = dataDic[@"bankNo"];
            param[@"bankCode"] = dataDic[@"bankCode"];
            param[@"bankName"] = dataDic[@"bank"];
            param[@"comTime"] = comTime;
            param[@"extendedField"] = [CoreArchive strForKey:LOGIN_BANKZF_STATUS];
            
            NSLog(@"电子社保码使用--参数--%@",param);
            
            [YW_DZSBK_SDK businessProcessWithDictionary:param viewController:self];
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
    
}



#pragma mark - 提示无卡
-(void)showNoCardTips{
    
    [EPTipsView sharedTipsView].leftButtonColor = [UIColor colorWithHex:0xFDB731];
    [EPTipsView ep_showAlertView:@"未查询到您名下的卡片信息，不能进行相关操作！" buttonText:@"我知道了" toView:self.tabBarController.view  buttonBlock:^{
    }];
}



/** 无卡 */
-(void)hasNoCardActionWithTag:(NSUInteger)tag{
    
    if(![YWManager sharedManager].isAuthentication){//未实人认证
        
        NSString *msg = @"   因您上传照片不符合实人认证要求，无法继续使用该功能，请重新进行实人认证。";
        RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"重新认证" cancelBtClcik:^{
            //取消按钮点击事件
            DMLog(@"取消");
        } sureBtClcik:^{
            //重新认证点击事件
            DMLog(@"重新认证");
            //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
            //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
            //VC.hidesBottomBarWhenPushed=YES;
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
            
        }];
        [self.view addSubview:lll];
        
    }else{//实人认证通过
        
        
        if (tag==BUTTON_TAG2) {   // 实人认证
            [MBProgressHUD showError:@"您已经实人认证！"];
        }else if (tag==BUTTON_TAG3) {     // 医保移动支付
            if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {
                if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {
                    UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                    YBzxH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBzxH5VC"];
                    VC.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:VC animated:YES];
                }else{
                    UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                    YBydH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBydH5VC"];
                    VC.hidesBottomBarWhenPushed=YES;
                    [self.navigationController pushViewController:VC animated:YES];
                }
            }else{
                //无卡权限拦截
                if(![YWManager sharedManager].isHasCard){
                    
                    [self showNoCardTips];
                    return ;
                }
                [MBProgressHUD showError:@"和谐卡未开通此项功能"];
            }
        }else if (tag ==BUTTON_TAG1){//电子社保码
            
            [self getDZSBKParam];
            
        }else if (tag ==BUTTON_TAG4){   // 银行卡支付
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            if ([[CoreArchive strForKey:LOGIN_BANKZF_STATUS] isEqualToString:@"1"]){
                UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
                BankKTVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankKTVC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
                BankXYVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankXYVC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
        }else{
        }
    }
    return;
    
}


/**
 实人认证拦截-登录-无卡-实人认证通过
 
 @return 是否继续后面的操作
 */
-(BOOL)isAuthenticatedAndHasNoCard{
    
    if([YWManager sharedManager].isAuthentication){//实人认证通过
        
        return YES;
    }else{//实人认证未通过
        
        if([YWManager sharedManager].isHasCard){//有卡
            
            
            SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
                //取消按钮点击事件
                DMLog(@"取消");
            } sureBtClcik:^{
                //确定按钮点击事件
                DMLog(@"认证");
                
                
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
                
            }];
            //[self.view addSubview:lll];
            __block UIView * blockView = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
                
                //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
                for (NSObject * window in [UIApplication sharedApplication].windows) {
                    if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                        blockView = (UIView *)window;
                    }
                }
                
                [blockView addSubview:lll];
                
            });
            return NO;
        }else{//无卡
            
            return NO;
        }
    }
}



/**
 电子社保码按钮点击事件
 */
-(void)dzsbkButtonClick{
    
            NSString *platform = @"sdk";
            NSString *apikey = @"S6WQ548S7QW4";
            NSString *privateKey = @"";
            NSDictionary *dic = @{@"platform":platform, @"apiKey":apikey, @"privateKey":privateKey};
    
            [YW_DZSBK_SDK initSDKWithDictionary:dic callBack:^(NSDictionary *dic) {
    
                if([dic[@"code"] integerValue] == 0){//初始化成功
                    DMLog(@"初始化成功");
    
                }else{
                    DMLog(@"初始化失败");
                    [MBProgressHUD showError:dic[@"msg"]];
                }
    
                NSLog(@"电子社保码SDK初始化结果:%@", dic);
    
            }];
    
    
            NSDate *currentDate = [NSDate date];//获取当前时间，日期
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
            NSString *dateString = [dateFormatter stringFromDate:currentDate];
            DMLog(@"dateString:%@",dateString);
            NSString *comTime = dateString;
    
            NSString * cardType = @"";
            if([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]){
                cardType =@"01";
            }else if([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"2"]){
                cardType =@"02";
            }
    
            NSMutableDictionary * dictionary = [NSMutableDictionary dictionary];
            dictionary[@"idCard"] = [CoreArchive strForKey:LOGIN_SHBZH];
            dictionary[@"userName"] = [CoreArchive strForKey:LOGIN_NAME];
            dictionary[@"mobile"] = [CoreArchive strForKey:LOGIN_CARD_MOBILE];
            dictionary[@"sourceUserId"] = [CoreArchive strForKey:LOGIN_ID];
            dictionary[@"cardType"] = [CoreArchive strForKey:LOGIN_CARD_TYPE];
            dictionary[@"cardNum"] = [CoreArchive strForKey:LOGIN_CARD_NUM];
            dictionary[@"extendedField"] = @"";
            dictionary[@"comTime"] = comTime;
    
            NSLog(@"查询电子社保码开通结果:dictionary=%@",dictionary);
    [YW_DZSBK_SDK openStatusWithDictionary:dictionary viewController:self callBack:^(NSDictionary *dic) {
    NSLog(@"开通结果:dictionary=%@",dictionary);
    NSLog(@"开通结果:dic=%@", dic);
    
    if([dic[@"result"] integerValue] ==0){//未开通
    
    }else if([dic[@"result"] integerValue]==1){//已开通
    
    }else if([dic[@"result"] integerValue]==2){//查询失败
    
    }
    
    }];
    [self getDZSBKParam];
    
    
}

@end
