//
//  YBcostVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YBcostVC.h"
#import "CLAlertView.h"
#import "ZYDetailVC.h"
#import "ZYDetailVC.h"
#import "YBCostCell.h"
#import "ServiceBL.h"
#import "TiShiCell.h"
#import "LoginVC.h"
#import "MZVC.h"
#import "HttpHelper.h"

#define APP_GETYEAR_JSON    @"/app/getYear.json"    // 获取年度


@interface YBcostVC ()<UITableViewDelegate,UITableViewDataSource,CLAlertViewDelegate,ServiceBLDelegate>

@property (nonatomic, strong)   NSMutableArray  *dataList;
@property (nonatomic, strong)   NSMutableArray  *datearray;
@property (nonatomic, strong)     ServiceBL     *serviceBL;
@property (nonatomic, strong)     YiBaoYeBean   *yebean;
@property (nonatomic, strong)   MBProgressHUD   *HUD;
@property (nonatomic, strong)   CLAlertView   *bottomView;//选择年份
@property (nonatomic, strong)       NSString     *year;
@property                              int      pageNo;
@property                             int       chooseno;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@property (nonatomic, strong)     NSString      *tishi;
@property       BOOL    hasData;
@property        int      yenum;
@property        int      num;

@end

@implementation YBcostVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"医保消费";
    HIDE_BACK_TITLE;
    [self initData];
    [self afn];
}

- (void)getYearData {
    
    [self showLoadingUI];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:@"1000" forKey:@"year_code"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,APP_GETYEAR_JSON];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"获取年度: %@", resultDict);
        self.HUD.hidden = YES;
        
        
        //获取年份成功
        if ([resultDict[@"resultCode"] integerValue] == 200) {
            
            NSMutableArray * arr = [NSMutableArray array];
            
            if((resultDict[@"data"][@"nowYear"] !=nil) && (resultDict[@"data"][@"earliestYear"] !=nil)){
                
                NSInteger nowYear = [resultDict[@"data"][@"nowYear"] integerValue];
                NSInteger earliestYear = [resultDict[@"data"][@"earliestYear"] integerValue];
                for (int i = 0; i <= (nowYear - earliestYear); i++) {
                    
                    [arr addObject:[NSString stringWithFormat:@"%li",nowYear-i]];
                    DMLog(@"获取年份处理--%li",nowYear-i);
                }
                self.datearray  = arr;
            }
            
        }
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"获取年度error%@",error);
    }];
}

#pragma mark - 初始化数据
-(void)initData{
    self.dataList = [[NSMutableArray alloc]initWithCapacity:0];
    self.datearray = [[NSMutableArray alloc]initWithCapacity:0];
    self.serviceBL = [ServiceBL sharedManager];
    self.serviceBL.delegate = self;
    self.pageNo = 1;
    self.tishi = @"hasdata";
    self.hasData = YES;
    self.yenum = 0;
    self.num = 0;
    
    NSDate *currentDate = [NSDate date];   //获取当前时间，日期
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    [yearFormatter setDateFormat:@"YYYY"];
    self.year = [yearFormatter stringFromDate:currentDate];
    NSString *yr = [yearFormatter stringFromDate:currentDate];
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:20];
//    for (int i=0; i<20; i++) {
//        int yy = [yr intValue];
//        int nt = yy - i;
//        NSString *next = [NSString stringWithFormat:@"%d",nt];
//        [arr addObject:next];
//    }
     self.datearray = arr;
    //获取年份信息
    [self getYearData];
    self.chooseno = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
    self.yenum = 0;
    self.num = 0;
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
            if ([CoreArchive boolForKey:LOGIN_STUTAS]) {
                [self loadData];
                [self loadYBData];
            }
        }else{
            self.tishi = @"noweb";
            self.hasData = NO;
            [self setupUI];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 加载数据
- (void)loadData{
    self.yenum = self.yenum + 1;
    DMLog(@"ye请求次数：%d",self.yenum);
    NSString *tradecode = @"30007";
    NSString *shbzh = @"e10adc3949ba59abbe56e057f20f883ez";
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self.serviceBL queryYiBaoYeWith:shbzh andAccess_Token:access_token andTradeCode:tradecode];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
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
}

#pragma mark - 医保账户余额查询接口回调
-(void)queryYiBaoYeSucceed:(NSMutableArray *)dictList{
    if (dictList.count==0||dictList==NULL) {
        if (self.yenum > 1) {
            self.HUD.hidden = YES;
            self.yebean = nil;
        }else{
            [self loadData];
        }
    }else{
        self.yebean = dictList[0];
    }
}

