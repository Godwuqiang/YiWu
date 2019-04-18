//
//  RealPersonVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "RealPersonVC.h"
#import "PhotoVC.h"
#import "SettingWebVC.h"
#import "AFNetworking.h"
#import "RealPersonCellOne.h"    // 185
#import "RealPersonCellTwo.h"   // 420
/**
 *  是否开启https SSL 验证
 *
 *  @return YES为开启，NO为关闭
 */
#define openHttpsSSL YES
/**
 *  SSL 证书名称，仅支持cer格式。“app.bishe.com.cer”,则填“app.bishe.com”
 */
#define     certificate  @"*.dabay.cn"


@interface RealPersonVC ()<UITableViewDelegate,UITableViewDataSource,PhotoVCDelegate>{
    BOOL   hasnet;
}

@property (nonatomic, strong)  UIImage  *Img1;
@property (nonatomic, strong)  UIImage  *Img2;
@property (nonatomic, strong)   NSData  *Imgdata1;
@property (nonatomic, strong)   NSData  *Imgdata2;

@property (nonatomic, strong)   NSString  *Imgpath1;
@property (nonatomic, strong)   NSString  *Imgpath2;
@property (nonatomic, strong)   NSString  *katype;

@property (nonatomic, strong)     UIView   *bgView;
@property (nonatomic, strong) UIImageView  *imgView;
@property (nonatomic, strong)    UIButton  *btn;
@property (nonatomic, strong)    UIButton  *closebtn;

@property (nonatomic, assign)    BOOL   issmka;
@property (nonatomic, assign)    BOOL   iscka;

@property (nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation RealPersonVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"实人认证";
    HIDE_BACK_TITLE;
    self.issmka = NO;
    self.iscka = NO;
    self.Img1 = [[UIImage alloc] init];
    self.Img2 = [[UIImage alloc] init];
    self.Imgdata1 = [[NSData alloc] init];
    self.Imgdata2 = [[NSData alloc] init];
    NSLog(@"str:%@",self.str);
    NSLog(@"phone:%@",self.phone);

    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [self setupNavigationBarStyle];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self afn];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:21.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
}

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [manger startMonitoring];
    //2.监听改变
    [manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            hasnet = YES;
        }else{
            hasnet = NO;
        }
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 初始化界面布局
- (void)setupUI
{
    __weak __typeof(self) weakSelf = self;
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    srtableview = [[UITableView alloc]init];
    [self.view addSubview:srtableview];
    srtableview.delegate = self;
    srtableview.dataSource = self;
    [srtableview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(weakSelf.view.mas_top);
        make.left.equalTo(weakSelf.view.mas_left).offset(15);
        make.right.equalTo(weakSelf.view.mas_right).offset(-15);
        make.bottom.equalTo(weakSelf.view.mas_bottom);
    }];
    srtableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    srtableview.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    [srtableview registerNib:[UINib nibWithNibName:@"RealPersonCellOne" bundle:nil] forCellReuseIdentifier:@"RealPersonCellOne"];
    [srtableview registerNib:[UINib nibWithNibName:@"RealPersonCellTwo" bundle:nil] forCellReuseIdentifier:@"RealPersonCellTwo"];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row==0) {
        return 215;
    }else{
        return 470;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        RealPersonCellOne *cell = [tableView dequeueReusableCellWithIdentifier:@"RealPersonCellOne"];
        [cell.smkaImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(smkaclick:)]];
        if (self.issmka) {
            cell.smkaImg.image = self.Img1;
        }else{
            cell.smkaImg.image = [UIImage imageNamed:@"img_photo"];
        }
        
        return cell;
    }else{
        RealPersonCellTwo *cell = [tableView dequeueReusableCellWithIdentifier:@"RealPersonCellTwo"];

        [cell.ckaImg addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(ckaclick:)]];
        [cell.nextBtn addTarget:self action:@selector(nextBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        if (self.iscka) {
            cell.ckaImg.image = self.Img2;
        }else{
            cell.ckaImg.image = [UIImage imageNamed:@"img_photo"];
        }
        
        return cell;
    }
}

