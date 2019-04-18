//
//  DTFSearchVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/1/25.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "DTFSearchVC.h"
#import "LoginVC.h"
#import "CanBaoInfoVC.h"
#import "WuXianPaymentVC.h"
#import "YBcostVC.h"
#import "YLJfafangVC.h"
#import "YLJAccountVC.h"
#import "PharmacyListVC.h"
#import "HospitalListVC.h"
#import "TrearmentListVC.h"
#import "MedicalListVC.h"
#import "BdH5VC.h"
#import "DTFQualificationVC.h"
#import "DTFRegisterVC.h"
#import "DXBPublicBlikeVC.h"
#import "ParkVC.h"
#import "CheckListVC.h"
#import "NetListVC.h"
#import "GuaShiVC.h"
#import "HttpHelper.h"
#import "SrrzBean.h"
#import "MJExtension.h"
#import "ModifyCardView.h"
#import "GHH5VC.h"
#import "RzwtgView.h"
#import "JFH5VC.h"
#import "DTFCitizenCardInfoConfirmVC.h"
#import "DTFHarmoCardInfoComfirmVC.h"
#import "SZKAlterView.h"
#import "DTFRechargeVC.h"
#import "BankKTVC.h"

#define SRRZ_STATUS_URL   @"/complexServer/checkSrrzStatus.json" // 实人认证状态

@interface DTFSearchVC ()<UISearchBarDelegate,UITableViewDataSource,UITableViewDelegate>

@property(nonatomic,strong)UISearchBar *searchBar;
@property(nonatomic,strong)UITableView *searchResult;
@property (nonatomic,strong) NSMutableArray *nameArray;
@property (nonatomic,strong) NSMutableArray *detailArray;
@property (nonatomic,strong) NSMutableArray *result;
@property (nonatomic,strong) NSMutableArray *detailResult;
@property (nonatomic,strong) UIImageView * noDataImageView;
@property (nonatomic,strong) UILabel * noDataLbale;

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property                     BOOL                       hasnet;
-(void)initSearchBar;//创建搜索
-(void)initTableView;//创建搜索结果的示意图

@end

@implementation DTFSearchVC

-(NSMutableArray *)result{
    if (!_result) {
        self.result = [NSMutableArray array];
    }
    return _result;
}

-(NSMutableArray *)detailResult {
    if (!_detailResult) {
        self.detailResult = [NSMutableArray array];
    }
    return _detailResult;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    self.title = @"搜索";
    
    self.nameArray = [@[@"参保信息", @"缴费记录", @"医保消费", @"养老待遇", @"养老个账",@"定点药店", @"定点医院", @"诊疗目录", @"药品目录", @"家庭账户授权",@"灵活就业人员参保", @"信息修改", @"社保待遇资格认证", @"长住外地备案", @"市民卡账户",@"交易记录", @"市民卡预挂失", @"服务网点", @"公共自行车", @"公共停车场",@"信用积分", @"车牌绑定", @"城乡居民财政补助", @"大钱包充值", @"就诊挂号",@"就诊缴费", @"检查检验单"] mutableCopy];
    
    self.detailArray = [@[@"查询社保参保险种信息", @"查询社保缴费信息", @"查询医保消费信息", @"查询企业退休人员待遇发放信息", @"查询企业养老个人账户信息",@"查找医保定点药店", @"查找医保定点医院", @"查询医保诊疗目录信息", @"查询医保药品目录信息", @"授权家庭成员使用医保个人账户",@"个体参保申报和参保中断", @"社保手机号修改", @"社保待遇享受人员资格认证和信息核对", @"异地安置、外派、探亲人员登记", @"查询市民卡大小钱包余额",@"查询市民卡消费、充值记录", @"在线办理市民卡预挂失", @"查找市民卡服务网点", @"查找附近的公共自行车", @"查找附近的停车场",@"查询个人信用积分", @"在线办理车牌绑定", @"查看城乡居民财政补助情况", @"大钱包账户在线充值", @"当日挂号，预约挂号",@"医保自费，一键支付", @"查询检查检验单"] mutableCopy];
    
    
    
    [self initSearchBar];
    [self initTableView];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self afn];

}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
}

