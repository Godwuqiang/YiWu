//
//  ParkVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ParkVC.h"
#import "ParkDetailVC.h"
#import "WebBL.h"
#import "ParkCell.h"
#import "TypeCell.h"

@interface ParkVC ()<UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UITextFieldDelegate,WebBLDelegate>
{
    UIView   *typeBgView;   // 浮层
    NSInteger curTypeRow;   // 当前选中停车场类型下标
    NSString *curTypeCode;  // 当前选中的停车场类型编码
    BOOL        _isNoData;  // 是否显示没有跟多数据了 （YES 显示， NO不显示）
}

@property(nonatomic, strong)    WebBL     *webBL;
@property(nonatomic, strong)   NSString   *seachKey;
@property(nonatomic, assign)     int      pageNo;
@property(nonatomic, strong) UITableView  *typeTBV;       // 停车场类型列表
@property(nonatomic, strong) NSMutableArray *typeArray;   // 停车类型数据源
@property(nonatomic, strong) NSMutableArray *dataList;    // 停车场数据


// 控件
@property(nonatomic, strong) MBProgressHUD    *HUD;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation ParkVC

- (UITableView *)typeTBV {
    if (_typeTBV == nil) {
        _typeTBV = [[UITableView alloc] initWithFrame:CGRectMake(0, 64+103, SCREEN_WIDTH, 0) style:UITableViewStylePlain];
        _typeTBV.delegate = self;
        _typeTBV.dataSource = self;
        _typeTBV.scrollEnabled = NO;
        _typeTBV.backgroundColor = [UIColor whiteColor];
        _typeTBV.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    }
    return _typeTBV;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"公共停车场";
    HIDE_BACK_TITLE;
    [self initData];
    [self initView];
    [self setParkTypeGuesture];
    [self setupCoverView];
    [self createTypeTBV];
    [self afn];
    
}

#pragma mark - 初始化数据
-(void)initData {
    
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
    self.seachKey = @"";
    
    self.dataList = [NSMutableArray new];
    self.typeArray = [[NSMutableArray alloc] initWithCapacity:5];
    [self.typeArray addObject:@"全部停车场"];
    [self.typeArray addObject:@"停车场"];
    [self.typeArray addObject:@"道路停车"];
    [self.typeArray addObject:@""];
    [self.typeArray addObject:@"取消"];
    
    curTypeRow = 0;
    curTypeCode = @"全部停车场";
}

#pragma mark - 初始化界面
-(void)initView {
    
    self.Coverview.hidden = YES;
    self.Tsview.hidden = YES;
    self.listtableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.listtableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    self.Searchtf.delegate = self;
    
    // 上啦加载更多
    self.listtableview.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
}

#pragma mark - 监听网络请求服务网点数据
-(void)afn{
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"3G|4G|WIFI");
            [self loadData];
        }else{
            DMLog(@"没有网络");
            self.Coverview.hidden = YES;
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            self.Refreshbtn.hidden = NO;
            [self.Refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark - 创建停车场类型
- (void)createTypeTBV {
    typeBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 64+103, SCREEN_WIDTH, 0)];
    typeBgView.backgroundColor = [UIColor blackColor];
    typeBgView.alpha = 0.6;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideTypeListView)];
    [typeBgView addGestureRecognizer:tap];
    [self.view addSubview:typeBgView];
    [self.view addSubview:self.typeTBV];
}

#pragma mark - 隐藏停车场类型数据
- (void)hideTypeListView {
    typeBgView.frame = CGRectMake(0, 64+103, SCREEN_WIDTH, 0);
    [UIView animateWithDuration:0.0 animations:^{
        self.typeTBV.frame = CGRectMake(0, 64+103, SCREEN_WIDTH, 0);
    }];
}

#pragma mark - 选择停车场类型VIEW添加手势
-(void)setParkTypeGuesture{
    //添加手势
    UITapGestureRecognizer *ParkTypeGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTypeListView)];
    ParkTypeGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [ParkTypeGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Typeview addGestureRecognizer:ParkTypeGesture];
}

