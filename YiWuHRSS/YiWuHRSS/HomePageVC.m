//
//  HomePageVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/11.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "HomePageVC.h"
#import "RegistSelectCardVC.h"
#import "CanBaoInfoVC.h"
#import "WuXianPaymentVC.h"
#import "YLJfafangVC.h"
#import "YLJAccountVC.h"
#import "YBcostVC.h"
#import "MedicalListVC.h"
#import "HospitalListVC.h"
#import "DXBPublicBlikeVC.h"
#import "PharmacyListVC.h"
#import "NetListVC.h"
#import "YLJAccountVC.h"
#import "MineWebVC.h"
#import "JFH5VC.h"
#import "GHH5VC.h"
#import "YBydH5VC.h"
#import "YBzxH5VC.h"
#import "BankXYVC.h"
#import "BankKTVC.h"
#import "LoginVC.h"
#import "MineWebVC.h"
#import "GuaShiVC.h"
#import "CheckListVC.h"
#import "BdH5VC.h"
#import "SZKAlterView.h"
#import "UIImageView+WebCache.h"
#import "NewsDetailVC.h"
#import "SrrzBean.h"
#import "ModifyCardView.h"
#import "RzwtgView.h"
#import "HomeCell.h"
#import "YFRollingLabel.h"
#import "BdH5VC.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"
#import "BannerBean.h"
#import "SDCycleScrollView.h"
#import "DTFSearchVC.h"
#import "YWLoginVC.h"
#import "YWRegistVC.h"
#import "YWRegistAndPaymentVC.h"
#import "YWPaymentOrderVC.h"



#define SRRZ_STATUS_URL   @"/complexServer/checkSrrzStatus.json" // 实人认证状态

#define CYCLE_VIEW_HEIGHT       (160)       // 轮播器高度
#define NEW_CELL_HEIGHT         (90)        // 表格分组视图高度
#define NEW_CELL_HEAD_HEIGHT    (40)        // 表格单元格行高

#define TAG_BUTTON_MIDDLE1 0x001
#define TAG_BUTTON_MIDDLE2 0x002
#define TAG_BUTTON_MIDDLE3 0x003
#define TAG_BUTTON_MIDDLE4 0x004
#define TAG_BUTTON_MIDDLE5 0x005
#define TAG_BUTTON_MIDDLE6 0x006
#define TAG_BUTTON_MIDDLE7 0x007
#define TAG_BUTTON_MIDDLE8 0x008
#define TAG_BUTTON_MIDDLE9 0x009
#define TAG_BUTTON_MIDDLE10 0x010
#define TAG_BUTTON_MIDDLE11 0x011
#define TAG_BUTTON_MIDDLE12 0x012
#define TAG_BUTTON_MIDDLE13 0x013


@interface HomePageVC ()<UITableViewDelegate,UITableViewDataSource,NewsBLDelegate, SDCycleScrollViewDelegate>
// 控件

@property (strong, nonatomic) UIView *navBar;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;
@property (weak, nonatomic)   IBOutlet UITableView  *tableview;
@property(nonatomic, strong)    SDCycleScrollView   *cycleScrollView;
@property(nonatomic,strong)         UIImageView     *rollingImg;      // 通知公告图片
@property(nonatomic, strong)      YFRollingLabel    *rollinglabel;   // 通知公告跑马灯
@property(nonatomic, strong)        NewsBL          *newsBL;
@property(nonatomic)            UITableViewCell     *HomePageCellImage; //轮播图的cell
@property(nonatomic)            UITableViewCell     *HomeNoticeCell; //通知公告的cell

@property (nonatomic, strong) UIView                *noDataView;    // 没有网络时的最新资讯
@property (nonatomic, strong) UIImageView           *noDataImgView;
@property (nonatomic, strong) UILabel               *noDataLabel;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

// 数据
@property(nonatomic, strong)       NSString         *gonggao;
@property(nonatomic, strong)       NSString         *isgo;
@property(nonatomic, strong)    NSMutableArray      *pngUrlArray;  // 轮播图URL数组
@property(nonatomic, strong)    NSMutableArray      *bannerUrlArray;  // 轮播图对应跳转链接URL数组
@property(nonatomic, strong)    NSMutableArray      *bannertitleArray;  // 轮播图对应标题URL数组
@property(nonatomic, strong)    NSMutableArray      *newsInfoList;  // 最新资讯列表

@property (nonatomic, strong) NSMutableArray * BannerBeanArray;

@property                           BOOL            hasnet;     // 判断有没有网络
@property                           BOOL            hasgonggao;

@end

@implementation HomePageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGRect topframe = CGRectMake(0,0,SCREEN_WIDTH,30);
    if(kIsiPhoneX){
        topframe = CGRectMake(0,0,SCREEN_WIDTH,30);
    }else{
        topframe = CGRectMake(0,0,SCREEN_WIDTH,20);
    }
    UIView *topview = [[UIView alloc] initWithFrame:topframe];
    topview.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.view addSubview:topview];
    self.automaticallyAdjustsScrollViewInsets = NO;

    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];

    [self initData];
    [self initTableView];
    [self initNavBar];
}
#pragma mark - 数据初始化
/**
 *  数据初始化
 */
