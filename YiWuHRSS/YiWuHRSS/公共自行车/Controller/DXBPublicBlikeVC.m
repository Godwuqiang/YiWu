//
//  DXBPublicBlikeVC.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBPublicBlikeVC.h"
#import <CoreLocation/CLLocationManager.h>
#import "DXBCenterAnnotation.h"
#import "DXBBikeShowView.h"
#import "DXBSearchBikeVC.h"
#import "DXBAnnotationView.h"
#import "DXBMAPointAnnotation.h"
#import "HttpHelper.h"
#import "FindZFPsdView.h"
#import <MapKit/MapKit.h>



#define    PUBLIC_GETPUBLI_MOBILELIST_JSON     @"public/getPublicMobileList.json"  // 获取公共自行车停车位信息（无搜索）


@interface DXBPublicBlikeVC ()<MAMapViewDelegate, UITextFieldDelegate, SearchBikeDelegate> {
    
    NSMutableArray *all_arrayList;
    
    BOOL isShowView;    // 上部自行车信息弹出框
    BOOL isMoveView;//是否移动地图
    BOOL isSearchBike;  // 是从自行车页面搜索回来的
    CLLocationCoordinate2D currentCoordinate;
    
    DXBCenterAnnotation *centerAnnotation;  // 点标注数据
    MAAnnotationView *centerAnnoView;
    
    
    DXBMAPointAnnotation *BikeAnnotation;  // 搜索出来的标注
}


@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) DXBBikeShowView *showView;
@property (nonatomic, strong) UIButton *btn_local;
@property (nonatomic, strong) UIButton *btn_refresh;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;

@property (nonatomic, assign) CLLocationCoordinate2D startCoordinate; // 步行导航起点
@property (nonatomic, assign) CLLocationCoordinate2D endCoordinate;   // 步行导航终点

@property (nonatomic, strong) MAAnnotationView *userLocationAnnotationView;

@property (nonatomic, strong) NSString *selectedTitle;

/// 附近无自行车站点
@property (nonatomic, strong) UIImageView *noBikeImgView;

/// 标注的数据
@property (nonatomic, strong) NSMutableArray *mark_arrayList;

// 控件
@property(nonatomic, strong)   MBProgressHUD    *HUD;


//网络监控-无网络
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (nonatomic, strong)UIImageView *tipsImageView;
@property (nonatomic, strong)UILabel *tipsLabel;
@property (nonatomic, strong)UIButton *tipsButton;

@property (nonatomic, strong)  NSString *key;
@property (nonatomic, strong)  NSMutableArray *searchList;


@end

@implementation DXBPublicBlikeVC


-(AFNetworkReachabilityManager *)manger{

    if(_manger == nil){
    
        _manger = [AFNetworkReachabilityManager sharedManager];
    }
    return _manger;
}

- (NSMutableArray *)mark_arrayList {
    
    if (!_mark_arrayList) {
        _mark_arrayList = [[NSMutableArray alloc] init];
    }
    return _mark_arrayList;
}

- (UIImageView *)noBikeImgView {
    
    if (!_noBikeImgView) {
        
        _noBikeImgView = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH / 2 - 60, self.bgView.frame.size.height / 2 - 50, 120, 32)];
        _noBikeImgView.image = [UIImage imageNamed:@"label_bike2"];
        _noBikeImgView.hidden = YES;
        [self.mapView addSubview:_noBikeImgView];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 120, 26)];
        label.text = @"附近无自行车站点";
        label.textColor = [UIColor colorWithHex:0xffffff];
        label.textAlignment = NSTextAlignmentCenter;
        label.font = [UIFont systemFontOfSize:12];
        [_noBikeImgView addSubview:label];
    }
    return _noBikeImgView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    if(kIsiPhoneX){
        self.topConstrains.constant += 20;
    }
    
    self.navigationItem.title = @"公共自行车";
    HIDE_BACK_TITLE
    self.key = @"";
    
    self.tf_search.delegate =self;
    
    all_arrayList = [[NSMutableArray alloc] init];
    isMoveView = YES;
    
    
