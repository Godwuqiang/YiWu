//
//  DTFExpatriateVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  外派人员登记

#import "DTFExpatriateVC.h"
#import "DTFRegisterRecordVC.h"
#import "DTFRegistModel.h"
#import "DXBResettlementhospitalVC.h"
#import "HSAddressPickerVC.h"
#import "HSDatePickerVC.h"
#import "DTFRegistModel.h"
#import "DXBresetReasonView.h"
#import "DTFAccessSelectView.h"
#import "HttpHelper.h"
#import "LZPickViewManager.h"

#define MAX_LIMIT_NUMS     100 //来限制最大输入只能100个字符
#define URL_GetNowTime        @"/shebao/getRecordBaseData.json"                   //获取当前时间

@interface DTFExpatriateVC ()<HSAddressPickerVCDelegate, HSDatePickerVCDelegate,UITextViewDelegate,UITextFieldDelegate>

/** 当testView在编辑的时候 scroll滑动时键盘不消失*/
@property (nonatomic, assign) BOOL isEditing;

@end

@implementation DTFExpatriateVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.hospitalList = [NSArray array];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedHospitalList:) name:@"selectedHospitalList" object:nil];
    
    [self setupUI];
    
    [self getNowTime];
}

- (void)dealloc {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"selectedHospitalList" object:nil];
}

-(void)setupUI{
    
    self.title = @"外派人员登记";
    
    self.contactName.delegate = self;
    self.contactMobile.delegate = self;
    
    self.registModel = [[DTFRegistModel alloc]init];
    self.addreeDetails.delegate = self;
    self.isTextViewFirstTimeEditding = YES;
    
    if(!_isFromReregist){
        //登记记录
        UIBarButtonItem *RightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_data"] style:UIBarButtonItemStylePlain target:self action:@selector(registerRecord)];
        RightButton.tintColor =[UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = RightButton;
    }
    
    //初始化选中的安置医院
    self.firstHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.firstHosipitalLabel.layer.borderWidth = 1.0;
    self.secondHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.secondHosipitalLabel.layer.borderWidth = 1.0;
    self.thirdHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.thirdHosipitalLabel.layer.borderWidth = 1.0;
    self.forthHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.forthHosipitalLabel.layer.borderWidth = 1.0;
    
    
    self.tableView.tableFooterView = [[UIView alloc]init];
    
}

/**
 显示医院
 */
-(void)setHospitalShow{
    
    if(self.hospitalList.count == 1){
        
        self.firstHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[0]];
        self.firstHosipitalLabel.hidden = NO;
        self.secondHosipitalLabel.hidden = YES;
        self.thirdHosipitalLabel.hidden = YES;
        self.forthHosipitalLabel.hidden = YES;
        
    }else if (self.hospitalList.count == 2){
        
        self.firstHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[0]];
        self.secondHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[1]];
        self.firstHosipitalLabel.hidden = NO;
        self.secondHosipitalLabel.hidden = NO;
        self.thirdHosipitalLabel.hidden = YES;
        self.forthHosipitalLabel.hidden = YES;
        
    }else if (self.hospitalList.count == 3){
        
        self.firstHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[0]];
        self.secondHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[1]];
        self.thirdHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[2]];
        self.firstHosipitalLabel.hidden = NO;
        self.secondHosipitalLabel.hidden = NO;
        self.thirdHosipitalLabel.hidden = NO;
        self.forthHosipitalLabel.hidden = YES;
        
    }else if (self.hospitalList.count == 4){
        
        self.firstHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[0]];
        self.secondHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[1]];
        self.thirdHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[2]];
        self.forthHosipitalLabel.text = [self showHospitalNameWith:self.hospitalList[3]];
        self.firstHosipitalLabel.hidden = NO;
        self.secondHosipitalLabel.hidden = NO;
        self.thirdHosipitalLabel.hidden = NO;
        self.forthHosipitalLabel.hidden = NO;
    }else{
        DMLog(@"空的医院列表");
    }
    
}

/**
 设置来自重新提交
 
 @param isFromReregist 来自重新提交
 */