- (void)initData{
    self.gonggao = @"";
    self.isgo = @"0";
    self.hasgonggao = NO;
    self.pngUrlArray = [[NSMutableArray alloc] init];
    self.bannerUrlArray = [[NSMutableArray alloc] init];
    self.bannertitleArray = [[NSMutableArray alloc] init];
    self.BannerBeanArray = [[NSMutableArray alloc] init];
    self.newsInfoList = [[NSMutableArray alloc] init];
    self.newsBL = [NewsBL sharedManager];
    self.newsBL.delegate = self;
    
}

- (void)initNavBar
{
    
    self.navBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kSafeAreaTopHeight)];
    self.navBar.backgroundColor = [[UIColor colorWithHex:0xfdb731] colorWithAlphaComponent:0];
    // 搜索按钮
    UIButton *searchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [searchBtn setBackgroundColor:[[UIColor whiteColor] colorWithAlphaComponent:0.68]];
    searchBtn.layer.cornerRadius = 4;
    searchBtn.layer.masksToBounds = YES;
    [searchBtn addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [searchBtn setTitle:@"输入搜索关键词" forState:UIControlStateNormal];
    [searchBtn setTitleColor:[UIColor colorWithHex:0x888888] forState:UIControlStateNormal];
    searchBtn.titleLabel.font = Font_Scale_375(14);//[UIFont systemFontOfSize:14];
    [searchBtn setImage:[UIImage imageNamed:@"icon_search"] forState:UIControlStateNormal];
    searchBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    searchBtn.imageEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
    searchBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    [self.navBar addSubview:searchBtn];
    

    //    self.navigationItem.titleView = navBar;
    [self.view addSubview:self.navBar];
    
    [searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
    
        make.left.equalTo(self.navBar).offset(kRatio_Scale_375(15));
        make.bottom.equalTo(self.navBar).offset(-kRatio_Scale_375(10));
        make.right.equalTo(self.navBar).offset(-kRatio_Scale_375(15));
        make.height.offset(kRatio_Scale_375(24));
    }];
    
}



#pragma mark - 初始化表格区域
/**
 *  初始化表格区域
 */
- (void)initTableView{
    self.tableview.delegate= self;
    self.tableview.dataSource= self;
    [self.tableview registerNib:[UINib nibWithNibName:@"NewsInfoCell" bundle:nil] forCellReuseIdentifier:@"NewsInfoCell"];
    [self.tableview registerNib:[UINib nibWithNibName:@"HomeCell" bundle:nil] forCellReuseIdentifier:@"HomeCell"];
    // 隐藏无用单元格分割线
    self.tableview.tableFooterView = [[UIView alloc] init];
    self.tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableview.backgroundColor = [UIColor clearColor];
    NSString *version = [UIDevice currentDevice].systemVersion;
    if (version.doubleValue >= 9.0) {
        // 针对 9.0 以上的iOS系统进行处理
        self.tableview.contentInset = UIEdgeInsetsMake(-20, 0, 0, 0);
    } else {
        // 针对 9.0 以下的iOS系统进行处理
    }
    
}

#pragma mark - 请求网络轮播图信息
/**
 *  请求网络轮播图信息
 */
- (void)loadNet{
    //1.创建网络状态监测管理者
//    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            [self.newsBL queryNoticeInfo];
            [self.newsBL requestBannersList];
            [self.newsBL requestNewsListWithType:@"100" andpageNum:1 andpagesize:3];
            _hasnet = YES;
        }else{
            _hasnet = NO;
        }
    }];
}

#pragma mark - 获取通知公告信息回调
-(void)queryNoticeInfoSucceed:(NoticeBean *)noticebean {
    
    NSString *content = noticebean.content;
    if ([Util IsStringNil:content]) {
        self.hasgonggao = NO;
    }else{
        self.hasgonggao = YES;
        self.gonggao = content;
        self.isgo = noticebean.is_details;
        
        [self.tableview reloadData];
    }
}

-(void)queryNoticeInfoFailed:(NSString *)error {
    
    self.hasgonggao = NO;
    DMLog(@"没有获取到通知公告的原因：%@",error);
}

