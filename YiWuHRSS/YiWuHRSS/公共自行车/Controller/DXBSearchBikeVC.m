//
//  DXBSearchBikeVC.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBSearchBikeVC.h"
#import "DXBSearchCell.h"
#import "HttpHelper.h"
#import "DXBBikeModel.h"
#import "DXBMAPointAnnotation.h"
#import "MJExtension.h"

#define    PUBLIC_SEARCH_GETPUBLI_MOBILELIST_JSON           @"public/getPublicMobileSearchList.json"  // 获取公共自行车停车位信息(搜索版)

static NSString *dxbSearchCell = @"dxbSearchCell";



@interface DXBSearchBikeVC ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>{
    
//    NSMutableArray *list_array;
}

@property (nonatomic, strong) NSMutableArray *list_array;

// 控件
@property(nonatomic, strong)   MBProgressHUD    *HUD;

//网络监控-无网络
@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (nonatomic, strong)UIImageView *tipsImageView;
@property (nonatomic, strong)UILabel *tipsLabel;
@property (nonatomic, strong)UIButton *tipsButton;
@property (nonatomic, assign) int   pageNo;
@property(nonatomic, strong)   NSString   *seachKey;

@end

@implementation DXBSearchBikeVC

-(AFNetworkReachabilityManager *)manger{
    
    if(_manger == nil){
        
        _manger = [AFNetworkReachabilityManager sharedManager];
        
    }
    [_manger startMonitoring];
    return _manger;
}

- (NSMutableArray *)mark_arrayList {
    
    if (!_list_array) {
        _list_array = [[NSMutableArray alloc] init];
    }
    return _list_array;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"搜索站点";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 30);
    [btn setImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backRootVC) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 71;
    self.tableView.tableFooterView = [UIView new];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"DXBSearchCell" bundle:nil] forCellReuseIdentifier:dxbSearchCell];
    
    // 上拉加载更多
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    
    self.seachKey = self.key;
    
    self.tf_search.delegate = self;
    self.tf_search.text = self.key;
    [self.tf_search addTarget:self action:@selector(textFieldEditChanged:) forControlEvents:UIControlEventEditingChanged];
}

- (void)backRootVC {
    
    [self.delegate goBackVC];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
}


- (void)setSearchDataArr:(NSMutableArray *)searchDataArr {
    
    self.list_array = searchDataArr;
    self.tableView.hidden = NO;
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.list_array.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DXBSearchCell *cell = [tableView dequeueReusableCellWithIdentifier:dxbSearchCell];
    if (nil == cell) {
        cell = [[DXBSearchCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dxbSearchCell];
    }
    
    DXBBikeModel *model = [self.list_array objectAtIndex:indexPath.row];
    cell.lb_name.text = model.name;
    
    NSRange range = [cell.lb_name.text rangeOfString:self.tf_search.text];
    
    [self setTextColor:cell.lb_name FontNumber:[UIFont systemFontOfSize:15] AndRange:range AndColor:[UIColor orangeColor]];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0); // 从新设置
    
    // 点击时的背景颜色
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.frame];
    cell.selectedBackgroundView.backgroundColor = [UIColor colorWithHex:0Xfff3de];
    
    
    return cell;
}

//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    [str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    DXBBikeModel *model = [self.list_array objectAtIndex:indexPath.row];
    
    
    DXBMAPointAnnotation *annotation = [[DXBMAPointAnnotation alloc] init];
    annotation.coordinate = CLLocationCoordinate2DMake([model.lat doubleValue], [model.lng doubleValue]); // 经纬度
    annotation.title = model.name;   // 标题
    // 车桩总数，可借数，距离，是否最近
    annotation.subtitle = [NSString stringWithFormat:@"%@|%@|%@|%@", model.capacity, model.availBike, model.distanceKm, model.address]; // 副标题
    annotation.mostRecent = @"不是最近的";
    NSString *search = self.tf_search.text;
    
    [self.delegate searchBikeVC:YES MapointAnnotation:annotation andSearchkey:search andSearchList:self.list_array];
    
    [self.navigationController popViewControllerAnimated:YES];
}


#pragma mark - uitextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
//     不允许输入空格
    if ([Util IsStringNil:string]) {
        
        return YES;
    }
    
//    NSString *key_word = [textField.text stringByReplacingCharactersInRange:range withString:string]; //变化后的字符串
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    
    if ([tem length] == 0) {
        return NO;
    }
    
//    [self loadData:key_word];
    
    return YES;
}

#pragma mark -  添加输入改变的方法
- (void)textFieldEditChanged:(UITextField *)textField
{
    NSString *keywords = textField.text;
    [self loadData:keywords];
}


- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    [self.list_array removeAllObjects];
    self.tableView.hidden = NO;
    [self.tableView reloadData];
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    
    
    if (![Util IsStringNil:textField.text]) {
        
        [self loadData:textField.text];
    }else {
        
        [self.list_array removeAllObjects];
        self.tableView.hidden = NO;
        [self.tableView reloadData];
    }
    
    return YES;
}