-(void)initSearchBar{
    
    if(kIsiPhoneX){
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64+24, self.view.bounds.size.width, 44)];
    }else{
        self.searchBar = [[UISearchBar alloc]initWithFrame:CGRectMake(0, 64, self.view.bounds.size.width, 44)];
    }
    
    _searchBar.keyboardType = UIKeyboardAppearanceDefault;
    _searchBar.placeholder = @"输入搜索关键词";
    _searchBar.delegate = self;
    _searchBar.searchBarStyle = UISearchBarStyleMinimal;
    _searchBar.barStyle = UIBarStyleDefault;
    _searchBar.backgroundColor = [UIColor colorWithHex:0xeeeeee];

    UITextField *searchField = [_searchBar valueForKey:@"_searchField"];
    searchField.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_searchBar];
    DMLog(@"searchField==%@",searchField.subviews);
    
    for (UIView * subView in searchField.subviews) {
//        if([[subView class] isKindOfClass:NSClassFromString(@"UISearchBarSearchFieldBackgroundView")]){
           DMLog(@"%@",[subView class]);
//        }
//        subView.backgroundColor = [UIColor redColor];
        
        if ([[subView class] isKindOfClass:NSClassFromString(@"UISearchBarSearchFieldBackgroundView")]) {
            subView.backgroundColor = [UIColor redColor];
            DMLog(@"sub---%@",subView.subviews);
        }
        DMLog(@"sub---%@",subView.subviews);
        
    }
    
}

- (void)initTableView{
    self.searchResult = [[UITableView alloc]initWithFrame:CGRectMake(0,CGRectGetMaxY(self.searchBar.frame), self.view.bounds.size.width, self.view.bounds.size.height-64-CGRectGetHeight(self.searchBar.frame))];
    _searchResult.dataSource = self;
    _searchResult.delegate =self;
    _searchResult.tableFooterView = [[UIView alloc]init];
    [_searchResult registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    [self.view addSubview:self.searchResult];
    
    self.noDataImageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_nosearch"]];
    self.noDataImageView.frame = CGRectMake((SCREEN_WIDTH-200)/2.0, 50, 200, 200);
    self.noDataLbale = [[UILabel alloc]init];
    self.noDataLbale.frame = CGRectMake(0, 270, SCREEN_WIDTH, 30);
    self.noDataLbale.textAlignment = NSTextAlignmentCenter;
    self.noDataLbale.font = [UIFont systemFontOfSize:14.0];
    self.noDataLbale.textColor = [UIColor colorWithHex:0x666666];
    self.noDataLbale.text = @"未查询到对应的搜索结果，请更换条件查询！";
    
    if (@available(iOS 11.0, *)) {
        self.searchResult.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    return YES;
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    //searchBar.showsCancelButton = NO;//取消的字体颜色，
    //[searchBar setShowsCancelButton:YES animated:YES];
    NSLog(@"heahtdyfgh");
    
    //改变取消的文本
    for(UIView *view in  [[[searchBar subviews] objectAtIndex:0] subviews]) {
        if ([view isKindOfClass:[UIButton class]]) {
            //UIButton *cancel =(UIButton *)view;
            //[cancel setTitle:@"取消" forState:UIControlStateNormal];
            //[cancel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }
}



-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    NSLog(@"我的");
}

/**
 *  搜框中输入关键字的事件响应
 *
 *  @param searchBar  UISearchBar
 *  @param searchText 输入的关键字
 */
-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    
    NSLog(@"输入的关键字是---%@---%lu",searchText,(unsigned long)searchText.length);
    self.result = nil;
    self.detailResult = nil;
    for (int i = 0; i < self.nameArray.count; i++) {
        //        NSString *string = self.nameArray[i];
        //        if (string.length >= searchText.length) {
        if ([self.nameArray[i] containsString:searchText] || [self.detailArray[i] containsString:searchText]) {
            [self.result addObject:self.nameArray[i]];
            [self.detailResult addObject:self.detailArray[i]];
        }
        //        }
    }
    
    if(self.result.count>0){
        [self.noDataImageView removeFromSuperview];
        [self.noDataLbale removeFromSuperview];
    }else{
        if([searchText isEqualToString:@""]){
            [self.noDataImageView removeFromSuperview];
            [self.noDataLbale removeFromSuperview];
        }else{
            [self.searchResult addSubview:self.noDataImageView];
            [self.searchResult addSubview:self.noDataLbale];
        }
    }
    [self.searchResult reloadData];
    
}

/**
 *  取消的响应事件
 *
 *  @param searchBar UISearchBar
 */
-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"取消吗");
    //[searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
}