//    [self setUpData];
    [self setUpView];
    
    
    [self afn];
    
    self.mapView.customizeUserLocationAccuracyCircleRepresentation = YES;
    
    self.searchList = [[NSMutableArray alloc] init];
    
}

// iOS 系统地图定位背景蓝色圆圈去掉
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay {
    
    return nil;
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    [self setupNavigationBarStyle];
    
    

}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    
    
    DXBSearchBikeVC *searchVC = [[DXBSearchBikeVC alloc] init];
    searchVC.coordinate2D = currentCoordinate;
    searchVC.delegate = self;
    [searchVC setValue:self.key forKey:@"key"];
    searchVC.searchDataArr = self.searchList;
    [self.navigationController pushViewController:searchVC animated:YES];
    
    return NO;
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

- (void)setUpData {
    
//    all_arrayList = [[NSMutableArray alloc] init];
    
    NSString *lat = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
    [self loadDataWithLat:lat Lng:lng];
}

#pragma mark - 请求数据
- (void)loadDataWithLat:(NSString *)latitude Lng:(NSString *)longitude {
    
    
    [self showLoadingUI];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:longitude forKey:@"longitude"];
    [param setValue:latitude forKey:@"latitude"];

    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,PUBLIC_GETPUBLI_MOBILELIST_JSON];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"获取公共自行车停车位信息（无搜索）: %@", resultDict);
        self.HUD.hidden = YES;
        
        NSNumber *resultTag = [resultDict objectForKey:@"success"];
        
        [all_arrayList removeAllObjects];
        if (resultTag.boolValue) {
            
            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:resultDict options:NSJSONWritingPrettyPrinted error:nil];
            NSString *jsonStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            NSLog(@"resultDic%@",jsonStr);
            
            // 要移除的标注数组
            
//            [self.mapView removeAnnotations:self.mapView.annotations];
            [self.mapView removeAnnotation:BikeAnnotation]; // 移除搜索出来的自行车
            [self.mapView removeAnnotations:self.mark_arrayList];
            [self.mark_arrayList removeAllObjects];
            
            NSArray *data = resultDict[@"data"];
            
            if (data.count == 0) {
                
                self.noBikeImgView.hidden = NO;
            }else {
                
                self.noBikeImgView.hidden = YES;
                [all_arrayList addObjectsFromArray:data];
                [self addannotations];
                
                self.mapView.zoomLevel = 16;
            }
            
        }else {
            
        }
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        DMLog(@"%@",error);
        [self.manger startMonitoring];
        
        [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
                

                [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
                
            }else{                
                
                [self showNoNetworkView];
                
            }
        }];
        
        
        
    }];
}


- (void)setUpView {
    
    ///初始化地图
    self.mapView = [[MAMapView alloc] init];
    ///把地图添加至view
    [self.bgView addSubview:self.mapView];
    [self.mapView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.bgView);
    }];
    
    self.mapView.delegate = self;
    self.mapView.zoomLevel = 15;    // 缩放级别（默认3-19，有室内地图时为3-20）
    self.mapView.showsUserLocation = true; // 是否显示用户位置
    self.mapView.userTrackingMode = MAUserTrackingModeFollow;
    self.mapView.rotateCameraEnabled=NO;
    
    // 当前地图的中心点
//    self.mapView.centerCoordinate = currentCoordinate;
    
    [self addannotations];
    
