//
//  YWQueryWIthYearVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWQueryWIthYearVC.h"
#import "YWSeriousIllnessVC.h"
#import "YWResidentTreatmentVC.h"
#import "CityPeopleProvideVC.h"

@interface YWQueryWIthYearVC ()

/** 年份 */
@property (nonatomic,strong) NSMutableArray<PickerViewModel *> * yearList;
/** 选择的年份 */
@property (nonatomic,strong) NSString * selectedYear;
/** HUD */
@property (nonatomic,strong) MBProgressHUD * HUD;

@end

@implementation YWQueryWIthYearVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //测试
//    self.idNumberTextField.text = @"330725197509116123";
//    self.nameTextField.text = @"王燕青";
    
    self.nameView.clipsToBounds = YES;
    self.nameView.layer.cornerRadius = 5.0;
    self.nameView.layer.borderWidth = 1.0;
    self.nameView.layer.borderColor = [UIColor colorWithHex:0xDFDFDF].CGColor;
    
    self.idNumberView.clipsToBounds = YES;
    self.idNumberView.layer.cornerRadius = 5.0;
    self.idNumberView.layer.borderWidth = 1.0;
    self.idNumberView.layer.borderColor = [UIColor colorWithHex:0xDFDFDF].CGColor;
    
    self.yearView.clipsToBounds = YES;
    self.yearView.layer.cornerRadius = 5.0;
    self.yearView.layer.borderWidth = 1.0;
    self.yearView.layer.borderColor = [UIColor colorWithHex:0xDFDFDF].CGColor;
    
    self.searchButton.clipsToBounds = YES;
    self.searchButton.layer.cornerRadius = 8.0;
    
    if(self.isSeriousIllness){
        self.title = @"大病保险";
    }
    if(self.isResidentTreatment){
        self.title = @"城乡居民医疗";
    }
    if (self.isJMYangLao) {
        self.title = @"城乡居民养老";
        self.yearView.hidden = YES;
    }
    
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapView)];
    [self.view addGestureRecognizer:tap];
    
    //获取年份
    NSDate *  senddate=[NSDate date];
    NSDateFormatter  *dateformatter=[[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy"];
    NSString *thisYearString=[dateformatter stringFromDate:senddate];
    self.yearList = [NSMutableArray array];
    
    PickerViewModel * model1 = [[PickerViewModel alloc]init];
    model1.title =thisYearString;
    model1.extraObj = thisYearString;
    [self.yearList addObject:model1];
    
    PickerViewModel * model2 = [[PickerViewModel alloc]init];
    model2.title =[NSString stringWithFormat:@"%ld",([thisYearString integerValue] +1)];
    model2.extraObj = model2.title;
    [self.yearList addObject:model2];
    
    self.yearLabel.text = self.yearList[1].extraObj;
    self.selectedYear = self.yearList[1].extraObj;//默认选中下一年
    
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

/**
 年份选择按钮

 @param sender 年份选择
 */
- (IBAction)yearButtonClick:(UIButton *)sender {
    
    
    [self.nameTextField resignFirstResponder];
    [self.idNumberTextField resignFirstResponder];
    
    EPPickerView *pikcerView = [EPPickerView showPickerViewWithNumberOfLevel:1];
    pikcerView.datas = self.yearList;
    pikcerView.selectOptionFinishBlock = ^(NSArray<PickerViewModel *> *selectedOptionArray) {
        self.yearLabel.text = [selectedOptionArray firstObject].title;
        self.selectedYear = [selectedOptionArray firstObject].extraObj;
    };
}


-(void)tapView{
    [self.nameTextField resignFirstResponder];
    [self.idNumberTextField resignFirstResponder];
}


/**
 查询按钮点击事件

 @param sender 查询按钮
 */
- (IBAction)searchButtonClock:(UIButton *)sender {
    
    DMLog(@"查询按钮");
    
    [self.nameTextField resignFirstResponder];
    [self.idNumberTextField resignFirstResponder];
    
    [self searchRecord];
}


/**
 查询按钮点击事件
 */
-(void)searchRecord{
    
//    [self showLoadingUI];
    
    
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"year"] = self.selectedYear;
    param[@"shbzh"] = self.idNumberTextField.text;
    param[@"name"] = self.nameTextField.text;
    param[@"device_type"] = @"2";
    param[@"app_version"] = version;
    
    
    
    NSString *url = @"";
    DMLog(@"param=%@",param);
    DMLog(@"url=%@",url);
    if(self.isSeriousIllness){//大病保险
        NSLog(@"大病保险");
        url = [NSString stringWithFormat:@"%@/insured/dbbxCheck",HOST_TEST];
    }else if(self.isResidentTreatment){//城乡居民医疗
        NSLog(@"城乡居民医疗");
        url = [NSString stringWithFormat:@"%@/insured/cxjmylCheck",HOST_TEST];
    }else if(self.isJMYangLao){//城乡居民养老
        NSLog(@"城乡居民养老");
        if (self.isOnlinePay) {
            url =[NSString stringWithFormat:@"%@/insured/get/cxshjmyljkxx",HOST_TEST];
        }else url = [NSString stringWithFormat:@"%@/insured/cxjmshylCheck",HOST_TEST];
        NSLog(@"城乡居民养老 %@",url);
    }
    

    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSDictionary *data = dictData[@"data"];
        DMLog(@"参保查询==%@",dictData);
        if([dictData[@"resultCode"] integerValue]==200){
            
            if(self.isSeriousIllness){//大病保险
                
                YWSeriousIllnessVC * seriousIllnessVC = [[YWSeriousIllnessVC alloc]init];
                seriousIllnessVC.isFromGotoPay = self.isOnlinePay;
                seriousIllnessVC.name = self.nameTextField.text;
                seriousIllnessVC.shbzh = data[@"shbzh"];
                seriousIllnessVC.year = self.selectedYear;
                seriousIllnessVC.cblx = data[@"cblx"];
                seriousIllnessVC.dzbz = data[@"dzbzList"][data[@"dzbz"]];
                seriousIllnessVC.jfdc = data[@"jfdcList"][data[@"jfdc"]];
                seriousIllnessVC.jfdcid = data[@"jfdc"];
                seriousIllnessVC.yjje = [NSString stringWithFormat:@"%.2f",[data[@"yjje"] doubleValue]];
                seriousIllnessVC.wjje = [NSString stringWithFormat:@"%.2f",[data[@"wjje"] doubleValue]];
                seriousIllnessVC.jfdcDict = data[@"jfdcList"];
                
                [self.navigationController pushViewController:seriousIllnessVC animated:YES];
            }
            if(self.isResidentTreatment){//城乡居民医疗
                
                YWResidentTreatmentVC * residentTreatmentVC = [[YWResidentTreatmentVC alloc]init];
                
                NSString * dzbz = data[@"dzbz"];
                residentTreatmentVC.name = self.nameTextField.text;
                residentTreatmentVC.shbzh = data[@"shbzh"];
                residentTreatmentVC.year = self.yearLabel.text;
                residentTreatmentVC.dzbz = dzbz;
                residentTreatmentVC.type = data[@"cblx"];
                residentTreatmentVC.cblxDict =  data[@"cblxList"];
                residentTreatmentVC.isFromGotoPay = self.isOnlinePay;
                [self.navigationController pushViewController:residentTreatmentVC animated:YES];
            }
            if (self.isJMYangLao) {
                CityPeopleProvideVC *vc= [[CityPeopleProvideVC alloc]init];
                vc.isZaiXianJiaoFei = self.isOnlinePay;
                [vc.dataSoure addObject:self.nameTextField.text];
                [vc.dataSoure addObject:self.idNumberTextField.text];
                [vc.dataSoure addObject:data[@"cmc"]];
                [vc.dataSoure addObject:data[@"cbm"]];
                if (self.isOnlinePay) {
                    if ([data[@"jfdcbm"] isEqualToString:@""]) {
                        [MBProgressHUD showError:@"此人尚未参保,请先前往参保。"];
                        return ;
                    }
                    NSDictionary *dic= @{@"jfdcbm":data[@"jfdcbm"],@"jfdcmc":data[@"jfdcmc"]};
                    [vc.dataSoure addObject:dic];
                }else{
                    [vc.dataSoure addObject:data[@"composite"][0]];
                    [vc.dataSoure addObject:data[@"composite"]];
                }
                [self.navigationController pushViewController:vc animated:YES];
                
            }
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




@end