- (void)loadData:(NSString *)key_word {
    
//    if ([Util IsStringNil:key_word]) {
//        
//        [self.list_array removeAllObjects];
//        self.tableView.hidden = NO;
//        [self.tableView reloadData];
//        
//        return;
//    }
    
    [self showLoadingUI];
    
    self.pageNo = 1;
    self.seachKey = key_word;
    
    
    NSString *lat = [NSString stringWithFormat:@"%f", self.coordinate2D.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", self.coordinate2D.longitude];
//    NSLog(@"当前经纬度： %@  %@", lat, lng);
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:lng forKey:@"longitude"];
    [param setValue:lat forKey:@"latitude"];
    [param setValue:key_word forKey:@"key_word"];
    [param setValue:@"1" forKey:@"page_no"];
    [param setValue:@"10" forKey:@"page_size"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,PUBLIC_SEARCH_GETPUBLI_MOBILELIST_JSON];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"获取公共自行车停车位信息(搜索版): %@", resultDict);
        
        self.HUD.hidden = YES;
        NSNumber *resultTag = [resultDict objectForKey:@"success"];
        NSInteger resultCode = [resultDict[@"resultCode"] integerValue];
      
        
        if (resultTag.boolValue) {
            
            [self.tipsImageView removeFromSuperview];
            [self.tipsLabel removeFromSuperview];
            [self.tipsButton removeFromSuperview];
            
            if (resultCode == 201) {
                
                self.tableView.hidden = YES;
                self.img_nobike.hidden = YES;
                self.lb_nobike.hidden = YES;
                return ;
            }
            
            [self.list_array removeAllObjects];
            NSArray *data = resultDict[@"data"];
            if (data.count != 0) {
                
                for (NSDictionary *dict in data) {
                    DXBBikeModel *model = [DXBBikeModel mj_objectWithKeyValues:dict];
                    [self.list_array addObject:model];
                }
                
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }else {
                
                self.tableView.hidden = YES;
                self.img_nobike.hidden = NO;
                self.lb_nobike.hidden = NO;
            }
        }else {
            
//            [MBProgressHUD showError:@"没有更多数据了！"];
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

#pragma mark - 加载更多数据
- (void)loadMoreData {
    
    DMLog(@"加载更多数据");
    self.pageNo = self.pageNo+1;
    
    [self showLoadingUI];
    
    NSString *lat = [NSString stringWithFormat:@"%f", self.coordinate2D.latitude];
    NSString *lng = [NSString stringWithFormat:@"%f", self.coordinate2D.longitude];
    
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appCurVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [param setValue:appCurVersion forKey:@"app_version"];
    [param setValue:@"2" forKey:@"device_type"];
    [param setValue:lng forKey:@"longitude"];
    [param setValue:lat forKey:@"latitude"];
    [param setValue:self.seachKey forKey:@"key_word"];
    [param setValue:@(self.pageNo) forKey:@"page_no"];
    [param setValue:@"10" forKey:@"page_size"];
    
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,PUBLIC_SEARCH_GETPUBLI_MOBILELIST_JSON];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *resultDict = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        [self.tableView.footer endRefreshing];
        
        DMLog(@"获取公共自行车停车位信息(搜索版): %@", resultDict);
        
        self.HUD.hidden = YES;
        NSNumber *resultTag = [resultDict objectForKey:@"success"];
        NSInteger resultCode = [resultDict[@"resultCode"] integerValue];
        
        
        if (resultTag.boolValue) {
            
            [self.tipsImageView removeFromSuperview];
            [self.tipsLabel removeFromSuperview];
            [self.tipsButton removeFromSuperview];
            
            if (resultCode == 201) {
                
                self.tableView.hidden = YES;
                self.img_nobike.hidden = YES;
                self.lb_nobike.hidden = YES;
                
//                [MBProgressHUD showError:resultDict[@"message"]];
                
                return ;
            }
            
//            [self.list_array removeAllObjects];
            NSArray *data = resultDict[@"data"];
            if (data.count != 0) {
                
                for (NSDictionary *dict in data) {
                    DXBBikeModel *model = [DXBBikeModel mj_objectWithKeyValues:dict];
                    [self.list_array addObject:model];
                }
                
                self.tableView.hidden = NO;
                [self.tableView reloadData];
            }else {
                
//                self.tableView.hidden = YES;
//                self.img_nobike.hidden = NO;
//                self.lb_nobike.hidden = NO;
                
                [MBProgressHUD showError:@"没有更多数据了！"];
                
            }
        }else {
            
            //            [MBProgressHUD showError:@"没有更多数据了！"];
        }
        
    } failure:^(NSError *error) {
        self.HUD.hidden = YES;
        [self.tableView.footer endRefreshing];
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


#pragma mark - 显示网络异常界面
/** 显显示网络异常界面 */
-(void)showNoNetworkView{
    
    
    self.tableView.hidden =YES;
//    self.bgView.hidden = YES;
//    self.searchView.hidden = YES;
    
    self.img_nobike.hidden = YES;
    self.lb_nobike.hidden = YES;
    
    
    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    
    
    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_noweb"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 130, 223, 206);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - 200)*0.5, 130+206, 200, 30);
    noDataTipsLabel.font = [UIFont systemFontOfSize:13];
    noDataTipsLabel.text = @"当前网络不可用，请检查网络设置";
    noDataTipsLabel.textColor = [UIColor darkGrayColor];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    //刷新按钮
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake((SCREEN_WIDTH - 150)*0.5, 130+206 + 30 +20, 150, 45);

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
            self.tableView.hidden = NO;
            
            self.img_nobike.hidden = NO;
            self.lb_nobike.hidden = NO;
            
            [self loadData:self.tf_search.text];
            
            
        }else{
            
            
        }
    }];
    
    
}




/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中";
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.tf_search resignFirstResponder];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.tf_search resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
