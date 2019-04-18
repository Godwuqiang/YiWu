//
//  DXBResettlementhospitalVC.m
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBResettlementhospitalVC.h"
#import "DXBHospitalCell.h"
#import "DXBSelecteHospitalView.h"
#import "HttpHelper.h"
#import "DTFRemoteVC.h"
#import "DXBSearchHospitalModel.h"
#import "MJExtension.h"
#import "AESCipher.h"
#import "NSString+category.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key

#define URL_GETCHOOSEHOSPITAL       @"/shebao/chooseHospitalAES.json"       // 选择安置医院接口

static NSString *dxbHospitalCell = @"dxbHospitalCell";


@interface DXBResettlementhospitalVC ()<UITableViewDelegate, UITableViewDataSource, DXBSelecteHospitalViewDelegate, UITextFieldDelegate>

/// 选择的医院View
@property (nonatomic, strong) DXBSelecteHospitalView *hospitalView;

/// 搜索到的医院列表
@property (nonatomic, strong) NSMutableArray *searchResultArray;

/** HUD */
@property(nonatomic ,strong) MBProgressHUD * HUD;

/** 页码 */
@property(nonatomic, assign)     int      pageNo;


@end

@implementation DXBResettlementhospitalVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"选择安置医院";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 20, 30);
    [btn setImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(backRootVC) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    
    self.search2Btn.layer.cornerRadius = 5;
    self.addBtn.layer.cornerRadius = 5;
    
    self.inputBtn.hidden = YES;
    self.tableView.hidden = YES;
    self.addBtn.hidden = YES;
    self.searchTextField.delegate = self;
    
    self.searchResultArray = [NSMutableArray array];
    
    self.pageNo = 1;
    
    self.hospitalView = [[DXBSelecteHospitalView alloc] initWithFrame:CGRectMake(0, 100, SCREEN_WIDTH, 0)];
    self.hospitalView.delegate = self;
    [self.view addSubview:self.hospitalView];
    
    
    [self.search1Btn setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
    [self.search1Btn setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 10)];
    [self.search1Btn setImageEdgeInsets:UIEdgeInsetsMake(0, 50, 0, 0)];
    
    [self.inputBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = 46;
    self.tableView.tableFooterView = [UIView new];
    [self.tableView registerNib:[UINib nibWithNibName:@"DXBHospitalCell" bundle:nil] forCellReuseIdentifier:dxbHospitalCell];
    
    // 上拉加载更多
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(loadMoreData)];
    
    
}

- (void)backRootVC {
    
    
    NSDictionary *tempDic = @{@"selectedhospital":self.selectedhospital};
    [[NSNotificationCenter defaultCenter] postNotificationName:@"selectedHospitalList" object:nil userInfo:tempDic];
    UIViewController *VC = [self.navigationController.viewControllers objectAtIndex:3];
    [self.navigationController popToViewController:VC animated:true];
    
}

- (void)viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    DMLog(@"已经选择的医院： %@", self.selectedhospital);
    
    if (self.selectedhospital.count == 0) {
        return;
    }
    if (self.selectedhospital.count <= 2) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 60)];
        self.bgTopConstraints.constant = 60;
    }else if (self.selectedhospital.count <= 4) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 110)];
        self.bgTopConstraints.constant = 110;
    }
    
    [self.hospitalView setListArray:self.selectedhospital];
    
}

