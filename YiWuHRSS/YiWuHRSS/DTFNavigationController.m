//
//  DTFNavigationController.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/10/12.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFNavigationController.h"

@interface DTFNavigationController ()<UINavigationControllerDelegate, UIGestureRecognizerDelegate>

@end

@implementation DTFNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    self.navigationBar.barTintColor = [UIColor colorWithHex:0xfdb731]; // 导航条颜色修改
    self.navigationBar.barStyle = UIBarStyleBlack;
    
    if ([self respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.interactivePopGestureRecognizer.delegate = self;
    }
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, 20, 30);
        [btn setImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
        [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
        
        viewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
        
    }
    [super pushViewController:viewController animated:animated];
    
    
}
- (void)back {
    [self popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    
    //解决： 侧滑返回到根视图后再侧滑返回时页面假死
    if (gestureRecognizer == self.interactivePopGestureRecognizer) {
        if (self.viewControllers.count == 1) {
            return NO;
        } else {
            return YES;
        }
    }
    return YES;
}


/**
 修复A控制器隐藏导航栏，B控制器显示导航控制器，B控制器被侧滑时出现导航栏消失的Bug
 
 @return 修复侧滑导致导航栏显示的问题
 */
-(UIViewController *)childViewControllerForStatusBarStyle{
    return self.visibleViewController;
}


@end