#pragma mark - 新闻列表回调
-(void)requestNewsListSucceed:(NSMutableArray *)dictList{
    [self.newsInfoList removeAllObjects];
    for (int i = 0; i < dictList.count; i++) {
        NewsBean *bean =dictList[i];
        //图片改为base64返回，
        NSString *pngurl = [bean.pngurl stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([Util IsStringNil:pngurl]) {
            NSString *url = [NSString stringWithFormat:@"%@%@;",PNG_HOST,@""];
            bean.pngurl = url;
            [self.newsInfoList addObject:bean];
        }else{
            NSArray *array = [pngurl componentsSeparatedByString:@";"];
            NSString *pgurl = array[0];
            NSString *url = [NSString stringWithFormat:@"%@%@;",PNG_HOST,pgurl];
            bean.pngurl = url;
            [self.newsInfoList addObject:bean];
        }
        //图片改为base64返回，
    }
    
    NSIndexSet *indexSet=[[NSIndexSet alloc]initWithIndex:1];
    [self.tableview reloadSections:indexSet withRowAnimation:UITableViewRowAnimationNone];
    [self.tableview reloadData];
}

-(void)requestNewsListFailed:(NSString *)error{
//    [MBProgressHUD showError:error];
}

#pragma mark - 首页轮播图回调
-(void)requestBannersListSucceed:(NSMutableArray *)dictList{
    
    [self.pngUrlArray removeAllObjects];
    [self.bannerUrlArray removeAllObjects];
    [self.bannertitleArray removeAllObjects];
    [self.BannerBeanArray removeAllObjects];
    
    for (int i = 0; i < dictList.count; i++) {
        BannerBean *bean =dictList[i];
        
        DMLog(@"首页轮播图回调--TF--%@",dictList);
        DMLog(@"bean.pngurl-%@",bean.pngurl);
        DMLog(@"bean.url-%@",bean.url);
        DMLog(@"bean.title-%@",bean.title);
        DMLog(@"bean.remarks-%@",bean.remarks);
        
        NSString *pngurl = [bean.pngurl stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([Util IsStringNil:pngurl]) {
            NSString *url = [NSString stringWithFormat:@"%@%@",PNG_HOST,@""];
            bean.pngurl = url;
            DMLog(@"轮播图URL-%@",url);
            [self.pngUrlArray addObject:url];
        }else{
            NSArray *array = [pngurl componentsSeparatedByString:@";"];
            NSString *pgurl = array[0];
            NSString *url = [NSString stringWithFormat:@"%@%@",PNG_HOST,pgurl];
            bean.pngurl = url;
            DMLog(@"轮播图URL-%@",url);
            [self.pngUrlArray addObject:url];
        }
        
        NSString * bannerUrl = [bean.url stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([Util IsStringNil:bannerUrl]) {

            [self.bannerUrlArray addObject:@""];
        }else{
            [self.bannerUrlArray addObject:bannerUrl];
        }
        
        NSString * title = [bean.title stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([Util IsStringNil:title]) {
            
            [self.bannertitleArray addObject:@""];
        }else{
            [self.bannertitleArray addObject:title];
        }
        [self.BannerBeanArray addObject:bean];
    }
    
    NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
}

-(void)requestBannersListFailed:(NSString *)error{
    
//    [MBProgressHUD showError:error];
}

-(void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.tabBarController.tabBar.hidden = NO;
    [self setupNavigationBarStyle];
    [self loadNet];
    
    // 如果你发现你的CycleScrollview会在viewWillAppear时图片卡在中间位置，你可以调用此方法调整图片位置
    [self.cycleScrollView adjustWhenControllerViewWillAppera];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat minAlphaOffset = 0;
    //- 64;
    CGFloat maxAlphaOffset = 100;
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat alpha = (offset - minAlphaOffset) / (maxAlphaOffset - minAlphaOffset);
    NSLog(@"scrollViewDidScroll: %f", scrollView.contentOffset.y);
    NSLog(@"888888: %f", alpha);
    
    self.navBar.backgroundColor = [[UIColor colorWithHex:0xfdb731] colorWithAlphaComponent:alpha];
    
    if (alpha < -0.1) {
        
        self.navBar.hidden = YES;
    } else {
        self.navBar.hidden = NO;
    }
    
    if(scrollView.contentOffset.y<0){//禁止下拉
        scrollView.contentOffset = CGPointMake(0, 0);
    }
}

-(BOOL)scrollViewShouldScrollToTop:(UIScrollView *)scrollView{
    return NO;
}


// 没有网络时的资讯列表界面
- (void)initWithNoDataView {
    
    if (!_noDataView) {
        
        self.noDataView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 320)];
        
        
        UIImage *img_noweb = [UIImage imageNamed:@"img_noweb"];
        self.noDataImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - img_noweb.size.width/2 , 10, img_noweb.size.width, img_noweb.size.height)];
        self.noDataImgView.image =img_noweb;
        
        self.noDataLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, self.noDataImgView.frame.origin.y + self.noDataImgView.frame.size.height + 10, SCREEN_WIDTH - 40, 20)];
        self.noDataLabel.text = @"当前网络不可用，请检查网络设置";
        self.noDataLabel.textAlignment = NSTextAlignmentCenter;
        self.noDataLabel.font = [UIFont systemFontOfSize:14];
        
        UIButton *btn_refresh = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_refresh.frame = CGRectMake(20, self.noDataLabel.frame.origin.y + self.noDataLabel.frame.size.height + 10, SCREEN_WIDTH - 40, 40);
        btn_refresh.backgroundColor = [UIColor colorWithHex:0xfdb731];
        [btn_refresh setTitle:@"重新刷新" forState:0];
        [btn_refresh setTitleColor:[UIColor whiteColor] forState:0];
        btn_refresh.layer.cornerRadius = 5;
        [btn_refresh addTarget:self action:@selector(btnrefreshClick) forControlEvents:UIControlEventTouchUpInside];
        
        [self.noDataView addSubview:self.noDataImgView];
        [self.noDataView addSubview:self.noDataLabel];
        [self.noDataView addSubview:btn_refresh];
    }
    
    if (_hasnet) {
        
        self.noDataImgView.image = [UIImage imageNamed:@"img_busy"];
        self.noDataLabel.text = @"服务暂不可用，请稍后重试";
    }else{
        
        self.noDataImgView.image = [UIImage imageNamed:@"img_noweb"];
        self.noDataLabel.text = @"当前网络不可用，请检查网络设置";
    }
}

