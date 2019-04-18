//
//  XBFFWDController.m
//  YiWuHRSS
//
//  Created by MacBook on 2018/5/22.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "XBFFWDController.h"
#import "PointAreaCell.h"
#import "WebBL.h"
#import "NetPointCell.h"
#import "FixedPointCell.h"
#import "NetDetailVC.h"

@interface XBFFWDController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UIGestureRecognizerDelegate, WebBLDelegate>{
    
    CGFloat  frame_y;
    UIView   *areaBgView; //浮层
    NSString *searchBarText;
    NSInteger curAreaRow;   //当前选中银行的下标
    NSString *curAreaCode;  //当前选中的银行名称
    NSInteger curTypeRow;   //当前选中全部类型下标
    NSString *curTypeCode;  //当前选中的类型名称
    NSString *curSelect;    //当前区域列表显示类型
    
        NSString * isMaked;
        NSString * isResetPassword;
    
}


@property (nonatomic, strong) NSMutableArray *dataList; // 数据
@property (nonatomic, assign) NSInteger pageCount;

@property (nonatomic, strong) UITableView *areaTBV; //医院类型列表
@property (nonatomic, strong) NSArray *areaArray;//统筹区数据源
@property (nonatomic, strong) NSArray *typeArray;//医院类型数据源
@property (nonatomic, strong) NSMutableArray *pointTypeArray;//类型数据源

@property(nonatomic, strong)        WebBL       *webBL;
@property(nonatomic, assign)       int          pageNo;
@property(nonatomic, copy)      NSString        *seachKey;

// 控件
@property(nonatomic, strong) MBProgressHUD    *HUD;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@end

@implementation XBFFWDController


- (NSMutableArray *)pointTypeArray {
    if (_pointTypeArray == nil) {
        _pointTypeArray = [NSMutableArray array];
    }
    return _pointTypeArray;
}

- (UITableView *)areaTBV {
    if (_areaTBV == nil) {
        _areaTBV = [[UITableView alloc] initWithFrame:CGRectMake(0, frame_y, SCREEN_WIDTH/2, 0) style:UITableViewStylePlain];
        _areaTBV.delegate = self;
        _areaTBV.dataSource = self;
        _areaTBV.backgroundColor = [UIColor whiteColor];
        _areaTBV.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _areaTBV;
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"服务网点";
    HIDE_BACK_TITLE;
    
    
    

    self.areaArray = @[@"全部银行", @"义乌农商银行", @"浙江稠州商业银行"];
    self.typeArray = @[@"全部类型", @"可制卡", @"可密码重置"];
    
    self.yytableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    // 设置cell下划线靠左显示
    [self.yytableView setSeparatorInset:UIEdgeInsetsZero];
    [self.yytableView setLayoutMargins:UIEdgeInsetsZero];
    self.yytableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    self.yytableView.tableFooterView = [[UIView alloc] init];
    self.yytableView.delegate = self;
    self.yytableView.dataSource = self;
    [self.yytableView registerNib:[UINib nibWithNibName:@"NetPointCell" bundle:nil] forCellReuseIdentifier:@"NetPointCell"];
    [self.yytableView registerNib:[UINib nibWithNibName:@"FixedPointCell" bundle:nil] forCellReuseIdentifier:@"FixedPointCell"];
    

    // 上拉加载更多
    self.yytableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    [self.view bringSubviewToFront:self.yytableView];
    
    self.Tsview.hidden = YES;
    self.pageCount = 1;
    self.bankNameLB.text = @"全部银行";
    curAreaCode = @"";
    self.typeNameLB.text = @"全部类型";
    curTypeCode = @"";
    curSelect = @"";
    
    [self setChooseGuesture];
    [self setTypeGuesture];
    [self createAreaTBV];
    curAreaRow = 0;
    curTypeRow = 0;
    
    
    /////////
    [self initData];
    [self afn];
}


#pragma mark - 创建统筹区
- (void)createAreaTBV {
    frame_y = 64+90;
    areaBgView = [[UIView alloc] initWithFrame:CGRectMake(0, frame_y, SCREEN_WIDTH, 0)];
    areaBgView.backgroundColor = [UIColor blackColor];
    areaBgView.alpha = 0.6;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideAreaListView)];
    [areaBgView addGestureRecognizer:tap];
    [self.view addSubview:areaBgView];
    
    [self.view addSubview:self.areaTBV];
}



