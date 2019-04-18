//
//  CityPeopleProvideVC.m
//  YiWuHRSS
//
//  Created by 大白 on 2019/3/6.
//  Copyright © 2019年 许芳芳. All rights reserved.
//

#import "CityPeopleProvideVC.h"
#import "CityPeopleProvideTableviewCell.h"
#import "YWPaymentOrderVC.h"
#import "YWRegistSuccessVC.h"
#import "YWRegistFailVC.h"
#import "EPPickerView.h"

@interface CityPeopleProvideVC ()<UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong)UITableView *tableView; //

@property (nonatomic,strong)UIView *headView;//头视图

@property (nonatomic,strong)UIView *footView;//尾视图

/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;

//@property (nonatomic,strong)
@end

@implementation CityPeopleProvideVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self initUI];
}

-(void)initUI{
    self.title = @"城乡居民养老";
    self.view.backgroundColor =[UIColor whiteColor];
    [self.view addSubview:self.tableView];
}
#pragma mark 缴费按钮点击
-(void)payFrom{
    if (_isZaiXianJiaoFei) {
        //立即缴费 前往付款界面
        [self gotoPay];
    }else{
     //前往确认缴费界面
       
        NSLog(@"确认参保中......");
        
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
        param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
//        param[@"cblx"] = self.selectedCBLX.extraObj;
//        param[@"year"] = self.year;
        param[@"shbzh"] = self.dataSoure[1];
        param[@"name"] = self.dataSoure[0];
        param[@"cmc"] =self.dataSoure[2];
        param[@"cbm"] =self.dataSoure[3];
        param[@"device_type"] = @"2";
        param[@"app_version"] = version;
        param[@"jfdcbm"] = self.dataSoure[4][@"jfdcbm"];
        
        NSString *url = [NSString stringWithFormat:@"%@/insured/cxshjmylcb",HOST_TEST];
        
        [self showLoadingUI];
        [HttpHelper post:url params:param success:^(id responseObj) {
            
            
            self.HUD.hidden = YES;
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            if([dictData[@"resultCode"] integerValue]==200){
                DMLog(@"参保结果==%@",dictData);
                
                YWRegistSuccessVC * registSuccessVC = [[YWRegistSuccessVC alloc]init];
                registSuccessVC.shbzh = self.dataSoure[1];
                registSuccessVC.name = self.dataSoure[0];
//                registSuccessVC.year = self.year;
                registSuccessVC.isResidentPension = YES;
                [self.navigationController pushViewController:registSuccessVC animated:YES];
            }else{
                YWRegistFailVC * registfailedVC = [[YWRegistFailVC alloc]init];
                registfailedVC.isResidentPension = YES;
                registfailedVC.reson = dictData[@"message"];
                [self.navigationController pushViewController:registfailedVC animated:YES];
            }
        } failure:^(NSError *error) {
            
            self.HUD.hidden = YES;
            Reachability *r = [Reachability reachabilityForInternetConnection];
            if ([r currentReachabilityStatus] == NotReachable) {
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            } else {
                [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
            }
        }];
        
    }
}


#pragma mark tableView 协议代理方法
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 5;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CityPeopleProvideTableviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"tableCell"];
    if (cell==nil) {
        cell =[[CityPeopleProvideTableviewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"tableCell"];
    }
    cell.name = @[@"姓名",@"身份证号",@"所在村",@"村编码",@"缴费档次"][indexPath.row];
    if (indexPath.row==4) {
        cell.value = self.dataSoure[indexPath.row][@"jfdcmc"];
    }else{
        cell.value = self.dataSoure[indexPath.row];
    }
    if (!_isZaiXianJiaoFei &&indexPath.row==4) {
        cell.directionImage.hidden = NO;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
    
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    WEAK_SELF(weakSelf);
    if (!_isZaiXianJiaoFei &&indexPath.row==4) {
            NSMutableArray *Extracts = [[NSMutableArray alloc] init];
            for (NSDictionary *info in self.dataSoure[5]) {

                PickerViewModel *md = [[PickerViewModel alloc] init];
                md.title = info[@"jfdcmc"];
                md.extraObj = info[@"jfdcbm"];
                [Extracts addObject:md];
            }
//            self.selectedExtractsInfo = responseArray.firstObject;
            //事项选择
            EPPickerView *pikcerView = [EPPickerView showPickerViewWithNumberOfLevel:1];
            pikcerView.datas = Extracts;
            pikcerView.selectOptionFinishBlock = ^(NSArray<PickerViewModel *> *selectedOptionArray) {
                NSDictionary *dic=@{@"jfdcbm":[selectedOptionArray firstObject].extraObj,@"jfdcmc":[selectedOptionArray firstObject].title};
                [weakSelf.dataSoure replaceObjectAtIndex:4 withObject:dic];
//                weakSelf.selectedExtractsInfo.tqsxName = [selectedOptionArray firstObject].title;
//                weakSelf.selectedExtractsInfo.tqsxid = [selectedOptionArray firstObject].extraObj;
//                [weakSelf setDataSourceWithAccountInfo:weakSelf.accountInfo];
                [weakSelf.tableView reloadData];
            };

    }
}

/**
 在线缴费
 */
-(void)gotoPay{
    
    NSLog(@"在线缴费中......");
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
//    param[@"year"] = self.year;
    param[@"shbzh"] = self.dataSoure[1];
    param[@"name"] = self.dataSoure[0];
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    param[@"jfdcbm"] = self.dataSoure[4][@"jfdcbm"];
    
    NSString *url = [NSString stringWithFormat:@"%@/insured/get/cxshjmyljkxx",HOST_TEST];
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSLog(@"dictData=====%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            if ([dictData[@"data"][@"ywlsh"] isEqualToString:@""]) {
                [MBProgressHUD showError:@"此人暂无支付订单,无需支付."];
                return ;
            }
            NSLog(@"城乡居民养老");
            YWPaymentOrderVC *  paymentOrderVC = [[YWPaymentOrderVC alloc]init];
            paymentOrderVC.jfje = dictData[@"data"][@"jfje"];
            paymentOrderVC.ybjkdh = dictData[@"data"][@"ywlsh"];
            paymentOrderVC.ywlb = dictData[@"data"][@"ywlb"];
            paymentOrderVC.shbzh = self.dataSoure[1];
            paymentOrderVC.isResidentPension = YES;
            [self.navigationController pushViewController:paymentOrderVC animated:YES];
            
        }else{
            [MBProgressHUD showError:dictData[@"message"]];
        }
        
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
        self.HUD.hidden = YES;
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
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

#pragma mark 懒加载
-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0 , UI_SCREEN_WIDTH, UI_SCREEN_HEIGHT) style:UITableViewStyleGrouped];
        _tableView.delegate =self;
        _tableView.dataSource =self;
        _tableView.backgroundColor = [UIColor whiteColor];
        _tableView.rowHeight = kRatio_Scale_667(50);
        _tableView.tableHeaderView = self.headView;
        _tableView.tableFooterView = self.footView;
        [_tableView registerClass:[CityPeopleProvideTableviewCell class] forCellReuseIdentifier:@"tableCell"];
    }
    return _tableView;
}

