//
//  DTFRegistBaseVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFRegistBaseVC.h"
#import "DTFRemoteVC.h"         //异地安置登记
#import "DTFVisiterFamilyVC.h"  //探亲安置登录
#import "DTFExpatriateVC.h"     //外派安置登录
#import "DXBAddMaterialVC.h"    //添加材料证明
#import "DXBAddDataVC.h"        // 添加材料证明
#import "DTFRegisterRecordVC.h" //登记记录列表
#import "SZKAlterView.h"
#import "DTFRegistModel.h"

#define URL_EXECUTERECORD_JSON       @"/shebao/executeRecord.json"       // 异地安置/探亲出差/外派登记


@interface DTFRegistBaseVC ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneNumLabel;
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;

/** HUD */
@property(nonatomic ,strong) MBProgressHUD * HUD;
/** 成功的提示View */
@property (nonatomic, strong) UIView * successView;
/** 失败的提示View */
@property (nonatomic, strong) UIView * errorView;



@end

@implementation DTFRegistBaseVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    
    

}

-(void)setupUI{
    
    if(kIsiPhoneX){
        self.topConstrains.constant += 20;
    }
    
    NSString *encodedImageStr = [CoreArchive strForKey:LOGIN_USER_PNG];
    if ([Util IsStringNil:encodedImageStr]) {
        self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
    }else{
        @try {
            NSData *encodeddata = [NSData dataFromBase64String:encodedImageStr];
            UIImage *encodedimage = [UIImage imageWithData:encodeddata];
            self.imageView.image = [Util circleImage:encodedimage withParam:0];
        } @catch (NSException *exception) {
            self.imageView.image = [UIImage imageNamed:@"img_touxiang"];
        }
    }
    
    self.nameLabel.text = [CoreArchive strForKey:LOGIN_NAME];
    
    //手机号脱敏
    NSString * phone = [[CoreArchive strForKey:LOGIN_APP_MOBILE] substringToIndex:3];
    phone = [NSString stringWithFormat:@"%@*****",phone];
    phone = [phone stringByAppendingString:[[CoreArchive strForKey:LOGIN_APP_MOBILE] substringFromIndex:8]];
    self.phoneNumLabel.text = phone;
    
    if(!self.isFromReregist){
        //登记记录
        UIBarButtonItem *RightButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"icon_record"] style:UIBarButtonItemStylePlain target:self action:@selector(registerRecord)];
        RightButton.tintColor =[UIColor whiteColor];
        self.navigationItem.rightBarButtonItem = RightButton;
    }
    
    
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"arrow_return"] style:UIBarButtonItemStylePlain target:self action:@selector(back)]; //为导航栏添加左侧按钮
    
    
    if([_type isEqualToString:@"1"]){//异地安置登记
        
        self.title = @"异地安置登记";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFRemoteVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFRemoteVC"];
        self.remoteVC = vc;
        self.remoteVC.parentVC = self;
        CGRect frame = CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height);
        vc.tableView.frame = frame;
        if(_isFromReregist){//如果来自重新提交
            vc.registModel = _registModel;
            vc.isFromReregist = YES;
        }
        [self.bgView addSubview:vc.tableView];
        
    }else if ([_type isEqualToString:@"2"]){//探亲登记
        
        self.title = @"探亲登记";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFVisiterFamilyVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFVisiterFamilyVC"];
        self.visiteFamilyVC = vc;
        self.visiteFamilyVC.parentVC = self;
        CGRect frame = CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height);
        vc.tableView.frame = frame;
        if(_isFromReregist){//如果来自重新提交
            vc.registModel = _registModel;
            vc.isFromReregist = YES;
        }
        [self.bgView addSubview:vc.tableView];
        
    }else{//外派人员登记
        
        self.title = @"外派人员登记";
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Record" bundle:nil];
        DTFExpatriateVC *vc = [sb instantiateViewControllerWithIdentifier:@"DTFExpatriateVC"];
        self.expatriateVC = vc;
        self.expatriateVC.parentVC = self;
        CGRect frame = CGRectMake(0, 0, _bgView.frame.size.width, _bgView.frame.size.height);
        vc.tableView.frame = frame;
        if(_isFromReregist){//如果来自重新提交
            vc.registModel = _registModel;
            vc.isFromReregist = YES;
        }
        [self.bgView addSubview:vc.tableView];
    }
}


