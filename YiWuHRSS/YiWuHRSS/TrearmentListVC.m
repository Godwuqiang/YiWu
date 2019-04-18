//
//  TrearmentListVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "TrearmentListVC.h"
#import "TreatmentDetailTVC.h"
#import "ServiceBL.h"



@interface TrearmentListVC ()<UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate,ServiceBLDelegate>

// 数据
@property(nonatomic, strong)    NSMutableArray  *dataList;
@property(nonatomic, copy)      NSString        *seachKey;
@property(nonatomic, assign)    BOOL            isKeywords;
@property(nonatomic, strong)      ServiceBL     *serviceBL;
@property(nonatomic, assign)         int         pageNo;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

// 控件
@property(nonatomic, strong) MBProgressHUD    *HUD;

@end

@implementation TrearmentListVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"诊疗目录";
    HIDE_BACK_TITLE;
    [self initData];
    [self setupCoverView];
    [self afn];
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self setupNavigationBarStyle];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
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
            self.refreshbtn.hidden = NO;
            [self.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
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

#pragma mark - 初始化界面
- (void)initView{
    
    self.listtableview.dataSource = self;
    self.listtableview.delegate = self;
    [self.listtableview setSeparatorInset:UIEdgeInsetsZero];
    [self.listtableview setLayoutMargins:UIEdgeInsetsZero];
    self.listtableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.listtableview.tableFooterView = [[UIView alloc] init];
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

#pragma mark - 加载数据
-(void)loadData{
    [self showLoadingUI];
    [self.serviceBL  queryZhenLiaoListWith:self.seachKey andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30013"];
}

#pragma mark - 加载更多数据
-(void)loadMoreData{
    [self showLoadingUI];
    self.pageNo = self.pageNo+1;
    [self.serviceBL  queryZhenLiaoListWith:self.seachKey andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30013"];
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

#pragma mark - 药品目录查询接口回调
-(void)queryZhenLiaoListSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    // 结束刷新
    [self.listtableview.footer endRefreshing];
    
    if (self.pageNo==1) {
        if (dictList.count==0||dictList==NULL) {
//            [MBProgressHUD showError:@"暂无数据！"];
            self.contentview.hidden = NO;
            self.TSbg.image = [UIImage imageNamed:@"img_nodata"];
            self.TSlb.text = @"没有搜索到相关数据，换个条件试试吧~";
            self.refreshbtn.hidden = YES;
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

-(void)queryZhenLiaoListFailed:(NSString *)error{
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
            self.refreshbtn.hidden = NO;
            [self.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if (self.pageNo==1) {
                [self.dataList removeAllObjects];
                self.contentview.hidden = NO;
                self.TSbg.image = [UIImage imageNamed:@"img_busy"];
                self.TSlb.text = @"服务暂不可用，请稍后重试";
                self.refreshbtn.hidden = NO;
                [self.refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *ZLCell = @"ZLCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ZLCell];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ZLCell];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    [cell setSeparatorInset:UIEdgeInsetsZero];
    [cell setLayoutMargins:UIEdgeInsetsZero];
    
    // 获取模型数据
    ZLBean *bean = self.dataList[indexPath.row];
    // Configure the cell...
    if (nil==bean) {
        cell.textLabel.text = @"暂无数据";
    }else{
        cell.textLabel.text = nil==bean.zlxmmc?@"无":bean.zlxmmc;
    }
    cell.textLabel.textColor = [UIColor colorWithHex:0x333333];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    ZLBean *bean = self.dataList[indexPath.row];
    TreatmentDetailTVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"TreatmentDetailTVC"];
    [VC setValue:bean forKey:@"bean"];
    VC.hidesBottomBarWhenPushed = YES;
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
    self.Coverview.hidden = YES;
    return YES;
}

#pragma mark - 重新刷新按钮
-(void)refreshUI{
    [self afn];
}

#pragma mark - 点击遮罩层会隐藏遮罩层
- (void)CoverViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    [self.keywords resignFirstResponder];
    self.Coverview.hidden = YES;
}

#pragma mark - 搜索按钮
- (IBAction)Search:(id)sender {
    
    [self.keywords resignFirstResponder];
    self.Coverview.hidden = YES;
    self.isKeywords = YES;
    self.seachKey = self.keywords.text;
    self.pageNo=1;
    [self showLoadingUI];
    [self.serviceBL  queryZhenLiaoListWith:self.seachKey andpageNo:self.pageNo andpageSize:MAX_PAGE_COUNT andTradeCode:@"30013"];
}

@end