#pragma mark - 重新刷新
- (void)btnrefreshClick {
    
    //1.创建网络状态监测管理者
    //    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            
            [self.newsBL requestNewsListWithType:@"100" andpageNum:1 andpagesize:3];
            _hasnet = YES;
        }else{
            _hasnet = NO;
        }
    }];
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
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
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark  - TableView
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
{
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        if (self.hasgonggao) {
            return 3;
        }else{
            return 2;
        }
    }else {
        
        if (self.newsInfoList.count == 0) {
            
            return 1;
        }else {
            
            return self.newsInfoList.count + 1;
        }
        
//        return self.newsInfoList.count + 1;
    }
}

#pragma mark - 设置分组头部标题的高度
-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0.1;
    } else {
        return NEW_CELL_HEAD_HEIGHT;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section==0) {
        return 10.0;
    }else{
        NSString *version = [UIDevice currentDevice].systemVersion;
        if (version.doubleValue >= 11.0) {
            return 0.1;
        } else {
            return 50.0;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    __weak typeof(self) weakSelf = self;
    
    if (indexPath.section == 1) {
        
        if (self.newsInfoList.count == 0) {
            
            static NSString *noDataCell = @"noDataCell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:noDataCell];
            if (cell == nil) {
                
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noDataCell];
                
            }
            cell.backgroundColor = [UIColor whiteColor];
            [self initWithNoDataView];
            [cell.contentView addSubview:self.noDataView];
            
            return cell;
            
        }else {
            
            if (indexPath.row==self.newsInfoList.count) {
                static NSString *bottomcell = @"bottomcell";
                
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:bottomcell];
                
                if (cell == nil)
                {
                    cell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:bottomcell];
                }
                cell.textLabel.text = @"点击查看更多>>";
                cell.textLabel.textAlignment = NSTextAlignmentCenter;
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                cell.textLabel.textColor = [UIColor colorWithHex:0x999999];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }else {
                // 创建单元格
                static NSString *NewsID = @"NewsInfoCell";
                NewsInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:NewsID];
                if ( nil == cell ){
                    cell = [[NewsInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:NewsID];
                }
                
                // 单元格赋值
                NewsBean *bean = self.newsInfoList[indexPath.row];
                if (bean== nil) {
                    cell.NewsBg.image = [UIImage imageNamed:@"img_nopic_s"];
                    cell.Title.text = @"暂无数据";
                    cell.Pubtime.text = @"暂无数据";
                }else{
                    DMLog(@"\n最新资讯中的配图--%@\n",bean.pngurl);
                    
                    [cell.NewsBg sd_setImageWithURL:[NSURL URLWithString:bean.pngurl] placeholderImage:[UIImage imageNamed:@"img_nopic_s"]];
                    cell.Title.text = nil==bean.title?@"无":bean.title;
                    cell.Pubtime.text = nil==bean.subtime?@"无":bean.subtime;
                }
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                return cell;
            }
            
        }
        
        
    }else {
        if (indexPath.row == 0) {
            
            // 轮播图
            
            static NSString *identifier7 = @"identifier7";
            if ( self.HomePageCellImage == nil)
            {
                self.HomePageCellImage = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identifier7];
             
                // 网络加载 --- 创建带标题的图片轮播器CYCLE_VIEW_HEIGHT+61
                self.cycleScrollView = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_WIDTH/375.0*184.0) delegate:self placeholderImage:[UIImage imageNamed:@"banner"]];
                self.cycleScrollView.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
                self.cycleScrollView.currentPageDotColor = [UIColor whiteColor]; // 自定义分页控件小圆标颜色
                [self.HomePageCellImage addSubview:self.cycleScrollView];
                
