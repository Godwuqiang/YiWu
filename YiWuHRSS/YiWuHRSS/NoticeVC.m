//
//  NoticeVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/26.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "NoticeVC.h"
#import "MsgCenterVC.h"
#import "DTFPrivateMsgVC.h"
#import "HttpHelper.h"

#define UNREAD_INFO_URL       @"news/queryUnReadInfo.json"

@interface NoticeVC ()<UIGestureRecognizerDelegate>

@property (nonatomic, weak)AFNetworkReachabilityManager *manger;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;

@end

@implementation NoticeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"消息中心";
    HIDE_BACK_TITLE;
    
    [self setNewsGuesture];
    [self setSixinGuesture];
    [self registerSerive];
    
    if(kIsiPhoneX){
        self.topConstrains.constant +=20;
    }
}

#pragma mark - 新闻通知VIEW添加手势
-(void)setNewsGuesture{
    //添加手势
    UITapGestureRecognizer * NewsGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(News)];
    NewsGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [NewsGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Newsview addGestureRecognizer:NewsGesture];
}

#pragma mark - 我的私信VIEW添加手势
-(void)setSixinGuesture{
    UITapGestureRecognizer * SixinGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Sixin)];
    SixinGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [SixinGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Sixinview addGestureRecognizer:SixinGesture];
}

#pragma mark - 注册通知
-(void)registerSerive{
    
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(JPush:) name:@"JPUSH" object:nil];
}

-(void)JPush:(NSNotification*) notification{
    
    [self QueryUnreadInfo];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
    [self loadNet];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
}

#pragma mark - 监听网络状态
-(void)loadNet {
    //1.创建网络状态监测管理者
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN || status==AFNetworkReachabilityStatusReachableViaWiFi) {
            if ([CoreArchive boolForKey:LOGIN_STUTAS]) {  //已经登录
                [self QueryUnreadInfo];
            }
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
}

- (void)dealloc{
    
    [self unRegisterSerive];
}

#pragma mark - 清除通知
-(void)unRegisterSerive{
    
    [[NSNotificationCenter defaultCenter]removeObserver:self name:@"JPUSH" object:nil];
}

#pragma mark - 新闻通知
-(void)News{
    UIStoryboard * MB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    MsgCenterVC * VC = [MB instantiateViewControllerWithIdentifier:@"MsgCenterVC"];
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 我的私信
-(void)Sixin{
    
    DTFPrivateMsgVC * VC =[[DTFPrivateMsgVC alloc]init];
    [VC setValue:@"消息中心" forKey:@"type"];
    [self.navigationController pushViewController:VC animated:YES];
}

-(void)QueryUnreadInfo {
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:[Util getuuid] forKey:@"imei"];
    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UNREAD_INFO_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        DMLog(@"===============%@",dictData);
        @try {
            NSString *temp = [dictData objectForKey:@"resultCode"];
            int iStatus = temp.intValue;
            if (iStatus == 200)
            {
                NSDictionary *dict = [dictData objectForKey:@"data"];
                NSString *personnum = [dict objectForKey:@"personUnReadNum"];
                [CoreArchive setStr:personnum key:@"personUnReadNum"];
                NSString *newsnum = [dict objectForKey:@"newsUnReadNum"];
                [CoreArchive setStr:newsnum key:@"newsUnReadNum"];
                int num1 = [newsnum intValue];
                int num2 = [personnum intValue];
                
                if (num2 == 0) {
                    self.Dot2img.hidden = YES;
                    self.Num2.hidden = YES;
                }else if (num2 > 9) {
                    self.Dot2img.hidden = NO;
                    self.Num2.hidden = NO;
                    self.Num2.text = @"...";
                    self.Num2leftconstrains.constant = 32;
                    self.Num2topconstrains.constant = 2;
                }else{
                    self.Dot2img.hidden = NO;
                    self.Num2.hidden = NO;
                    self.Num2leftconstrains.constant = 34;
                    self.Num2.text = [NSString stringWithFormat:@"%d", num2];
                    self.Num2topconstrains.constant = 5;
                }
                
                if (num1 == 0) {
                    self.Dot1img.hidden = YES;
                    self.Num1.hidden = YES;
                }else if (num1 > 9) {
                    self.Dot1img.hidden = NO;
                    self.Num1.hidden = NO;
                    self.Num1.text = @"...";
                    self.Num1leftconstrains.constant = 32;
                    self.Num1topconstrains.constant = 2;
                }else{
                    self.Dot1img.hidden = NO;
                    self.Num1.hidden = NO;
                    self.Num1.text = [NSString stringWithFormat:@"%d", num1];
                    self.Num1leftconstrains.constant = 34;
                    self.Num1topconstrains.constant = 5;
                }
                
            }
        } @catch (NSException *exception) {
            DMLog(@"%@",exception);
        }
    } failure:^(NSError *error) {
        DMLog(@"%@",error);
    }];
}

@end
