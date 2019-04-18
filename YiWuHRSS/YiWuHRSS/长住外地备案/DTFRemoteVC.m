//
//  DTFRemoteVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  异地安置登记

#import "DTFRemoteVC.h"
#import "DXBResettlementhospitalVC.h"
#import "HSAddressPickerVC.h"
#import "HSDatePickerVC.h"

@interface DTFRemoteVC ()<HSAddressPickerVCDelegate, HSDatePickerVCDelegate>

@property (weak, nonatomic) IBOutlet UILabel *firstHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthHosipitalLabel;



@end

@implementation DTFRemoteVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupUI];
    
}


-(void)setupUI{
    
    self.title = @"异地安置登记";
    
    //登记记录
    UIBarButtonItem *RightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_data"] style:UIBarButtonItemStylePlain target:self action:@selector(registerRecord)];
    RightButton.tintColor =[UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = RightButton;
    
    //初始化选中的安置医院
    self.firstHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.firstHosipitalLabel.layer.borderWidth = 1.0;
    self.secondHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.secondHosipitalLabel.layer.borderWidth = 1.0;
    self.thirdHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.thirdHosipitalLabel.layer.borderWidth = 1.0;
    self.forthHosipitalLabel.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
    self.forthHosipitalLabel.layer.borderWidth = 1.0;
}





/**
 登记记录点击事件
 */
-(void)registerRecord{
    
    DMLog(@"登记记录");
    
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if(indexPath.row == 3){//选择安置地点
        DMLog(@"选择安置地点");
        
        HSAddressPickerVC *vc = [[HSAddressPickerVC alloc] init];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
        
        
    }else if (indexPath.row ==5){//选择安置原因
        DMLog(@"选选择安置原因");
        
        
    }else if (indexPath.row == 8){//选择结束事件
        DMLog(@"选择结束时间");
        
        HSDatePickerVC *vc = [[HSDatePickerVC alloc] init];
        vc.delegate = self;
        [self presentViewController:vc animated:YES completion:nil];
        
        
    }else if (indexPath.row == 10){//选择安置医院
        DMLog(@"选择安置医院");
        DXBResettlementhospitalVC *hospitalVC = [[DXBResettlementhospitalVC alloc] init];
        [self.navigationController pushViewController:hospitalVC animated:YES];
        
    }else if (indexPath.row == 13){//登记表和证历本获取方式选择
        DMLog(@"登记表和证历本获取方式选择");
        
        
    }
    
}


#pragma mark - HSDatePickerVCDelegate 选择安置地点
-(void)addressPicker:(HSAddressPickerVC*)addressPicker
    selectedProvince:(NSString*)province
                city:(NSString*)city
                area:(NSString*)area {
    
    DMLog(@"选择了   %@--%@--%@",province,city,area);
    
}

#pragma mark - HSDatePickerVCDelegate 选择结束时间
- (void)datePicker:(HSDatePickerVC*)datePicker
          withYear:(NSString *)year
             month:(NSString *)month
               day:(NSString *)day {
    
    DMLog(@"选择了   %@--%@--%@",year,month,day);
}



@end