#pragma mark - 为遮盖层View添加手势
-(void)setupCoverView{
    UITapGestureRecognizer* singleTapRecognizer;
    singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(CoverViewHandleSingleTapFrom:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    [self.Coverview addGestureRecognizer:singleTapRecognizer];
}

#pragma mark - 显示停车类型数据
- (void)showTypeListView{
    typeBgView.frame = CGRectMake(0, 64+103, SCREEN_WIDTH, SCREEN_HEIGHT-167);
    
    [self.typeTBV reloadData];
    [UIView animateWithDuration:0.0 animations:^{
        
        self.typeTBV.frame = CGRectMake(0, 64+103, SCREEN_WIDTH, 210);
    }];
}

#pragma mark - 点击遮罩层会隐藏遮罩层
- (void)CoverViewHandleSingleTapFrom:(UITapGestureRecognizer *)recognizer{
    [self.Searchtf resignFirstResponder];
    self.Coverview.hidden = YES;
}

#pragma mark - 请求公共停车位数据
-(void)loadData{
    
    self.pageNo = 1;
    _isNoData = NO;
    
    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LON]?@"29.293017":[CoreArchive strForKey:CURRENT_LON];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LAT]?@"120.063697": [CoreArchive strForKey:CURRENT_LAT];
    NSString *type;
    if ([curTypeCode isEqualToString:@"全部停车场"]) {
        type = @"";
    }else if ([curTypeCode isEqualToString:@"停车场"]) {
        type = @"A";
    }else if ([curTypeCode isEqualToString:@"道路停车"]) {
        type = @"B";
    }else {
        type = @"";
    }
    
    [self showLoadingUI];
    [self.webBL queryPublicParksWithLongitude:lng andLatitude:lat andType:type andpageNo:self.pageNo andpageSize:10];
}

#pragma mark - 加载更多数据
- (void)loadMoreData {
    
    self.pageNo = self.pageNo+1;
    
    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LON]?@"29.293017":[CoreArchive strForKey:CURRENT_LON];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LAT]?@"120.063697": [CoreArchive strForKey:CURRENT_LAT];
    NSString *type;
    if ([curTypeCode isEqualToString:@"全部停车场"]) {
        type = @"";
    }else if ([curTypeCode isEqualToString:@"停车场"]) {
        type = @"A";
    }else if ([curTypeCode isEqualToString:@"道路停车"]) {
        type = @"B";
    }else {
        type = @"";
    }
    
    [self showLoadingUI];
    
    if ([self.seachKey isEqualToString:@""]) {
        
        // 无搜索
        [self.webBL queryPublicParksWithLongitude:lng andLatitude:lat andType:type andpageNo:self.pageNo andpageSize:10];
    } else {
        
        // 搜索
        [self.webBL getPublicCarSearchListWithLongitude:lng andLatitude:lat andKeywords:self.seachKey andType:type andpageNo:self.pageNo andpageSize:10];
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

#pragma mark - 获取公共汽车停车位信息接口回调
-(void)queryPublicParksSucceed:(NSMutableArray*)dictList {
    
    DMLog(@"111111111111111111111222");
    [self.listtableview.footer endRefreshing];
    
    self.HUD.hidden = YES;
    
    if (self.pageNo == 1) {
        
        if (dictList.count==0) {
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noparking"];
            self.Tslb.text = @"未匹配到搜索站点，换个条件试试吧~";
            self.Refreshbtn.hidden = YES;
            return;
        }else{
            [self.dataList removeAllObjects];
            [self.dataList addObjectsFromArray:dictList];
            self.Tsview.hidden = YES;
            [self.listtableview reloadData];
        }
    }else {
        
        if (dictList.count < 10) {
            
            _isNoData = YES;
            
            [self.dataList addObjectsFromArray:dictList];
            self.Tsview.hidden = YES;
            [self.listtableview reloadData];
        }else {
            
            _isNoData = NO;
            
            [self.dataList addObjectsFromArray:dictList];
            self.Tsview.hidden = YES;
            [self.listtableview reloadData];
        }
    }
}

-(void)queryPublicParksFailed:(NSString*)error {
    
    DMLog(@"222222222222222222211");
    
    self.HUD.hidden = YES;
    [self.listtableview.footer endRefreshing];
    
    if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
        self.Tsview.hidden = NO;
        self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
        self.Tslb.text = @"当前网络不可用，请检查网络设置";
        self.Refreshbtn.hidden = NO;
        [self.Refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.Tsview.hidden = NO;
        self.Tsimg.image = [UIImage imageNamed:@"img_busy"];
        self.Tslb.text = @"服务暂不可用，请稍后重试";
        self.Refreshbtn.hidden = NO;
        [self.Refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
    }
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

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.listtableview) {
        return 1;
    } else if (tableView == self.typeTBV) {
        return self.typeArray.count;
    } else {
        return 0;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.listtableview) {
        return self.dataList.count;
    } else if (tableView == self.typeTBV) {
        return 1;
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    if (tableView == self.listtableview) {
        if (section == 0) {
            return 15;
        }else {
            return 0.1;
        }
    }
    
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    // 停车场列表
    if (tableView == self.listtableview) {
        
        if (_isNoData) {
            if (section == self.dataList.count-1) {
                return 30;
            }else{
                return 15;
            }
        }else {
            
            return 15;
        }
    }else {
        return 0.1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // 停车场列表
    if (tableView == self.listtableview) {
        static NSString *cellId = @"cell";
        ParkCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
        if (cell == nil) {
            cell = [[[NSBundle mainBundle] loadNibNamed:@"ParkCell" owner:self options:nil] firstObject];
        }
        
        cell.parkbean = self.dataList[indexPath.section];
        
        return cell;
    }
    
    // 停车场类型列表
    if (tableView == self.typeTBV) {
        TypeCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TypeCell" owner:self options:nil] firstObject];

        for (int i = 0; i < self.typeArray.count; i++) {
            if ([self.typeArray[i] isEqualToString:curTypeCode]) {
                curTypeRow = i;
            }
        }
        if (indexPath.row == curTypeRow) {
            cell.Type.textColor = [UIColor colorWithHex:0xffffff];
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xfdb731];
        }else if (indexPath.row == 3){
            cell.Type.textColor = [UIColor colorWithHex:0xfdb731];
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xcdcdcd];
        }else if (indexPath.row == 4){
            cell.Type.textColor = [UIColor colorWithHex:0xfdb731];
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xffffff];
        }else {
            cell.Type.textColor = [UIColor colorWithHex:0x333333];
            cell.contentView.backgroundColor = [UIColor colorWithHex:0xffffff];
        }
        cell.Type.text = self.typeArray[indexPath.row];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    
    return [UITableViewCell new];
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.listtableview) {
        return 78;
    } else if (tableView == self.typeTBV) {
        if (indexPath.row == 3) {
            return 10;
        }else{
            return 50;
        }
    } else {
        return 0;
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (tableView == self.listtableview) {
        
        if (_isNoData) {
            
            if (section==self.dataList.count-1) {
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
                footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
                
                UILabel *Lb = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100, 10, 200, 16)];
                Lb.font = [UIFont systemFontOfSize:13];
                Lb.textColor = [UIColor colorWithHex:0x999999];
                Lb.text = @"没有更多数据了~";
                Lb.textAlignment = NSTextAlignmentCenter;
                
                [footerView addSubview:Lb];
                return footerView;
            }else{
                UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
                footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
                
                return footerView;
            }
            
        }else {
            
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 15)];
            footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            
            return footerView;
        }
        
    }else{
        return nil;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    // 停车场列表
    if (tableView == self.listtableview) {
        ParkBean *bean = self.dataList[indexPath.section];
//        NSString *bt;
//        if ([bean.type isEqualToString:@"A"]) {
//            bt = @"停车场";
//        }else if ([bean.type isEqualToString:@"B"]) {
//            bt = @"道路停车";
//        }else{
//            bt = @"停车场";
//        }
        
        ParkDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"ParkDetailVC"];
        [VC setValue:bean.id forKey:@"PID"];
//        [VC setValue:bt forKey:@"bt"];
        [self.navigationController pushViewController:VC animated:YES];
    }
    
    // 停车场类型列表
    if (tableView == self.typeTBV) {
        if (indexPath.row == 0 || indexPath.row == 1 || indexPath.row == 2) {
            curTypeRow = indexPath.row;
            curTypeCode = self.typeArray[indexPath.row];
            self.type.text = curTypeCode;
            
            [self afn];
        }
        [self hideTypeListView];
    }
}

