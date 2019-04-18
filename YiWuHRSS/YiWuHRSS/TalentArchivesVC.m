//
//  TalentArchivesVC.m
//  YiWuHRSS
//
//  Created by 大白 on 2019/4/9.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import "TalentArchivesVC.h"
#import "TalentArchivesCell.h"

@interface TalentArchivesVC ()<UITableViewDelegate,UITableViewDataSource>
@property (nonatomic, strong)   NSMutableDictionary  *dataList;
@property (nonatomic, strong)   MBProgressHUD  *HUD;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation TalentArchivesVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"人才档案";
    HIDE_BACK_TITLE;
    [self afn];
    
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
//    NSString *shbzh = @"e10adc3949ba59abbe56e057f20f883ez";
//    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self showLoadingUI];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    NSString *url = [NSString stringWithFormat:@"%@/shebao/executeTalentArchives",HOST_TEST];
    [HttpHelper post:url params:param success:^(id responseObj) {
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        if([dictData[@"resultCode"] integerValue]==200){
            self.dataList =[[NSMutableDictionary alloc]initWithDictionary:dictData[@"data"]];
            [self setupUI];
        }else{
            [self setupUI];
        }
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        [self setupUI];
    }];
//    [self.serviceBL queryCanBaoInfoWith:shbzh andAccess_Token:access_token andTradeCode:@"30001"];
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

#pragma mark - 初始化界面UI
- (void)setupUI
{
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    
    bgImg = [[UIImageView alloc] init];
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
    NSString *name = [CoreArchive strForKey:LOGIN_NAME];
    namelb.text = name;
    namelb.textAlignment = NSTextAlignmentLeft;
    namelb.textColor = [UIColor colorWithHex:0x333333];
    namelb.font = [UIFont systemFontOfSize:16];
    [self.view addSubview:namelb];
    [namelb mas_makeConstraints:^(MASConstraintMaker *make) {
        
        if(kIsiPhoneX){
            make.top.equalTo(weakSelf.view.mas_top).offset(108);
        }else{
            make.top.equalTo(weakSelf.view.mas_top).offset(88);
        }
        make.left.equalTo(headurl.mas_right).offset(10);
        make.height.equalTo(@18);
        make.width.offset(kRatio_Scale_375(80));
    }];

    
    
    cardlb = [[UILabel alloc]init];
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    if ([type isEqualToString:@"1"]) {
        NSString *cardnum = [CoreArchive strForKey:LOGIN_CARD_NUM];
        cardlb.text = [NSString stringWithFormat:@"卡号:%@",[Util HeadStr:cardnum WithNum:0]];
    }else{
        cardlb.text = @"";
    }
    cardlb.textAlignment = NSTextAlignmentLeft;
    cardlb.textColor = [UIColor colorWithHex:0x999999];
    cardlb.font = [UIFont systemFontOfSize:13];
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

    if(kIsiPhoneX){
        cbinfotableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 155, SCREEN_WIDTH, SCREEN_HEIGHT-155) style:UITableViewStyleGrouped];
    }else{
        cbinfotableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 135, SCREEN_WIDTH, SCREEN_HEIGHT-135) style:UITableViewStyleGrouped];
    }
    
    [self.view addSubview:cbinfotableview];
    cbinfotableview.delegate = self;
    cbinfotableview.dataSource = self;
    cbinfotableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    cbinfotableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    cbinfotableview.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, cbinfotableview.bounds.size.width, 0.01f)];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return kRatio_Scale_375(100);
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (section==0) {
        return 10.0;
    }else{
        return 50.0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TalentArchivesCell *cell  = [TalentArchivesCell createCellWithTableView:tableView];
    if (self.dataList) {
        NSDictionary *dic= self.dataList[@"talnetList"][0];
        cell.state = dic[@"dazt"] ?dic[@"dazt"] :@"";
        cell.arriveTime = dic[@"ddsj"] ?  dic[@"ddsj"] :@"";
        cell.leaveTime = dic[@"zcsj"] ? dic[@"zcsj"] : @"";
    }
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
    UIImageView *Img = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-30, 35)];
    Img.image = [UIImage imageNamed:@"bg_title"];
    
    UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 25, 100, 20)];
    headerLab.font = [UIFont systemFontOfSize:15];
    if (section==0) {
        headerLab.text = @"档案管理信息";
    }else{
        headerLab.text = @"参保险种";
    }
    headerLab.textColor = [UIColor colorWithHex:0xfdb731];
    
    [headerView  addSubview:Img];
    [headerView  addSubview:headerLab];
    
    return headerView;
}



@end