-(NSMutableArray *)dataSoure{
    if (!_dataSoure) {
        _dataSoure = [[NSMutableArray alloc]init];
//        _dataSoure = [[NSMutableArray alloc]initWithArray:@[@"李美丽",@"420823198008279984",@"大兴村",@"9988000",@[@"100元/次",@"200元/次",@"300元/次",@"400元/次"]]];
    }
    return _dataSoure;
}

#pragma mark 头视图
-(UIView *)headView{
    if (!_headView) {
        _headView= [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth_Scale_375, kRatio_Scale_667(30))];
        _headView.backgroundColor =[UIColor whiteColor];
        UIImageView *image = [[UIImageView alloc]initWithFrame:CGRectMake(kRatio_Scale_375(10),kRatio_Scale_667(5), kRatio_Scale_375(20), kRatio_Scale_667(20))];
        image.image = [UIImage imageNamed:@"icon_jmyanglao"];
        [_headView addSubview:image];
        UILabel *value = [[UILabel alloc]initWithFrame:CGRectMake(image.right+10, kRatio_Scale_667(5), kRatio_Scale_375(200), kRatio_Scale_667(20))];
        value.text = @"城乡居民养老参保缴费";
        value.font = Font_Scale_375(14);
        value.textColor = [UIColor colorWithHex:0xfdb731];
        [_headView addSubview:value];
    }
    return _headView;
}

#pragma mark 尾视图
-(UIView *)footView{
    if (!_footView) {
        _footView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, kWidth_Scale_375, kRatio_Scale_667(150))];
        UIButton *btn = [[UIButton alloc]init];
        [_footView addSubview:btn];
        [btn setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        if (_isZaiXianJiaoFei) {
            [btn setTitle:@"立即缴费" forState:UIControlStateNormal];
        }else{
            [btn setTitle:@"确认参保" forState:UIControlStateNormal];
        }
        btn.clipsToBounds = YES;
        btn.layer.cornerRadius = 5;
        [btn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_footView).with.insets(UIEdgeInsetsMake(kRatio_Scale_667(90), kRatio_Scale_375(10), kRatio_Scale_667(10), kRatio_Scale_375(10)));
            
        }];
        [btn addTarget:self action:@selector(payFrom) forControlEvents:UIControlEventTouchUpInside];
    }
    return _footView;
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
