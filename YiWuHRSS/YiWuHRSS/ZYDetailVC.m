//
//  ZYDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ZYDetailVC.h"
#import "ServiceBL.h"
#import "YBDetailCellOne.h"
#import "YBDetailCellFour.h"
#import "YBDetailCellFive.h"
#import "TiShiCell.h"
#import "LoginVC.h"


@interface ZYDetailVC ()<UITableViewDelegate,UITableViewDataSource,ServiceBLDelegate>

@property (nonatomic, strong)   NSMutableArray  *dataList;
@property (nonatomic, strong)     ServiceBL     *serviceBL;
@property(nonatomic, strong)   MBProgressHUD    *HUD;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@property (nonatomic, strong)     NSString      *tishi;
@property       BOOL    hasData;
@property        int      num;

@end

@implementation ZYDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"住院详情";
    HIDE_BACK_TITLE;
    [self initData];
    [self afn];
}

#pragma mark - 初始化数据
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

#pragma mark - 监测网络状态
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

#pragma mark - 加载诊疗数据
- (void)loadData{
    self.num = self.num + 1;
    DMLog(@"ye请求次数：%d",self.num);
    NSString *tradecode = @"30010";
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [self showLoadingUI];
    [self.serviceBL queryZYWith:self.ce andxfType:@"2" andAccess_Token:access_token andTradeCode:tradecode andJSCXH:self.jscxh];
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

#pragma mark -  住院详情查询接口回调
-(void)queryZYSucceed:(NSMutableArray *)dictList{
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

-(void)queryZYFailed:(NSString *)error{
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

#pragma mark - 初始化界面UI
- (void)setupUI
{
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    zytableview = [[UITableView alloc]initWithFrame:CGRectMake(0, 35, SCREEN_WIDTH, SCREEN_HEIGHT-35) style:UITableViewStyleGrouped];
    [self.view addSubview:zytableview];
    zytableview.delegate = self;
    zytableview.dataSource = self;
    zytableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    zytableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    [zytableview registerNib:[UINib nibWithNibName:@"YBDetailCellOne" bundle:nil] forCellReuseIdentifier:@"YBDetailCellOne"];
    [zytableview registerNib:[UINib nibWithNibName:@"YBDetailCellFive" bundle:nil] forCellReuseIdentifier:@"YBDetailCellFive"];
    [zytableview registerNib:[UINib nibWithNibName:@"YBDetailCellFour" bundle:nil] forCellReuseIdentifier:@"YBDetailCellFour"];
    [zytableview registerNib:[UINib nibWithNibName:@"TiShiCell" bundle:nil] forCellReuseIdentifier:@"TiShiCell"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_hasData) {
        if (section==0) {
            return 1;
        }else if (section==1){
            return self.dataList.count;
        }else{
            return 1;
        }
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_hasData) {
        if (indexPath.section==0) {
            return 180;
        }else if (indexPath.section==1){
            return  220;
        }else{
            return 90;
        }
    }else{
        return 400;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if (_hasData) {
        return 3;
    }else{
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (_hasData) {
        return 35.0;
    }else{
        return 0.1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 15.0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (_hasData) {
        if (indexPath.section==0) {
            YBDetailCellOne *cell = [tableView dequeueReusableCellWithIdentifier:@"YBDetailCellOne"];
            if ( nil == cell ){
                cell = [[YBDetailCellOne alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YBDetailCellOne"];
            }
            [cell ConfigCellOneWithZYBean:self.dataList[0]];
            return cell;
        }else if (indexPath.section==1){
            YBDetailCellFive *cell = [tableView dequeueReusableCellWithIdentifier:@"YBDetailCellFive"];
            if ( nil == cell ){
                cell = [[YBDetailCellFive alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YBDetailCellFive"];
            }
            [cell ConfigCellWithZYBean:self.dataList[indexPath.row]];
            return cell;
            
        }else{
            YBDetailCellFour *cell = [tableView dequeueReusableCellWithIdentifier:@"YBDetailCellFour"];
            if ( nil == cell ){
                cell = [[YBDetailCellFour alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"YBDetailCellFour"];
            }
            [cell ConfigCellFourWithZYBean:self.dataList[0]];
            return cell;
        }
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
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 35)];
        UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(15, 0, SCREEN_WIDTH-30, 35)];
        bgImg.image = [UIImage imageNamed:@"bg_title"];
        
        UILabel *headerLab = [[UILabel alloc] initWithFrame:CGRectMake(40, 10, 100, 20)];
        headerLab.font = [UIFont systemFontOfSize:15];
        if (section==0) {
            headerLab.text = @"基本信息";
        }else if (section==1){
            headerLab.text = @"处方描述";
        }else{
            headerLab.text = @"结算明细";
        }
        headerLab.textColor = [UIColor colorWithHex:0xfdb731];
        
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

#pragma mark - 重新刷新按钮
-(void)refreshUI{
    [self afn];
}

@end