#pragma mark - 统筹区VIEW添加手势
-(void)setChooseGuesture{
    UITapGestureRecognizer * ChoosetapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAreaListView)];
    ChoosetapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [ChoosetapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.bankView addGestureRecognizer:ChoosetapGesture];
}

#pragma mark - 医院类型VIEW添加手势
-(void)setTypeGuesture{
    UITapGestureRecognizer * TypetapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showTypeListView)];
    TypetapGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [TypetapGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.typeView addGestureRecognizer:TypetapGesture];
}

#pragma mark - 显示统筹区数据
- (void)showAreaListView{
    areaBgView.frame = CGRectMake(0, frame_y, SCREEN_WIDTH, SCREEN_HEIGHT-frame_y);
    curSelect = @"area";
    [self.areaTBV reloadData];
    [UIView animateWithDuration:0.0 animations:^{
        self.areaTBV.frame = CGRectMake(0, frame_y, SCREEN_WIDTH/2, self.areaArray.count*50);
    }];
}

#pragma mark - 显示医院类型数据
- (void)showTypeListView{
    areaBgView.frame = CGRectMake(0, frame_y, SCREEN_WIDTH, SCREEN_HEIGHT-frame_y);
    curSelect = @"type";
    [self.areaTBV reloadData];
    [UIView animateWithDuration:0.0 animations:^{
        self.areaTBV.frame = CGRectMake(SCREEN_WIDTH/2, frame_y, SCREEN_WIDTH/2, self.typeArray.count*50);
    }];
}

