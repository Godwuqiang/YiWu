//
//  MsgCenterVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/4/26.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "MsgCenterVC.h"
#import "NewsBL.h"
#import "MsgDetailVC.h"
#import "ContextDetailVC.h"
#import "FTPopOverMenu.h"
#import "NewsCell.h"


@interface MsgCenterVC ()<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate,UITextFieldDelegate,NewsBLDelegate>

// 数据
@property(nonatomic, strong)    NSMutableArray  *dataList;     // 数据数组
@property(nonatomic, strong)    NSMutableArray  *choosearray;  // 是否被选中数组
@property(nonatomic, strong)        NewsBL      *newsBL;
@property(nonatomic, assign)       int           pageNo;

@property      BOOL     isEdit;       // 是否处于批量删除状态
@property      BOOL     isAllRead;    // 是否全部已读
@property      BOOL     isAllChoose;  // 是否选择全部删除
@property      BOOL     hasMoreData;  // 是否已经加载完全部数据

@property (nonatomic, strong)   NSIndexPath  *beforeindexPath;   // 前一个右滑选中的cell
@property (nonatomic, strong)   NSIndexPath  *selectindexPath;   // 当前右滑选中的cell
@property      BOOL     isDelete;     // 是否右滑显示删除按钮

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

// 控件
@property (nonatomic, strong)   MBProgressHUD    *HUD;
@property (nonatomic, strong)      UIButton      *editBut;

@end

@implementation MsgCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"新闻通知";
    HIDE_BACK_TITLE;
    
    self.editBut = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editBut.frame = CGRectMake(0, 0, 40, 19);
    [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
    self.editBut.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.editBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editBut addTarget:self action:@selector(onNavButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editBut];
    self.editBut.hidden = YES;
    
    [self initData];
    [self initView];
    [self setAllChooseGuesture];
    [self registerSerive];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
    self.selectindexPath = nil;
    [self afn];
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

#pragma mark - 注册通知
-(void)registerSerive{
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(JPush:) name:@"JPUSH" object:nil];
}

-(void)JPush:(NSNotification*) notification{
    
    [self loadData];
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
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"JPUSH" object:nil];
}

#pragma mark - 初始化数据
- (void)initData{
    self.dataList = [NSMutableArray array];
    self.choosearray = [NSMutableArray array];
    self.newsBL = [NewsBL sharedManager];
    self.newsBL.delegate = self;
    self.pageNo = 1;
    self.isEdit = NO;
    self.isAllRead = NO;
    self.isAllChoose = NO;
    self.hasMoreData = YES;
    self.beforeindexPath = nil;
    self.selectindexPath = nil;
}

#pragma mark - 初始化界面
- (void)initView{
    self.listtableview.dataSource = self;
    self.listtableview.delegate = self;
    self.listtableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    // 设置cell下划线靠左显示
    [self.listtableview setSeparatorInset:UIEdgeInsetsZero];
    [self.listtableview setLayoutMargins:UIEdgeInsetsZero];
    self.listtableview.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.listtableview.tableFooterView = [[UIView alloc] init];
    [self.listtableview registerNib:[UINib nibWithNibName:@"NewsCell" bundle:nil] forCellReuseIdentifier:@"NewsCell"];
    
    // 下拉和上提刷新
    self.listtableview.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(loadData)];
    self.listtableview.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    // 在tableview上添加左右滑动手势
    UISwipeGestureRecognizer *leftSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(delete:)];
    leftSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [self.listtableview addGestureRecognizer:leftSwipeGestureRecognizer];
    
    UISwipeGestureRecognizer *rightSwipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(recover:)];
    rightSwipeGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [self.listtableview addGestureRecognizer:rightSwipeGestureRecognizer];
    
    self.contentview.hidden = YES;
}

