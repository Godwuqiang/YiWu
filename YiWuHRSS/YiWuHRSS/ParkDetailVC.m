//
//  ParkDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ParkDetailVC.h"
#import "ParkDetailOneCell.h"
#import <MapKit/MapKit.h>
#import "KCAnnotation.h"
#import "WebBL.h"


@interface ParkDetailVC ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate,WebBLDelegate>{
    MKMapView  *MapView;
}

@property (nonatomic, strong)    WebBL     *webBL;
// 控件
@property (nonatomic, strong) MBProgressHUD    *HUD;
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;

@property (nonatomic, strong) ParkBean *pbean;

@end

@implementation ParkDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    self.navigationItem.title = [NSString stringWithFormat:@"%@详情",self.bt];
    self.navigationItem.title = @"停车场详情";
    HIDE_BACK_TITLE;
    [self initData];
    [self afn];
}

#pragma mark -  初始化数据
-(void)initData{
    
    self.webBL = [WebBL sharedManager];
    self.webBL.delegate = self;
    
    self.Brieftableview.dataSource = self;
    self.Brieftableview.delegate = self;
    [self.Brieftableview registerNib:[UINib nibWithNibName:@"ParkDetailOneCell" bundle:nil] forCellReuseIdentifier:@"ParkDetailOneCell"];
    
    self.Brieftableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.Brieftableview.tableFooterView = [[UIView alloc] init];
    self.Brieftableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    self.Tsview.hidden = YES;
    self.Dwbtn.hidden = YES;
    self.Dhbtn.hidden = YES;
    self.tbbottom.constant = 45;
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
            self.Tsview.hidden = NO;
            self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
            self.Tslb.text = @"当前网络不可用，请检查网络设置";
            self.Tsbtn.hidden = NO;
            [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
        }
    }];
}

