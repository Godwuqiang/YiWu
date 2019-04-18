//
//  HospitalDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/20.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "HospitalDetailVC.h"
#import "DetailOneCell.h"
#import "DetailThreeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "KCAnnotation.h"


@interface HospitalDetailVC ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>{
           MKMapView  *MapView;
//    CLLocationManager *_locationManager;
}

@end

@implementation HospitalDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"医院详情";
    HIDE_BACK_TITLE;
    [self initData];
}

#pragma mark - 初始化界面数据
-(void)initData{
    self.brieftableview.dataSource = self;
    self.brieftableview.delegate = self;
    [self.brieftableview registerNib:[UINib nibWithNibName:@"DetailOneCell" bundle:nil] forCellReuseIdentifier:@"DetailOneCell"];
    [self.brieftableview registerNib:[UINib nibWithNibName:@"DetailThreeCell" bundle:nil] forCellReuseIdentifier:@"DetailThreeCell"];
    self.brieftableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.brieftableview.tableFooterView = [[UIView alloc] init];
    
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) { // 没有经纬度数据
        self.Dhbtn.hidden = YES;
        self.Dwbtn.hidden = YES;
    }else{
        self.Dhbtn.hidden = NO;
        self.Dwbtn.hidden = NO;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) { // 没有经纬度
        return 2;
    }else{
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) { // 没有经纬度
        if (indexPath.section==0) {
            return 115;
        }else{
            if ([Util IsStringNil:self.bean.jj]||[self.bean.jj isEqualToString:@"暂无"]||[self.bean.jj isEqualToString:@"无"]) {
                return 40;
            }else{
                return 100;
            }
        }
    }else{
        if (indexPath.section==0) {
            return 115;
        }else if (indexPath.section==1){
            if ([Util IsStringNil:self.bean.jj]||[self.bean.jj isEqualToString:@"暂无"]||[self.bean.jj isEqualToString:@"无"]) {
                return 40;
            }else{
                return 100;
            }
        }else{
            int gao1,gao2;
            //区别屏幕尺寸
            if ( SCREEN_HEIGHT > 667) //6p
            {
                gao1 = 452;
                gao2 = 392;
            }
            else if (SCREEN_HEIGHT > 568)//6
            {
                gao1 = 382;
                gao2 = 322;
            }
            else if (SCREEN_HEIGHT > 480)//5s
            {
                gao1 = 280;
                gao2 = 225;
            }
            else //3.5寸屏幕
            {
                gao1 = 240;
                gao2 = 180;
            }
            
            if ([Util IsStringNil:self.bean.jj]||[self.bean.jj isEqualToString:@"暂无"]||[self.bean.jj isEqualToString:@"无"]) {
                return gao1;
            }else{
                return gao2;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) {  // 没有经纬度
        if (section==0) {
            return 10.0;
        }else{
            return 0.1;
        }
    }else{
        if (section==0 || section==1) {
            return 10.0;
        }else{
            return 0.1;
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) {  // 没有经纬度
        if (indexPath.section==0) {
            DetailOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailOneCell"];
            if ( nil == cell ){
                cell = [[DetailOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailOneCell"];
            }
            [cell.Dbtn addTarget:self action:@selector(CallTel) forControlEvents:UIControlEventTouchUpInside];
            
            if (nil==self.bean) {
                cell.Dname.text = @"暂无数据";
                cell.Daddress.text = @"暂无数据";
                cell.Dtel.text = @"暂无数据";
            }else{
                cell.Dname.text = nil==self.bean.ddyljgmc?@"":self.bean.ddyljgmc;
                cell.Daddress.text = nil==self.bean.dz?@"":self.bean.dz;
                cell.Dtel.text = nil==self.bean.lxdh?@"":self.bean.lxdh;
            }
            return cell;
        }else{
            if ([Util IsStringNil:self.bean.jj]||[self.bean.jj isEqualToString:@"暂无"]||[self.bean.jj isEqualToString:@"无"]) {
                static NSString  *HospitalDetailCellID = @"HospitalDetailCellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HospitalDetailCellID];
                if ( nil == cell ){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HospitalDetailCellID];
                    
                }
                UILabel *jj = [[UILabel alloc] init];
                [cell.contentView addSubview:jj];
                [jj mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).offset(10);
                    make.left.equalTo(cell.contentView.mas_left).offset(20);
                    make.height.equalTo(@18);
                }];
                jj.text = @"暂无";
                jj.textColor = [UIColor colorWithHex:0x666666];
                jj.font = [UIFont systemFontOfSize:14];
                
                return cell;
            }else{
                DetailThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailThreeCell"];
                if ( nil == cell ){
                    cell = [[DetailThreeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailThreeCell"];
                }
                // textview 改变字体的行间距
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 10;// 字体的行间距
                
                NSDictionary *attributes = @{
                                             NSForegroundColorAttributeName:[UIColor colorWithHex:0x666666],
                                             NSFontAttributeName:[UIFont systemFontOfSize:14],
                                             NSParagraphStyleAttributeName:paragraphStyle
                                             };
                NSString *js = [NSString stringWithFormat:@"       %@",self.bean.jj];
                cell.Describe.attributedText = [[NSAttributedString alloc] initWithString:js attributes:attributes];
                
                [cell.Describe setContentOffset:CGPointZero];
                
                return cell;
            }
        }
    }else{
        if (indexPath.section==0) {
            DetailOneCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailOneCell"];
            if ( nil == cell ){
                cell = [[DetailOneCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailOneCell"];
            }
            [cell.Dbtn addTarget:self action:@selector(CallTel) forControlEvents:UIControlEventTouchUpInside];
            
            if (nil==self.bean) {
                cell.Dname.text = @"暂无数据";
                cell.Daddress.text = @"暂无数据";
                cell.Dtel.text = @"暂无数据";
            }else{
                cell.Dname.text = nil==self.bean.ddyljgmc?@"":self.bean.ddyljgmc;
                cell.Daddress.text = nil==self.bean.dz?@"":self.bean.dz;
                cell.Dtel.text = nil==self.bean.lxdh?@"":self.bean.lxdh;
            }
            return cell;
        }else if (indexPath.section==1){
            if ([Util IsStringNil:self.bean.jj]||[self.bean.jj isEqualToString:@"暂无"]||[self.bean.jj isEqualToString:@"无"]) {
                static NSString  *HospitalDetailCellID = @"HospitalDetailCellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HospitalDetailCellID];
                if ( nil == cell ){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HospitalDetailCellID];
                    
                }
                UILabel *jj = [[UILabel alloc] init];
                [cell.contentView addSubview:jj];
                [jj mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.top.equalTo(cell.contentView.mas_top).offset(10);
                    make.left.equalTo(cell.contentView.mas_left).offset(20);
                    make.height.equalTo(@18);
                }];
                jj.text = @"暂无";
                jj.textColor = [UIColor colorWithHex:0x666666];
                jj.font = [UIFont systemFontOfSize:14];
                
                return cell;
            }else{
                DetailThreeCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailThreeCell"];
                if ( nil == cell ){
                    cell = [[DetailThreeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailThreeCell"];
                }
                // textview 改变字体的行间距
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
                paragraphStyle.lineSpacing = 10;// 字体的行间距
                
                NSDictionary *attributes = @{
                                             NSForegroundColorAttributeName:[UIColor colorWithHex:0x666666],
                                             NSFontAttributeName:[UIFont systemFontOfSize:14],
                                             NSParagraphStyleAttributeName:paragraphStyle
                                             };
                NSString *js = [NSString stringWithFormat:@"       %@",self.bean.jj];
                cell.Describe.attributedText = [[NSAttributedString alloc] initWithString:js attributes:attributes];
                
                [cell.Describe setContentOffset:CGPointZero];
                
                return cell;
            }
        }else{
            static NSString  *HospitalMapCellID = @"HospitalMapCellID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HospitalMapCellID];
            if ( nil == cell ){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HospitalMapCellID];
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
            NSString *lat = nil==self.bean.wd?@"":self.bean.wd;
            NSString *lon = nil==self.bean.jd?@"":self.bean.jd;
            float laa = [lat floatValue];
            float loo = [lon floatValue];
            CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
            MapView.centerCoordinate = location;
            
            KCAnnotation *annotation = [[KCAnnotation alloc] init];
            annotation.coordinate = location;
            annotation.title = nil==self.bean.ddyljgmc?@"":self.bean.ddyljgmc;
            annotation.image=[UIImage imageNamed:@"map_icon"];
            [MapView addAnnotation:annotation];
            //放大到标注的位置
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(annotation.coordinate, 500, 500);
            [MapView setRegion:region animated:YES];
            
            return cell;
        }
    }
}


- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if ([Util IsStringNil:self.bean.jd] || [Util IsStringNil:self.bean.wd]) {  // 没有经纬度
        if (section==0) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
            footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            return footerView;
        }else{
            return nil;
        }
    }else{
        if (section==0 || section==1) {
            UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 10)];
            footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
            return footerView;
        }else{
            return nil;
        }
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark - 拨打电话
-(void)CallTel{
    if (nil==self.bean.lxdh) {
        DMLog(@"没有手机号码");
    }else{
        NSString *tel = [NSString stringWithFormat:@"telprompt://%@",self.bean.lxdh];
        NSURL *url = [NSURL URLWithString:tel];
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
}


#pragma mark - 地图控件代理方法
#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
//大头针的回调方法（与cell的复用机制很相似）
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[KCAnnotation class]]) {
        static NSString *key1=@"AnnotationKey1";
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
- (IBAction)DhbtnClicked:(id)sender {
    //路线规划
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"iosamap://"]]) {   //高德地图
        NSString *urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=&slon=&sname=&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0", [self.bean.wd floatValue], [self.bean.jd floatValue], self.bean.ddyljgmc];
        NSString *sss = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sss]];
    } else {    //自带地图
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([self.bean.wd floatValue], [self.bean.jd floatValue]);
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil]];
        toLocation.name = self.bean.ddyljgmc;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - 定位按钮点击事件
- (IBAction)DwbtnClicked:(id)sender {
    NSString *lat = nil==self.bean.wd?@"":self.bean.wd;
    NSString *lon = nil==self.bean.jd?@"":self.bean.jd;
    float laa = [lat floatValue];
    float loo = [lon floatValue];
    CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
    MapView.centerCoordinate = location;
}

@end