//    MAUserLocationRepresentation *localPoint = [[MAUserLocationRepresentation alloc] init];
//    localPoint.showsHeadingIndicator = YES;
//    localPoint.image = [UIImage imageNamed:@"icon_location"];
//    [self.mapView updateUserLocationRepresentation:localPoint];
    
    
    self.btn_refresh = [[UIButton alloc] init];
    [self.btn_refresh setBackgroundImage:[UIImage imageNamed:@"icon_refresh"] forState:0];
    [self.btn_refresh addTarget:self action:@selector(refreshLocal) forControlEvents:1 << 6];
    [self.bgView addSubview:self.btn_refresh];
    [self.btn_refresh mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@11);
        make.bottom.equalTo(@-80);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    self.btn_local = [[UIButton alloc] init];
    [self.btn_local setBackgroundImage:[UIImage imageNamed:@"icon_location2"] forState:0];
    [self.btn_local addTarget:self action:@selector(local) forControlEvents:1 << 6];
    [self.bgView addSubview:self.btn_local];
    [self.btn_local mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@11);
        make.bottom.equalTo(@-32);
        make.width.equalTo(@40);
        make.height.equalTo(@40);
        
    }];
}

- (void)refreshLocal {
    
    if (isShowView) {
        [self.showView setHidden:YES];
        
        self.mapView.centerCoordinate = currentCoordinate;
        centerAnnotation.coordinate = currentCoordinate;
        
        isShowView = NO;
        isSearchBike = NO;
        isMoveView = YES;
        
        self.tf_search.text = @"";
        self.key = @"";
        [self.searchList removeAllObjects];
        
    }
    
    self.mapView.zoomLevel = 16;
    
//    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeAnnotations:self.mark_arrayList];
    
    self.selectedTitle = @"";
    
    NSString *lat = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
    NSString *lon = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
    
    [self loadDataWithLat:lat Lng:lon];
    
    [self.mapView reloadMap];
    
}

- (void)local {

    if(self.mapView.userLocation.updating && self.mapView.userLocation.location) {
        [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    }
    self.mapView.zoomLevel = 16;
}

#pragma mark - 添加大头针和动画

/**
 添加大头针
 */
- (void)addannotations {
    
//    for (NSDictionary *dict in all_arrayList) {
//        
//        MAPointAnnotation *annotation = [[MAPointAnnotation alloc] init];
//        annotation.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]); // 经纬度
//        annotation.title = dict[@"name"];   // 标题
//        annotation.subtitle = [NSString stringWithFormat:@"%@|%@", dict[@"availBike"], dict[@"capacity"]]; // 副标题
//        [self.mark_arrayList addObject:annotation];
//    }
    
    
    for (NSInteger i=0; i<all_arrayList.count; i++) {
        
        NSDictionary*dict=all_arrayList[i];
        DXBMAPointAnnotation *annotation = [[DXBMAPointAnnotation alloc] init];
        annotation.coordinate = CLLocationCoordinate2DMake([dict[@"lat"] doubleValue], [dict[@"lng"] doubleValue]); // 经纬度
        annotation.title = dict[@"name"];   // 标题
        
        // 车桩总数，可借数，距离，是否最近
        annotation.subtitle = [NSString stringWithFormat:@"%@|%@|%@|%@", dict[@"capacity"], dict[@"availBike"], dict[@"distanceKm"], dict[@"address"]]; // 副标题
        [self.mark_arrayList addObject:annotation];
        
        if (i==0) {
            
            annotation.mostRecent = @"离我最近";
        }
        
        
        
    }
    
    
    [self.mapView addAnnotations:self.mark_arrayList];
//    [self.mapView addAnnotation:centerAnnotation];
    
}


#pragma mark - mapViewDelegate
- (void)mapView:(MAMapView *)mapView mapWillMoveByUser:(BOOL)wasUserAction {
    
    NSLog(@"地图将要发生移动时调用此接口");
//    centerAnnotation.lockedToScreen = YES;
    if (!isMoveView) {
        //不能移动
        centerAnnotation.lockedToScreen = NO;
    }else{
        centerAnnotation.lockedToScreen = YES;
    }
    
//    if (wasUserAction) {
//        
//        // 从搜索界面回来时，不隐藏self.showView
//        if (isShowView) {
//            [self.showView setHidden:YES];
//        }
//        
//        
//        [self.mapView removeAnnotations:self.mark_arrayList];
//        
//        self.selectedTitle = @"";
//        
//        
//        [self addannotations];
//        
//        
//        isShowView = NO;
//    }
}

- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction {
    
    NSLog(@"地图移动结束后调用此接口:经纬度%f, %f", mapView.centerCoordinate.longitude, mapView.centerCoordinate.latitude);
    
    if (isShowView) {
        //不能移动
        return;
    }

    CGFloat interval_lon = fabs(currentCoordinate.longitude - mapView.centerCoordinate.longitude);
    CGFloat interval_lat = fabs(currentCoordinate.latitude - mapView.centerCoordinate.latitude);
//
//    if (interval_lon > 0.005 || interval_lat > 0.005) {
    if (interval_lon > 0 || interval_lat > 0) {
    
        // 当经纬度偏移大于0.005时才去刷新数据
        
        NSString *lat = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.latitude];
        NSString *lon = [NSString stringWithFormat:@"%f", mapView.centerCoordinate.longitude];

        [self loadDataWithLat:lat Lng:lon];
        currentCoordinate = mapView.centerCoordinate;
    
    }

}