#pragma mark - 搜索1
- (IBAction)search1BtnClick:(id)sender {
    
    self.inputBtn.hidden = !self.inputBtn.hidden;
    
    if (self.inputBtn.hidden) {
        [self.search1Btn setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
    }else {
        [self.search1Btn setImage:[UIImage imageNamed:@"icon_up"] forState:UIControlStateNormal];
    }
}

#pragma mark - 输入
- (IBAction)inputButtonClick:(id)sender {
    
    self.searchTextField.text = @"";
    
    if ([self.search1Btn.titleLabel.text isEqualToString:@"搜索"]) {
        [self.search1Btn setTitle:@"输入" forState:UIControlStateNormal];
        [self.inputBtn setTitle:@"搜索" forState:UIControlStateNormal];
        self.search2Btn.hidden = YES;
        self.lineView.hidden = YES;
        self.addBtn.hidden = NO;
        self.tableView.hidden = YES;
        self.no_hospitalImgView.hidden = YES;
        self.no_hospitalLabel.hidden = YES;
        self.searchTextField.placeholder = @"输入安置医院名称";
        self.input_entryImgView.image = [UIImage imageNamed:@"input_entry"];
        
        // 如果输入添加的医院有4加，则按钮变灰，不能再添加
        if (self.selectedhospital.count == 4) {
            
            [self.addBtn setBackgroundColor:[UIColor lightGrayColor]];
//            self.addBtn.userInteractionEnabled = NO;
            self.input_entryImgView.image = [UIImage imageNamed:@"input_entry_gray"];
        }
        
    }else {
        [self.search1Btn setTitle:@"搜索" forState:UIControlStateNormal];
        [self.inputBtn setTitle:@"输入" forState:UIControlStateNormal];
        self.search2Btn.hidden = NO;
        self.lineView.hidden = NO;
        self.addBtn.hidden = YES;
        self.input_entryImgView.image = [UIImage imageNamed:@"input_entry"];
        
        if ([self.searchTextField.text isEqualToString:@""]) {
            self.no_hospitalImgView.hidden = NO;
            self.no_hospitalLabel.hidden = NO;
            self.tableView.hidden = YES;
        }else {
            self.no_hospitalImgView.hidden = YES;
            self.no_hospitalLabel.hidden = YES;
            self.tableView.hidden = NO;
        }
        
        self.searchTextField.placeholder = @"搜索安置医院名称";
    }
    
    
    
    self.inputBtn.hidden = YES;
    [self.search1Btn setImage:[UIImage imageNamed:@"icon_down"] forState:UIControlStateNormal];
}



#pragma mark - 搜索2
- (IBAction)search2BtnClick:(id)sender {
    
    [self.searchTextField resignFirstResponder];
    if ([self.searchTextField.text length] < 4) {
        
        [MBProgressHUD showError:@"请输入4个及以上字符再进行搜索"];
        return;
    }
    
    self.pageNo = 1;
    [self searchHospital];
    
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldClear:(UITextField *)textField {
    
    if ([self.search1Btn.titleLabel.text containsString:@"搜索"]) {
        
        self.no_hospitalImgView.hidden = NO;
        self.no_hospitalLabel.hidden = NO;
        self.tableView.hidden = YES;
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    NSLog(@"textFieldDidBeginEditing");
    self.inputBtn.hidden = YES;
}

#pragma mark - 添加按钮
- (IBAction)addButtonClick:(id)sender {
    
    
    
    if (self.selectedhospital.count == 4) {
        
        [MBProgressHUD showError:@"最多添加4家医院，请删除已选择的医院后再进行输入或选择操作"];
        return;
    }
    
    if ([self.searchTextField.text isEqualToString:@""]) {
        
        [MBProgressHUD showError:@"请输入医院名称"];
        return;
    }
    
    // 如果医院已经添加了，不在继续添加
    if ([self.selectedhospital containsObject:[NSString stringWithFormat:@"%@;90005", self.searchTextField.text]]) {
        [MBProgressHUD showError:@"该医院已添加，请重新选择或录入其他安置医院~"];
        return;
    }

    [self.selectedhospital addObject:[NSString stringWithFormat:@"%@;90005", self.searchTextField.text]];
    
    self.searchTextField.text = @""; // 添加成功后清除输入框
    
    if (self.selectedhospital.count <= 2) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 60)];
        self.bgTopConstraints.constant = 60;
    }else if (self.selectedhospital.count <= 4) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 110)];
        self.bgTopConstraints.constant = 110;
    }
    
    [self.hospitalView setListArray:self.selectedhospital];
    
    // 如果输入添加的医院有4加，则按钮变灰，不能再添加
    if (self.selectedhospital.count == 4) {
        
        [self.addBtn setBackgroundColor:[UIColor lightGrayColor]];
//        self.addBtn.userInteractionEnabled = NO;
        self.input_entryImgView.image = [UIImage imageNamed:@"input_entry_gray"];
    }
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.searchResultArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    DXBHospitalCell *cell = [tableView dequeueReusableCellWithIdentifier:dxbHospitalCell];
    if (nil == cell) {
        cell = [[DXBHospitalCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:dxbHospitalCell];
    }
    
    DXBSearchHospitalModel *model = self.searchResultArray[indexPath.row];
    cell.hospitalName.text = model.yljgmc;
    
//    UIView* tempView=[[UIView alloc] initWithFrame:cell.frame];
//    tempView.backgroundColor = [UIColor whiteColor];
//    cell.backgroundView = tempView;  //更换背景色     不能直接设置backgroundColor
//    UIView* tempView1=[[UIView alloc] initWithFrame:cell.frame];
//    tempView1.backgroundColor = [UIColor colorWithHex:0xfdb731];
//    cell.selectedBackgroundView = tempView1;
    
    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if ([self.selectedhospital containsObject:[NSString stringWithFormat:@"%@;%@", model.yljgmc, model.yljgbm]]) {
        
        cell.contentView.backgroundColor = [UIColor colorWithHex:0xfdb731];
    }

    return cell;
}