//                UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"bg_search1"]];
//                imageView.frame = CGRectMake(15, 25, SCREEN_WIDTH-30, (SCREEN_WIDTH-30)/690.0*60);
//                [self.HomePageCellImage addSubview:imageView];
//
//                UIButton *searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
//                searchButton.frame = CGRectMake(15, 25, SCREEN_WIDTH-30, (SCREEN_WIDTH-30)/690.0*60);
//                [searchButton setImageEdgeInsets:UIEdgeInsetsMake(20, 0, 0, 0)];
//                //[searchButton setImage:[UIImage imageNamed:@"bg_search1"] forState:UIControlStateNormal];
//                [searchButton addTarget:self action:@selector(searchButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//                self.HomePageCellImage.backgroundColor = [UIColor clearColor];
//                [self.HomePageCellImage addSubview:searchButton];
            }
            
            
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                
                if (self.pngUrlArray.count > 0) {
                    
                    self.cycleScrollView.imageURLStringsGroup = self.pngUrlArray;
                }
            });
            
            return self.HomePageCellImage;
        }else {
            if (self.hasgonggao) {
                if (indexPath.row == 1) {
                    static NSString *noticecell = @"noticecell";
                    
                    if (self.HomeNoticeCell == nil)
                    {
                        self.HomeNoticeCell =[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:noticecell];
                        
                        self.HomeNoticeCell.backgroundColor = [UIColor colorWithHex:0xfffcf1];
                        
                        self.HomeNoticeCell.selectionStyle = UITableViewCellSelectionStyleNone;
                        
                        self.rollingImg = [[UIImageView alloc] initWithFrame:CGRectMake(16, 12, 15, 14)];
                        self.rollingImg.image = [UIImage imageNamed:@"icon_notice"];
                        [self.HomeNoticeCell.contentView addSubview:self.rollingImg];
                        
                        self.rollinglabel = [[YFRollingLabel alloc] initWithFrame:CGRectMake(36, 10, SCREEN_WIDTH - 46, 16) textArray:@ [self.gonggao] font:[UIFont systemFontOfSize:12] textColor:[UIColor colorWithHex:0x333333]];
                        
                        [self.HomeNoticeCell.contentView addSubview:self.rollinglabel];
                        self.rollinglabel.speed = 0.7;
                        [self.rollinglabel setOrientation:RollingOrientationLeft];
                        [self.rollinglabel setInternalWidth:self.rollinglabel.frame.size.width / 3];;
                        
                        //Label Click Event Using Block
                        self.rollinglabel.labelClickBlock = ^(NSInteger index){
                            DMLog(@"点击了滚动文字");
                            [weakSelf GoTzgg];
                        };
                    }
                    
                    return self.HomeNoticeCell;
                    
                }else{
                    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
                    if ( nil == cell ){
                        cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
                    }
                    [cell.Btn1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn5 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn6 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn7 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn8 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn9 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn10 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn11 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn12 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn13 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
                }
            }else {
                    HomeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HomeCell"];
                    if ( nil == cell ){
                        cell = [[HomeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"HomeCell"];
                    }
                    [cell.Btn1 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn2 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn3 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn4 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn5 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn6 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn7 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn8 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn9 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn10 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn11 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn12 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell.Btn13 addTarget:self action:@selector(btnPressed:) forControlEvents:UIControlEventTouchUpInside];
                    
                    return cell;
            }
        }
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    if (section != 0) {
        CGRect headerframe = CGRectMake(0,0,self.tableview.frame.size.width,NEW_CELL_HEAD_HEIGHT);
        
        UIView *headerview = [[UIView alloc] initWithFrame:headerframe];
        headerview.backgroundColor = [UIColor whiteColor];
        UILabel *titlb = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, 120, 20)];
        titlb.text = @"最新资讯";
        titlb.textColor = [UIColor colorWithHex:0xfdb731];
        
        UIView *bkline = [[UIView alloc] initWithFrame:CGRectMake(0, 40, SCREEN_WIDTH, 1)];
        bkline.backgroundColor = [UIColor colorWithHex:0xe7e7e7];
        
        UILabel *line = [[UILabel alloc] initWithFrame:CGRectMake(15, 39, 70, 2)];
        line.text = @"";
        line.textColor = [UIColor colorWithHex:0xfdb731];
        line.backgroundColor = [UIColor colorWithHex:0xfdb731];
        
        [headerview addSubview:titlb];
        [headerview addSubview:line];
        [headerview addSubview:bkline];
        
        return headerview;

    }else{
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (section==0) {
        CGRect footerframe = CGRectMake(0,0,self.tableview.frame.size.width,10);
        
        UIView *footerview = [[UIView alloc] initWithFrame:footerframe];
        footerview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        return footerview;
    }else{
        CGRect footerframe = CGRectMake(0,0,self.tableview.frame.size.width,50);
        
        UIView *footerview = [[UIView alloc] initWithFrame:footerframe];
        footerview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        return footerview;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int heigt;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
       heigt = 360;      //
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        heigt = 320;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        heigt = 270;
    }
    else //3.5寸屏幕
    {
        heigt = 240;
    }

    if (indexPath.section == 0)
    {
        if (indexPath.row==0) {
            return SCREEN_WIDTH/375.0*184.0;//CYCLE_VIEW_HEIGHT+61;
        }else{
            if (self.hasgonggao) {
                if (indexPath.row == 1) {
                    return 36;
                }else{
                    return heigt;
                }
            }else{
                return heigt;
            }
        }
    }
    if (indexPath.section == 1) {
        
        if (self.newsInfoList.count == 0) {
            
            return 320;
        }else {
            
            if (indexPath.row == 3) {
                
                return 50;
            }else {
                return NEW_CELL_HEIGHT;
            }
        }
        
    }
    
    return 0;
    
//    else if (indexPath.section==1&&indexPath.row==3) {
//        return 50;
//    }else {
//        return  NEW_CELL_HEIGHT;
//    }
}

