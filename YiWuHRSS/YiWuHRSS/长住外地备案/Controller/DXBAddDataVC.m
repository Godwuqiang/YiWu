//
//  DXBAddDataVC.m
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBAddDataVC.h"
#import "LDImagePicker.h"
#import "DTFRegistModel.h"
#import "HttpHelper.h"

#define URL_EXECUTERECORD_JSON       @"/shebao/executeRecord.json"       // 异地安置/探亲出差/外派登记

@interface DXBAddDataVC ()<LDImagePickerDelegate>

/// 证件照片
@property (nonatomic, strong) NSString *imageDataStr;

/** HUD */
@property(nonatomic ,strong) MBProgressHUD * HUD;
/** 成功的提示View */
@property (nonatomic, strong) UIView * successView;
/** 失败的提示View */
@property (nonatomic, strong) UIView * errorView;

@end

@implementation DXBAddDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.title = @"添加材料说明";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.wpzmwjLabel.layer.borderWidth = 1;
    self.wpzmwjLabel.layer.borderColor = [UIColor colorWithHex:0x7ea4b0].CGColor;
    
    
    self.bgView.hidden = YES;
    self.bgView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    
    self.attentionLabel.text = @"1、保证拍摄的照片清晰可见\n2、拍摄后需要审核后才有效";
}



#pragma mark - 选择照片
- (IBAction)choosePhotoButtonClick:(id)sender {
    
    self.bgView.hidden = NO;
//    UIWindow* currentWindow = [UIApplication sharedApplication].keyWindow;
//    [currentWindow addSubview:self.bgView];
    [self.view bringSubviewToFront:self.bgView];
}


#pragma mark - 确认提交备案
- (IBAction)submissionButtonClick:(id)sender {
    
    if ([Util IsStringNil:self.imageDataStr]) {
        
        [MBProgressHUD showError:@"请上传本单位（机关事业单位或国企）下发的外派文件"];
        return;
    }
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"type"] = self.registModel.type; // 业务类型:01异地就医;02探亲出差;03外派登记
    param[@"contact_name"] = self.registModel.contact_name; // 联系人姓名
    param[@"contact_mobile"] = self.registModel.contact_mobile; // 联系人联系方式
    param[@"provice_code"] = self.registModel.provice_code; // 省编码
    param[@"city_code"] = self.registModel.city_code; // 市编码
    param[@"country_code"] = self.registModel.country_code; // 区县编码
    param[@"address"] = self.registModel.address; // 具体地址
    param[@"reason"] = self.registModel.reason; // 安置原因 011回原籍居住；012户籍异地落户居住；013随直系亲属异地居住；021探亲；022出差
    param[@"djbhqfs"] = self.registModel.djbhqfs; // 登记表获取方式 1自取；2邮寄；
    param[@"start_time"] = self.registModel.start_time; // 开始时间
    param[@"end_time"] = self.registModel.end_time; // 结束时间
    param[@"hospital_id"] = self.registModel.hospital_id; // 医院ID或者医院名称 中间用^隔开
    param[@"document_image"] = self.imageDataStr; // 证件照片
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


#pragma mark - 拍照
- (IBAction)PhotographButton:(id)sender {
    
    DMLog(@"拍照");
    self.bgView.hidden = YES;
    
    [CoreArchive setStr:@"重拍" key:@"cancelTitle"];
    
    LDImagePicker *imagePicker = [LDImagePicker sharedInstance];
    imagePicker.Type = @"外派人员登记";
    imagePicker.delegate = self;
    [imagePicker showImagePickerWithType:ImagePickerCamera InViewController:self Scale:0.75];
}

#pragma mark - 从相机选择
- (IBAction)cameraSelectionClick:(id)sender {
    
    DMLog(@"从相机选择");
    
    self.bgView.hidden = YES;
    
    [CoreArchive setStr:@"重新选择" key:@"cancelTitle"];
    
    LDImagePicker *imagePicker = [LDImagePicker sharedInstance];
    imagePicker.Type = @"外派人员登记";
    imagePicker.delegate = self;
    [imagePicker showImagePickerWithType:ImagePickerPhoto InViewController:self Scale:0.75];
}

#pragma mark - 取消
- (IBAction)cancelButtonClick:(id)sender {
    
    DMLog(@"取消");
    self.bgView.hidden = YES;
}

- (void)imagePicker:(LDImagePicker *)imagePicker didFinished:(UIImage *)editedImage {
    
    DMLog(@"完成选择照片...");
    [self.hukouBtn setBackgroundImage:editedImage forState:UIControlStateNormal];
    
//    NSData *data = UIImageJPEGRepresentation(editedImage, 0.5f);
    NSData *data = [self imageData:editedImage];
    self.imageDataStr = [data base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    
}
- (void)imagePickerDidCancel:(LDImagePicker *)imagePicker {
    
    DMLog(@"点击取消");
    
    self.imageDataStr = @"";
    
}

- (NSData *)imageData:(UIImage *)myimage
{
    NSData *data=UIImageJPEGRepresentation(myimage, 1.0);
    
    if (data.length>1024 *1024) {
        if (data.length>10240*1024) {//10M以及以上
            data=UIImageJPEGRepresentation(myimage, 0.01);//压缩之后1M~
        }else if (data.length>5120*1024){//5M~10M
            data=UIImageJPEGRepresentation(myimage, 0.1);//压缩之后0.5M~1M
        }else if (data.length>2048*1024){//2M~5M
            data=UIImageJPEGRepresentation(myimage, 0.2);//压缩之后0.4M~1M
        }else {
            //1M~2M
            data=UIImageJPEGRepresentation(myimage, 0.5);//压缩之后0.5M~1M
        }
    }
    return data;
}


/**
 *  加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"加载中";
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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


@end