#pragma mark - 市民卡点击拍照事件
-(void)smkaclick:(UITapGestureRecognizer *)gestureRecognizer
{
    self.katype = @"smkaImg";
    if (self.issmka) {
        self.bgView = [[UIView alloc] init];
        self.bgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
        UIColor *color = [UIColor blackColor];
        self.bgView.backgroundColor = [color colorWithAlphaComponent:1.0];
        
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
        
        self.closebtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 30, 30, 30)];
        [self.closebtn addTarget:self action:@selector(closebtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.closebtn setBackgroundImage:[UIImage imageNamed:@"btn_return2"] forState:UIControlStateNormal];
        
        self.imgView = [[UIImageView alloc] init];
        self.imgView.image = self.Img1;
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.frame = CGRectMake(0.0, 64.0, SCREEN_WIDTH, SCREEN_HEIGHT-64-gao);
        
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.imgView.bottom, SCREEN_WIDTH, gao)];
        [self.btn addTarget:self action:@selector(picbtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.btn setBackgroundImage:[UIImage imageNamed:@"btn_rephoto2"] forState:UIControlStateNormal];
        
        [self.bgView addSubview:self.imgView];
        [self.bgView addSubview:self.btn];
        [self.bgView addSubview:self.closebtn];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.bgView];
        
    }else{
        NSString *type = @"smkaImg";
        PhotoVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoVC"];
        [VC  setValue:type forKey:@"type"];
        VC.imgDelegate = self;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}

#pragma mark - 持卡拍照点击事件
-(void)ckaclick:(UITapGestureRecognizer *)gestureRecognizer
{
    self.katype = @"ckaImg";
    if (self.iscka) {
        self.bgView = [[UIView alloc] init];
        self.bgView.frame = CGRectMake(0.0, 0.0, SCREEN_WIDTH, SCREEN_HEIGHT);
        UIColor *color = [UIColor blackColor];
        self.bgView.backgroundColor = [color colorWithAlphaComponent:1.0];
        
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
        
        self.closebtn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, 30.0, 30, 30)];
        [self.closebtn addTarget:self action:@selector(closebtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.closebtn setBackgroundImage:[UIImage imageNamed:@"btn_return2"] forState:UIControlStateNormal];
        
        self.imgView = [[UIImageView alloc] init];
        self.imgView.image = self.Img2;
        self.imgView.contentMode = UIViewContentModeScaleAspectFit;
        self.imgView.frame = CGRectMake(0.0, 64.0, SCREEN_WIDTH, SCREEN_HEIGHT-64-gao);
        
        self.btn = [[UIButton alloc] initWithFrame:CGRectMake(0.0, self.imgView.bottom, SCREEN_WIDTH, gao)];
        [self.btn addTarget:self action:@selector(picbtnClicked) forControlEvents:UIControlEventTouchUpInside];
        [self.btn setBackgroundImage:[UIImage imageNamed:@"btn_rephoto2"] forState:UIControlStateNormal];
        
        [self.bgView addSubview:self.imgView];
        [self.bgView addSubview:self.btn];
        [self.bgView addSubview:self.closebtn];
        
        [[[UIApplication sharedApplication] keyWindow] addSubview:self.bgView];
        
    }else{
        NSString *type = @"ckaImg";
        PhotoVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoVC"];
        [VC  setValue:type forKey:@"type"];
        VC.imgDelegate = self;
        [self.navigationController pushViewController:VC animated:YES];
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

#pragma mark -  下一步按钮  先上传图片
- (IBAction)nextBtnClicked:(UIButton *)sender {
    NSUInteger len1 = [self.Imgdata1 length]/1000;
    if (len1==0) {
        [MBProgressHUD showError:@"请拍市民卡"];
        return;
    }
    NSUInteger len2 = [self.Imgdata2 length]/1000;
    if (len2==0) {
        [MBProgressHUD showError:@"请拍持卡照"];
        return;
    }
    if (!hasnet) {
        [MBProgressHUD showError:@"当前网络不可用，请检查网络设置"];
        return;
    }
    self.Imgdata1 = UIImageJPEGRepresentation(self.Img1,0.2);
    self.Imgdata2 = UIImageJPEGRepresentation(self.Img2,0.2);

    [self showLoadingUI];
    
    NSDate *currentDate = [NSDate date];//获取当前时间，日期
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:currentDate];
    NSLog(@"dateString:%@",dateString);
    NSString *comTime = dateString;
    
    NSString *platform = @"107135e01f964cc7abd6b2941d879434";
    NSString *apikey = @"c4b1d46c7aeb43df8b3aa28ad5d7624b";
    NSString *type = [CoreArchive strForKey:LOGIN_CARD_TYPE];
    
    NSString *kh = [CoreArchive strForKey:LOGIN_CARD_NUM];
    NSString *bk = [CoreArchive strForKey:LOGIN_BANK_CARD];
    
    NSString *cardtype;
    NSString *cardnum;
    if ([type isEqualToString:@"1"]) {
        cardtype = @"100";
        cardnum = [Util HeadStr:kh WithNum:1];
    }else{
        cardtype = @"730";
        cardnum = @"";
    }
    NSString *account = [Util HeadStr:bk WithNum:1];
    
    NSDictionary *param = @{@"platform":platform,
                            @"apikey":apikey,
                            @"cardType":cardtype,
                            @"cardNum":cardnum,
                            @"comTime":comTime,
                            @"account":account};
    DMLog(@"param=%@",param);
    @try {
        AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
        manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/html",@"image/jpeg",@"image/png",@"application/octet-stream",@"text/json",nil];
        
        if (openHttpsSSL) {
            [manager setSecurityPolicy:[self customSecurityPolicy]];
        }

        [manager POST:HOST_NAME parameters:param constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
            [formData appendPartWithFileData:self.Imgdata1 name:@"cardImg1" fileName:self.Imgpath1 mimeType:@"image/png"];
            [formData appendPartWithFileData:self.Imgdata2 name:@"cardImg2" fileName:self.Imgpath2 mimeType:@"image/png"];
        } progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            self.HUD.hidden = YES;
            DMLog(@"%@",responseObject);
            if ([responseObject[@"code"] integerValue] == 1000) {//上传成功
                [MBProgressHUD showError:@"图片上传成功"];
                [self nextstep];
            }else{
                NSString *msg = responseObject[@"msg"];
                [MBProgressHUD showError:msg];
            }
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            self.HUD.hidden = YES;
            [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
        }];
    } @catch (NSException *exception) {
        self.HUD.hidden = YES;
        [MBProgressHUD showError:@"服务暂不可用，请稍后重试"];
    }
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"图片上传中";
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn removeFromSuperview];
    [self.closebtn removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn = nil;
    self.closebtn = nil;
}