-(void)setIsFromReregist:(BOOL)isFromReregist{
    
    _isFromReregist = isFromReregist;
    if(_isFromReregist){
        
        self.contactName.text = self.registModel.contact_name;
        self.contactMobile.text = self.registModel.contact_mobile;
        self.address.text = self.registModel.azdz;
        self.address.textColor = [UIColor colorWithHex:0x333333];
        self.addreeDetails.text = self.registModel.address;
        self.addreeDetails.textColor = [UIColor colorWithHex:0x333333];

        
        NSString *year = [self.registModel.end_time substringToIndex:4];
        NSRange range = NSMakeRange(4, 2);
        NSString *mouth = [self.registModel.end_time substringWithRange:range];
        NSString * day = [self.registModel.end_time substringFromIndex:6];
        self.endTime.text = [NSString stringWithFormat:@"%@-%@-%@",year,mouth,day];
        self.endTime.textColor = [UIColor colorWithHex:0x333333];
        
        self.hospitalList = [self.registModel.hospital_id componentsSeparatedByString:@"^"];
        [self setHospitalShow];
        
        [self setupHospitalString];
        
        if(self.hospitalList.count == 0){
            
            self.selectedHospital.text = [NSString stringWithFormat:@"请选择外派安置医院"];
            self.selectedHospital.textColor = [UIColor colorWithHex:0x999999];
        }else{
            
            self.selectedHospital.text = [NSString stringWithFormat:@"已选%li家医院",self.hospitalList.count];
            self.selectedHospital.textColor = [UIColor colorWithHex:0x333333];
        }
        
        if([self.registModel.djbhqfs isEqualToString:@"1"]){
            
            self.djbhqfs.text = @"自取";
        }else if ([self.registModel.djbhqfs isEqualToString:@"2"]){
            self.djbhqfs.text = @"邮寄";
        }else{
        }
        self.djbhqfs.textColor = [UIColor colorWithHex:0x333333];
    }
}



/**
 登记记录点击事件
 */