#pragma mark - 地图初始化完成（在此之后，可以进行坐标计算）
- (void)mapInitComplete:(MAMapView *)mapView {
    
    NSLog(@"地图初始化完成（在此之后，可以进行坐标计算）");
    
    if ([CLLocationManager locationServicesEnabled] && ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorized)) {
        //定位功能可用
        
        currentCoordinate = mapView.centerCoordinate;
        [self setUpData];
        // 当前地图的中心点
        self.mapView.centerCoordinate = currentCoordinate;
        
        
    }else if ([CLLocationManager authorizationStatus] ==kCLAuthorizationStatusDenied) {
        //定位不能用
        FindZFPsdView *qq=[FindZFPsdView alterViewWithTitle:@"定位功能未启用"content:@"打开定位功能可以获得更好的体验" cancel:@"取消" sure:@"设置" cancelBtClcik:^{
            //取消按钮点击事件
            CLLocationCoordinate2D coor; // 坐标
            coor.longitude = 120.063697;
            coor.latitude = 29.293017;
            currentCoordinate = coor;

            // 当前地图的中心点
            self.mapView.centerCoordinate = currentCoordinate;


            NSString *lat = [NSString stringWithFormat:@"%f", currentCoordinate.latitude];
            NSString *lng = [NSString stringWithFormat:@"%f", currentCoordinate.longitude];
            [self loadDataWithLat:lat Lng:lng];
            
            
        } sureBtClcik:^{
            
            //跳转至 系统的权限设置界面
            NSURL *settingsURL = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
            [[UIApplication sharedApplication] openURL:settingsURL];
            
        }];
        [self.view addSubview:qq];
    }
    
    centerAnnotation = [[DXBCenterAnnotation alloc] init];
    centerAnnotation.coordinate = currentCoordinate; // self.mapView.centerCoordinate;
    centerAnnotation.lockedScreenPoint = CGPointMake(self.bgView.bounds.size.width/2, self.bgView.bounds.size.height/2);
    centerAnnotation.lockedToScreen = YES;
    
    // 地图中间的大头针
    [self.mapView addAnnotation:centerAnnotation];
    [self.mapView showAnnotations:@[centerAnnotation] animated:YES];
    
}