-(void)queryYiBaoYeFailed:(NSString *)error{
    self.HUD.hidden = YES;
    if (self.yenum > 1) {
        DMLog(@"医保余额数据请求不到！");
    }else{
        [self loadData];
    }
}

#pragma mark - 加载医保消费数据
-(void)loadYBData{
    self.num = self.num + 1;
    DMLog(@"请求次数：%d",self.num);
    NSString *tradecode = @"30008";
    NSString *shbzh = @"e10adc3949ba59abbe56e057f20f883ez";
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self showLoadingUI];
    [self.serviceBL queryYBCostListWith:shbzh andyear:self.year andpageNo:self.pageNo andpageSize:PAGE_SIZE andAccess_Token:access_token andTradeCode:tradecode];
}

#pragma mark - 医保消费记录查询接口回调
-(void)queryYBCostSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    if (dictList.count==0||dictList==NULL) {
        if (self.num > 1) {
            self.tishi = @"nodata";
            self.hasData = NO;
            [self setupUI];
        }else{
            [self showLoadingUI];
            [self loadYBData];
        }
    }else{
        self.dataList = dictList;
        self.tishi = @"hasdata";
        self.hasData = YES;
        [self setupUI];
    }
}

-(void)queryYBCostFailed:(NSString *)error{
    self.HUD.hidden = YES;
    long code = [error longLongValue];
    if (self.num > 1) {
        if (code==1001){
            self.tishi = @"nodata";
            self.hasData = NO;
            [self setupUI];
        }else if (code==5001 ||code==5002) {
            self.tishi = @"shixiao";
            self.hasData = NO;
            [self setupUI];
        }else{
            if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
                self.tishi = @"noweb";
                self.hasData = NO;
                [self setupUI];
            }else{
                self.tishi = @"busy";
                self.hasData = NO;
                [self setupUI];
            }
        }
    }else{
        [self showLoadingUI];
        [self loadYBData];
    }
}