-(void)registerRecord{
    
    DMLog(@"登记记录");
    
    self.registModel = [[DTFRegistModel alloc]init];
    self.addreeDetails.delegate = self;
    self.isTextViewFirstTimeEditding = YES;
    
    DTFRegisterRecordVC * vc = [[DTFRegisterRecordVC alloc]init];
    vc.type = @"3";
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{

    if (!self.isEditing) {
        
        [self.contactName resignFirstResponder];
        [self.contactMobile resignFirstResponder];
        [self.addreeDetails resignFirstResponder];
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.contactName resignFirstResponder];
    [self.contactMobile resignFirstResponder];
    [self.addreeDetails resignFirstResponder];
    
    if(indexPath.row == 2){//选择外派地点
        DMLog(@"选择外派地点");
        
        [CoreArchive setInt:0 key:PROVICE_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:CITY_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:AREA_COMPONENT_INDEX];
        
        HSAddressPickerVC *vc = [[HSAddressPickerVC alloc] init];
        vc.delegate = self;
        [self.parentVC presentViewController:vc animated:YES completion:nil];
        
        
    }else if (indexPath.row == 6){//选择结束时间
        DMLog(@"选择结束事件");
//        HSDatePickerVC *vc = [[HSDatePickerVC alloc] init];
//        vc.delegate = self;
//        [self.parentVC presentViewController:vc animated:YES completion:nil];
        
        [CoreArchive setInt:0 key:PROVICE_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:CITY_COMPONENT_INDEX];
        [CoreArchive setInt:0 key:AREA_COMPONENT_INDEX];
        
        NSString *MinDate = [self dateStringAfterlocalDateForYear:1 Month:0 Day:0 Hour:0 Minute:0 Second:0];
        NSString *MinDateStr = [[MinDate componentsSeparatedByString:@" "] firstObject];
        
        NSString *MaxDate = [self dateStringAfterlocalDateForYear:10 Month:0 Day:0 Hour:0 Minute:0 Second:0];
        NSString *MaxDateStr = [[MaxDate componentsSeparatedByString:@" "] firstObject];
        
        [[LZPickViewManager initLZPickerViewManager] showWithMaxDateString:MaxDateStr withMinDateString:MinDateStr didSeletedDateStringBlock:^(NSString *dateString) {
            
            self.endTime.text = dateString;
            self.endTime.textColor = [UIColor colorWithHex:0x333333];
            
            NSArray *dateArr = [dateString componentsSeparatedByString:@"-"];
            NSString *year = dateArr[0];
            NSString *month = dateArr[1];
            NSString *day = dateArr[2];
            self.registModel.end_time = [NSString stringWithFormat:@"%@%@%@",year,month,day];
        }];
        
        
    }else if (indexPath.row == 8){//选择外派安置医院
        DMLog(@"选择外派安置医院");
        if (self.registModel.provice_code == nil) {
            [MBProgressHUD showError:@"请选择外派地点"];
            return;
        }
        DXBResettlementhospitalVC *hospitalVC = [[DXBResettlementhospitalVC alloc] init];
        hospitalVC.yyszs = self.registModel.provice_code;
        [hospitalVC setSelectedhospital:[self.hospitalList mutableCopy]];
        [self.parentVC.navigationController pushViewController:hospitalVC animated:YES];
        
        
    }else if (indexPath.row == 11){//登记表和证历本获取方式选择
        DMLog(@"登记表和证历本获取方式选择");
        DTFAccessSelectView * accessSelectView = [[[NSBundle mainBundle] loadNibNamed:@"DTFAccessSelectView" owner:self.parentVC options:nil] firstObject];
        [self.parentVC.navigationController.view addSubview:accessSelectView];
        accessSelectView.djbhqfs = self.registModel.djbhqfs;
        [accessSelectView setFrame:self.parentVC.view.bounds];
        accessSelectView.selectedType = ^(NSString *type) {
            
            if([type isEqualToString:@"1"] || [type isEqualToString:@"2"]){
                self.registModel.djbhqfs = type;
                self.djbhqfs.textColor = [UIColor colorWithHex:0x333333];
                if([type isEqualToString:@"1"]){
                    self.djbhqfs.text = @"自取";
                    self.remarkLabel.text = self.zqRemark;
                }else{
                    self.djbhqfs.text = @"邮寄";
                    self.remarkLabel.text = self.yjRemark;
                }
                DMLog(@"登记表获取方式-自取或邮寄-%@",self.registModel.djbhqfs);
            }else{
                self.registModel.djbhqfs = nil;
                self.djbhqfs.text = @"请选择获取方式";
                self.djbhqfs.textColor = [UIColor colorWithHex:0x999999];
                DMLog(@"登记表获取方式-错误的类型");
            }
            [self.tableView reloadData];
        };
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    
    if(indexPath.row == 0){
        return 50.0;
    }else if (indexPath.row == 1){
        return 50.0;
    }else if (indexPath.row == 2){
        return 50.0;
    }else if (indexPath.row == 3){
        return 65.0;
    }else if (indexPath.row == 4){
        return 40.0;
    }else if (indexPath.row == 5){
        return 50.0;
    }else if (indexPath.row == 6){
        return 50.0;
    }else if (indexPath.row == 7){
        return 15.0;
    }else if (indexPath.row == 8){
        return 50.0;
    }else if (indexPath.row == 9){
        if(self.hospitalList.count == 0){
            return 0.01;
        }
        if(self.hospitalList.count <3){
            return 70.0;
        }else if(self.hospitalList.count>2){
            return 130.0;
        }else{
            return 0.0;
        }
    }else if (indexPath.row == 10){
        
        return 15.0;
    }else if (indexPath.row == 11){
        return 60.0;
    }else if (indexPath.row == 12){
        if([self.registModel.djbhqfs isEqualToString:@"1"]){
            
            return [self.zqRemark getHeightBySizeOfFont:12 width:([UIScreen mainScreen].bounds.size.width-40)]+15.0;
        }else if ([self.registModel.djbhqfs isEqualToString:@"2"]){
            return [self.yjRemark getHeightBySizeOfFont:12 width:([UIScreen mainScreen].bounds.size.width-40)]+25.0;
        }else{
            return 0;
        }
    }else{
        return 50.0;
    }
}




#pragma mark - HSDatePickerVCDelegate 选择安置地点
- (void)addressPicker:(HSAddressPickerVC *)addressPicker selectedProvince:(NSString *)province city:(NSString *)city area:(NSString *)area ProvinceCode:(NSString *)provinceCode CityCode:(NSString *)cityCode AreaCode:(NSString *)areaCode {
    
    DMLog(@"名称： %@--%@--%@   编码：%@--%@--%@",province, city, area, provinceCode, cityCode, areaCode);
    self.address.text = [NSString stringWithFormat:@"%@%@%@",province,city,area];
    self.address.textColor = [UIColor colorWithHex:0x333333];
    self.registModel.provice_code = provinceCode;
    self.registModel.city_code = cityCode;
    self.registModel.country_code = areaCode;
}

//#pragma mark - HSDatePickerVCDelegate 选择结束时间
//- (void)datePicker:(HSDatePickerVC*)datePicker
//          withYear:(NSString *)year
//             month:(NSString *)month
//               day:(NSString *)day {
//    self.endTime.text = [NSString stringWithFormat:@"%@-%@-%@",year,month,day];
//    self.endTime.textColor = [UIColor colorWithHex:0x333333];
//    self.registModel.end_time = [NSString stringWithFormat:@"%@%@%@",year,month,day];
//    DMLog(@"选择了   %@--%@--%@",year,month,day);
//}

#pragma mark - 安置医院列表返回的数据
-(void)selectedHospitalList:(NSNotification *)notification{
    
    self.hospitalList = notification.userInfo[@"selectedhospital"];
    
    [self setHospitalShow];
    
    //已选医院字符串进行拼接
    NSString * hospitalString = @"";
    for (int i= 0; i < self.hospitalList.count; i++) {
        if(i==0){
            NSString * nameString = [self.hospitalList[0] componentsSeparatedByString:@";"].firstObject;
            NSString * codeString = [self.hospitalList[0] componentsSeparatedByString:@";"].lastObject;
            if([codeString isEqualToString:@"90005"]){
                hospitalString = [hospitalString stringByAppendingString:nameString];
            }else{
                hospitalString = [hospitalString stringByAppendingString:codeString];
            }
        }else{
            NSString * nameString = [self.hospitalList[i] componentsSeparatedByString:@";"].firstObject;
            NSString * codeString = [self.hospitalList[i] componentsSeparatedByString:@";"].lastObject;
            if([codeString isEqualToString:@"90005"]){
                hospitalString = [hospitalString stringByAppendingString:[NSString stringWithFormat:@"^%@",nameString]];
            }else{
                hospitalString = [hospitalString stringByAppendingString:[NSString stringWithFormat:@"^%@",codeString]];
            }
        }
    }

    if(self.hospitalList.count == 0){
        self.registModel.hospital_id = nil;
        self.selectedHospital.text = [NSString stringWithFormat:@"请选择安置医院"];
        self.selectedHospital.textColor = [UIColor colorWithHex:0x999999];
    }else{
        self.registModel.hospital_id = hospitalString;
        self.selectedHospital.text = [NSString stringWithFormat:@"已选%li家医院",self.hospitalList.count];
        self.selectedHospital.textColor = [UIColor colorWithHex:0x333333];
    }
    DMLog(@"self.registModel.hospital_id=%@",self.registModel.hospital_id);
    NSLog(@"安置医院列表: %@", self.hospitalList);
    [self.tableView reloadData];
}


#pragma mark - 是否允许进行下一步操作


/**
 YES:可以进行下一步操作  NO:不可以进行下一步操作
 
 @return 是否允许进行下一步操作
 */
-(BOOL)canGotoNext{
    
    self.registModel.type = @"03";
    self.registModel.reason = @"022";
    
    self.registModel.contact_name = self.contactName.text;
    self.registModel.contact_mobile = self.contactMobile.text;
    
    if(self.registModel.contact_name.length >50){
        return NO;
    }
    
    if(self.registModel.contact_mobile.length >50){
        return NO;
    }
    
    if(self.registModel.provice_code == nil){
        [MBProgressHUD showError:@"请选择外派地点"];
        return NO;
    }
    if(self.registModel.city_code == nil){
        [MBProgressHUD showError:@"请选择外派地点"];
        return NO;
    }
    if(self.registModel.country_code == nil){
        [MBProgressHUD showError:@"请选择外派地点"];
        return NO;
    }
    
    if(self.registModel.address == nil){
        [MBProgressHUD showError:@"请输入外派地的详细地址用于邮寄登记表与异地就医证历本"];
        return NO;
    }else if (self.registModel.address.length >100){
        return NO;
    }
    
    if(self.registModel.start_time == nil){
        [MBProgressHUD showError:@"开始时间获取失败"];
        return NO;
    }
    
    if(self.registModel.end_time ==nil){
        [MBProgressHUD showError:@"请选择1年以后的日期"];
        return NO;
    }
    
    if(self.registModel.hospital_id == nil){
        [MBProgressHUD showError:@"请选择安置医院"];
        return NO;
    }
    
    
    if(self.registModel.djbhqfs == nil){
        [MBProgressHUD showError:@"请选择获取方式"];
        return NO;
    }
    
    return YES;
}

/**
 判断是否写入内容，点击返回是否显示提示
 
 @return 是否显示提示
 */
-(BOOL)canGotoBack{
    
    [self.contactName resignFirstResponder];
    [self.contactMobile resignFirstResponder];
    [self.addreeDetails resignFirstResponder];
    
    if(self.contactName.text.length != 0){
        
        return NO;
    }
    
    if(self.contactMobile.text.length != 0){
        
        return NO;
    }
    
    
    if(self.registModel.provice_code != nil){
        
        return NO;
    }
    if(self.registModel.city_code != nil){
        
        return NO;
    }
    if(self.registModel.country_code != nil){
        
        return NO;
    }
    
    if(self.registModel.address != nil){
        
        return NO;
    }
    
    if(self.registModel.reason != nil){
        
        return NO;
    }

    
    if(self.registModel.end_time !=nil){
        
        return NO;
    }
    
    if(self.registModel.hospital_id != nil){
        
        return NO;
    }
    
    
    if(self.registModel.djbhqfs != nil){
        
        return NO;
    }
    
    return YES;
}



#pragma mark - textViewDelegate
-(void)textViewDidBeginEditing:(UITextView *)textView{
    
    self.isEditing = YES;
    if(self.isTextViewFirstTimeEditding){
        self.addreeDetails.text =@"";
        self.isTextViewFirstTimeEditding = NO;
        self.addreeDetails.textColor = [UIColor colorWithHex:0x333333];
    }else{
        self.isTextViewFirstTimeEditding = NO;
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView{
    
    self.isEditing = NO;
    if(self.addreeDetails.text.length == 0){
        self.addreeDetails.text = @"请输入外派地的详细地址用于邮寄登记表与异地就医证历本";
        self.addreeDetails.textColor = [UIColor colorWithHex:0x999999];
        self.isTextViewFirstTimeEditding = YES;
        self.registModel.address = nil;
    }else{
        
        self.addreeDetails.textColor = [UIColor colorWithHex:0x333333];
        self.isTextViewFirstTimeEditding = NO;
        self.registModel.address = self.addreeDetails.text;
    }
    
}

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text{
    
    NSLog(@"addreeDetails-%@",text);
    
    // 不允许输入空格
    if ([text isEqualToString:@" "]) {
        return NO;
    }
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        return YES;
    }else{
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = [text substringWithRange:rg];
            
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
        }
        return NO;
    }
}
-(void)textViewDidChange:(UITextView *)textView{
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
}

#pragma mark - textFieldDelegate

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    
    if((self.contactName.text.length + string.length)>50){
        return NO;
    }
    
    if((self.contactMobile.text.length + string.length)>50){
        return NO;
    }
    return YES;
}





#pragma mark - 获取当前时间
-(void)getNowTime{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_GetNowTime];
    
    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        NSLog(@"获取登记记录列表-%@",dictData);
        NSLog(@"获取登记记录列表-message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            DMLog(@"nowTime--%@",dictData[@"data"][@"nowTime"]);
            // 格式化时间
            NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
            formatter.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
            [formatter setDateStyle:NSDateFormatterMediumStyle];
            [formatter setTimeStyle:NSDateFormatterShortStyle];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            // 格式化时间
            NSDateFormatter* formatter2 = [[NSDateFormatter alloc] init];
            formatter2.timeZone = [NSTimeZone timeZoneWithName:@"shanghai"];
            [formatter2 setDateStyle:NSDateFormatterMediumStyle];
            [formatter2 setTimeStyle:NSDateFormatterShortStyle];
            [formatter2 setDateFormat:@"yyyyMMdd"];
            
            // 毫秒值转化为秒
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[dictData[@"data"][@"nowTime"] doubleValue]/ 1000.0];
            NSString* dateString = [formatter stringFromDate:date];
            
            // 毫秒值转化为秒2
            NSDate* date2 = [NSDate dateWithTimeIntervalSince1970:[dictData[@"data"][@"nowTime"] doubleValue]/ 1000.0];
            NSString* dateString2 = [formatter2 stringFromDate:date2];
            
            self.startTime.text = dateString;
            self.registModel.start_time = dateString2;
            self.yjRemark = dictData[@"data"][@"yjRemark"];
            self.zqRemark = dictData[@"data"][@"zqRemark"];
            
            DMLog(@"dateString--%@",dateString);
            
        }else{
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
    } failure:^(NSError *error) {
        
        
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
        
    }];
}