#pragma mark - 隐藏统筹区数据
- (void)hideAreaListView {
    areaBgView.frame = CGRectMake(0, frame_y, SCREEN_WIDTH, 0);
    [UIView animateWithDuration:0.0 animations:^{
        self.areaTBV.frame = CGRectMake(0, frame_y, SCREEN_WIDTH, 0);
    }];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.yytableView) {
        return self.dataList.count;
    } else if (tableView == self.areaTBV) {
        if ([curSelect isEqualToString:@"area"]) {
            return 3;
        }else if ([curSelect isEqualToString:@"type"]){
            return 3;
        }else{
            return 0;
        }
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //定点列表
    if (tableView == self.yytableView) {

        
        NetPointBean *bean = self.dataList[indexPath.row];
//        NSString *tp = ;
        if ([bean.ismaked isEqualToString:@"1"] || [bean.isResetPassword isEqualToString:@"1"]) {
            NetPointCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NetPointCell"];
//            if ( nil == cell ){
//                cell = [[NetPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NetPointCell"];
//            }
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
            
//            cell.Type.hidden = NO;
            if ([bean.ismaked isEqualToString:@"0"]) {
                
                cell.Type.hidden = YES;
                cell.type2RightConstraint.constant = 15;
            } else {
                
                cell.Type.hidden = NO;
                cell.type2RightConstraint.constant = 85;
            }
            
            if ([bean.isResetPassword isEqualToString:@"0"]) {
                
                cell.Type2.hidden = YES;
//                cell.type2RightConstraint.constant = 15;
            } else {
                
                cell.Type2.hidden = NO;
//                cell.type2RightConstraint.constant = 85;
            }
            
            
            
            
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
//            if ( nil == cell ){
//                cell = [[FixedPointCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"FixedPointCell"];
//            }
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
    
    //统筹区/定点类型列表
    if (tableView == self.areaTBV) {
        PointAreaCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"PointAreaCell" owner:self options:nil] firstObject];
        if ([curSelect isEqualToString:@"area"]) {       // 统筹区
            
            for (int i = 0; i < self.areaArray.count; i++) {
                
                if ([self.areaArray[i] isEqualToString:curAreaCode]) {
                    curAreaRow = i;
                }
            }
            if (indexPath.row == curAreaRow) {
                cell.titleLB.textColor = [UIColor colorWithHex:0xFFFFFF];
                cell.contentView.backgroundColor = [UIColor colorWithHex:0xFDB731];
            } else {
                cell.titleLB.textColor = [UIColor colorWithHex:0x333333];
                cell.contentView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
            }
            cell.titleLB.text = self.areaArray[indexPath.row];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else if ([curSelect isEqualToString:@"type"]){  // 医院类型
            if (self.typeArray.count == 0) {
                return cell;
            }
            
            for (int i = 0; i < self.typeArray.count; i++) {
                
                if ([self.typeArray[i] isEqualToString:curTypeCode]) {
                    curTypeRow = i;
                }
            }
            if (indexPath.row == curTypeRow) {
                cell.titleLB.textColor = [UIColor colorWithHex:0xFFFFFF];
                cell.contentView.backgroundColor = [UIColor colorWithHex:0xFDB731];
            } else {
                cell.titleLB.textColor = [UIColor colorWithHex:0x333333];
                cell.contentView.backgroundColor = [UIColor colorWithHex:0xFFFFFF];
            }
            
            cell.titleLB.text = self.typeArray[indexPath.row];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }else{
            return cell;
        }
    }
    
    return [UITableViewCell new];
    
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.yytableView) {
        
        NetPointBean *bean = self.dataList[indexPath.row];
        NSString *tp = bean.ismaked;
        if ([tp isEqualToString:@"1"] || [bean.isResetPassword isEqualToString:@"1"]) {
            return 102;
        }else{
            return 75;
        }
        
    } else if (tableView == self.areaTBV) {
        return 50;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //定点列表
    if (tableView == self.yytableView) {
        
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        NetPointBean *bean = self.dataList[indexPath.row];
        NetDetailVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"NetDetailVC"];
        [VC setValue:bean forKey:@"bean"];
        [self.navigationController pushViewController:VC animated:YES];
        
    }
    //统筹区/定点类型列表
    if (tableView == self.areaTBV) {
        if ([curSelect isEqualToString:@"area"]) {       // 全部银行
            curAreaRow = indexPath.row;
            curAreaCode = self.areaArray[indexPath.row];
            self.bankNameLB.text = self.areaArray[indexPath.row];
            
            [self loadbankdata];
            
            
        }else if ([curSelect isEqualToString:@"type"]){  // 全部类型
            curTypeRow = indexPath.row;
            curTypeCode = self.typeArray[indexPath.row];
            self.typeNameLB.text = self.typeArray[indexPath.row];
            
            [self loadbankdata];
            }
        }
        [self hideAreaListView];
        [self.areaTBV reloadData];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
            [self LoadBankData];
        }else{
            DMLog(@"没有网络");
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

-(void)LoadBankData{
    self.pageNo=1;
    
    NSString *bankMark = [[NSString alloc] init];
    if ([curAreaCode isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([curAreaCode isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    
    if ([curTypeCode isEqualToString:@"可制卡"]) {
        isMaked = @"1";
        isResetPassword = @"";
    } else if ([curTypeCode isEqualToString:@"可密码重置"]) {
        isResetPassword = @"1";
        isMaked = @"";
    } else {
        isMaked = @"";
        isResetPassword = @"";
    }
    
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:isMaked isResetPassword:isResetPassword];
}


#pragma mark - 搜索按钮点击事件
- (IBAction)SearchBtnClicked:(id)sender {
    
    NSString *bankMark;
    if ([curAreaCode isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([curAreaCode isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    
    self.Tsview.hidden =YES;
    self.seachKey = self.Searchtf.text;
    [self.Searchtf resignFirstResponder];
    
    if ([curTypeCode isEqualToString:@"可制卡"]) {
        isMaked = @"1";
        isResetPassword = @"";
    } else if ([curTypeCode isEqualToString:@"可密码重置"]) {
        isResetPassword = @"1";
        isMaked = @"";
    } else {
        isMaked = @"";
        isResetPassword = @"";
    }
    
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:isMaked isResetPassword:isResetPassword];
    
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.view endEditing:YES];
}

#pragma mark - 初始化数据
- (void)initData{
    self.dataList = [NSMutableArray array];
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
    self.pageNo = 1;
    self.Searchtf.delegate = self;
    self.seachKey = @"";
    curAreaCode = @"全部银行";
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
//            [self initView];
            [self loadData];
        }else{
            DMLog(@"没有网络");
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark - 请求服务网点数据
-(void)loadData{
    NSString *bankMark =  [[NSString alloc] init];
    if ([curAreaCode isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([curAreaCode isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    
    if ([curTypeCode isEqualToString:@"可制卡"]) {
        isMaked = @"1";
        isResetPassword = @"";
    } else if ([curTypeCode isEqualToString:@"可密码重置"]) {
        isResetPassword = @"1";
        isMaked = @"";
    } else {
        isMaked = @"";
        isResetPassword = @"";
    }
    
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:isMaked isResetPassword:isResetPassword];
    
}

#pragma mark - 加载更多数据
-(void)loadMoreData{
    NSString *bankMark = [[NSString alloc] init];
    if ([curAreaCode isEqualToString:@"浙江稠州商业银行"]) {
        bankMark = @"7000";
    }else if ([curAreaCode isEqualToString:@"义乌农商银行"]) {
        bankMark = @"6000";
    }else{
        bankMark = @"1000";
    }
    self.pageNo = self.pageNo+1;
    
    if ([curTypeCode isEqualToString:@"可制卡"]) {
        isMaked = @"1";
        isResetPassword = @"";
    } else if ([curTypeCode isEqualToString:@"可密码重置"]) {
        isResetPassword = @"1";
        isMaked = @"";
    } else {
        isMaked = @"";
        isResetPassword = @"";
    }
    
    [self showLoadingUI];
    [self.webBL queryNetWorkPointWithKeyWords:self.seachKey andbankMark:bankMark andpageNum:self.pageNo andpageSize:MAX_PAGE_COUNT isMaked:isMaked isResetPassword:isResetPassword];
    
}

#pragma mark - 重新刷新按钮点击事件
-(void)refreshUI{
    [self afn];
}

#pragma mark - 服务网点查询接口回调
-(void)queryNetWorkPointSucceed:(NSMutableArray *)dictList{
    self.HUD.hidden = YES;
    // 结束刷新
    [self.yytableView.footer endRefreshing];
    if (self.pageNo==1) {
        if (dictList.count==0) {
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_nodata"];
            self.Tslb.text = @"没有搜索到相关数据，换个条件试试吧~";
            self.yytableView.hidden = YES;
            return;
        }else{
            [self.dataList removeAllObjects];
            self.dataList = dictList;

            self.Tsview.hidden = YES;
            self.yytableView.hidden = NO;
            [self.yytableView reloadData];
        }
    }else{
        if (dictList.count==0) {
            [MBProgressHUD showError:@"没有更多数据了！"];
            return;
        }else{
            [self.dataList addObjectsFromArray:dictList];
            self.Tsview.hidden = YES;
            self.yytableView.hidden  = NO;
            [self.yytableView reloadData];
        }
    }
}

-(void)queryNetWorkPointFailed:(NSString *)error{
    // 结束刷新
    self.HUD.hidden = YES;
    [self.yytableView.footer endRefreshing];
    
    int iStatus = error.intValue;
    if (iStatus==2000) {
        [MBProgressHUD showError:@"参数不合法"];
    }else{
        if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
            self.Tsview.hidden = NO;
            self.yytableView.hidden = YES;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }else{
            if (self.pageNo==1) {
                [self.dataList removeAllObjects];
                self.Tsview.hidden = NO;
                self.yytableView.hidden =YES;
                self.Tsimg.image = [UIImage imageNamed:@"img_busy"];
                self.Tslb.text = @"服务暂不可用，请稍后重试";
                [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
            }
        }
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


@end
