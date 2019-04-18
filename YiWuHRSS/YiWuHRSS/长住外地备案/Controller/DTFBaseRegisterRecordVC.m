//
//  DTFBaseRegisterRecordVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFBaseRegisterRecordVC.h"
#import "DTFRemoteRecordVC.h"           //异地安置登记记录
#import "DTFVisiterFamilyRecordVC.h"    //探亲登记记录
#import "DTFExpatriateRecordVC.h"       //外派人员登记记录
#import "DTFRegistRecordModel.h"
#import "HttpHelper.h"
#import "MJExtension.h"
#import "DTFRecordDetailsModel.h"       //记录详情
#import "DTFRegistModel.h"
#import "DTFRemoteVC.h"                 //异地安置-用来重新提交
#import "DTFVisiterFamilyVC.h"          //探亲-用来重新提交
#import "DTFExpatriateVC.h"             //外派-用来重新提交
#import "DTFRegistBaseVC.h"
#import "AESCipher.h"
#import "NSString+category.h"

#define AESEncryptKey       @"Yi17wu_EnPun_k88"                     //AES加密的key


#define URL_GetRecordInfoDetails        @"/shebao/recordDetailAES.json"       //获取记录详情

@interface DTFBaseRegisterRecordVC ()

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *statusLabelTop; //审核状态离顶部的位置


@property (weak, nonatomic) IBOutlet UIImageView *statusImageView;      //状态图标
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;              //审核状态
@property (weak, nonatomic) IBOutlet UILabel *statusReasonLabel;        //原因
@property (weak, nonatomic) IBOutlet UIView *bgView;                    //加载登记记录详情View

@property (strong, nonatomic) UITableView * registDetailTabelView;      //申请记录的详情
@property (strong, nonatomic) DTFRemoteRecordVC * remoteRecordVC;       
@property (strong, nonatomic) DTFVisiterFamilyRecordVC * visiterFamilyRecordVC;
@property (strong, nonatomic) DTFExpatriateRecordVC * expatriateRecordVC;


/** 记录详情 */
@property (nonatomic,strong) DTFRecordDetailsModel * recordDetailsModel;
/** HUD */
@property(nonatomic ,strong) MBProgressHUD * HUD;






@end

@implementation DTFBaseRegisterRecordVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    [self getRecordInfoDetails];
}

-(void)setupUI{
    
    if([_shzt isEqualToString:@"0"]){//审核中
        
        self.statusImageView.image = [UIImage imageNamed:@"img_audit"];
        self.statusLabel.text = @"审核中！";
        self.statusLabelTop.constant = (26-10);
        self.statusReasonLabel.hidden = YES;
        
    }else if ([_shzt isEqualToString:@"1"]){//审核成功
        
        if(self.remark == nil || [self.remark isEqualToString:@""]){
            
            self.statusImageView.image = [UIImage imageNamed:@"icon_success"];
            self.statusLabel.text = @"审核成功！";
            self.statusLabelTop.constant = (26-10);
            self.statusReasonLabel.hidden = YES;
            
        }else{
            
            self.statusImageView.image = [UIImage imageNamed:@"icon_success"];
            self.statusLabel.text = @"审核成功！";
            self.statusReasonLabel.text = self.remark;
            self.statusReasonLabel.textColor = [UIColor colorWithHex:0x666666];
            
        }
        
        
        
    }else if ([_shzt isEqualToString:@"2"]){//审核失败
        
        self.statusImageView.image = [UIImage imageNamed:@"icon_fail"];
        self.statusLabel.text = @"审核失败！";
        self.statusLabelTop.constant = (26-10);
        self.statusReasonLabel.hidden = YES;
        
        //重新提交
        //UIBarButtonItem *RightButton = [[UIBarButtonItem alloc]initWithTitle:@"重新提交" style:UIBarButtonItemStylePlain target:self action:@selector(recommitRegister)];
        //RightButton.tintColor =[UIColor whiteColor];
        //self.navigationItem.rightBarButtonItem = RightButton;
        
    }else{
        
        self.statusImageView.image = [UIImage imageNamed:@""];
        self.statusLabel.text = @"--";
    }
    
    
    
    CGRect frame = _bgView.frame;

    if([_type isEqualToString:@"1"]){//异地安置登记记录详情页
        
        self.title = @"异地安置登记记录";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFRemoteRecordVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFRemoteRecordVC"];
        self.registDetailTabelView = vc.tableView;
        self.remoteRecordVC = vc;
        
    }else if ([_type isEqualToString:@"2"]){//探亲登记记录详情页
        
        self.title = @"探亲登记记录";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFVisiterFamilyRecordVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFVisiterFamilyRecordVC"];
        self.registDetailTabelView = vc.tableView;
        self.visiterFamilyRecordVC= vc;
        
    }else{//外派人员登记记录详情页
        
        self.title = @"外派人员登记记录";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFExpatriateRecordVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFExpatriateRecordVC"];
        self.registDetailTabelView = vc.tableView;
        self.expatriateRecordVC = vc;
    }
    
    self.registDetailTabelView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
    [self.bgView addSubview:_registDetailTabelView];
    
    

}