#pragma mark -  请求数据
-(void)loadData{
    
    [self showLoadingUI];
    NSString *lat = nil==[CoreArchive strForKey:CURRENT_LAT]?@"29.293017":[CoreArchive strForKey:CURRENT_LAT];
    NSString *lng = nil==[CoreArchive strForKey:CURRENT_LON]?@"120.063697": [CoreArchive strForKey:CURRENT_LON];
    [self.webBL queryParkInfoWithLongitude:lng andLatitude:lat andId:self.PID];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

#pragma mark - 获取公共汽车停车位单个信息接口回调
-(void)queryParkInfoSucceed:(ParkBean *)bean {
    
    self.HUD.hidden = YES;
    if ([Util IsStringNil:bean.longitude] || [Util IsStringNil:bean.latitude]) { // 没有经纬度 不显示地图
        self.Dwbtn.hidden = YES;
        self.Dhbtn.hidden = YES;
        self.tbbottom.constant = 0;
    }else{
        self.Dwbtn.hidden = NO;
        self.Dhbtn.hidden = NO;
        self.tbbottom.constant = 45;
    }
    self.pbean = bean;
    [self.Brieftableview reloadData];
}

-(void)queryParkInfoFailed:(NSString*)error {
    
    self.HUD.hidden = YES;
    if ([error isEqualToString:@"当前网络不可用，请检查网络设置"]) {
        self.Tsview.hidden = NO;
        self.Tsimg.image = [UIImage imageNamed:@"img_noweb"];
        self.Tslb.text = @"当前网络不可用，请检查网络设置";
        self.Tsbtn.hidden = NO;
        [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
    }else{
        self.Tsview.hidden = NO;
        self.Tsimg.image = [UIImage imageNamed:@"img_busy"];
        self.Tslb.text = @"服务暂不可用，请稍后重试";
        self.Tsbtn.hidden = NO;
        [self.Tsbtn addTarget:self action:@selector(refreshUI) forControlEvents:UIControlEventTouchUpInside];
    }
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([Util IsStringNil:self.pbean.longitude] || [Util IsStringNil:self.pbean.latitude]) { // 没有经纬度 不显示地图
        return 1;
    }else{
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section==0) {
        return 132;
    }else{
        if ([Util IsStringNil:self.pbean.longitude] || [Util IsStringNil:self.pbean.latitude]) { // 没有经纬度
            return 0;
        }else{
            
            int gao1;
            //区别屏幕尺寸
            if ( SCREEN_HEIGHT > 667) //6p
            {
                gao1 = 473;
            }
            else if (SCREEN_HEIGHT > 568)//6
            {
                gao1 = 405;
            }
            else if (SCREEN_HEIGHT > 480)//5s
            {
                gao1 = 305;
            }
            else //3.5寸屏幕
            {
                gao1 = 265;
            }
            
            return gao1;
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    if ([Util IsStringNil:self.pbean.longitude] || [Util IsStringNil:self.pbean.latitude]) { // 没有经纬度 不显示地图
        return 0.1;
    }else{
        if (section==0) {
//            return 22.0;
            return 50.0;
        }else{
            return 0.1;
        }
    }
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    

    if (section == 0) {
        
        UIView *bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 50)];
        bgView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        UILabel *Lb = [[UILabel alloc] initWithFrame:CGRectMake(20, 5, SCREEN_WIDTH - 40, 40)];
        Lb.font = [UIFont systemFontOfSize:12];
        Lb.textColor = [UIColor colorWithHex:0x999999];
        Lb.numberOfLines = 0;
        Lb.textAlignment = NSTextAlignmentLeft;
        
        NSMutableAttributedString *str1 = [[NSMutableAttributedString alloc] initWithString:@"备注：如停车场数据异常，可致电义乌市城建资源经营有限责任公司客服热线：85500777。"];
        [str1 addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHex:0x666666] range:NSMakeRange(0,2)];
        Lb.attributedText = str1;
        [bgView addSubview:Lb];
        
        return bgView;
        
    }else {
        return nil;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        ParkDetailOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ParkDetailOneCell"];
        if ( nil == cell ){
            cell = [[ParkDetailOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ParkDetailOneCell"];
        }
        cell.parkbean = self.pbean;
        
        return cell;
    }else{
        if ([Util IsStringNil:self.pbean.longitude] || [Util IsStringNil:self.pbean.latitude]) { // 没有经纬度
            return nil;
        }else{
            static NSString  *ParkMapCellID = @"ParkMapCellID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ParkMapCellID];
            if ( nil == cell ){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ParkMapCellID];
            }
            MapView = [[MKMapView alloc] init];
            [cell.contentView addSubview:MapView];
            [MapView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.contentView.mas_top);
                make.left.equalTo(cell.contentView.mas_left);
                make.right.equalTo(cell.contentView.mas_right);
                make.bottom.equalTo(cell.contentView.mas_bottom);
            }];
            
            UIImageView *zn = [[UIImageView alloc] init];
            [cell.contentView addSubview:zn];
            [zn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(cell.contentView.mas_top).offset(8);
                make.right.equalTo(cell.contentView.mas_right).offset(-8);
                make.width.equalTo(@26);
                make.height.equalTo(@26);
            }];
            zn.image = [UIImage imageNamed:@"icon_map3"];
            
            MapView.delegate = self;
            
            //用户位置追踪(用户位置追踪用于标记用户当前位置，此时会调用定位服务)
            MapView.userTrackingMode=MKUserTrackingModeNone;
            MapView.showsUserLocation = NO;
            
            //设置地图类型
            MapView.mapType=MKMapTypeStandard;
            
            //添加大头针
            NSString *lat = nil==self.pbean.latitude?@"":self.pbean.latitude;
            NSString *lon = nil==self.pbean.longitude?@"":self.pbean.longitude;
            float laa = [lat floatValue];
            float loo = [lon floatValue];
            CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
            MapView.centerCoordinate = location;
            
            KCAnnotation *annotation = [[KCAnnotation alloc] init];
            annotation.coordinate = location;
            annotation.title = nil==self.pbean.parkname?@"":self.pbean.parkname;
            annotation.image=[UIImage imageNamed:@"map_icon"];
            [MapView addAnnotation:annotation];
            
            //放大到标注的位置
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
            [MapView setRegion:region animated:YES];
        
            return cell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[KCAnnotation class]]) {
        static NSString *key1=@"PAnnotationKey";
        MKAnnotationView *annotationView=[MapView dequeueReusableAnnotationViewWithIdentifier:key1];
        //如果缓存池中不存在则新建
        if (!annotationView) {
            annotationView=[[MKAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:key1];
            annotationView.canShowCallout=true;//允许交互点击
            annotationView.calloutOffset=CGPointMake(0, -1);//定义详情视图偏移量
        }
        
        //修改大头针视图
        //重新设置此类大头针视图的大头针模型(因为有可能是从缓存池中取出来的，位置是放到缓存池时的位置)
        annotationView.annotation=annotation;
        annotationView.image=((KCAnnotation *)annotation).image;//设置大头针视图的图片
        
        return annotationView;
    }else {
        return nil;
    }
}

#pragma mark - 开始导航按钮点击事件
- (IBAction)Dh:(id)sender {
    //路线规划
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {   //高德地图
        NSString *urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=&slon=&sname=&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0", [self.pbean.latitude floatValue], [self.pbean.longitude floatValue], self.pbean.parkname];
        NSString *sss = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sss]];
    } else {    //自带地图
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([self.pbean.latitude floatValue], [self.pbean.longitude floatValue]);
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil]];
        toLocation.name = self.pbean.parkname;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - 定位按钮点击事件
- (IBAction)Dw:(id)sender {
    
    NSString *lat = nil==self.pbean.latitude?@"":self.pbean.latitude;
    NSString *lon = nil==self.pbean.longitude?@"":self.pbean.longitude;
    float laa = [lat floatValue];
    float loo = [lon floatValue];
    CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
    MapView.centerCoordinate = location;
}

#pragma mark - 重新刷新按钮点击事件
-(void)refreshUI{
    [self afn];
}

@end
