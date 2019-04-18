//
//  ServerCenterVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/26.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ServerCenterVC.h"
#import "AboutUsVC.h"
#import "BdH5VC.h"
#import "LoginVC.h"


@interface ServerCenterVC ()<UIGestureRecognizerDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topConstrains;

@end

@implementation ServerCenterVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"服务中心";
    HIDE_BACK_TITLE;
    [self setHotLineGuesture];
    [self setProblemGuesture];
    [self setInviteGuesture];
    [self setAboutusGuesture];
    if(kIsiPhoneX){
        self.topConstrains.constant += 20;
    }
}

#pragma mark - 服务热线VIEW添加手势
-(void)setHotLineGuesture{
    //添加手势
    UITapGestureRecognizer * HotLineGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(HotLineCall)];
    HotLineGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [HotLineGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Hotlineview addGestureRecognizer:HotLineGesture];
}

#pragma mark - 疑难解答VIEW添加手势
-(void)setProblemGuesture{
    UITapGestureRecognizer * ProblemGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Problem)];
    ProblemGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [ProblemGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Problemview addGestureRecognizer:ProblemGesture];
}

#pragma mark - 邀请码VIEW添加手势
-(void)setInviteGuesture{
    UITapGestureRecognizer * InviteGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Invite)];
    InviteGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [InviteGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Inviteview addGestureRecognizer:InviteGesture];
}

#pragma mark - 关于我们VIEW添加手势
-(void)setAboutusGuesture{
    UITapGestureRecognizer * AboutusGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(Aboutus)];
    AboutusGesture.delegate = self;
    
    //选择触发事件的方式（默认单机触发）
    [AboutusGesture setNumberOfTapsRequired:1];
    //将手势添加到需要相应的view中去
    [self.Aboutusview addGestureRecognizer:AboutusGesture];
}

- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupNavigationBarStyle];
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 拨打服务热线电话
-(void)HotLineCall{
    NSURL *url = [NSURL URLWithString:@"telprompt://96150"];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - 疑难解答
-(void)Problem{

    UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
    BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
    [VC setValue:@"/h5/question_list.html?" forKey:@"url"];
    [VC setValue:@"疑难解答" forKey:@"tit"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

#pragma mark - 邀请码
-(void)Invite{
    
    
    if([CoreArchive boolForKey:LOGIN_STUTAS]){ //登录
        
        UIStoryboard *SB = [UIStoryboard storyboardWithName:@"Service" bundle:nil];
        BdH5VC *VC = [SB instantiateViewControllerWithIdentifier:@"BdH5VC"];
        NSString *token = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        NSString *urlString = [NSString stringWithFormat:@"/h5/invite.html?token=%@&version=%@",token,version];
        [VC setValue:urlString forKey:@"url"];
        [VC setValue:@"邀请码" forKey:@"tit"];
        VC.hidesBottomBarWhenPushed=YES;
        [self.navigationController pushViewController:VC animated:YES];
    }else{
    
        YWLoginVC * loginVC = [[YWLoginVC alloc]init];
        loginVC.isFromRegist = YES;
        DTFNavigationController * navVC = [[DTFNavigationController alloc]initWithRootViewController:loginVC];
        [self presentViewController:navVC animated:YES completion:nil];
    
    }
    
    
    
}

#pragma mark - 关于我们
-(void)Aboutus{
    UIStoryboard *UB = [UIStoryboard storyboardWithName:@"Mine" bundle:nil];
    AboutUsVC * VC = [UB instantiateViewControllerWithIdentifier:@"AboutUsVC"];
    VC.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:VC animated:YES];
}

@end
