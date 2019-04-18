//
//  PhotoVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "PhotoVC.h"
#import "CameraSessionView.h"



@interface PhotoVC ()<CACameraSessionDelegate>

@property (nonatomic, strong) CameraSessionView *cameraView;
@property (nonatomic, strong)     UILabel      *lb1;
@property (nonatomic, strong)     UILabel      *lb2;
@property (nonatomic, strong)    UIImageView    *xukuang1;
@property (nonatomic, strong)    UIImageView    *xukuang2;

@property (nonatomic, strong)      UIImage      *IMG;
@property (nonatomic, strong)       NSData      *IMGDATA;

@property (nonatomic, strong)     UIView   *bgView;
@property (nonatomic, strong) UIImageView  *imgView;
@property (nonatomic, strong)    UIButton  *btn1;
@property (nonatomic, strong)    UIButton  *btn2;

@end

@implementation PhotoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"实人认证";
    HIDE_BACK_TITLE;
    [self setupUI];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化界面布局
- (void)setupUI
{
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor whiteColor];
    
    titlb = [[UILabel alloc] init];
    [self.view addSubview:titlb];
    [titlb mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top).offset(84);
        make.left.equalTo(weakSelf.view.mas_left);
        make.right.equalTo(weakSelf.view.mas_right);
        make.height.equalTo(@15);
    }];
    titlb.font = [UIFont systemFontOfSize:13];
    titlb.textColor = [UIColor colorWithHex:0x666666];
    titlb.textAlignment = NSTextAlignmentCenter;
    titlb.text = @"请将拍摄内容置入虚线框内，确保文字清晰";
    
    CGFloat width = self.view.frame.size.width;
    CGFloat heigt = self.view.frame.size.height;
    _cameraView = [[CameraSessionView alloc] initWithFrame:CGRectMake(0, 110, width, heigt-110)];
    
    
    //Set the camera view's delegate and add it as a subview
    _cameraView.delegate = self;
    
    //Apply animation effect to present the camera view
    CATransition *applicationLoadViewIn =[CATransition animation];
    [applicationLoadViewIn setDuration:0.6];
    [applicationLoadViewIn setType:kCATransitionReveal];
    [applicationLoadViewIn setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn]];
    [[_cameraView layer]addAnimation:applicationLoadViewIn forKey:kCATransitionReveal];
    
    [self.view addSubview:_cameraView];
    
    int k1,k2,g1,g2,w2;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
        k1 = 260;
        k2 = 150;
        g1 = 130;
        g2 = 410;
        w2 = 200;
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        k1 = 240;
        k2 = 130;
        g1 = 130;
        g2 = 390;
        w2 = 190;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        k1 = 220;
        k2 = 90;
        g1 = 130;
        g2 = 370;
        w2 = 150;
    }
    else //3.5寸屏幕
    {
        k1 = 180;
        k2 = 30;
        g1 = 120;
        g2 = 360;
        w2 = 120;
    }

    if ([self.type isEqualToString:@"smkaImg"]) {
        _xukuang1 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width-40, k1)];   // k1=240 6
        _xukuang1.center = CGPointMake(self.view.center.x, self.view.center.y);
        _xukuang1.image = [UIImage imageNamed:@"bg_rect13"];
        [self.view addSubview:_xukuang1];
        
        _lb1 = [[UILabel alloc] init];
        [self.view addSubview:_lb1];
        [_lb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_xukuang1.mas_top).offset(15);
            make.left.equalTo(weakSelf.view.mas_left).offset(30);
            make.right.equalTo(weakSelf.view.mas_right);
            make.height.equalTo(@15);
        }];
        _lb1.font = [UIFont systemFontOfSize:15];
        _lb1.textColor = [UIColor whiteColor];
        _lb1.text = @"市民卡区域";
        
    }else{
        _xukuang1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, g1, width-40, k1)];  // g1=130 6
        _xukuang1.image = [UIImage imageNamed:@"bg_rect11"];
        [self.view addSubview:_xukuang1];
        
        _lb1 = [[UILabel alloc] init];
        [self.view addSubview:_lb1];
        [_lb1 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_xukuang1.mas_top).offset(15);
            make.left.equalTo(weakSelf.view.mas_left).offset(30);
            make.right.equalTo(weakSelf.view.mas_right);
            make.height.equalTo(@15);
        }];
        _lb1.font = [UIFont systemFontOfSize:15];
        _lb1.textColor = [UIColor whiteColor];
        _lb1.text = @"头像区域";
        
        _xukuang2 = [[UIImageView alloc] initWithFrame:CGRectMake(20, g2, w2, k2)];   // k2=160 g2=390  6
        _xukuang2.image = [UIImage imageNamed:@"bg_rect12"];
        [self.view addSubview:_xukuang2];
        
        _lb2 = [[UILabel alloc] init];
        [self.view addSubview:_lb2];
        [_lb2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_xukuang2.mas_top).offset(15);
            make.left.equalTo(weakSelf.view.mas_left).offset(30);
            make.right.equalTo(weakSelf.view.mas_right);
            make.height.equalTo(@15);
        }];
        _lb2.font = [UIFont systemFontOfSize:15];
        _lb2.textColor = [UIColor whiteColor];
        _lb2.text = @"市民卡区域";
    }
}