// 区头
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 36;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 36)];
    headerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 100, 36)];
    label.text = @"请选择医院";
    label.textColor = [UIColor colorWithHex:0x666666];
    label.font = [UIFont systemFontOfSize:13];
    [headerView addSubview:label];
    
    return headerView;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    
    DXBSearchHospitalModel *model = self.searchResultArray[indexPath.row];
    // 如果医院已经添加了，不在继续添加
    if ([self.selectedhospital containsObject:[NSString stringWithFormat:@"%@;%@", model.yljgmc, model.yljgbm]]) {
        
        [self.tableView reloadData];
        
        [self.selectedhospital removeObject:[NSString stringWithFormat:@"%@;%@", model.yljgmc, model.yljgbm]];

        if (self.selectedhospital.count <= 2) {
            
            [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 60)];
            self.bgTopConstraints.constant = 60;
        }else if (self.selectedhospital.count <= 4) {
            
            [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 110)];
            self.bgTopConstraints.constant = 110;
        }
        
        if (self.selectedhospital.count == 0) {
            [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 0)];
            self.bgTopConstraints.constant = 0;
        }
        
        [self.hospitalView setListArray:self.selectedhospital];
        
        return;
    }
    
    if (self.selectedhospital.count == 4) {
        
        [MBProgressHUD showError:@"最多添加4家医院，请删除已选择的医院后再进行输入或选择操作"];
        return;
    }
    
    [self.selectedhospital addObject:[NSString stringWithFormat:@"%@;%@", model.yljgmc, model.yljgbm]];
    
    if (self.selectedhospital.count <= 2) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 60)];
        self.bgTopConstraints.constant = 60;
    }else if (self.selectedhospital.count <= 4) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 110)];
        self.bgTopConstraints.constant = 110;
    }
    
    [self.hospitalView setListArray:self.selectedhospital];
    
    
    ////////
    DXBHospitalCell* cell=[tableView cellForRowAtIndexPath:indexPath];
    cell.contentView.backgroundColor = [UIColor colorWithHex:0xfdb731];
    
}

#pragma mark - DXBSelecteHospitalView Delegate
- (void)deleteSelectedHospitalList:(NSInteger)indexItem {
    
    DMLog(@"删除选择的医院列表  : %li", indexItem);
    DMLog(@"选择的医院： %@", self.selectedhospital);

    [self.selectedhospital removeObjectAtIndex:indexItem];
    if (self.selectedhospital.count <= 2) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 60)];
        self.bgTopConstraints.constant = 60;
    }else if (self.selectedhospital.count <= 4) {
        
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 110)];
        self.bgTopConstraints.constant = 110;
    }
    
    if (self.selectedhospital.count == 0) {
        [self.hospitalView setFrame:CGRectMake(0, 100, SCREEN_WIDTH, 0)];
        self.bgTopConstraints.constant = 0;
    }
    
    [self.hospitalView setListArray:self.selectedhospital];
    
    
    // 如果选择的医院小于4个，则可以再添加
    if (self.selectedhospital.count < 4) {
        
        [self.addBtn setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
//        self.addBtn.userInteractionEnabled = YES;
        
        self.input_entryImgView.image = [UIImage imageNamed:@"input_entry"];
    }
    
    
    /** 删除选择的医院时，cell上的选中背景颜色去掉 */

    if (!self.tableView.hidden) {
        [self.tableView reloadData];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    [self.searchTextField resignFirstResponder];
}

#pragma mark - 搜索医院列表
- (void)searchHospital {
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"ddyljgmc"] = self.searchTextField.text;
    param[@"yyszs"] = self.yyszs;
    param[@"page_no"] = @(self.pageNo); // 页码
    param[@"page_size"] = @"15"; // 每页显示数量
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_GETCHOOSEHOSPITAL];
    
    DMLog(@"param--%@",param);
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    [self showLoadingUI];
    [HttpHelper post:url params:paramDict success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        [self.tableView.footer endRefreshing];
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSString * dataBackString = aesDecryptString(dictData[@"dataBack"], AESEncryptKey);
        dictData = [NSString db_dictionaryWithJsonString:dataBackString];

        
        DMLog(@"选择安置医院接口-%@",dictData);
        DMLog(@"选择安置医院接口-message====%@",dictData[@"message"]);
        
        
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            if (self.pageNo == 1) {
                [self.searchResultArray removeAllObjects];
            }
            
            self.no_hospitalImgView.hidden = YES;
            self.no_hospitalLabel.hidden = YES;
            self.tableView.hidden = NO;
            
            NSDictionary * dataDict = dictData[@"data"];
            NSArray *hospitalList = dataDict[@"hospitalList"];
            for (NSDictionary *dict in hospitalList) {
                
                DXBSearchHospitalModel *model = [DXBSearchHospitalModel mj_objectWithKeyValues:dict];
                [self.searchResultArray addObject:model];
            }
            [self.tableView reloadData];
            
        }else{
            
            if (self.pageNo == 1) {
                
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
                
                self.no_hospitalImgView.hidden = NO;
                self.no_hospitalLabel.hidden = NO;
                self.tableView.hidden = YES;
            }else {
                
                [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
            }
            
            
        }
        
    } failure:^(NSError *error) {
        
        self.HUD.hidden = YES;
        [self.tableView.footer endRefreshing];
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
    }];
}

#pragma mark - 上拉加载更多
- (void)loadMoreData {
    
    self.pageNo = self.pageNo+1;
    [self searchHospital];
}

/**
 *  加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    [self.view endEditing:YES];
    self.inputBtn.hidden = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}


@end