#pragma mark - 初始化界面UI
- (void)setupUI
{
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    UIImageView *bgImg = [[UIImageView alloc] init];
    [self.view addSubview:bgImg];
    [bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
        if(kIsiPhoneX){
            make.top.equalTo(weakSelf.view.mas_top).offset(84);
        }else{
            make.top.equalTo(weakSelf.view.mas_top).offset(64);
        }
        
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@68);
    }];
    bgImg.image = [UIImage imageNamed:@"bg_line"];
    
    headurl = [[UIImageView alloc] init];
    [self.view addSubview:headurl];
    [headurl mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if(kIsiPhoneX){
            make.top.equalTo(weakSelf.view.mas_top).offset(96);
        }else{
            make.top.equalTo(weakSelf.view.mas_top).offset(76);
        }
        make.left.equalTo(weakSelf.view.mas_left).offset(15);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    NSString *encodedImageStr = [CoreArchive strForKey:LOGIN_USER_PNG];
    if ([Util IsStringNil:encodedImageStr]) {
        headurl.image = [UIImage imageNamed:@"img_touxiang"];
    }else{
        @try {
            NSData *encodeddata = [NSData dataFromBase64String:encodedImageStr];
            UIImage *encodedimage = [UIImage imageWithData:encodeddata];
            headurl.image = [Util circleImage:encodedimage withParam:0];
        } @catch (NSException *exception) {
            headurl.image = [UIImage imageNamed:@"img_touxiang"];
        }
    }
    
    namelb = [[UILabel alloc]init];
    [self.view addSubview:namelb];
    [namelb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if(kIsiPhoneX){
            make.top.equalTo(weakSelf.view.mas_top).offset(108);
        }else{
            make.top.equalTo(weakSelf.view.mas_top).offset(88);
        }
        make.left.equalTo(headurl.mas_right).offset(10);
        make.height.equalTo(@20);
    }];
    NSString *name = [CoreArchive strForKey:LOGIN_NAME];
    namelb.text = name;
    namelb.textColor = [UIColor colorWithHex:0x333333];
    namelb.font = [UIFont systemFontOfSize:16];
    
    
    cardlb = [[UILabel alloc]init];
    [self.view addSubview:cardlb];
    [cardlb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if(kIsiPhoneX){
            make.top.equalTo(weakSelf.view.mas_top).offset(110);
        }else{
            make.top.equalTo(weakSelf.view.mas_top).offset(90);
        }
        make.left.equalTo(namelb.mas_right).offset(15);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@15);
    }];
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    if ([type isEqualToString:@"1"]) {
        NSString *cardnum = [CoreArchive strForKey:LOGIN_CARD_NUM];
        cardlb.text = [NSString stringWithFormat:@"卡号:%@",[Util HeadStr:cardnum WithNum:0]];
    }else{
        cardlb.text = @"";
    }
    cardlb.textColor = [UIColor colorWithHex:0x999999];
    cardlb.font = [UIFont systemFontOfSize:13];
    
    UIImageView *accountview = [[UIImageView alloc]init];
    [self.view  addSubview:accountview];
    [accountview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgImg.mas_bottom);
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@40);
    }];
    accountview.backgroundColor = [UIColor whiteColor];
    
    UILabel *account = [[UILabel alloc] init];
    [self.view  addSubview:account];
    [account mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountview.mas_top).offset(10);
        make.left.equalTo(weakSelf.view.mas_left).offset(15);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
    }];
    account.textColor = [UIColor colorWithHex:0x333333];
    account.text = @"医保账户余额:";
    account.font = [UIFont systemFontOfSize:14];
    
    accountlb = [[UILabel alloc] init];
    [self.view  addSubview:accountlb];
    [accountlb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountview.mas_top).offset(10);
        make.right.equalTo(weakSelf.view.mas_right).offset(-15);
        make.width.equalTo(@120);
        make.height.equalTo(@20);
    }];
    accountlb.textAlignment = NSTextAlignmentRight;
    accountlb.textColor = [UIColor colorWithHex:0x333333];
    NSString *ye;
    if (nil==self.yebean) {
        ye = @"--";
    }else{
        ye = nil==self.yebean.zhye?@"--":self.yebean.zhye;
    }
    accountlb.text = [NSString stringWithFormat:@"%@",ye];
    accountlb.font = [UIFont systemFontOfSize:14];
    
    
    UIImageView *bgview = [[UIImageView alloc]init];
    [self.view  addSubview:bgview];
    [bgview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(accountview.mas_bottom).offset(13);
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@40);
    }];
    bgview.backgroundColor = [UIColor whiteColor];
    
    UILabel *year = [[UILabel alloc] init];
    [self.view  addSubview:year];
    [year mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgview.mas_top).offset(10);
        make.centerX.equalTo(weakSelf.view.mas_centerX).offset(-25);  //-35
        make.width.equalTo(@110);   //130
        make.height.equalTo(@20);
    }];
    year.textColor = [UIColor colorWithHex:0x666666];
    year.text = @"当前选择年度:";
    year.font = [UIFont systemFontOfSize:15];
    
    yearbtn = [[UIButton alloc]init];
    [self.view addSubview:yearbtn];
    [yearbtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(bgview.mas_top).offset(8);
        make.centerX.equalTo(year.mas_right).offset(10);  //20
        make.width.equalTo(@70);
        make.height.equalTo(@25);
    }];
    yearbtn.titleLabel.font = [UIFont systemFontOfSize:15];
    [yearbtn setTitle:self.year forState:UIControlStateNormal];
    [yearbtn setBackgroundImage:[UIImage imageNamed:@"arrow_down"] forState:UIControlStateNormal];
    [yearbtn setTitleColor:[UIColor colorWithHex:0xF8AB26] forState:UIControlStateNormal];
    [yearbtn addTarget:self action:@selector(yearBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    if(kIsiPhoneX){
        ybinfotableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 265, SCREEN_WIDTH, SCREEN_HEIGHT-265) style:UITableViewStyleGrouped];
    }else{
        ybinfotableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 225, SCREEN_WIDTH, SCREEN_HEIGHT-225) style:UITableViewStyleGrouped];
    }
    
    [self.view addSubview:ybinfotableview];
    ybinfotableview.delegate = self;
    ybinfotableview.dataSource = self;
    ybinfotableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    ybinfotableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    ybinfotableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, ybinfotableview.bounds.size.width, 0.01f)];
    
    [ybinfotableview registerNib:[UINib nibWithNibName:@"YBCostCell" bundle:nil] forCellReuseIdentifier:@"YBCostCell"];
    [ybinfotableview registerNib:[UINib nibWithNibName:@"TiShiCell" bundle:nil] forCellReuseIdentifier:@"TiShiCell"];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_hasData) {
         return self.dataList.count;
    }else{
        return 1;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    // 设置间距为0.1时，间距为最小值
    return 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 40.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_hasData) {
        return 60;
    }else{
        return 400;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasData) {
        YBCostCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YBCostCell"];
        if ( nil == cell ){
            cell = [[YBCostCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YBCostCell"];
        }
        if (self.dataList.count==1) {
            if (indexPath.row==0) {
                cell.BgImg.image = [UIImage imageNamed:@"bg_tab_top"];
            }
            [cell ConfigCellWithYiBaoCostBean:self.dataList[indexPath.row]];
        }else{
            if (indexPath.row==0) {
                cell.BgImg.image = [UIImage imageNamed:@"bg_tab_top2"];
            }else if (indexPath.row==self.dataList.count-1) {
                cell.BgImg.image = [UIImage imageNamed:@"bg_tab4"];
            }else{
                cell.BgImg.image = [UIImage imageNamed:@"bg_tab_mid"];
            }
            [cell ConfigCellWithYiBaoCostBean:self.dataList[indexPath.row]];
        }
        return cell;
    }else{
        TiShiCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TiShiCell"];
        if ( nil == cell ){
            cell = [[TiShiCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TiShiCell"];
        }
        if ([self.tishi isEqualToString:@"nodata"]) {
            cell.TSImg.image = [UIImage imageNamed:@"img_nodata"];
            cell.TSlb.text = @"没有数据，请重新选择";
            cell.refreshbtn.hidden = YES;
            cell.Tsbg.image = [UIImage imageNamed:@"bg_tab7c"];
            
            return cell;
        }else if ([self.tishi isEqualToString:@"noweb"]) {
            cell.TSImg.image = [UIImage imageNamed:@"img_noweb"];
            cell.TSlb.text = @"当前网络不可用，请检查网络设置";
            cell.refreshbtn.hidden = NO;
            cell.Tsbg.image = [UIImage imageNamed:@"bg_tab7c"];
            [cell.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }else if ([self.tishi isEqualToString:@"shixiao"]) {
            cell.TSImg.image = [UIImage imageNamed:@"img_busy"];
            cell.TSlb.text = @"找不到您的登录信息，请重新登录试试~";
            cell.refreshbtn.hidden = YES;
                
            return cell;
        }else{
            cell.TSImg.image = [UIImage imageNamed:@"img_busy"];
            cell.TSlb.text = @"服务暂不可用，请稍后重试";
            cell.refreshbtn.hidden = NO;
            cell.Tsbg.image = [UIImage imageNamed:@"bg_tab7c"];
            [cell.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40)];
    UILabel *footerLab = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 40)];
    footerLab.font = [UIFont systemFontOfSize:12];
    footerLab.textColor = [UIColor colorWithHex:0x999999];
    footerLab.numberOfLines = 0;
    footerLab.text = @"备注：医保费用报销累计以医保年度为准，医保年度为当年7月1日至次年6月30日。";
    
    NSMutableAttributedString * attributedString1 = [[NSMutableAttributedString alloc] initWithString:footerLab.text];
    NSMutableParagraphStyle * paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle1 setLineSpacing:5.0];
    [attributedString1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, [footerLab.text length])];
    [footerLab setAttributedText:attributedString1];
    
    [footerView addSubview:footerLab];
    return footerView;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    if (_hasData) {
        YiBaoCostBean *bean = self.dataList[indexPath.row];
        if ([bean.ybxflx isEqualToString:@"1"]) {
            MZVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MZVC"];
            [VC setValue:bean.ybxfdh forKey:@"ce"];
            [self.navigationController pushViewController:VC animated:YES];
        }else{
            ZYDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ZYDetailVC"];
            [VC setValue:bean.ybxfdh forKey:@"ce"];
            [VC setValue:bean.jscxh forKey:@"jscxh"];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }
}

#pragma mark - 年份按钮点击事件
- (void)yearBtnClicked:(UIButton *)sender {
    
    NSLog(@"选择年份按钮被点击");
    
    CLAlertView *bottomView = [CLAlertView globeBottomView];
    self.bottomView = bottomView;
    bottomView.delegate = self;
    bottomView.hlightButton = self.chooseno;
    bottomView.titleArray = self.datearray;
    bottomView.title = @"请选择年份";
    [bottomView show];
}

- (void)globeBottomViewButtonClick:(NSInteger)index{
    self.chooseno = (int)index;
    self.year = self.datearray[self.chooseno];
    [yearbtn setTitle:self.year forState:UIControlStateNormal];
    [self afn];
}

#pragma mark - 重新刷新按钮事件
-(void)refreshUI{
    [self afn];
}

@end
