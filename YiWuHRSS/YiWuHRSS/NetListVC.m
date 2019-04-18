//
//  NetListVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "NetListVC.h"
#import "NetDetailVC.h"
#import "CLAlertView.h"
#import "WebBL.h"
#import "NetPointCell.h"
#import "FixedPointCell.h"


#define paddingWidth1   10
#define paddingWidth2   35
#define paddingWidth3   40


@interface NetListVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,CLAlertViewDelegate,WebBLDelegate>

// 数据
@property(nonatomic, strong)    NSMutableArray  *dataList;
@property(nonatomic, copy)      NSString        *seachKey;
@property(nonatomic, strong)        WebBL       *webBL;
@property(nonatomic, assign)       int          pageNo;

@property (nonatomic, strong)   NSMutableArray  *datearray;
@property                             int       chooseno;
@property (nonatomic, strong)       NSString    *choosebank;

// 控件
@property(nonatomic, strong) MBProgressHUD    *HUD;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;


@end

@implementation NetListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"服务网点";
    HIDE_BACK_TITLE;
    [self initData];
    [self setupBankView];
    [self setupCoverView];
    [self afn];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:21.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

#pragma mark - 初始化数据
- (void)initData{
    self.dataList = [NSMutableArray array];
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
    self.pageNo = 1;
    self.keywords.delegate = self;
    self.seachKey = @"";
    self.chooseno = 0;
    self.choosebank = @"全部银行";
    
    self.datearray = [[NSMutableArray alloc] initWithCapacity:3];
    [self.datearray addObject:@"全部银行"];
    [self.datearray addObject:@"义乌农商银行"];
    [self.datearray addObject:@"浙江稠州商业银行"];
}

#pragma mark - 为选择银行View添加手势
- (void)setupBankView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bankViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.yhview addGestureRecognizer:singleTapRecognizer];
}

#pragma mark - 为遮盖层View添加手势
-(void)setupCoverView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CoverViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.Coverview addGestureRecognizer:singleTapRecognizer];
}

#pragma mark - 初始化界面
- (void)initView{
    
    self.Searchbtn.layer.cornerRadius = 8;
    self.Coverview.hidden = YES;
    self.listtableview.dataSource = self;
    self.listtableview.delegate = self;
    // 设置cell下划线靠左显示
    [self.listtableview setSeparatorInset:UIEdgeInsetsZero];
    [self.listtableview setLayoutMargins:UIEdgeInsetsZero];
    self.listtableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.listtableview.tableFooterView = [[UIView alloc] init];
    [self.listtableview registerNib:[UINib nibWithNibName:@"NetPointCell" bundle:nil] forCellReuseIdentifier:@"NetPointCell"];
    [self.listtableview registerNib:[UINib nibWithNibName:@"FixedPointCell" bundle:nil] forCellReuseIdentifier:@"FixedPointCell"];
    
    // 上拉加载更多
    self.listtableview.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.contentview.hidden = YES;
}

