//
//  YLJAccountVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "YLJAccountVC.h"
#import "ServiceBL.h"
#import "YLJAccountCell.h"
#import "TiShiCell.h"
#import "LoginVC.h"

@interface YLJAccountVC ()<UITableViewDelegate,UITableViewDataSource,ServiceBLDelegate>

@property (nonatomic, strong)   NSMutableArray  *dataList;
@property(nonatomic, strong)      ServiceBL     *serviceBL;
@property(nonatomic, strong)   MBProgressHUD    *HUD;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@property (nonatomic, strong)     NSString      *tishi;
@property       BOOL    hasData;
@property        int      num;

@end

@implementation YLJAccountVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"养老个账";
    HIDE_BACK_TITLE;
    [self initData];
    [self afn];
}

#pragma mark -  初始化数据
-(void)initData{
    self.dataList = [[NSMutableArray alloc]initWithCapacity:0];
    self.serviceBL = [ServiceBL sharedManager];
    self.serviceBL.delegate = self;
    self.tishi = @"nodata";
    self.hasData = NO;
    self.num = 0;
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
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

#pragma mark - 请求养老金账户
- (void)loadData{
    self.num = self.num + 1;
    DMLog(@"请求次数：%d",self.num);
    NSString *year = @"";
    NSString *tradecode = @"30003";
    NSString *shbzh = @"e10adc3949ba59abbe56e057f20f883ez";
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self showLoadingUI];
    [self.serviceBL queryYLAccountWithYear:year andshbzh:shbzh andAccess_Token:access_token andTradeCode:tradecode];
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

#pragma mark - 养老账户查询接口回调
-(void)queryYLAccountSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    if (dictList.count==0||dictList==NULL) {
        if (self.num > 1) {
            self.tishi = @"nodata";
            self.hasData = NO;
            [self setupUI];
        }else{
            [self showLoadingUI];
            [self loadData];
        }
    }else{
        self.dataList = dictList;
        self.tishi = @"hasdata";
        self.hasData = YES;
        [self setupUI];
    }
}

-(void)queryYLAccountFailed:(NSString *)error{
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
        [self loadData];
    }
}

#pragma mark - 初始化界面UI布局
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
        make.width.equalTo(@41);
        make.height.equalTo(@41);
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
        make.height.equalTo(@18);
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
        make.left.equalTo(namelb.mas_right).offset(10);
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
    
    if(kIsiPhoneX){
        accounttableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 152, SCREEN_WIDTH, SCREEN_HEIGHT-152) style:UITableViewStyleGrouped];
    }else{
        accounttableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 132, SCREEN_WIDTH, SCREEN_HEIGHT-132) style:UITableViewStyleGrouped];
    }
    
    [self.view addSubview:accounttableview];
    accounttableview.delegate = self;
    accounttableview.dataSource = self;
    accounttableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    accounttableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    accounttableview.contentInset = UIEdgeInsetsMake(-25, 0, 0, 0); // 减小tableview在grouped形势下的顶部留白问题
    
    [accounttableview registerNib:[UINib nibWithNibName:@"YLJAccountCell" bundle:nil] forCellReuseIdentifier:@"YLJAccountCell"];
    [accounttableview registerNib:[UINib nibWithNibName:@"TiShiCell" bundle:nil] forCellReuseIdentifier:@"TiShiCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_hasData) {
        return self.dataList.count;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_hasData) {
        return 170;
    }else{
        return 400;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_hasData) {
        return 45.0;
    }else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasData) {
        YLJAccountCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YLJAccountCell"];
        if ( nil == cell ){
            cell = [[YLJAccountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YLJAccountCell"];
        }
        [cell ConfigCellWithYLAccountBean:self.dataList[indexPath.section]];
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
            
            return cell;
        }else if ([self.tishi isEqualToString:@"noweb"]) {
            cell.TSImg.image = [UIImage imageNamed:@"img_noweb"];
            cell.TSlb.text = @"当前网络不可用，请检查网络设置";
            cell.refreshbtn.hidden = NO;
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
            [cell.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            return cell;
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (_hasData) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 45)];
        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-30, 35)];
        bgImg.image = [UIImage imageNamed:@"bg_title"];
        
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 20, 200, 20)];
        headerLab.font = [UIFont systemFontOfSize:15];
        YLAccountBean *bean = self.dataList[section];
        NSString *nd = bean.ffnd;
        headerLab.text = [NSString stringWithFormat:@"%@年度养老保险个人账户",nd];
        headerLab.textColor = [UIColor colorWithHex:0xfdb731];
        
        UILabel *Lab = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-100, 20, 70, 14)];
        Lab.font = [UIFont systemFontOfSize:12];
        Lab.textAlignment = NSTextAlignmentRight;
        Lab.text = @"金额单位：元";
        Lab.textColor = [UIColor colorWithHex:0x666666];
        
        [headerView  addSubview:bgImg];
        [headerView  addSubview:headerLab];
        
        return headerView;
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 重新刷新按钮事件
-(void)refreshUI{
    [self afn];
}

@end