-(void)back{

    if([_type isEqualToString:@"1"]){
        
        if(self.remoteVC.canGotoBack){
            
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showAlertView];
        }
        
    }else if ([_type isEqualToString:@"2"]){
        
        if(self.visiteFamilyVC.canGotoBack){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showAlertView];
        }
        
    }else if ([_type isEqualToString:@"3"]){
        
        if(self.expatriateVC.canGotoBack){
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [self showAlertView];
        }
        
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


#pragma  mark -  下一步：跳转相关的拍张提示等页面（2.4版本开始不需要上传图片）
- (IBAction)nextButtonClick:(UIButton *)sender {
    
    DMLog(@"下一步按钮点击");
    
    if ([_type isEqualToString:@"1"] || [_type isEqualToString:@"2"]) {
        
        
        if([_type isEqualToString:@"1"]){
            
            if(!self.remoteVC.canGotoNext) return;
            [self registRequestWith:self.remoteVC.registModel];
            
            //DXBAddMaterialVC * vc = [[DXBAddMaterialVC alloc]init];
            //vc.noPotoMessage = @"请上传本人户口本照片";
            //vc.registModel = self.remoteVC.registModel;
            //[self.navigationController pushViewController:vc animated:YES];
            
        }else{
            if(!self.visiteFamilyVC.canGotoNext) return;
            [self registRequestWith:self.visiteFamilyVC.registModel];
            
            //DXBAddMaterialVC * vc = [[DXBAddMaterialVC alloc]init];
            //vc.noPotoMessage = @"请上传直系亲属户口本照片";
            //vc.registModel = self.visiteFamilyVC.registModel;
            //[self.navigationController pushViewController:vc animated:YES];
        }
        
        
    }else if ([_type isEqualToString:@"3"]) {
        
        if(!self.expatriateVC.canGotoNext) return ;
        [self registRequestWith:self.expatriateVC.registModel];
        
        //DXBAddDataVC *vc = [[DXBAddDataVC alloc] init];
        //vc.registModel =  self.expatriateVC.registModel;
        //[self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - 登记记录点击事件
-(void)registerRecord{
    
    DMLog(@"登记记录");
    DTFRegisterRecordVC * vc = [[DTFRegisterRecordVC alloc]init];
    vc.type = _type;
    [self.navigationController pushViewController:vc animated:YES];
}

/**
 显示保存内容提示
 */
-(void)showAlertView{
    
    SZKAlterView *lll=[SZKAlterView alterViewWithTitle:@"" content:@"当前页面信息未保存，退出后信息将丢失，是否继续？" cancel:@"取消" sure:@"继续退出" cancelBtClcik:^{
        //取消按钮点击事件
        DMLog(@"取消");
    } sureBtClcik:^{
        //确定按钮点击事件
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [self.navigationController.view addSubview:lll];
}

/**
 *  加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}

#pragma mark - 显示成功的提示

-(void)showSuccessView{
    
    
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.15, SCREEN_HEIGHT *0.2422, SCREEN_WIDTH * 0.7, SCREEN_HEIGHT *0.2375);
    UIView * successView = [[UIView alloc]initWithFrame:frame];
    self.successView = successView;
    successView.backgroundColor = [UIColor whiteColor];
    successView.clipsToBounds = YES;
    successView.layer.cornerRadius = 7.0;
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.215, frame.size.width * 0.198, frame.size.width * 0.198);//frame.size.width *0.198
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:@"icon_success"];
    [self.successView addSubview:imageView];
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,frame.size.height * 0.65, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"提交成功！";
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [self.successView addSubview:tipsLabel];
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:successView];
    [self.navigationController.view addSubview:hudView];
    
    self.successView = hudView;
    
    //3.0秒后消失
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.successView.hidden = YES;
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:1] animated:YES];
    });
}

#pragma mark - 显示失败的提示

-(void)showErrorViewWithTips:(NSString *)tips{
    
    
    
    CGRect frame =  CGRectMake(SCREEN_WIDTH * 0.1, SCREEN_HEIGHT *0.287, SCREEN_WIDTH * 0.8, SCREEN_HEIGHT *0.2870);
    UIView * errorView = [[UIView alloc]initWithFrame:frame];
    self.errorView = errorView;
    errorView.backgroundColor = [UIColor whiteColor];
    errorView.clipsToBounds = YES;
    errorView.layer.cornerRadius = 7.0;
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.15, frame.size.width * 0.198, frame.size.width * 0.198);//frame.size.width *0.198
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    imageView.image = [UIImage imageNamed:@"icon_fail"];
    [self.errorView addSubview:imageView];
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,frame.size.height * 0.50, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = @"提交失败！";
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [self.errorView addSubview:tipsLabel];
    
    
    //DetailsLabel
    CGRect detailsFrame = CGRectMake(frame.size.width * 0.12,frame.size.height * 0.645, frame.size.width *0.76, frame.size.height * 0.3);
    UILabel *detailsLabel = [[UILabel alloc]initWithFrame:detailsFrame];
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    detailsLabel.text = tips;
    detailsLabel.numberOfLines = 0;
    detailsLabel.textColor = [UIColor colorWithHex:0xff0000];
    detailsLabel.font = [UIFont systemFontOfSize:15.0];
    [self.errorView addSubview:detailsLabel];
    
    
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:errorView];
    [self.navigationController.view addSubview:hudView];
    
    self.errorView = hudView;
    
    //弹出显示失败信息的动画
    CGRect beforeFrame = errorView.frame;
    errorView.frame = CGRectMake(beforeFrame.origin.x, beforeFrame.origin.y -400, beforeFrame.size.width, beforeFrame.size.height);
    CGRect afterFrame = errorView.frame;
    [UIView animateWithDuration:0.3 animations:^{
        
        errorView.frame = CGRectMake(afterFrame.origin.x, afterFrame.origin.y + 400, afterFrame.size.width, afterFrame.size.height);
        
    } completion:^(BOOL finished) {
        
        //3.0秒后消失
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            [UIView animateWithDuration:0.3 animations:^{
                
                errorView.frame = CGRectMake(errorView.origin.x, errorView.origin.y + 600, errorView.size.width, errorView.size.height);
                
            } completion:^(BOOL finished) {
                
                self.errorView.hidden = YES;
            }];
        });
    }];
}

-(void)registRequestWith:(DTFRegistModel *)registModel{
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"type"] = registModel.type; // 业务类型:01异地就医;02探亲出差;03外派登记
    param[@"contact_name"] = registModel.contact_name; // 联系人姓名
    param[@"contact_mobile"] = registModel.contact_mobile; // 联系人联系方式
    param[@"provice_code"] = registModel.provice_code; // 省编码
    param[@"city_code"] = registModel.city_code; // 市编码
    param[@"country_code"] = registModel.country_code; // 区县编码
    param[@"address"] = registModel.address; // 具体地址
    param[@"reason"] = registModel.reason; // 安置原因 011回原籍居住；012户籍异地落户居住；013随直系亲属异地居住；021探亲；022出差
    param[@"djbhqfs"] = registModel.djbhqfs; // 登记表获取方式 1自取；2邮寄；
    param[@"start_time"] = registModel.start_time; // 开始时间
    param[@"end_time"] = registModel.end_time; // 结束时间
    param[@"hospital_id"] = registModel.hospital_id; // 医院ID或者医院名称 中间用^隔开
    param[@"document_image"] = @""; // 证件照片(2.4版本以后不上传图片)
    NSString *url = [NSString stringWithFormat:@"%@%@",HOST_TEST,URL_EXECUTERECORD_JSON];
    
    DMLog(@"param--%@",param);
    
    [self showLoadingUI];
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        self.HUD.hidden = YES;
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"异地安置-%@",dictData);
        DMLog(@"异地安置-message====%@",dictData[@"message"]);
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            // 提交成功后pop到长住外地备案
            [self showSuccessView];
            
        }else{
            [self showErrorViewWithTips:dictData[@"message"]];
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


@end