/**
 *  键盘上搜索事件的响应
 *
 *  @param searchBar UISearchBar
 */
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSLog(@"取");
    [searchBar setShowsCancelButton:NO animated:YES];
    [searchBar resignFirstResponder];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.view endEditing:YES];
}

/**
 *  UITableView的三个代理
 *
 *
 *  @return 行数
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.result.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];
    cell.imageView.image = [UIImage imageNamed:@"icon_list"];
    cell.textLabel.text = self.result[indexPath.row];
    cell.detailTextLabel.text = self.detailResult[indexPath.row];
    cell.separatorInset = UIEdgeInsetsMake(10, 0, 0, 0);
    
    NSRange range1 = [cell.textLabel.text rangeOfString:self.searchBar.text];
    NSRange range2 = [cell.detailTextLabel.text rangeOfString:self.searchBar.text];
    [self setTextColor:cell.textLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:range1 AndColor:[UIColor orangeColor]];
    [self setTextColor:cell.detailTextLabel FontNumber:[UIFont systemFontOfSize:15] AndRange:range2 AndColor:[UIColor orangeColor]];
    return cell;
}


//设置不同字体颜色
-(void)setTextColor:(UILabel *)label FontNumber:(id)font AndRange:(NSRange)range AndColor:(UIColor *)vaColor
{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:label.text];
    //设置字号
    //[str addAttribute:NSFontAttributeName value:font range:range];
    //设置文字颜色
    [str addAttribute:NSForegroundColorAttributeName value:vaColor range:range];
    
    label.attributedText = str;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 60;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSString * modelName = self.result[indexPath.row];
    
    
    if([modelName isEqualToString:@""]) return;

    
    if([modelName isEqualToString:@"参保信息"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            CanBaoInfoVC *VC = [SB instantiateViewControllerWithIdentifier:@"CanBaoInfoVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"缴费记录"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle: nil];
            WuXianPaymentVC *VC = [SB instantiateViewControllerWithIdentifier:@"WuXianPaymentVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"医保消费"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            YBcostVC *VC = [SB instantiateViewControllerWithIdentifier:@"YBcostVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"养老待遇"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            YLJfafangVC *VC = [SB instantiateViewControllerWithIdentifier:@"YLJfafangVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"养老个账"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
            YLJAccountVC *VC = [SB instantiateViewControllerWithIdentifier:@"YLJAccountVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"定点药店"]){
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        PharmacyListVC *VC = [SB instantiateViewControllerWithIdentifier:@"PharmacyListVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"定点医院"]){
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        HospitalListVC *VC = [SB instantiateViewControllerWithIdentifier:@"HospitalListVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"诊疗目录"]){
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        TrearmentListVC *VC = [SB instantiateViewControllerWithIdentifier:@"TrearmentListVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"药品目录"]){
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        MedicalListVC *VC = [SB instantiateViewControllerWithIdentifier:@"MedicalListVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"家庭账户授权"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/account_auth_step1.html?" forKey:@"url"];
            [VC setValue:@"家庭账户授权" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"灵活就业人员参保"]){
        
        DMLog(@"灵活就业人员参保");
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/flex_employ_index.html?" forKey:@"url"];
            [VC setValue:@"灵活就业人员参保" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"信息修改"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/modify.html?" forKey:@"url"];
            [VC setValue:@"信息修改" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
        DMLog(@"信息修改");
        
    }else if ([modelName isEqualToString:@"社保待遇资格认证"]){
        
        DMLog(@"社保待遇资格认证");
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            DTFQualificationVC * vc = [[DTFQualificationVC alloc]init];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"长住外地备案"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
            DTFRegisterVC * VC = [SB instantiateViewControllerWithIdentifier:@"DTFRegisterVC"];
            [self.navigationController pushViewController:VC animated:YES];
            
        }
        
    }else if ([modelName isEqualToString:@"市民卡账户"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/account_info.html?" forKey:@"url"];
            [VC setValue:@"市民卡账户" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"交易记录"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/transaction_record.html?" forKey:@"url"];
            [VC setValue:@"交易记录" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"市民卡预挂失"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            GuaShiVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"GuaShiVC"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"服务网点"]){
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        NetListVC *VC = [SB instantiateViewControllerWithIdentifier:@"NetListVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"公共自行车"]){
        
        DMLog(@"公共自行车");
        
        DXBPublicBlikeVC *VC = [[DXBPublicBlikeVC alloc] init];
        VC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"公共停车场"]){
        
        DMLog(@"公共停车场");
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName: @"Service" bundle: nil];
        ParkVC *VC = [SB instantiateViewControllerWithIdentifier:@"ParkVC"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
        
    }else if ([modelName isEqualToString:@"信用积分"]){
        
        DMLog(@"信用积分");
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/credit.html?" forKey:@"url"];
            [VC setValue:@"信用积分" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"车牌绑定"]){
        
        DMLog(@"车牌绑定");
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/car_bind_step1.html?" forKey:@"url"];
            [VC setValue:@"车牌绑定" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
    }else if ([modelName isEqualToString:@"城乡居民财政补助"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
            BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
            [VC setValue:@"/h5/finance_subsidy.html?" forKey:@"url"];
            [VC setValue:@"城乡居民财政补助" forKey:@"tit"];
            VC.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:VC animated:YES];
        }
        
        DMLog(@"城乡居民财政补助");
        
    }else if ([modelName isEqualToString:@"大钱包充值"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{//已登录
            
            //LOGIN_BANKZF_STATUS
            if([[CoreArchive strForKey:LOGIN_SRRZ_STATUS] isEqualToString:@"1"]){
                
                if([[CoreArchive strForKey:LOGIN_BANKZF_STATUS] isEqualToString:@"1"]){//银行卡支付开通
                    
                    DTFRechargeVC * vc = [[DTFRechargeVC alloc]init];
                    [self.navigationController pushViewController:vc animated:YES];
                    
                }else{//银行卡支付未开通
                    
                    SZKAlterView * bankcardStatus = [SZKAlterView alterViewWithTitle:@"" content:@"您还没有开通银行卡支付功能，请开通后再进行充值。" cancel:@"取消" sure:@"去开通" cancelBtClcik:^{
                        
                    } sureBtClcik:^{
                        UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
                        BankKTVC * VC = [MB instantiateViewControllerWithIdentifier:@"BankKTVC"];
                        VC.hidesBottomBarWhenPushed=YES;
                        [self.navigationController pushViewController:VC animated:YES];
                    }];
                    
                    __block UIView * blockView = nil;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        if (blockView == nil) blockView = [[UIApplication sharedApplication].windows lastObject];
                        
                        //适配iOS11，iOS新增_UIInteractiveHighlightEffectWindow，要加载的在上面的是UITextEffectsWindow
                        for (NSObject * window in [UIApplication sharedApplication].windows) {
                            if([NSStringFromClass([window class]) isEqualToString:@"UITextEffectsWindow"]){
                                blockView = (UIView *)window;
                            }
                        }
                        [blockView addSubview:bankcardStatus];
                    });
                }
            }else{//未实人认证
                
                [self showSRRZView];
            }
        }
        
    }else if ([modelName isEqualToString:@"就诊挂号"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            if (_hasnet) {
                [self CheckSrrzStatusWithTag:1];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
        
    }else if ([modelName isEqualToString:@"就诊缴费"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            if (_hasnet) {
                [self CheckSrrzStatusWithTag:2];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
        
    }else if ([modelName isEqualToString:@"检查检验单"]){
        
        if (![CoreArchive boolForKey:LOGIN_STUTAS]) {//未登录
            YWLoginVC * loginVC = [[YWLoginVC alloc]init];
            loginVC.isFromRegist = YES;
            DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
            [self presentViewController:navVC animated:YES completion:nil];
        }else{
            if (_hasnet) {
                UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle: nil];
                CheckListVC *VC = [SB instantiateViewControllerWithIdentifier:@"CheckListVC"];
                VC.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:VC animated:YES];
            }else{
                [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
            }
        }
        
    }
}


#pragma mark - 实人认证状态查询接口
-(void)CheckSrrzStatusWithTag:(NSUInteger)tag{
    NSString *access_token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    [param setValue:access_token forKey:@"access_token"];
    [param setValue:@"2" forKey:@"device_type"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,SRRZ_STATUS_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
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
                        [self.tabBarController.selectedViewController.view addSubview:vv];
                    }else{
                        if ([bean.renzhengStatus isEqualToString:@"1"]) {  // 认证成功
                            if (tag==1) {   // 就诊挂号
                                if (_hasnet) {
                                    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                                    GHH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"GHH5VC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }else {     // 就诊缴费
                                if (_hasnet) {
                                    UIStoryboard *SB = [UIStoryboard storyboardWithName: @"HomePage" bundle: nil];
                                    JFH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"JFH5VC"];
                                    VC.hidesBottomBarWhenPushed=YES;
                                    [self.navigationController pushViewController:VC animated:YES];
                                }else{
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }
                        }else if ([bean.renzhengStatus isEqualToString:@"5"]){   // 未认证
                            [self showSRRZView];
                        }else{              // 认证不通过
                            // NSString *msg = [resultDict objectForKey:@"message"];
                            NSString *msg = @"   因您上传照片不符合实人认证要求，无法继续使用该功能，请重新进行实人认证。";
                            RzwtgView *lll=[RzwtgView alterViewWithContent:msg cancel:@"取消" sure:@"重新认证" cancelBtClcik:^{
                                //取消按钮点击事件
                                DMLog(@"取消");
                            } sureBtClcik:^{
                                //重新认证点击事件
                                DMLog(@"重新认证");
                                if (_hasnet) {
                                    //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
                                    //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
                                    //VC.hidesBottomBarWhenPushed=YES;
                                    //[self.navigationController pushViewController:VC animated:YES];
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
                                    [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
                                }
                            }];
                            [self.tabBarController.selectedViewController.view addSubview:lll];
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
    }];
}


#pragma mark - 显示实人认证弹窗
-(void)showSRRZView{
    SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"您还没有实人认证，请先进行实人认证" cancel:@"取消" sure:@"认证" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        DMLog(@"认证");
        if (_hasnet) {
            //UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
            //MineWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"MineWebVC"];
            //VC.hidesBottomBarWhenPushed=YES;
            //[self.navigationController pushViewController:VC animated:YES];
            
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
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        }
    }];
    //[self.tabBarController.selectedViewController.view addSubview:lll];
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

#pragma mark -  请求检查网络状态
- (void)afn{
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            _hasnet = YES;
        }else{
            _hasnet = NO;
        }
    }];
}



@end