#pragma mark - 获取登记记录详情
-(void)getRecordInfoDetails{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"apply_id"] = self.apply_id;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_GetRecordInfoDetails];
    
    NSString * paramString = aesEncryptString(param.mj_JSONString, AESEncryptKey);
    NSMutableDictionary * paramDict = [NSMutableDictionary dictionary];
    paramDict[@"param"]= paramString;

    
    DMLog(@"URL--%@",url);
    DMLog(@"param--%@",param);
    
    [self showLoadingUI];
    
    [HttpHelper post:url params:paramDict success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        NSString * dataBackString = aesDecryptString(dictData[@"dataBack"], AESEncryptKey);
        dictData = [NSString db_dictionaryWithJsonString:dataBackString];

        
        DMLog(@"获取登记记录详情-%@",dictData);
        DMLog(@"获取登记记录详情-message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            NSDictionary * dataDict = dictData[@"data"];
            self.recordDetailsModel = [DTFRecordDetailsModel mj_objectWithKeyValues:dataDict];
            DMLog(@"记录详情--%@",self.recordDetailsModel);
            DMLog(@"%@",self.recordDetailsModel.name);
            DMLog(@"%@",self.recordDetailsModel.azyy);
            
            
            if([_type integerValue] == 1){
                
                self.remoteRecordVC.recordDetailsModel = self.recordDetailsModel;
                
            }else if ([_type integerValue] == 2){
                
                self.visiterFamilyRecordVC.recordDetailsModel = self.recordDetailsModel;
                
            }else if ([_type integerValue] == 3){
                
                self.expatriateRecordVC.recordDetailsModel = self.recordDetailsModel;
                
            }else{
                DMLog(@"登记记录类型错误");
            }
            
        }else if ([dictData[@"resultCode"] integerValue] == 102){
   
            
        }else{
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }

    } failure:^(NSError *error) {
        
        self.HUD.hidden = YES;
        DMLog(@"监听网络状态");
        Reachability *r = [Reachability reachabilityForInternetConnection];
        if ([r currentReachabilityStatus] == NotReachable) {
            [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        } else {
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }
        
    }];
    
}


/**
 *  加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}


/**
 重新提交
 */