#pragma mark - 监听网络请求服务网点数据
-(void)afn{
    //1.创建网络状态监测管理者
//    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"3G|4G|WIFI");
            [self initView];
            [self loadData];
        }else{
            DMLog(@"没有网络");
            self.contentview.hidden = NO;
            self.Coverview.hidden = YES;
            self.TSbg.image = [UIImage imageNamed:@"img_noweb"];
            self.TSlb.text = @"当前网络不可用，请检查网络设置";
            self.TSbtn.hidden = NO;
            [self.TSbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark - 请求服务网点数据
-(void)loadData{
    NSString *bankMark =  [[NSString alloc] init];
    if ([self.choosebank isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([self.choosebank isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:@"" isResetPassword:@""];
}

#pragma mark - 加载更多数据
-(void)loadMoreData{
    NSString *bankMark = [[NSString alloc] init];
    if ([self.choosebank isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([self.choosebank isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    self.pageNo = self.pageNo+1;
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:@"" isResetPassword:@""];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}


#pragma mark - 服务网点查询接口回调
-(void)queryNetWorkPointSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    // 结束刷新
    [self.listtableview.footer endRefreshing];
    if (self.pageNo==1) {
        if (dictList.count==0) {
            self.contentview.hidden = NO;
            self.TSbg.image = [UIImage imageNamed:@"img_nodata"];
            self.TSlb.text = @"没有搜索到相关数据，换个条件试试吧~";
            self.TSbtn.hidden = YES;
            return;
        }else{
            [self.dataList removeAllObjects];
            self.dataList = dictList;
            self.listtableview.hidden = NO;
            self.searchImg.hidden = NO;
            self.keywords.hidden = NO;
            self.searchBg.hidden = NO;
            self.contentview.hidden = YES;
            [self.listtableview reloadData];
        }
    }else{
        if (dictList.count==0) {
            [MBProgressHUD showError:@"没有更多数据了！"];
            self.contentview.hidden = YES;
            return;
        }else{
            [self.dataList addObjectsFromArray:dictList];
            self.listtableview.hidden = NO;
            self.searchImg.hidden = NO;
            self.keywords.hidden = NO;
            self.searchBg.hidden = NO;
            self.contentview.hidden = YES;
            [self.listtableview reloadData];
        }
    }
}

-(void)queryNetWorkPointFailed:(NSString *)error{
    // 结束刷新
    self.HUD.hidden = YES;
    [self.listtableview.footer endRefreshing];
    
    int iStatus = error.intValue;
    if (iStatus==2000) {
        [MBProgressHUD showError:@"参数不合法"];
    }else{
        if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
            self.contentview.hidden = NO;
            self.TSbg.image = [UIImage imageNamed:@"img_noweb"];
            self.TSlb.text = @"当前网络不可用，请检查网络设置";
            self.TSbtn.hidden = NO;
            [self.TSbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if (self.pageNo==1) {
                [self.dataList removeAllObjects];
                self.contentview.hidden = NO;
                self.TSbg.image = [UIImage imageNamed:@"img_busy"];
                self.TSlb.text = @"服务暂不可用，请稍后重试";
                self.TSbtn.hidden = NO;
                [self.TSbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    NetPointBean *bean = self.dataList[indexPath.row];
    NSString *tp = bean.ismaked;
    if ([tp isEqualToString:@"1"]) {
        return 80;
    }else{
        return 75;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NetPointBean *bean = self.dataList[indexPath.row];
    NSString *tp = bean.ismaked;
    if ([tp isEqualToString:@"1"]) {
        NetPointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetPointCell"];
        if ( nil == cell ){
            cell = [[NetPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NetPointCell"];
        }
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
        if (nil==bean) {
            cell.Name.text = @"暂无数据";
            cell.Address.text = @"暂无数据";
        }else{
            cell.Name.text = nil==bean.branchnmae?@"无":bean.branchnmae;
            cell.Address.text = nil==bean.address?@"无":bean.address;
        }
        
        //设置边缘弯曲角度
        cell.Type.hidden = NO;
        cell.Type.layer.cornerRadius = 5;
        cell.Type.clipsToBounds = YES;
        
        if ([Util IsStringNil:bean.distance]) {
            cell.addImg.hidden = YES;
            cell.Jl.hidden = YES;
        }else{
            if ([Util IsStringNil:bean.jingdu]||[Util IsStringNil:bean.weidu]) { // 没有经纬度
                cell.addImg.hidden = YES;
                cell.Jl.hidden = YES;
            }else{
                cell.addImg.hidden = NO;
                cell.Jl.hidden = NO;
                double distance = [bean.distance doubleValue];
                if (distance>999) {
                    cell.Jl.text = @">999km";
                }else if (distance<0.1){
                    cell.Jl.text = @"<0.1km";
                }else{
                    cell.Jl.text = [NSString stringWithFormat: @"距离%.1lfkm", distance];
                }
            }
        }
        
        return cell;
    }else{
        FixedPointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FixedPointCell"];
        if ( nil == cell ){
            cell = [[FixedPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FixedPointCell"];
        }
        [cell setSeparatorInset:UIEdgeInsetsZero];
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
        if (nil==bean) {
            cell.Jgname.text = @"暂无数据";
            cell.Jgadd.text = @"暂无数据";
            cell.addImg.hidden = YES;
            cell.Jl.hidden = YES;
        }else{
            cell.Jgname.text = nil==bean.branchnmae?@"无":bean.branchnmae;
            cell.Jgadd.text = nil==bean.address?@"无":bean.address;
            if ([Util IsStringNil:bean.distance]) {
                cell.addImg.hidden = YES;
                cell.Jl.hidden = YES;
            }else{
                if ([Util IsStringNil:bean.jingdu]||[Util IsStringNil:bean.weidu]) { // 没有经纬度
                    cell.addImg.hidden = YES;
                    cell.Jl.hidden = YES;
                }else{
                    cell.addImg.hidden = NO;
                    cell.Jl.hidden = NO;
                    double distance = [bean.distance doubleValue];
                    if (distance>999) {
                        cell.Jl.text = @">999km";
                    }else if (distance<0.1){
                        cell.Jl.text = @"<0.1km";
                    }else{
                        cell.Jl.text = [NSString stringWithFormat: @"距离%.1lfkm", distance];
                    }
                }
            }
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NetPointBean *bean = self.dataList[indexPath.row];
    NetDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"NetDetailVC"];
    [VC setValue:bean forKey:@"bean"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    self.Coverview.hidden = NO;
    self.searchImg.hidden = NO;
    return YES;
}

#pragma mark - 点击Return键的时候，（标志着编辑已经结束了）
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.seachKey = self.keywords.text;
    self.pageNo=1;
    self.Coverview.hidden = YES;
    
    return YES;
}

#pragma mark - 重新刷新按钮点击事件
-(void)refreshUI{
    [self afn];
}

#pragma mark - 选择银行按钮
- (void)bankViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    CLAlertView *bottomView = [CLAlertView globeBottomView];
    bottomView.delegate = self;
    bottomView.hlightButton = self.chooseno;
    bottomView.titleArray = self.datearray;
    bottomView.title = @"请选择银行";
    [bottomView show];
}

#pragma mark - 点击遮罩层会隐藏遮罩层
- (void)CoverViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    [self.keywords resignFirstResponder];
    self.Coverview.hidden = YES;
}

- (void)globeBottomViewButtonClick:(NSInteger)index{
    self.chooseno = (int)index;
    self.choosebank = self.datearray[self.chooseno];
    self.bank.text = self.choosebank;

    [self loadbankdata];
}

#pragma mark - 选择银行后请求数据
-(void)loadbankdata{
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"3G|4G|WIFI");
            [self initView];
            [self LoadBankData];
        }else{
            DMLog(@"没有网络");
            self.contentview.hidden = NO;
            self.TSbg.image = [UIImage imageNamed:@"img_noweb"];
            self.TSlb.text = @"当前网络不可用，请检查网络设置";
            self.TSbtn.hidden = NO;
            [self.TSbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

-(void)LoadBankData{
    self.pageNo=1;
    
    NSString *bankMark = [[NSString alloc] init];
    if ([self.choosebank isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([self.choosebank isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:@"" isResetPassword:@""];
}

#pragma mark - 搜索按钮
- (IBAction)Search:(id)sender {
    NSString *bankMark;
    if ([self.choosebank isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([self.choosebank isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    [self showLoadingUI];
    self.Coverview.hidden =YES;
    self.seachKey = self.keywords.text;
    [self.keywords resignFirstResponder];
    
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:@"" isResetPassword:@""];
}


@end
