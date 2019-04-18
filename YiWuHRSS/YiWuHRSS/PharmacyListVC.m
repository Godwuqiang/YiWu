//
//  PharmacyListVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "PharmacyListVC.h"
#import "PharmacyDetailVC.h"
#import "ServiceBL.h"
#import "FixedPointCell.h"


@interface PharmacyListVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ServiceBLDelegate>

// 数据
@property(nonatomic, strong)    NSMutableArray  *dataList;
@property(nonatomic, copy)      NSString        *seachKey;
@property(nonatomic, assign)    BOOL            isKeywords;
@property(nonatomic, strong)      ServiceBL     *serviceBL;
@property(nonatomic, assign)       int           pageNo;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

// 控件
@property(nonatomic, strong)   MBProgressHUD    *HUD;


@end

@implementation PharmacyListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"定点药店";
    HIDE_BACK_TITLE;
    [self initData];
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
    self.serviceBL = [ServiceBL sharedManager];
    self.serviceBL.delegate = self;
    self.pageNo = 1;
    self.isKeywords = NO;
    self.keywords.delegate = self;
    self.seachKey = @"";
}

#pragma mark - 初始化UI
- (void)initView{
    self.listtableview.dataSource = self;
    self.listtableview.delegate = self;
    // 设置cell下划线靠左显示
    [self.listtableview setSeparatorInset:UIEdgeInsetsZero];
    [self.listtableview setLayoutMargins:UIEdgeInsetsZero];
    self.listtableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.listtableview.tableFooterView = [[UIView alloc] init];
    [self.listtableview registerNib:[UINib nibWithNibName:@"FixedPointCell" bundle:nil] forCellReuseIdentifier:@"FixedPointCell"];
    
    // 上拉加载更多
    self.listtableview.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    self.contentview.hidden = YES;
    self.Coverview.hidden = YES;
}

#pragma mark - 为遮盖层View添加手势
-(void)setupCoverView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CoverViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.Coverview addGestureRecognizer:singleTapRecognizer];
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

#pragma mark - 加载数据
-(void)loadData{
    [self showLoadingUI];
    [self.serviceBL queryDingDianYaoWith:self.seachKey andtype:@"2" andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30014"];
}

#pragma mark - 加载更多数据
-(void)loadMoreData{
    [self showLoadingUI];
    self.pageNo = self.pageNo+1;
    [self.serviceBL queryDingDianYaoWith:self.seachKey andtype:@"2" andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30014"];
}


/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 两点机构查询接口回调
-(void)queryDingDianYaoSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    // 结束刷新
    [self.listtableview.footer endRefreshing];
    if (self.pageNo==1) {
        if (dictList.count==0||dictList==NULL) {
            self.contentview.hidden = NO;
            self.TSbg.image = [UIImage imageNamed:@"img_nodata"];
            self.TSlb.text = @"没有搜索到相关数据，换个条件试试吧~";
            self.TSbtn.hidden = YES;
            return;
        }
    }else{
        if (dictList.count==0||dictList==NULL) {
            [MBProgressHUD showError:@"没有更多数据了！"];
            self.contentview.hidden = YES;
            return;
        }
    }
    
    if (self.isKeywords) {
        self.isKeywords = NO;
        [self.dataList removeAllObjects];
    }
    
    [self.dataList addObjectsFromArray:dictList];
    self.listtableview.hidden = NO;
    self.searchImg.hidden = NO;
    self.keywords.hidden = NO;
    self.searchBg.hidden = NO;
    self.contentview.hidden = YES;
    [self.listtableview reloadData];
   
}

-(void)queryDingDianYaoFailed:(NSString *)error{
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
                //        [self.listtableview reloadData];
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
    return 75;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    FixedPointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FixedPointCell"];
    if ( nil == cell ){
        cell = [[FixedPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FixedPointCell"];
    }
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    // 获取模型数据
    DDJGBean *bean = self.dataList[indexPath.row];
    // Configure the cell...
    if (nil==bean) {
        cell.Jgname.text = @"暂无数据";
        cell.Jgadd.text = @"暂无数据";
        cell.addImg.hidden = YES;
        cell.Jl.hidden = YES;
    }else{
        cell.Jgname.text = nil==bean.ddyljgmc?@"无":bean.ddyljgmc;
        cell.Jgadd.text = nil==bean.dz?@"无":bean.dz;
        if ([Util IsStringNil:bean.jl]) {
            cell.addImg.hidden = YES;
            cell.Jl.hidden = YES;
        }else{
            if ([Util IsStringNil:bean.jd] || [Util IsStringNil:bean.wd]) { // 没有经纬度
                cell.addImg.hidden = YES;
                cell.Jl.hidden = YES;
            }else{
                cell.addImg.hidden = NO;
                cell.Jl.hidden = NO;
                double distance = [bean.jl doubleValue];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    DDJGBean *bean = self.dataList[indexPath.row];
    PharmacyDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PharmacyDetailVC"];
    [VC setValue:bean forKey:@"bean"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 点击遮罩层会隐藏遮罩层
- (void)CoverViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    [self.keywords resignFirstResponder];
    self.Coverview.hidden = YES;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    self.Coverview.hidden = NO;
    self.searchImg.hidden = NO;
    return YES;
}

// 点击Return键的时候，（标志着编辑已经结束了）
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    self.Coverview.hidden = YES;
    self.searchImg.hidden = NO;
    return YES;
}

#pragma mark - 重新刷新按钮
-(void)refreshUI{
    [self afn];
}

#pragma mark - 搜索按钮
- (IBAction)Search:(id)sender {
    [self.keywords resignFirstResponder];
    self.Coverview.hidden = YES;
    self.isKeywords = YES;
    self.seachKey = self.keywords.text;
    self.pageNo=1;
    [self showLoadingUI];
    [self.serviceBL queryDingDianYaoWith:self.seachKey andtype:@"2" andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30011"];
}

@end