-(void)recommitRegister{
    
    DTFRegistModel * registModel = [[DTFRegistModel alloc]init];
    registModel.contact_name = _recordDetailsModel.name;
    DMLog(@"contact_name=%@",registModel.contact_name);
    registModel.contact_mobile = _recordDetailsModel.mobile;
    DMLog(@"contact_mobile=%@",registModel.contact_mobile);
    registModel.provice_code = [NSString stringWithFormat:@"%@0000",[_recordDetailsModel.azdzbm substringToIndex:2]];
    DMLog(@"provice_code=%@",registModel.provice_code);
    registModel.city_code = [NSString stringWithFormat:@"%@00",[_recordDetailsModel.azdzbm substringToIndex:4]];
    DMLog(@"registModel.city_code%@",registModel.city_code);
    registModel.country_code = _recordDetailsModel.azdzbm;
    DMLog(@"country_code=%@",registModel.country_code);
    registModel.azdz = _recordDetailsModel.azdz;
    DMLog(@"azdz=%@",registModel.azdz);
    registModel.address = _recordDetailsModel.jtdz;
    DMLog(@"address=%@",registModel.address);
    
    
    //安置原因
    registModel.reason = _recordDetailsModel.ydazyy;
    DMLog(@"reason%@",registModel.reason);
    if([_recordDetailsModel.ydazyy isEqualToString:@"回原籍居住"]){
        registModel.reason = @"011";
    }else if ([_recordDetailsModel.ydazyy isEqualToString:@"户籍异地落户居住"]){
        registModel.reason = @"012";
    }else if ([_recordDetailsModel.ydazyy isEqualToString:@"随直系亲属异地居住"]){
        registModel.reason = @"013";
    }else if ([_recordDetailsModel.ydazyy isEqualToString:@"探亲"]){
        registModel.reason = @"021";
    }else if ([_recordDetailsModel.ydazyy isEqualToString:@"出差"]){
        registModel.reason = @"022";
    }else{
        registModel.reason = @"000";
    }
    DMLog(@"reason%@",registModel.reason);
    
    //登记表和证
    if([_recordDetailsModel.djbhqfs isEqualToString:@"邮寄"]){
        registModel.djbhqfs = @"2";
    }else if ([_recordDetailsModel.djbhqfs isEqualToString:@"自取"]){
        registModel.djbhqfs = @"1";
    }else{
        registModel.djbhqfs = @"0";
    }
    DMLog(@"djbhqfs=%@",registModel.djbhqfs);
    registModel.end_time = _recordDetailsModel.endTime;
    DMLog(@"end_time=%@",registModel.end_time);
    
    //结束时间
    NSArray * endTimeArray = [_recordDetailsModel.endTime componentsSeparatedByString:@"-"];
    NSString * endTime = @"";
    for (int i = 0; i< endTimeArray.count; i++) {
        endTime = [endTime stringByAppendingString:endTimeArray[i]];
    }
    registModel.end_time = endTime;
    DMLog(@"end_time=%@",registModel.end_time);
    
    //已选医院字符串进行拼接
    NSString * hospitalString = @"";
    for (int i= 0; i < _recordDetailsModel.azyy.count; i++) {
        if(i==0){
            hospitalString = [hospitalString stringByAppendingString:_recordDetailsModel.azyy[0]];
        }else{
            hospitalString = [hospitalString stringByAppendingString:[NSString stringWithFormat:@"^%@",_recordDetailsModel.azyy[i]]];
        }
    }
    registModel.hospital_id = hospitalString;
    DMLog(@"hospital_id=%@",registModel.hospital_id);
    registModel.document_image = _recordDetailsModel.documentPic;
    
    DTFRegistBaseVC * registVC = [[DTFRegistBaseVC alloc]init];
    registVC.type = _type;
    
    
    if([_type isEqualToString:@"1"]){
        
        registModel.type = @"01";
        
    }else if ([_type isEqualToString:@"2"]){
        
        registModel.type = @"02";
        
    }else if ([_type isEqualToString:@"3"]){
        
        registModel.type = @"03";
        
    }else{
        DMLog(@"记录类型错误");
    }
    registVC.registModel = registModel;
    registVC.isFromReregist = YES;
    [self.navigationController pushViewController:registVC animated:YES];
}





@end
