//
//  NetDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "NetDetailVC.h"
#import "DetailTwoCell.h"
#import "DetailThreeCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Foundation/Foundation.h>
#import "KCAnnotation.h"

@interface NetDetailVC ()<UITableViewDataSource,UITableViewDelegate,MKMapViewDelegate>{
    MKMapView  *MapView;
}

@end

@implementation NetDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"服务网点详情";
    HIDE_BACK_TITLE;
    [self initData];
}

#pragma mark - 初始化数据
-(void)initData{    
    self.brieftableview.dataSource = self;
    self.brieftableview.delegate = self;
    [self.brieftableview registerNib:[UINib nibWithNibName:@"DetailTwoCell" bundle:nil] forCellReuseIdentifier:@"DetailTwoCell"];
    [self.brieftableview registerNib:[UINib nibWithNibName:@"DetailThreeCell" bundle:nil] forCellReuseIdentifier:@"DetailThreeCell"];
    self.brieftableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.brieftableview.tableFooterView = [[UIView alloc] init];
    
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) { // 没有经纬度数据
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
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) { // 没有经纬度数据
        return 2;
    }else{
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) {  // 没有经纬度数据
        if (indexPath.section==0) {
            return 115;
        }else{
            if ([Util IsStringNil:self.bean.jianjie]||[self.bean.jianjie isEqualToString:@"暂无"]||[self.bean.jianjie isEqualToString:@"无"]) {
                return 40;
            }else{
                return 100;
            }
        }
    }else{
        if (indexPath.section==0) {
            return 115;
        }else if (indexPath.section==1){
            if ([Util IsStringNil:self.bean.jianjie]||[self.bean.jianjie isEqualToString:@"暂无"]||[self.bean.jianjie isEqualToString:@"无"]) {
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
            
            if ([Util IsStringNil:self.bean.jianjie]||[self.bean.jianjie isEqualToString:@"暂无"]||[self.bean.jianjie isEqualToString:@"无"]) {
                return gao1;
            }else{
                return gao2;
            }
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) {  // 没有经纬度
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
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) {  // 没有经纬度
        if (indexPath.section==0) {
            DetailTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTwoCell"];
            if ( nil == cell ){
                cell = [[DetailTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailTwoCell"];
            }
            [cell.callBtn addTarget:self action:@selector(CallTel) forControlEvents:UIControlEventTouchUpInside];
            
            if (nil==self.bean) {
                cell.Netname.text = @"暂无数据";
                cell.address.text = @"暂无数据";
                cell.tel.text = @"暂无数据";
                cell.zk.hidden = YES;
            }else{
                cell.Netname.text = nil==self.bean.branchnmae?@"":self.bean.branchnmae;
                cell.address.text = nil==self.bean.address?@"":self.bean.address;
                cell.tel.text = nil==self.bean.tel?@"":self.bean.tel;
                NSString *tp = self.bean.ismaked;
                if ([tp isEqualToString:@"1"]) {
                    cell.zk.hidden = NO;
                    cell.zk.layer.cornerRadius = 5;
                    cell.zk.clipsToBounds = YES;
                }else{
                    cell.zk.hidden = YES;
                }
            }
            return cell;
        }else{
            if ([Util IsStringNil:self.bean.jianjie]||[self.bean.jianjie isEqualToString:@"暂无"]||[self.bean.jianjie isEqualToString:@"无"]) {
                static NSString  *NetDetailCellID = @"NetDetailCellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NetDetailCellID];
                if ( nil == cell ){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NetDetailCellID];
                    
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
                NSString *js = [NSString stringWithFormat:@"       %@",self.bean.jianjie];
                cell.Describe.attributedText = [[NSAttributedString alloc] initWithString:js attributes:attributes];
                
                [cell.Describe setContentOffset:CGPointZero];
                
                return cell;
            }
        }
    }else{
        if (indexPath.section==0) {
            DetailTwoCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DetailTwoCell"];
            if ( nil == cell ){
                cell = [[DetailTwoCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DetailTwoCell"];
            }
            [cell.callBtn addTarget:self action:@selector(CallTel) forControlEvents:UIControlEventTouchUpInside];
            
            if (nil==self.bean) {
                cell.Netname.text = @"暂无数据";
                cell.address.text = @"暂无数据";
                cell.tel.text = @"暂无数据";
                cell.zk.hidden = YES;
            }else{
                cell.Netname.text = nil==self.bean.branchnmae?@"":self.bean.branchnmae;
                cell.address.text = nil==self.bean.address?@"":self.bean.address;
                cell.tel.text = nil==self.bean.tel?@"":self.bean.tel;
                NSString *tp = self.bean.ismaked;
                if ([tp isEqualToString:@"1"]) {
                    cell.zk.hidden = NO;
                    cell.zk.layer.cornerRadius = 5;
                    cell.zk.clipsToBounds = YES;
                }else{
                    cell.zk.hidden = YES;
                }
            }
            return cell;
        }else if (indexPath.section==1){
            if ([Util IsStringNil:self.bean.jianjie]||[self.bean.jianjie isEqualToString:@"暂无"]||[self.bean.jianjie isEqualToString:@"无"]) {
                static NSString  *NetDetailCellID = @"NetDetailCellID";
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NetDetailCellID];
                if ( nil == cell ){
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:NetDetailCellID];
                    
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
                NSString *js = [NSString stringWithFormat:@"       %@",self.bean.jianjie];
                cell.Describe.attributedText = [[NSAttributedString alloc] initWithString:js attributes:attributes];
                
                [cell.Describe setContentOffset:CGPointZero];
                //            [cell.DspBtn addTarget:self action:@selector(UpDownClicked:) forControlEvents:UIControlEventTouchUpInside];
                
                return cell;
            }
        }else{
            static NSString  *NetMapCellID = @"NetMapCellID";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NetMapCellID];
            if ( nil == cell ){
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NetMapCellID];
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
            NSString *lat = nil==self.bean.weidu?@"":self.bean.weidu;
            NSString *lon = nil==self.bean.jingdu?@"":self.bean.jingdu;
            float laa = [lat floatValue];
            float loo = [lon floatValue];
            CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
            MapView.centerCoordinate = location;
            
            KCAnnotation *annotation = [[KCAnnotation alloc] init];
            annotation.coordinate = location;
            annotation.title = nil==self.bean.branchnmae?@"":self.bean.branchnmae;
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
    if ([Util IsStringNil:self.bean.jingdu]||[Util IsStringNil:self.bean.weidu]) {  // 没有经纬度
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

#pragma mark - 打电话按钮
-(void)CallTel{
    if (nil==self.bean.tel) {
        DMLog(@"没有手机号码");
    }else{
        NSString *tel = [NSString stringWithFormat:@"telprompt://%@",self.bean.tel];
        NSURL *url = [NSURL URLWithString:tel];
        [[UIApplication sharedApplication] openURL:url];
        return;
    }
}

#pragma mark 显示大头针时调用，注意方法中的annotation参数是即将显示的大头针对象
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id)annotation{
    //由于当前位置的标注也是一个大头针，所以此时需要判断，此代理方法返回nil使用默认大头针视图
    if ([annotation isKindOfClass:[KCAnnotation class]]) {
        static NSString *key1=@"AnnotationKey3";
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
        NSString *urlString = [NSString stringWithFormat:@"iosamap://path?sourceApplication=applicationName&sid=BGVIS1&slat=&slon=&sname=&did=BGVIS2&dlat=%f&dlon=%f&dname=%@&dev=0&m=0&t=0", [self.bean.weidu floatValue], [self.bean.jingdu floatValue], self.bean.branchnmae];
        NSString *sss = [urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:sss]];
    } else {    //自带地图
        MKMapItem *currentLocation = [MKMapItem mapItemForCurrentLocation];
        CLLocationCoordinate2D endCoor = CLLocationCoordinate2DMake([self.bean.weidu floatValue], [self.bean.jingdu floatValue]);
        MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:endCoor addressDictionary:nil]];
        toLocation.name = self.bean.branchnmae;
        
        [MKMapItem openMapsWithItems:@[currentLocation, toLocation]
                       launchOptions:@{MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving,MKLaunchOptionsShowsTrafficKey: [NSNumber numberWithBool:YES]}];
    }
}

#pragma mark - 定位按钮点击事件
- (IBAction)DwbtnClicked:(id)sender {
    NSString *lat = nil==self.bean.weidu?@"":self.bean.weidu;
    NSString *lon = nil==self.bean.jingdu?@"":self.bean.jingdu;
    float laa = [lat floatValue];
    float loo = [lon floatValue];
    CLLocationCoordinate2D location=CLLocationCoordinate2DMake(laa, loo);
    MapView.centerCoordinate = location;
}

@end
