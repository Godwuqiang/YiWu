//
//  ServiceTVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/12.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ServiceTVC.h"
#import "CanBaoInfoVC.h"
#import "WuXianPaymentVC.h"
#import "YLJfafangVC.h"
#import "YBcostVC.h"
#import "MedicalListVC.h"
#import "HospitalListVC.h"
#import "PharmacyListVC.h"
#import "NetListVC.h"
#import "YLJAccountVC.h"
#import "MineWebVC.h"
#import "TrearmentListVC.h"
#import "JFH5VC.h"
#import "GHH5VC.h"
#import "LoginVC.h"
#import "SZKAlterView.h"
#import "GuaShiVC.h"
#import "CheckListVC.h"
#import "HttpHelper.h"
#import "SrrzBean.h"
#import "ModifyCardView.h"
#import "RzwtgView.h"
#import "MJExtension.h"
#import "BdH5VC.h"
#import "ParkVC.h"
#import "BankKTVC.h"
#import "BankXYVC.h"
#import "DXBPublicBlikeVC.h"
#import "DTFQualificationVC.h"
#import "DTFQualificationConfirmVC.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"
#import "DTFRechargeVC.h"
#import "DTFRegisterVC.h"
#import "XBFFWDController.h"
#import "YWRegistAndPaymentVC.h"
#import "TalentArchivesVC.h"
#import "ElectronicEngineerVC.h"


#define SRRZ_STATUS_URL   @"/complexServer/checkSrrzStatus.json" // 实人认证状态


@interface ServiceTVC ()

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property                     BOOL                       hasnet;

@end

@implementation ServiceTVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title =@"服务";
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.tabBarController.tabBar.hidden = NO;
    [self setupNavigationBarStyle];
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

#pragma mark -  请求检查网络状态
- (void)afn{
    //1.创建网络状态监测管理者
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 20;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
//    if (indexPath.row == 9) {
//        return 0.01;
//    }
//    if (indexPath.row == 16) {
//        return 0.01;
//    }
    if (indexPath.row==0||indexPath.row==10||indexPath.row==17) {
        return 40;
    }else{

        return 75;
    }
}