// 加载大头针
- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    
    NSLog(@"当mapView新添加annotation views时，调用此接口");
    /* 自定义userLocation对应的annotationView. */
    if ([annotation isMemberOfClass:[MAUserLocation class]]) {
        
        static NSString *userLocationStyleReuseIndetifier = @"userLocationStyleReuseIndetifier";
        MAAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:userLocationStyleReuseIndetifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation
                                                          reuseIdentifier:userLocationStyleReuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"icon_location"]; // 定位图片
        annotationView.zIndex = 0;
        self.userLocationAnnotationView = annotationView;
        return annotationView;
        
    }

    
    if ([annotation isMemberOfClass:[DXBCenterAnnotation class]]) {
        static NSString *reuseCenterid = @"myCenterId";
        MAAnnotationView *annotationView = [self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseCenterid];
        if (!annotationView) {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:nil reuseIdentifier:reuseCenterid];
        }
        annotationView.image = [UIImage imageNamed:@"icon_mappin"]; // 中间大头针
        annotationView.zIndex = 100;
        annotationView.canShowCallout = NO;
        centerAnnoView = annotationView;
        return annotationView;
    }
    
    DXBMAPointAnnotation*DXBAnnotation = (DXBMAPointAnnotation*)annotation;
    static NSString *reuseid = @"myId";
    DXBAnnotationView *annotationView = (DXBAnnotationView *)[self.mapView dequeueReusableAnnotationViewWithIdentifier:reuseid];
    if (!annotationView) {
        annotationView = [[DXBAnnotationView alloc] initWithAnnotation:DXBAnnotation reuseIdentifier:reuseid];
    }
    
    
    if ([DXBAnnotation.title isEqualToString:self.selectedTitle]) {
        
        annotationView.image = [UIImage imageNamed:@"icon_bike2"];
        
    }else {
        
        annotationView.image = [UIImage imageNamed:@"icon_bike1"];
    }
    

    //最近的这几个字相当于annotation的callout
    if ([DXBAnnotation.mostRecent isEqualToString:@"离我最近"])
    {
        
        annotationView.canShowCallout = NO;
        [annotationView setSelected:YES animated:YES];
        [annotationView setSelfInitString:DXBAnnotation.mostRecent];
        //这里防止被覆盖加上一个层级   这个层级关系没起作用，很奇怪
        annotationView.zIndex=1;
    }else
    {
        annotationView.zIndex = 0;
        annotationView.canShowCallout = NO;
//        [annotationView setSelected:NO animated:NO];
        [annotationView setSelected:YES animated:YES];
        [annotationView setSelfInitString:@""];
    }
    
    return annotationView;
}

// 单击地图
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate {
    
    NSLog(@"单击地图回调，返回经纬度");
    
    if (isSearchBike) {
        
        // 说明是从自行车页面搜索回来的，点击地图，showView不消失
        return;
    }
    
    if (isShowView) {
        [self.showView setHidden:YES];
        
        self.mapView.centerCoordinate = currentCoordinate;
        centerAnnotation.coordinate = currentCoordinate;
        
        isShowView = NO;
        isMoveView = YES;
        
    }
    
    self.mapView.zoomLevel = 16;
    
    
    [self.mapView removeAnnotations:self.mark_arrayList];
    
    self.selectedTitle = @"";
    
    
    [self addannotations];
    
    
}



- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
    NSLog(@"当选中一个annotation view时，调用此接口");
    if ([view.annotation isMemberOfClass:[MAUserLocation class]]) {
        
        return;
    }
    
    if ([view.annotation isMemberOfClass:[DXBCenterAnnotation class]]) {
        
        return;
    }
    
    
//    self.mapView.zoomLevel = 15;
    if (!self.showView) {
        self.showView = [[DXBBikeShowView alloc] initWithFrame:CGRectMake(0, -128, SCREEN_WIDTH, 128)];
        [self.bgView addSubview:self.showView];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 128);
        } completion:^(BOOL finished) {
        }];
    }
    isShowView = YES;
    [self.showView setHidden:NO];
    
    __weak DXBPublicBlikeVC *weakSelf = self;
    self.showView.gotoOtherPlace = ^(){
        
        [weakSelf gotoPlace:weakSelf.endCoordinate Title:weakSelf.showView.label_name.text];
    };
    
    self.showView.label_name.text = view.annotation.title;
    NSArray *counts = [view.annotation.subtitle componentsSeparatedByString:@"|"];
    self.showView.label_carPileTotal.text = [NSString stringWithFormat:@"车桩总数：%@", counts[0]];
    self.showView.label_availTotal.text = [NSString stringWithFormat:@"%@", counts[1]];
    self.showView.label_distance.text = [NSString stringWithFormat:@"%@KM", counts[2]];
    self.showView.label_address.text = [NSString stringWithFormat:@"%@", counts[3]];
    
    self.startCoordinate = centerAnnotation.coordinate;
    self.endCoordinate = view.annotation.coordinate;
    
    self.selectedTitle = view.annotation.title;