// UITableView分割线整行显示
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{

    self.Coverview.hidden = NO;
    return YES;
}

#pragma mark - 点击Return键的时候，（标志着编辑已经结束了）
-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    self.Coverview.hidden = YES;
    return YES;
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSString *key_word = [textField.text stringByReplacingCharactersInRange:range withString:string];
    self.seachKey = key_word;
    
    return YES;
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    self.seachKey = @"";
    
    return YES;
}

#pragma mark - 搜索按钮点击事件
- (IBAction)Search:(id)sender {
    
    self.seachKey = self.Searchtf.text;
    
//    if ([self.seachKey isEqualToString:@""]) {
//        return;
//    }
    
    [self.Searchtf resignFirstResponder];
    self.Coverview.hidden = YES;
//    [self afn];
    
    
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"3G|4G|WIFI");
//            [self loadData];
            
            NSString *lat = nil==[CoreArchive strForKey:CURRENT_LON]?@"29.293017":[CoreArchive strForKey:CURRENT_LON];
            NSString *lng = nil==[CoreArchive strForKey:CURRENT_LAT]?@"120.063697": [CoreArchive strForKey:CURRENT_LAT];
            NSString *type;
            if ([curTypeCode isEqualToString:@"全部停车场"]) {
                type = @"";
            }else if ([curTypeCode isEqualToString:@"停车场"]) {
                type = @"A";
            }else if ([curTypeCode isEqualToString:@"道路停车"]) {
                type = @"B";
            }else {
                type = @"";
            }
            
            self.pageNo = 1;
            
            [self showLoadingUI];
            [self.webBL getPublicCarSearchListWithLongitude:lng andLatitude:lat andKeywords:self.seachKey andType:type andpageNo:self.pageNo andpageSize:10];
            
        }else{
            DMLog(@"没有网络");
            self.Coverview.hidden = YES;
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            self.Refreshbtn.hidden = NO;
            [self.Refreshbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
    
}

#pragma mark - 重新刷新按钮点击事件
-(void)refreshUI{
    [self afn];
}

@end