#pragma mark - 参保信息按钮
- (IBAction)canbaoBtnClicked:(id)sender {

    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        CanBaoInfoVC *VC = [SB instantiateViewControllerWithIdentifier:@"CanBaoInfoVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 缴费记录
- (IBAction)jfBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle: nil];
        WuXianPaymentVC *VC = [SB instantiateViewControllerWithIdentifier:@"WuXianPaymentVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 医保消费
- (IBAction)ybxfBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        YBcostVC *VC = [SB instantiateViewControllerWithIdentifier:@"YBcostVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 养老待遇
- (IBAction)yldyBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        YLJfafangVC *VC = [SB instantiateViewControllerWithIdentifier:@"YLJfafangVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 养老金账户
- (IBAction)ylzhBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        YLJAccountVC *VC = [SB instantiateViewControllerWithIdentifier:@"YLJAccountVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 定点药店
- (IBAction)ddydBtnClicked:(id)sender {
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    PharmacyListVC *VC = [SB instantiateViewControllerWithIdentifier:@"PharmacyListVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 定点医院
- (IBAction)ddyyBtnClicked:(id)sender {
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    HospitalListVC *VC = [SB instantiateViewControllerWithIdentifier:@"HospitalListVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 医保诊疗目录 (原先服务网点)
- (IBAction)fwwdBtnClicked:(id)sender {
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    TrearmentListVC *VC = [SB instantiateViewControllerWithIdentifier:@"TrearmentListVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -  医保药品目录  (原先医保诊疗目录)
- (IBAction)zlmlBtnClicked:(id)sender {
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    MedicalListVC *VC = [SB instantiateViewControllerWithIdentifier:@"MedicalListVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -  家庭账户授权 (原先医保药品目录)
- (IBAction)ypmmBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        if(![YWManager sharedManager].isHasCard){//无卡权限拦截
            [self showNoCardTips];
            return;
        }
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/account_auth_step1.html?" forKey:@"url"];
        [VC setValue:@"家庭账户授权" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 社保待遇资格认证
- (IBAction)sbdyzgrzBtnClick:(id)sender {
    

    DMLog(@"社保待遇资格认证");
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{

        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        DTFQualificationVC * vc = [[DTFQualificationVC alloc]init];
        vc.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - 长住外地备案
- (IBAction)longFieldRecordButtonClick:(UIButton *)sender {
    
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFRegisterVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFRegisterVC"];
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}


#pragma mark - 城乡居民医疗缴费

- (IBAction)residentTreatmentButtonClick:(UIButton *)sender {
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
        registPaymentVC.registAndPaymentType = EPRegistAndPaymentResidentTreatment;
        [self.navigationController pushViewController:registPaymentVC animated:YES];
    }
}


#pragma mark - 大病保险

- (IBAction)searousIllButtonClick:(UIButton *)sender {

    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
        registPaymentVC.registAndPaymentType = EPRegistAndPaymentSeriousIllness;
        [self.navigationController pushViewController:registPaymentVC animated:YES];
    }
}


#pragma mark - 灵活就业人员参保
- (IBAction)lhjyrycbBtnClick:(id)sender {
    

    DMLog(@"灵活就业人员参保");
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/flex_employ_index.html?" forKey:@"url"];
        [VC setValue:@"灵活就业人员参保" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    } 
}

#pragma mark - 信息修改
- (IBAction)xxxgBtnClick:(id)sender {

    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/modify.html?" forKey:@"url"];
        [VC setValue:@"信息修改" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }

    DMLog(@"信息修改");
}

#pragma mark - 就诊挂号
- (IBAction)jzghBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        if (_hasnet) {
            [self CheckSrrzStatusWithTag:1];
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }
}

#pragma mark - 就诊缴费
- (IBAction)jzjfBtnClicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        if (_hasnet) {
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            [self CheckSrrzStatusWithTag:2];
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }
}

#pragma mark - 市民卡账户
- (IBAction)ggfw1Clicked:(id)sender {
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
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/account_info.html?" forKey:@"url"];
        [VC setValue:@"市民卡账户" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 交易记录
- (IBAction)ggfw2Clicked:(id)sender {
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
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/transaction_record.html?" forKey:@"url"];
        [VC setValue:@"交易记录" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 市民卡预挂失
- (IBAction)ggfw3Clicked:(id)sender {
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
        
        GuaShiVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuaShiVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 服务网点
- (IBAction)ggfw4Clicked:(id)sender {
//    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
//    NetListVC *VC = [SB instantiateViewControllerWithIdentifier:@"NetListVC"];
//    VC.hidesBottomBarWhenPushed=YES;
//    [self.navigationController pushViewController:VC animated:YES];
    
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    XBFFWDController *VC = [SB instantiateViewControllerWithIdentifier:@"XBFFWDController"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
    
}

#pragma mark - 检查检验单
- (IBAction)zhyl3Clicked:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        if (_hasnet) {
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle: nil];
            CheckListVC *VC = [SB instantiateViewControllerWithIdentifier:@"CheckListVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }
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
                        [self.tabBarController.selectedViewController.view addSubview:vv];
                    }else{
                        if ([bean.renzhengStatus isEqualToString:@"1"]) {  // 认证成功
                            
                            if (tag==1) {   // 就诊挂号
                                if (_hasnet) {
                                    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                                    GHH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"GHH5VC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }else {     // 就诊缴费
                                if (_hasnet) {
                                    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                                    JFH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"JFH5VC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }
                        }else if ([bean.renzhengStatus isEqualToString:@"5"]){   // 未认证
                            [self showSRRZView];
                        }else{              // 认证不通过
                            // NSString *msg = [resultDict objectForKey:@"message"];
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
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }];
                            [self.tabBarController.selectedViewController.view addSubview:lll];
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

#pragma mark - 显示实人认证弹窗
-(void)showSRRZView{
    SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
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
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
                
            }else{//实人认证-和谐卡-信息核对
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                VC.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:VC animated:YES];
            }
            
        }else{
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }];
    //[self.tabBarController.selectedViewController.view addSubview:lll];
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


#pragma mark - 公共自行车
- (IBAction)ggzxcBtnClicked:(id)sender {
    
    DMLog(@"公共自行车");
    
    DXBPublicBlikeVC *VC = [[DXBPublicBlikeVC alloc] init];
    VC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 公共停车场
- (IBAction)cstccBtnClicked:(id)sender {
    
    DMLog(@"公共停车场");
    
    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
    ParkVC *VC = [SB instantiateViewControllerWithIdentifier:@"ParkVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 信用积分
- (IBAction)cpbdBtnClicked:(id)sender {
    
    DMLog(@"信用积分");
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/credit.html?" forKey:@"url"];
        [VC setValue:@"信用积分" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}

#pragma mark - 车牌绑定
- (IBAction)xyjfBtnClicked:(id)sender {
    
    DMLog(@"车牌绑定");
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];

    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/car_bind_step1.html?" forKey:@"url"];
        [VC setValue:@"车牌绑定" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}


#pragma mark - 城乡居民财政补助

- (IBAction)subsidyButtonClick:(UIButton *)sender {
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];

    }else{
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        BdH5VC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/finance_subsidy.html?" forKey:@"url"];
        [VC setValue:@"城乡居民财政补助" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
    DMLog(@"城乡居民财政补助");
}


#pragma mark - 大钱包充值
- (IBAction)rechargeButtonClick:(UIButton *)sender {
    
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];

    }else{//已登录
        
        //无卡权限拦截
        if(![YWManager sharedManager].isHasCard){
            
            [self showNoCardTips];
            return ;
        }
        
        //无卡-实人认证-权限拦截
        if(![self isAuthenticatedAndHasNoCard]) return;
        
        //LOGIN_BANKZF_STATUS
        if([[CoreArchive strForKey:LOGIN_SRRZ_STATUS] isEqualToString:@"1"]){
            
            if([[CoreArchive strForKey:LOGIN_BANKZF_STATUS] isEqualToString:@"1"]){//银行卡支付开通
                
                DTFRechargeVC * vc = [[DTFRechargeVC alloc]init];
                [self.navigationController pushViewController:vc animated:YES];
                
            }else{//银行卡支付未开通
                
                SZKAlterView * bankcardStatus = [SZKAlterView alterViewWithTitle:@"" content:@"您还没有开通银行卡支付功能，请开通后再进行充值。" cancel:@"取消" sure:@"去开通" cancelBtClcik:^{
                    
                } sureBtClcik:^{
                    
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
                }];
                
                __block UIView * blockView = nil;
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
                    
                    //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
                    for (NSObject * window in [UIApplication sharedApplication].windows) {
                        if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                            blockView = (UIView *)window;
                        }
                    }
                    [blockView addSubview:bankcardStatus];
                });
            }
        }else{//未实人认证
            
            [self showSRRZView];
        }
    }
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

#pragma mark - 提示无卡
-(void)showNoCardTips{
    
    [EPTipsView sharedTipsView].leftButtonColor = [UIColor colorWithHex:0xFDB731];
    [EPTipsView ep_showAlertView:@"未查询到您名下的卡片信息，不能进行相关操作！" buttonText:@"我知道了" toView:self.tabBarController.view  buttonBlock:^{
        
    }];
}


/** 无卡 */
-(void)hasNoCardActionWithTag:(NSUInteger)tag{
    
    
    if([YWManager sharedManager].isAuthentication){//实人认证通过
        
        
        if(![YWManager sharedManager].isHasCard){//无卡权限拦截
            [self showNoCardTips];
            return;
        }
        
        if (tag==1) {   // 就诊挂号
            if (_hasnet) {
                UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                GHH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"GHH5VC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }else {     // 就诊缴费
            if (_hasnet) {
                UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                JFH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"JFH5VC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
    }else{//实人认证未通过
        
        [self showSRRZView];
    }
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


#pragma mark -城乡居民养老
- (IBAction)jmyanglao:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
        registPaymentVC.registAndPaymentType = EPRegistAndPaymentResidentPension;
        [self.navigationController pushViewController:registPaymentVC animated:YES];
    }
}

#pragma mark  - 空闲的btn 人才档案
- (IBAction)kongxian:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        TalentArchivesVC *talent= [[TalentArchivesVC alloc]init];
        [self.navigationController pushViewController:talent animated:YES];
    }
    
}

#pragma mark  - 市民卡申领
- (IBAction)smkslClick:(UIButton *)sender {
}
#pragma mark  - 电子社保卡
- (IBAction)dzsbkslClick:(id)sender {
    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    }else{
        ElectronicEngineerVC *talent= [[ElectronicEngineerVC alloc]init];
        [self.navigationController pushViewController:talent animated:YES];
    }
    
}
@end