//    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView removeAnnotations:self.mark_arrayList];
    
    [self addannotations];
}

// 位置或者设备方向更新后，会调用此函数
- (void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation updatingLocation:(BOOL)updatingLocation
{
    if (!updatingLocation && self.userLocationAnnotationView != nil)
    {
        [UIView animateWithDuration:0.1 animations:^{
            
            double degree = userLocation.heading.trueHeading - self.mapView.rotationDegree;
            self.userLocationAnnotationView.transform = CGAffineTransformMakeRotation(degree * M_PI / 180.f );
            
        }];
    }
}

- (void)searchBikeVC:(BOOL)searchBikeVC MapointAnnotation:(DXBMAPointAnnotation *)annotation andSearchkey:(NSString *)searchkey andSearchList:(NSMutableArray *)list_array {
    
    self.tf_search.text = searchkey;
    self.key = searchkey;
    [self.searchList setArray:list_array];
    
    if (searchBikeVC) {
        
        if (!self.showView) {
            self.showView = [[DXBBikeShowView alloc] initWithFrame:CGRectMake(0, -128, SCREEN_WIDTH, 128)];
            [self.bgView addSubview:self.showView];
            
            [UIView animateWithDuration:0.5 animations:^{
                self.showView.frame = CGRectMake(0, 0, SCREEN_WIDTH, 128);
            } completion:^(BOOL finished) {
            }];
        }
        isShowView = YES;
        isMoveView = NO;
        isSearchBike = YES;
        self.noBikeImgView.hidden = YES;
        [self.showView setHidden:NO];
//        [self.btn_local setHidden:YES];
//        [self.btn_refresh setHidden:YES];
        
        __weak DXBPublicBlikeVC *weakSelf = self;
        self.showView.gotoOtherPlace = ^(){
            
            [weakSelf gotoPlace:weakSelf.endCoordinate Title:weakSelf.showView.label_name.text];
        };
        
        self.showView.label_name.text = annotation.title;
        NSArray *counts = [annotation.subtitle componentsSeparatedByString:@"|"];
        self.showView.label_carPileTotal.text = [NSString stringWithFormat:@"车桩总数：%@", counts[0]];
        self.showView.label_availTotal.text = [NSString stringWithFormat:@"%@", counts[1]];
        self.showView.label_distance.text = [NSString stringWithFormat:@"%@KM", counts[2]];
        self.showView.label_address.text = [NSString stringWithFormat:@"%@", counts[3]];
        
        self.startCoordinate = centerAnnotation.coordinate;
        self.endCoordinate = annotation.coordinate;
        
        self.selectedTitle = annotation.title;
        
        NSLog(@"--------: %@", self.selectedTitle);
        
        BikeAnnotation = annotation;
        
        [self.mapView removeAnnotations:self.mapView.annotations];
        
        [self.mapView addAnnotation:centerAnnotation];
        [self.mapView addAnnotation:annotation];
        
        
        
//        UIEdgeInsets edgeInset=UIEdgeInsetsMake(0, 0, 0, 0);
        UIEdgeInsets edgeInset=UIEdgeInsetsMake(260, 10, 10, 10);
        
        [self.mapView showAnnotations:@[annotation,centerAnnotation] edgePadding:edgeInset animated:YES];
        
        
    }else {
        
    }
}

- (void)goBackVC {
    
    self.tf_search.text = @"";
    self.key = @"";
    [self.searchList removeAllObjects];
    
    if (isShowView) {
        [self.showView setHidden:YES];
        
        self.mapView.centerCoordinate = currentCoordinate;
        centerAnnotation.coordinate = currentCoordinate;
        
        isShowView = NO;
        isMoveView = YES;
        isSearchBike = NO;
    }
    
    self.mapView.zoomLevel = 16;
    
    [self.mapView removeAnnotation:BikeAnnotation]; // 移除搜索出来的自行车
    [self.mapView removeAnnotations:self.mark_arrayList];
    
    self.selectedTitle = @"";
    
    [self addannotations];
    
}

#pragma mark - 去这里
- (void)gotoPlace:(CLLocationCoordinate2D)coordinate Title:(NSString *)title {

    // 后台返回的目的地坐标是百度地图的
    // 百度地图与高德地图、苹果地图采用的坐标系不一样，故高德和苹果只能用地名不能用后台返回的坐标
    CGFloat latitude  = coordinate.latitude;  // 纬度
    CGFloat longitude = coordinate.longitude; // 经度
    NSString *address = title; // 送达地址
    
    // 打开地图的优先级顺序：高德地图->苹果地图
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {

        NSString *urlString = [[NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=%f&slon=%f&sname=%@&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&t=2",currentCoordinate.latitude,currentCoordinate.longitude,@"",latitude,longitude,address]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *r = [NSURL URLWithString:urlString];
        [[UIApplication sharedApplication] openURL:r];

    }else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"http://maps.apple.com"]]){
        
        CLLocationCoordinate2D from =CLLocationCoordinate2DMake(currentCoordinate.latitude,currentCoordinate.longitude);
        MKMapItem *currentLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:from addressDictionary:nil]];
        currentLocation.name =@"我的位置";
        //终点
        CLLocationCoordinate2D to =CLLocationCoordinate2DMake(latitude,longitude);
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:to addressDictionary:nil]];
        NSLog(@"网页google地图:%f,%f",to.latitude,to.longitude);
        toLocation.name = address;
        NSArray *items = [NSArray arrayWithObjects:currentLocation, toLocation,nil];
        NSDictionary *options =@{
                                 MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving,
                                 MKLaunchOptionsMapTypeKey:
                                     [NSNumber numberWithInteger:MKMapTypeStandard],
                                 MKLaunchOptionsShowsTrafficKey:@YES
                                 };
        
        //打开苹果自身地图应用
        [MKMapItem openMapsWithItems:items launchOptions:options];
    }
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
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