#pragma mark - CACameraSessionDelegate
-(void)didCaptureImage:(UIImage *)image {
    DMLog(@"CAPTURED IMAGE");
    
    self.IMG = [self checkImage:image];
    
    int gao;
    //区别屏幕尺寸
    if ( SCREEN_HEIGHT > 667) //6p
    {
        gao = 51;
    }
    else if (SCREEN_HEIGHT > 568)//6
    {
        gao = 45;
    }
    else if (SCREEN_HEIGHT > 480)//5s
    {
        gao = 40;
    }
    else //3.5寸屏幕
    {
        gao = 35;
    }
    
    self.bgView = [[UIView alloc] init];
    self.bgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    UIColor *color = [UIColor colorWithHex:0xeeeeee];
    self.bgView.backgroundColor = [color colorWithAlphaComponent:1.0];
    
    self.imgView = [[UIImageView alloc] init];
    self.imgView.image = image;
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    self.imgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
    
    self.btn1 = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.imgView.bottom-gao, SCREEN_WIDTH/2, gao)];
    [self.btn1 addTarget:self action:@selector(rephotobtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.btn1 setBackgroundImage:[UIImage imageNamed:@"btn_rephoto3"] forState:UIControlStateNormal];
    
    self.btn2 = [[UIButton alloc] initWithFrame:CGRectMake(self.btn1.right, self.imgView.bottom-gao, SCREEN_WIDTH/2, gao)];
    [self.btn2 addTarget:self action:@selector(usephotobtnClicked) forControlEvents:UIControlEventTouchUpInside];
    [self.btn2 setBackgroundImage:[UIImage imageNamed:@"btn_usephoto"] forState:UIControlStateNormal];
    
    
    [self.bgView addSubview:self.imgView];
    [self.bgView addSubview:self.btn1];
    [self.bgView addSubview:self.btn2];
    
    [self.view addSubview:self.bgView];
    
}

-(void)didCaptureImageWithData:(NSData *)imageData {
    DMLog(@"CAPTURED IMAGE DATA");
    self.IMGDATA = imageData;
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    //Show error alert if image could not be saved
    if (error) [[[UIAlertView alloc] initWithTitle:@"Error!" message:@"Image couldn't be saved" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil, nil] show];
}


-(UIImage *)checkImage:(UIImage *)image{
    
    NSData *sendImageData = UIImageJPEGRepresentation(image, 0.4);
    NSUInteger sizeOrigin = [sendImageData length];
    NSUInteger sizeOriginKB = sizeOrigin / 1024;
    
    if (sizeOriginKB > 200) {
        float a = 200.0000;
        float b = (float)sizeOriginKB;
        float q = sqrtf(a / b);
        
        CGSize sizeImage = [image size];
        CGFloat widthSmall = sizeImage.width * q;
        CGFloat heighSmall = sizeImage.height * q;
        CGSize sizeImageSmall = CGSizeMake(widthSmall, heighSmall);
        
        UIGraphicsBeginImageContext(sizeImageSmall);
        CGRect smallImageRect = CGRectMake(0, 0, sizeImageSmall.width, sizeImageSmall.height);
        [image drawInRect:smallImageRect];
        UIImage *smallImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return smallImage;
    }else{
        image=[UIImage imageWithData:sendImageData];
    }
    return image;
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn1 removeFromSuperview];
    [self.btn2 removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn1 = nil;
    self.btn2 = nil;
}

#pragma mark -  重新拍照按钮点击事件
- (void)rephotobtnClicked{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn1 removeFromSuperview];
    [self.btn2 removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn1 = nil;
    self.btn2 = nil;
}

#pragma mark -  使用照片按钮点击事件
-(void)usephotobtnClicked{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn1 removeFromSuperview];
    [self.btn2 removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn1 = nil;
    self.btn2 = nil;
    
    //拿到图片
    NSString *path_document = NSHomeDirectory();
    //设置一个图片的存储路径
    NSString *imagePath;
    
    if ([self.type isEqualToString:@"smkaImg"]) {
        imagePath = [path_document stringByAppendingString:@"/Documents/cardImg1.png"];
    }else{
        imagePath = [path_document stringByAppendingString:@"/Documents/cardImg2.png"];
    }
    //把图片直接保存到指定的路径（同时应该把图片的路径imagePath存起来，下次就可以直接用来取）
    [UIImagePNGRepresentation(self.IMG) writeToFile:imagePath atomically:YES];
    
    if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(didSelectedImage:andImagePath:andType:)]) {
        [self.imgDelegate didSelectedImage:self.IMG andImagePath:imagePath andType:self.type];
    }
    
    if (self.imgDelegate && [self.imgDelegate respondsToSelector:@selector(didSelectedImageData:andType:)]) {
        [self.imgDelegate didSelectedImageData:self.IMGDATA andType:self.type];
    }
    
    [self.navigationController popViewControllerAnimated:YES];

}


@end
