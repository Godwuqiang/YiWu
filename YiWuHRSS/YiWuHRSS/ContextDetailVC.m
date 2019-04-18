//
//  ContextDetailVC.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/6/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ContextDetailVC.h"
#import "HttpHelper.h"

#define NEWS_ONEREAD_URL      @"news/updateAllOneRead.json"

@interface ContextDetailVC ()

@end

@implementation ContextDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"详情";
    
    //自定义左边 的按钮
    UIButton *leftButton = [[UIButton alloc]init];
    leftButton.frame = CGRectMake(0, 10, 20, 20);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(doclickLeftButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItems = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    //解决按钮不靠左 靠右的问题.
    UIBarButtonItem *nagetiveSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    nagetiveSpacer.width = -12;//这个值可以根据自己需要自己调整
    self.navigationItem.leftBarButtonItems = @[nagetiveSpacer, leftBarButtonItems];
    
    [self initView];
    [self SetOneNewsRead];
}

#pragma mark - 初始化界面显示
-(void)initView{
    if ([self.LX isEqualToString:@"liebiao"]) {     // 从列表中进入
        self.Title.text = self.bean.title;
        self.Time.text = self.bean.update_time;
        self.Context.text = self.bean.content;
    }else if ([self.LX isEqualToString:@"tuisong"]) {  // 从推送中进入
        self.Title.text = self.bean.msgTitle;
        self.Time.text = self.bean.sendTime;
        self.Context.text = self.bean.content;
    }
}

-(void)viewWillAppear:(BOOL)animated{
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
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - 返回按钮点击事件
-(void)doclickLeftButton{
    if ([self.LX isEqualToString:@"liebiao"]) {  // 从消息列表中进入的
        [self.navigationController popViewControllerAnimated:NO];
    }else if ([self.LX isEqualToString:@"tuisong"]) {     // 从推送进入
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - 修改群推列表单个已读
-(void)SetOneNewsRead {
   
    NSMutableDictionary *param = [[NSMutableDictionary alloc] init];
    NSString *accesstoken = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    [param setValue:@"2" forKey:@"device_type"];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [param setValue:version forKey:@"app_version"];
    [param setValue:accesstoken forKey:@"access_token"];
    [param setValue:self.bean.msgId forKey:@"msg_id"];

    DMLog(@"param=%@",param);
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,NEWS_ONEREAD_URL];
    DMLog(@"url=%@",url);
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
    } failure:^(NSError *error) {
        
    }];
}


@end