#pragma mark - 全选VIEW添加手势
-(void)setAllChooseGuesture{
    //添加手势
    UITapGestureRecognizer * AllchossetapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AllChoose)];
    AllchossetapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [AllchossetapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Allselectview addGestureRecognizer:AllchossetapGesture];
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
            DMLog(@"3G|4G|wifi");
            [self showLoadingUI];
            [self loadData];
        }else{
            DMLog(@"未知");
            self.contentview.hidden = NO;
            self.Tsbg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            self.Tsbtn.hidden = NO;
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark - 下拉显示功能按钮
-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event {
    
    if (nil != self.selectindexPath) {
        self.beforeindexPath = self.selectindexPath;
        self.selectindexPath = nil;
        [self.listtableview reloadRowsAtIndexPaths:@[self.beforeindexPath] withRowAnimation:UITableViewRowAnimationNone];
    }
    
    if (_isEdit) {
        self.isEdit = NO;
        [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
        [self.editBut setTitle:@"" forState:UIControlStateNormal];
        [self.listtableview reloadData];
        self.bottomconstrains.constant = 0;
        
        [self.choosearray removeAllObjects];
        for (int i=0; i<self.dataList.count; i++) {
            [self.choosearray addObject:@"0"];
        }
    }else{
        [FTPopOverMenu showFromEvent:event
                       withMenuArray:@[@"全部已读",@"批量删除"]
                          imageArray:@[@"icon_message_read",@"icon_message_delete"]
                           doneBlock:^(NSInteger selectedIndex) {
                               if (selectedIndex==0) {   // 全部已读
                                   self.isAllRead = YES;
                                   [self SetNewsAllRead];
                                   self.bottomconstrains.constant = 0;
                               }else{       // 批量删除
                                   [self.editBut setImage:nil forState:UIControlStateNormal];
                                   [self.editBut setTitle:@"取消" forState:UIControlStateNormal];
                                   self.isEdit = YES;
                                   [self.listtableview reloadData];
                                   self.bottomconstrains.constant = 60;
                               }
                           } dismissBlock:^{
                               
                           }];
    }
}

#pragma mark - 全选VIEW
-(void)AllChoose{
    
    self.isAllChoose = !self.isAllChoose;
    if (self.isAllChoose) {
        self.Selectimg.image = [UIImage imageNamed:@"message_select_on"];
        [self.choosearray removeAllObjects];
        for (int i=0; i<self.dataList.count; i++) {
            [self.choosearray addObject:@"1"];
        }
    }else{
        self.Selectimg.image = [UIImage imageNamed:@"message_select"];
        [self.choosearray removeAllObjects];
        for (int i=0; i<self.dataList.count; i++) {
            [self.choosearray addObject:@"0"];
        }
    }
    
    [self.listtableview reloadData];
}

#pragma mark - 加载消息列表数据
-(void)loadData{
    self.pageNo = 1;
    self.hasMoreData = YES;
    [self.newsBL requestMsgListWithpageNum:self.pageNo andpagesize:MAX_PAGE_COUNT andaccesstoken:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
}

#pragma mark - 加载更多数据
-(void)loadMoreData{
    
    if (self.hasMoreData) {
        [self showLoadingUI];
        self.pageNo = self.pageNo+1;
        [self.newsBL requestMsgListWithpageNum:self.pageNo andpagesize:MAX_PAGE_COUNT andaccesstoken:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
    }else{
        // 结束刷新
        [self.listtableview.footer endRefreshing];
        [self.listtableview.footer noticeNoMoreData];
    }
}


/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

#pragma mark - 消息中心查询回调
-(void)requestMsgListSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    
    if (self.pageNo==1) {
        // 结束刷新
        [self.listtableview.header endRefreshing];
        if (dictList.count==0||dictList==NULL) {
            self.contentview.hidden = NO;
            self.Tsbg.image = [UIImage imageNamed:@"img_nodata"];
            self.Tslb.text = @"当前暂无消息~";
            self.Tsbtn.hidden = YES;
        
            self.editBut.hidden = YES;
            
            return;
        }
        self.editBut.hidden = NO;
        self.isAllChoose = NO;
        self.Selectimg.image = [UIImage imageNamed:@"message_select"];
        [self.dataList removeAllObjects];
        [self.choosearray removeAllObjects];
    }else{
        // 结束刷新
        [self.listtableview.footer endRefreshing];
        if (dictList.count==0||dictList==NULL) {
            self.hasMoreData = NO;
            [MBProgressHUD showError:@"没有更多消息了！"];
            self.contentview.hidden = YES;
            [self.listtableview reloadData];
            
            return;
        }
    }
    
    [self.dataList addObjectsFromArray:dictList];
    for (int i=0; i<self.dataList.count; i++) {
        [self.choosearray addObject:@"0"];
    }
    self.listtableview.hidden = NO;
    self.contentview.hidden = YES;
    [self.listtableview reloadData];
}

-(void)requestMsgListFailed:(NSString *)error{
    // 结束刷新
    self.HUD.hidden = YES;
    if (self.pageNo==1) {
        [self.listtableview.header endRefreshing];
    }else{
        [self.listtableview.footer endRefreshing];
    }
    
    long code = [error longLongValue];
    if (code == 5001 || code == 5002) {
        self.contentview.hidden = NO;
        self.Tsbg.image = [UIImage imageNamed:@"img_busy"];
        self.Tslb.text = @"找不到您的登录信息，请重新登录试试~";
        self.Tsbtn.hidden = YES;
        self.editBut.hidden = YES;
    }else {
        if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
            self.contentview.hidden = NO;
            self.Tsbg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            self.Tsbtn.hidden = NO;
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if (self.pageNo==1) {
                self.isAllChoose = NO;
                [self.dataList removeAllObjects];
                [self.choosearray removeAllObjects];
                self.contentview.hidden = NO;
                self.Tsbg.image = [UIImage imageNamed:@"img_busy"];
                self.Tslb.text = @"服务暂不可用，请稍后重试";
                self.Tsbtn.hidden = NO;
                [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.dataList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.hasMoreData) {
        return 0.1;
    }else{
        return 30;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NewsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewsCell"];
    if ( nil == cell ){
        cell = [[NewsCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NewsCell"];
    }
    
    // 获取模型数据
    MsgBean *bean = self.dataList[indexPath.row];
    cell.msgbean = bean;
    
    cell.isEdit = self.isEdit;
    cell.isChoosed = [self.choosearray[indexPath.row] boolValue];
    
    if (self.selectindexPath==indexPath) {
        cell.isDelete = YES;
    }else{
        cell.isDelete = NO;
    }
    
    [cell.deleteBtn setTag:indexPath.row+1];
    [cell.deleteBtn addTarget:self action:@selector(DeleteOneNew:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (self.hasMoreData) {
        return nil;
    }else{
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        UILabel *Lb = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100, 10, 200, 16)];
        Lb.font = [UIFont systemFontOfSize:13];
        Lb.textColor = [UIColor colorWithHex:0x999999];
        Lb.text = @"没有更多消息了~";
        Lb.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:Lb];
        return footerView;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    MsgBean *bean = self.dataList[indexPath.row];
    
    if (self.isEdit) {   // 批量删除编辑状态
        NSString *ischoose = self.choosearray[indexPath.row];
        if ([ischoose isEqualToString:@"1"]) {
            [self.choosearray replaceObjectAtIndex:indexPath.row withObject:@"0"];
        }else{
            [self.choosearray replaceObjectAtIndex:indexPath.row withObject:@"1"];
        }
        [self.listtableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
        
        if ([self IsAllChoosed]) {
            self.isAllChoose = YES;
            self.Selectimg.image = [UIImage imageNamed:@"message_select_on"];
        }else{
            self.isAllChoose = NO;
            self.Selectimg.image = [UIImage imageNamed:@"message_select"];
        }
        
    }else{               // 跳转详情页
//        [self SetOneNewsRead:bean.msgId];   // 至为已读
        if ([bean.type isEqualToString:@"1"]) {
            if ([Util IsStringNil:bean.url]) {
                [MBProgressHUD showError:@"消息链接为空"];
            }else{
                MsgDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"MsgDetailVC"];
                [VC setValue:bean forKey:@"bean"];
                [self.navigationController pushViewController:VC animated:YES];
            }
        }else{
            ContextDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ContextDetailVC"];
            [VC setValue:bean forKey:@"bean"];
            [VC setValue:@"liebiao" forKey:@"LX"];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }
}

#pragma mark - 重新刷新按钮
-(void)refreshUI{
    [self afn];
}

#pragma mark - 删除按钮
- (IBAction)Delete:(id)sender {
    if (self.isAllChoose) {    // 全部删除群推消息
        [self.newsBL deleteAllNews:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
    }else {       // 批量删除群推消息
        NSMutableString *msgidlist = [[NSMutableString alloc] initWithCapacity:0];
        for (int i=0; i < self.dataList.count; i++) {
            NSString *ischoose = self.choosearray[i];
            if ([ischoose isEqualToString:@"1"]) {
                MsgBean *bean = self.dataList[i];
                [msgidlist appendString:bean.msgId];
                [msgidlist appendString:@";"];
            }
        }
        
        if ([Util IsStringNil:msgidlist]) {
            [MBProgressHUD showError:@"请选择需要删除的消息"];
        }else{
            [msgidlist substringToIndex:([msgidlist length]-1)];
            [self.newsBL deleteNewsList:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN] andmsgIdlist:msgidlist];
        }
    }
}

#pragma mark - 右滑删除按钮
-(void)DeleteOneNew:(UIButton *) button {
    
    NSUInteger BtnTag = [button tag];
    button.hidden = YES;
    MsgBean *bean = self.dataList[BtnTag-1];
    [self.dataList removeObjectAtIndex:BtnTag-1];
    [self.newsBL deleteNewsList:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN] andmsgIdlist:bean.msgId];
}

#pragma mark - 删除全部群推消息回调
-(void)deleteAllNewsSucceed:(NSString*)success {
    [MBProgressHUD showError:success];
    self.selectindexPath = nil;
    [self afn];
}

-(void)deleteAllNewsFailed:(NSString *)error {
    [MBProgressHUD showError:error];
}

#pragma mark - 批量/单个删除群推消息回调
-(void)deleteNewsListSucceed:(NSString*)success {
    [MBProgressHUD showError:success];
    self.selectindexPath = nil;
    [self afn];
}

-(void)deleteNewsListFailed:(NSString *)error {
    [MBProgressHUD showError:error];
}

-(void)SetNewsAllRead {
    
    [self.newsBL updateNewsAllRead:[CoreArchive strForKey:LOGIN_ACCESS_TOKEN]];
}

#pragma mark - 修改群推列表全部已读回调
-(void)updateNewsAllReadSucceed:(NSString*)success {
    
    if (![self HasUnreadNews]) {
       [MBProgressHUD showError:success];
    }
    [self afn];
}

-(void)updateNewsAllReadFailed:(NSString *)error {
    
    [MBProgressHUD showError:error];
}

#pragma mark - 判断是否全部选中
-(BOOL)IsAllChoosed{
    
    int num = 0;
    for (int i=0; i<self.dataList.count; i++) {
        if ([self.choosearray[i] isEqualToString:@"1"]) {
            num = num + 1;
        }
    }
    if (num == self.dataList.count) {
        return YES;
    }else{
        return NO;
    }
}

#pragma mark - 判断是否有未读消息
-(BOOL)HasUnreadNews {
    
    for (int i=0; i<self.dataList.count; i++) {
        MsgBean *bean = self.dataList[i];
        if ([bean.readStatus isEqualToString:@"0"]) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - cell左滑删除手势
- (void)delete:(UIGestureRecognizer *)recognizer {
    
    if (!self.isEdit) {
        
        if (nil != self.selectindexPath) {
            self.beforeindexPath = self.selectindexPath;
            self.selectindexPath = nil;
            [self.listtableview reloadRowsAtIndexPaths:@[self.beforeindexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        CGPoint point = [recognizer locationInView:self.listtableview];
        NSIndexPath *indexPath = [self.listtableview indexPathForRowAtPoint:point];
        self.selectindexPath = indexPath;
        [self.listtableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        return;
    }
}

#pragma mark - cell右滑删除手势
- (void)recover:(UIGestureRecognizer *)recognizer {
    
    if (!self.isEdit) {
        self.selectindexPath = nil;
        CGPoint location = [recognizer locationInView:self.listtableview];
        NSIndexPath *indexPath = [self.listtableview indexPathForRowAtPoint:location];
        [self.listtableview reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        return;
    }
    
}


@end