- (void)dealloc{
    // 销毁加载中动画控件
    if ( nil != self.HUD ){
        [self.HUD removeFromSuperview];
        self.HUD = nil;
    }
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"gotoservice" object:nil];
}

#pragma mark - PhotoVCDelegate
- (void)didSelectedImage:(UIImage *)image andImagePath:(NSString *)imagepath andType:(NSString *)type{
    if ([type isEqualToString:@"smkaImg"]) {
        self.Img1 = image;
        self.issmka = YES;
        self.Imgpath1 = imagepath;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:0 inSection:0];
        [srtableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }else{
        self.iscka = YES;
        self.Img2 = image;
        self.Imgpath2 = imagepath;
        NSIndexPath *indexPath=[NSIndexPath indexPathForRow:1 inSection:0];
        [srtableview reloadRowsAtIndexPaths:[NSArray arrayWithObjects:indexPath,nil] withRowAnimation:UITableViewRowAnimationNone];
    }
}


- (void)didSelectedImageData:(NSData *)imagedata andType:(NSString *)type{
    if ([type isEqualToString:@"smkaImg"]) {
        self.Imgdata1 = imagedata;
        self.issmka = YES;
    }else{
        self.iscka = YES;
        self.Imgdata2 = imagedata;
    }
}

#pragma mark - 跳转至下一步界面
-(void)nextstep{
    UIStoryboard *MB = [UIStoryboard storyboardWithName: @"Mine" bundle: nil];
    SettingWebVC *VC = [MB instantiateViewControllerWithIdentifier:@"SettingWebVC"];
    [VC setValue:self.str forKey:@"str"];
    [VC setValue:self.phone forKey:@"phone"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - HTTPS证书配置
- (AFSecurityPolicy*)customSecurityPolicy {
    NSString *cerPath = [[NSBundle mainBundle] pathForResource:certificate ofType:@"cer"];
    NSData *cerData = [NSData dataWithContentsOfFile:cerPath];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy defaultPolicy];
    securityPolicy.allowInvalidCertificates = YES;
    securityPolicy.validatesDomainName = NO;
    securityPolicy.pinnedCertificates = [NSSet setWithObject:cerData];
    return securityPolicy;
}

#pragma mark -  重新拍照按钮点击事件
- (void)picbtnClicked{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn removeFromSuperview];
    [self.closebtn removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn = nil;
    self.closebtn = nil;
    
    PhotoVC *VC = [self.storyboard instantiateViewControllerWithIdentifier:@"PhotoVC"];
    [VC  setValue:self.katype forKey:@"type"];
    VC.imgDelegate = self;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark -  关闭按钮点击事件
-(void)closebtnClicked{
    [self.bgView removeFromSuperview];
    [self.imgView removeFromSuperview];
    [self.btn removeFromSuperview];
    [self.closebtn removeFromSuperview];
    self.bgView = nil;
    self.imgView = nil;
    self.btn = nil;
    self.closebtn = nil;
}


@end