#pragma mark - 点击按钮事件
- (void)btnPressed:(UIButton *) button
{
    NSUInteger BtnTag = [button tag];
    if (BtnTag==TAG_BUTTON_MIDDLE1) {                // 参保信息
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {   //未登录

            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
            
        }else{
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            CanBaoInfoVC *VC = [SB instantiateViewControllerWithIdentifier:@"CanBaoInfoVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE2) {       // 缴费记录
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {  //未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            WuXianPaymentVC *VC = [SB instantiateViewControllerWithIdentifier:@"WuXianPaymentVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE4) {      // 市民卡账户
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/account_info.html?" forKey:@"url"];
            [VC setValue:@"市民卡账户" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE6) {     // 检查检验单
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            if (_hasnet) {
                
                //无卡权限拦截
                if(![YWManager sharedManager].isHasCard){
                    
                    [self showNoCardTips];
                    return ;
                }
                
                //无卡-实人认证-权限拦截
                if(![self isAuthenticatedAndHasNoCard]) return;
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle: nil];
                CheckListVC *VC = [SB instantiateViewControllerWithIdentifier:@"CheckListVC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE7) {    // 公共自行车
        
        DXBPublicBlikeVC *VC = [[DXBPublicBlikeVC alloc] init];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else if (BtnTag==TAG_BUTTON_MIDDLE9) {     // 定点医院->大病保险
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
            registPaymentVC.registAndPaymentType = EPRegistAndPaymentSeriousIllness;
            [self.navigationController pushViewController:registPaymentVC animated:YES];
        }

    }else if (BtnTag==TAG_BUTTON_MIDDLE10) {    // 市民卡预挂失
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            GuaShiVC *VC = [SB instantiateViewControllerWithIdentifier:@"GuaShiVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE11) {    // 家庭账户授权
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            //无卡权限拦截
            if(![YWManager sharedManager].isHasCard){
                
                [self showNoCardTips];
                return ;
            }
            //无卡-实人认证-权限拦截
            if(![self isAuthenticatedAndHasNoCard]) return;
            
            UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/account_auth_step1.html?" forKey:@"url"];
            [VC setValue:@"家庭账户授权" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
    }else if (BtnTag==TAG_BUTTON_MIDDLE12 || BtnTag==TAG_BUTTON_MIDDLE13){
        self.tabBarController.selectedIndex = 1;
    }else{
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) { // 未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            if (_hasnet) {
                [self CheckSrrzStatusWithTag:BtnTag];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
    }
}
#pragma mark - 点击轮播图进行跳转
-(void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index{
    DMLog(@"轮播图点击%li",index);
    
    
    if(self.bannerUrlArray[index] == nil || [self.bannerUrlArray[index] isEqualToString:@""]){
        return;
    }else{
        UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
        BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
        VC.url = self.bannerUrlArray[index];
        VC.title = self.bannertitleArray[index];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
//    if (indexPath.section == 0) {
//        if (self.hasgonggao) {
//            if ([self.isgo isEqualToString:@"1"]) {
//                if (indexPath.row == 1) {  // 通知公告跳转链接
//                    UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
//                    BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
//                    [VC setValue:@"/h5/notice.html?" forKey:@"url"];
//                    [VC setValue:@"通知公告" forKey:@"tit"];
//                    VC.hidesBottomBarWhenPushed=YES;
//                    [self.navigationController pushViewController:VC animated:YES];
//                }
//            }
//        }
//    }
    
    if (indexPath.section==1) {
        if (indexPath.row==self.newsInfoList.count) {
            self.tabBarController.selectedIndex = 2;
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
            NewsDetailVC *VC = [SB instantiateViewControllerWithIdentifier:@"NewsDetailVC"];
            VC.hidesBottomBarWhenPushed=YES;
            NewsBean *bean = self.newsInfoList[indexPath.row];
            DMLog(@"%@",bean);
            [VC setValue:bean.id forKey:@"ID"];
            [VC setValue:bean forKey:@"news"];
            [self.navigationController pushViewController:VC animated:YES];
        }
    }
}

#pragma mark - 实人认证弹窗
-(void)showSRRZView{
    SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"认证");

        
        if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
            DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
            
        }else{//实人认证-和谐卡-信息核对
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
            DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
            VC.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }];
    //[self.view addSubview:lll];
    __block UIView * blockView = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
        
        //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
        for (NSObject * window in [UIApplication sharedApplication].windows) {
            if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                blockView = (UIView *)window;
            }
        }
        
        [blockView addSubview:lll];
        
    });
}

#pragma mark - 实人认证状态查询接口
-(void)CheckSrrzStatusWithTag:(NSUInteger)tag{
    
    
    if(![YWManager sharedManager].isHasCard){//无卡的时候
        
        [self hasNoCardActionWithTag:tag];
        return;
    }
    
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_STATUS_URL];
    DMLog(@"url=%@",url);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        self.HUD.hidden = YES;
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",resultDict);
        if ([resultDict isKindOfClass:[NSNull class]] || resultDict==nil) {
            DMLog(@"服务暂不可用，请稍后重试");
        }else{
            @try {
                NSNumber *resultTag = [resultDict objectForKey:@"success"];
                if (resultTag.boolValue==YES)
                {
                    NSArray *arrTemp = [[NSArray alloc] init];
                    arrTemp = [resultDict objectForKey:@"data"];
                    //NSDictionary *dict = arrTemp[0];
                    SrrzBean *bean = [SrrzBean mj_objectWithKeyValues:arrTemp];
                    BOOL  isblack = [bean.blackFlag isEqualToString:@"1"];
                    if (isblack) {  // 社保黑名单
                        ModifyCardView *vv = [ModifyCardView alterViewWithcontent:@"    您已被拉入实人认证黑名单，不能进行实人认证！" sure:@"我知道了" sureBtClcik:^{
                            // 点击我知道了按钮
                            DMLog(@"我知道了！");
                        }];
                        //弹出提示框；
                        [self.view addSubview:vv];
                    }else{
                        if ([bean.renzhengStatus isEqualToString:@"1"]) {  // 认证成功
                            if (tag==TAG_BUTTON_MIDDLE3) {   // 实人认证
                                [MBProgressHUD showError:@"您已经实人认证！"];
                            }else if (tag==TAG_BUTTON_MIDDLE5) {     // 就诊挂号
                                if (_hasnet) {
                                    
                                    //无卡权限拦截
                                    if(![YWManager sharedManager].isHasCard){
                                        
                                        [self showNoCardTips];
                                        return ;
                                    }
                                    
                                    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                                    GHH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"GHH5VC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }else{   // 医保移动支付
                                if (_hasnet) {
                                    
                                    
                                    if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
                                        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
                                        loginVC.isFromRegist = YES;
                                        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
                                        [self presentViewController:navVC animated:YES completion:nil];
                                    }else{
                                        
                                        YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
                                        registPaymentVC.registAndPaymentType = EPRegistAndPaymentResidentTreatment;
                                        [self.navigationController pushViewController:registPaymentVC animated:YES];
                                    }
                                    return;
                                    
                                    //无卡权限拦截
                                    if(![YWManager sharedManager].isHasCard){
                                        
                                        [self showNoCardTips];
                                        return ;
                                    }
                                    
                                    
                                    if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {
                                        if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {
                                            UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                            YBzxH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBzxH5VC"];
                                            VC.hidesBottomBarWhenPushed=YES;
                                            [self.navigationController pushViewController:VC animated:YES];
                                        }else{
                                            UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                            YBydH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBydH5VC"];
                                            VC.hidesBottomBarWhenPushed=YES;
                                            [self.navigationController pushViewController:VC animated:YES];
                                        }
                                    }else{
                                        [MBProgressHUD showError:@"抱歉，和谐卡暂不支持该功能~"];
                                    }
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }
                        }else if ([bean.renzhengStatus isEqualToString:@"5"]){   // 未认证
                            if (_hasnet) {
                                if (tag==TAG_BUTTON_MIDDLE3) {   // 实人认证
                                    if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                                        
                                        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                                        DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                                        VC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                        
                                    }else{//实人认证-和谐卡-信息核对
                                        
                                        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                                        DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                                        VC.hidesBottomBarWhenPushed = YES;
                                        [self.navigationController pushViewController:VC animated:YES];
                                    }
                                }else{
                                    [self showSRRZView];
                                }
                            }else{
                                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                            }
                        }else{              // 认证不通过
                            
                            [self showSRRZView];
                            return;
                        }
                    }
                }else{
                    NSString *msg = [resultDict objectForKey:@"message"];
                    [MBProgressHUD showError:msg];
                }
            } @catch (NSException *exception) {
                DMLog(@"%@",exception);
            }
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        self.HUD.hidden = YES;
    }];
}

#pragma mark - 通知公告跳转
-(void)GoTzgg {
    if ([self.isgo isEqualToString:@"1"]) {
        UIStoryboard * SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
        BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
        [VC setValue:@"/h5/notice.html?" forKey:@"url"];
        [VC setValue:@"通知公告" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }
}
#pragma mark - 搜索按钮点击事件
-(void)searchButtonClick:(UIButton *)searchButtonClick{
    
    DTFSearchVC * searchVC = [[DTFSearchVC alloc]init];
    [self.navigationController pushViewController:searchVC animated:YES];
    
    
}


#pragma mark - 提示无卡
-(void)showNoCardTips{
    
    
    [EPTipsView sharedTipsView].leftButtonColor = [UIColor colorWithHex:0xFDB731];
    [EPTipsView ep_showAlertView:@"未查询到您名下的卡片信息，不能进行相关操作！" buttonText:@"我知道了" toView:self.tabBarController.view  buttonBlock:^{
        
    }];
    
}

/** 无卡 */
-(void)hasNoCardActionWithTag:(NSUInteger)tag{
    
    DMLog(@"无卡用户");
    
    
    if([YWManager sharedManager].isAuthentication){//实人认证通过
        
        if (tag==TAG_BUTTON_MIDDLE3) {   // 实人认证
            [MBProgressHUD showError:@"您已经实人认证！"];
        }else if (tag==TAG_BUTTON_MIDDLE5) {     // 就诊挂号
            if (_hasnet) {
                
                //无卡权限拦截
                if(![YWManager sharedManager].isHasCard){
                    
                    [self showNoCardTips];
                    return ;
                }
                
                UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                GHH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"GHH5VC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }else{   // 医保移动支付->城乡居民医疗
            if (_hasnet) {
                
                if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
                    YWLoginVC * loginVC = [[YWLoginVC alloc]init];
                    loginVC.isFromRegist = YES;
                    DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
                    [self presentViewController:navVC animated:YES completion:nil];
                }else{
                    
                    YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
                    registPaymentVC.registAndPaymentType = EPRegistAndPaymentResidentTreatment;
                    [self.navigationController pushViewController:registPaymentVC animated:YES];
                }
                
                return;
                
                if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
                    YWLoginVC * loginVC = [[YWLoginVC alloc]init];
                    loginVC.isFromRegist = YES;
                    DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
                    [self presentViewController:navVC animated:YES completion:nil];
                }else{
                    YWRegistAndPaymentVC *registPaymentVC= [[YWRegistAndPaymentVC alloc]init];
                    registPaymentVC.registAndPaymentType = EPRegistAndPaymentSeriousIllness;
                    [self.navigationController pushViewController:registPaymentVC animated:YES];
                }
                return;
                
//                //无卡权限拦截
//                if(![YWManager sharedManager].isHasCard){
//
//                    [self showNoCardTips];
//                    return ;
//                }
//
//
//                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {
//                    if ([[CoreArchive strForKey:LOGIN_YDZF_STATUS] isEqualToString:@"1"]) {
//                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
//                        YBzxH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBzxH5VC"];
//                        VC.hidesBottomBarWhenPushed=YES;
//                        [self.navigationController pushViewController:VC animated:YES];
//                    }else{
//                        UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
//                        YBydH5VC *VC = [MB instantiateViewControllerWithIdentifier:@"YBydH5VC"];
//                        VC.hidesBottomBarWhenPushed=YES;
//                        [self.navigationController pushViewController:VC animated:YES];
//                    }
//                }else{
//                    [MBProgressHUD showError:@"抱歉，和谐卡暂不支持该功能~"];
//                }
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
        
    }else{//实人认证未通过
        
        [self showSRRZView];
        
//        NSString *msg = @"   因您上传照片不符合实人认证要求，无法继续使用该功能，请重新进行实人认证。";
//        RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"重新认证" cancelBtClcik:^{
//            //取消按钮点击事件
//            DMLog(@"取消");
//        } sureBtClcik:^{
//            //重新认证点击事件
//            DMLog(@"重新认证");
//            if (_hasnet) {
//                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
//
//                    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
//                    DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
//                    VC.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:VC animated:YES];
//
//                }else{//实人认证-和谐卡-信息核对
//
//                    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
//                    DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
//                    VC.hidesBottomBarWhenPushed = YES;
//                    [self.navigationController pushViewController:VC animated:YES];
//                }
//            }else{
//                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
//            }
//        }];
//        [self.view addSubview:lll];
    }
}


/**
 实人认证拦截-登录-无卡-实人认证通过

 @return 是否继续后面的操作
 */
-(BOOL)isAuthenticatedAndHasNoCard{
    
    if([YWManager sharedManager].isAuthentication){//实人认证通过
        
        return YES;
    }else{//实人认证未通过
        
        if([YWManager sharedManager].isHasCard){//有卡
            
            
            SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
                //取消按钮点击事件
                DMLog(@"取消");
            } sureBtClcik:^{
                //确定按钮点击事件
                DMLog(@"认证");
                
                
                if ([[CoreArchive strForKey:LOGIN_CARD_TYPE] isEqualToString:@"1"]) {// 实人认证-市民卡-信息核对
                    
                    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                    DTFCitizenCardInfoConfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFCitizenCardInfoConfirmVC"];
                    VC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:VC animated:YES];
                    
                }else{//实人认证-和谐卡-信息核对
                    
                    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Authenticate" bundle:nil];
                    DTFHarmoCardInfoComfirmVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFHarmoCardInfoComfirmVC"];
                    VC.hidesBottomBarWhenPushed = YES;
                    [self.navigationController pushViewController:VC animated:YES];
                }
                
            }];
            //[self.view addSubview:lll];
            __block UIView * blockView = nil;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
                
                //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
                for (NSObject * window in [UIApplication sharedApplication].windows) {
                    if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                        blockView = (UIView *)window;
                    }
                }
                
                [blockView addSubview:lll];
                
            });
            return NO;
        }else{//无卡
            
            return NO;
        }
    }
}


#pragma mark - showLoadingUI
/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.label.text = @"加载中";
    self.HUD.hidden = NO;
}


@end
