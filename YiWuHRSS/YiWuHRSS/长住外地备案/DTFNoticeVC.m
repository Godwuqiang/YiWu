//
//  DTFNoticeVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFNoticeVC.h"
#import "DTFRemoteVC.h"         //异地安置登记
#import "DTFVisiterFamilyVC.h"  //探亲安置登录
#import "DTFExpatriateVC.h"     //外派安置登录

@interface DTFNoticeVC ()

@property (weak, nonatomic) IBOutlet UILabel *noticeContentLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIButton *agreedButton;


@end

@implementation DTFNoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectButton.selected  = YES;
    
    if([self.type isEqualToString:@"1"]){//异地安置登记
        
        self.title = @"异地安置登记须知内容";
        self.noticeContentLabel.text = @"须知内容：\n一、本市职工基本医疗保险退休人员方可办理异地安置备案手续；\n备案登记表须填写完整、准确；\n三、医保处二个工作日内审核待遇申请，审核通过后，待遇从申请当天开始；\n四、异地安置登记后两年之内不得解除。\n五、异地安置期间义乌市社会保障市民卡不能在义乌本地定点医疗机构使用，请选择适当日期申请，并谨慎填写结束时间；\n六、就医医院为县域内的医保定点医院，审核通过后若需更改医院请到医保处窗口办理；\n七、登记表与异地就医证历本可选择自取或邮寄。邮寄时收件人默认待遇享受人,收件地址默认安置地详细地址，请务必确保地址可寄达。邮寄费用由医保处承担。";
        
    }else if ([self.type isEqualToString:@"2"]){//探亲登记
        
        self.title = @"探亲登记须知内容";
        self.noticeContentLabel.text = @"须知内容：\n一、本市职工基本医疗保险参保人员与城乡居民基本医疗保险参保人员方可办理探亲登记备案手续；\n二、备案登记表须填写完整、准确；\n三、医保处二个工作日内审核待遇申请，审核通过后，待遇从申请当天开始；\n四、探亲登记后三个月之内不得解除；\n五、探亲期间义乌市社会保障市民卡不能在义乌本地定点医疗机构使用，请选择适当日期申请，并谨慎填写结束时间；\n六、就医医院为县域内的医保定点医院，审核通过后若需更改医院请到医保处窗口办理；\n七、登记表与异地就医证历本可选择自取或邮寄。邮寄时收件人默认待遇享受人,收件地址默认探亲地详细地址，请务必确保地址可寄达。邮寄费用由医保处承担。";
    }else{//外派人员登记
        
        self.title = @"外派人员登记须知内容";
        self.noticeContentLabel.text = @"须知内容：\n一、参加本市职工基本医疗保险的机关、事业及国有企业人员，且被派往外地工作一年以上，方可办理外派登记备案手续；\n二、备案登记表须填写完整、准确；\n三、外派登记后一年之内不得解除；\n四、外派期间义乌市社会保障市民卡不能在义乌本地定点医疗机构使用，请选择适当日期申请，并谨慎填写结束时间；\n五、医保处二个工作日内审核待遇申请，审核通过后，待遇从申请当天开始；\n六、就医医院为县域内的医保定点医院，审核通过后若需更改医院请到医保处窗口办理；\n七、登记表与异地就医证历本可选择自取或邮寄。邮寄时收件人默认待遇享受人,收件地址默认外派地详细地址，请务必确保地址可寄达。邮寄费用由医保处承担。";
    }
    
}


#pragma mark -  选中同意按钮

- (IBAction)selectButtonClick:(UIButton *)sender {
    self.selectButton = sender;
    _selectButton.selected = ! _selectButton.selected;
}



#pragma mark - 已阅读并同意承诺
- (IBAction)agreedButtonClick:(UIButton *)sender {
    
    if(!self.selectButton.selected){
        
        [MBProgressHUD showError:@"请勾选承诺内容后继续~"];
        return ;
    }
    
    if([self.type isEqualToString:@"1"]){//异地安置登记
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFRemoteVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFRemoteVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else if ([self.type isEqualToString:@"2"]){//探亲登记
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFVisiterFamilyVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFVisiterFamilyVC"];
        [self.navigationController pushViewController:vc animated:YES];
        
    }else{//外派人员登记
        
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFExpatriateVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFExpatriateVC"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}





@end
