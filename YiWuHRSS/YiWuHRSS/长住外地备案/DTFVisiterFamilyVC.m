//
//  DTFVisiterFamilyVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//  探亲安置登记

#import "DTFVisiterFamilyVC.h"

@interface DTFVisiterFamilyVC ()

@property (weak, nonatomic) IBOutlet UILabel *firstHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *secondHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *thirdHosipitalLabel;
@property (weak, nonatomic) IBOutlet UILabel *forthHosipitalLabel;

@end

@implementation DTFVisiterFamilyVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    

}

-(void)setupUI{
    
    self.title = @"探亲登记";
    
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
    
    if(indexPath.row == 3){//选择探亲地点
        DMLog(@"择探亲地点");
        
        
    }else if (indexPath.row ==5){//选择探亲原因
        DMLog(@"选择探亲原因");
        
        
    }else if (indexPath.row == 8){//选择结束事件
        DMLog(@"选择结束事件");
        
        
    }else if (indexPath.row == 10){//选择探亲安置医院
        DMLog(@"选择探亲安置医院");
        
        
    }else if (indexPath.row == 13){//登记表和证历本获取方式选择
        DMLog(@"登记表和证历本获取方式选择");
        
        
    }
    
}





@end