-(NSString *)showHospitalNameWith:(NSString *)totalString{
    
    totalString = [[totalString componentsSeparatedByString:@";"] firstObject];
    return totalString;
}

/**
 *  ** 在当前日期时间加上 某个时间段(传负数即返回当前时间之前x月x日的时间)
 *
 *  @param year   当前时间若干年后 （传负数为当前时间若干年前）
 *  @param month  当前时间若干月后  （传0即与当前时间一样）
 *  @param day    当前时间若干天后
 *  @param hour   当前时间若干小时后
 *  @param minute 当前时间若干分钟后
 *  @param second 当前时间若干秒后
 *
 *  @return 处理后的时间字符串
 */
- (NSString *)dateStringAfterlocalDateForYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day Hour:(NSInteger)hour Minute:(NSInteger)minute Second:(NSInteger)second
{
    // 当前日期
    NSDate *localDate = [NSDate date]; // 为伦敦时间
    // 在当前日期时间加上 时间：格里高利历
    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *offsetComponent = [[NSDateComponents alloc]init];
    
    [offsetComponent setYear:year ];  // 设置开始时间为当前时间的前x年
    [offsetComponent setMonth:month];
    [offsetComponent setDay:day];
    [offsetComponent setHour:(hour+8)]; // 中国时区为正八区，未处理为本地，所以+8
    [offsetComponent setMinute:minute];
    [offsetComponent setSecond:second];
    // 当前时间后若干时间
    NSDate *minDate = [gregorian dateByAddingComponents:offsetComponent toDate:localDate options:0];
    
    NSString *dateString = [NSString stringWithFormat:@"%@",minDate];
    
    return dateString;
}

/**
 根据hospitalList拼接hospital_id
 */
-(void)setupHospitalString{
    //已选医院字符串进行拼接
    NSString * hospitalString = @"";
    for (int i= 0; i < self.hospitalList.count; i++) {
        if(i==0){
            NSString * nameString = [self.hospitalList[0] componentsSeparatedByString:@";"].firstObject;
            NSString * codeString = [self.hospitalList[0] componentsSeparatedByString:@";"].lastObject;
            if([codeString isEqualToString:@"90005"]){
                hospitalString = [hospitalString stringByAppendingString:nameString];
            }else{
                hospitalString = [hospitalString stringByAppendingString:codeString];
            }
        }else{
            NSString * nameString = [self.hospitalList[i] componentsSeparatedByString:@";"].firstObject;
            NSString * codeString = [self.hospitalList[i] componentsSeparatedByString:@";"].lastObject;
            if([codeString isEqualToString:@"90005"]){
                hospitalString = [hospitalString stringByAppendingString:[NSString stringWithFormat:@"^%@",nameString]];
            }else{
                hospitalString = [hospitalString stringByAppendingString:[NSString stringWithFormat:@"^%@",codeString]];
            }
        }
    }
    self.registModel.hospital_id = hospitalString;
}



@end