-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
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
        }else{
            
            
            [self showNoNetworkView];
        }
    }];
}


#pragma mark - 显示网络异常界面
/** 显显示网络异常界面 */
-(void)showNoNetworkView{
    
    
    
    self.bgView.hidden = YES;
    self.searchView.hidden = YES;
    
    
    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    

    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_noweb"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 100, 223, 206);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - 200)*0.5, 100+206, 200, 30);
    noDataTipsLabel.font = [UIFont systemFontOfSize:13];
    noDataTipsLabel.text = @"当前网络不可用，请检查网络设置";
    noDataTipsLabel.textColor = [UIColor darkGrayColor];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    //刷新按钮
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake((SCREEN_WIDTH - 150)*0.5, 100+206 + 30 +20, 150, 45);
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateNormal];
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateHighlighted];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [refreshButton setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    refreshButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    refreshButton.clipsToBounds = YES;
    refreshButton.layer.cornerRadius = 3;
    [refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.tipsButton = refreshButton;
    
    
    
    
    
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.tipsButton];
    
}


/**
 重新刷新按钮被点击
 */
-(void)refreshButtonClick{

    [self.manger startMonitoring];
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            
            [self.tipsImageView removeFromSuperview];
            [self.tipsLabel removeFromSuperview];
            [self.tipsButton removeFromSuperview];
            
            self.bgView.hidden = NO;
            self.searchView.hidden = NO;
            
            
        }else{
            
            
        }
    }];


}


@end
