//
//  EPTipsView.m
//  EPTools
//
//  Created by Donkey-Tao on 2018/1/9.
//  Copyright © 2018年 Donkey-Tao. All rights reserved.
//

#import "EPTipsView.h"


@interface EPTipsView ()

/** 提示蒙版View */
@property (nonatomic,strong) UIView * hudView;
/** 提示View */
@property (nonatomic,strong) UIView * tipsView;

@end

@implementation EPTipsView


#pragma mark - 获取EPTipsView的单例对象

/** EPTipsView的单例 */
+ (EPTipsView *)sharedTipsView {
    
    static dispatch_once_t  onceToken;
    static EPTipsView * setSharedInstance;
    dispatch_once(&onceToken, ^{//线程锁
        setSharedInstance = [[EPTipsView alloc] init];
    });
    return setSharedInstance;
}


/**
 显示带有成功图标的提示框
 
 @param title 提示成功的信息
 @param view 即将显示在View上
 */
+ (void)ep_showSuccessViewWithTitle:(NSString *)title toView:(UIView *)view{
    
    
    [self ep_showTipsWithType:EPTipsTypeSuccess title:title toView:view];
}


/**
 显示带有失败图标的提示框：失败图标+提示
 
 @param title 提示失败的信息
 @param view 即将显示在View上
 */
+ (void)ep_showErrorViewWithTitle:(NSString *)title toView:(UIView *)view{
    [self ep_showTipsWithType:EPTipsTypeError title:title toView:view];
}

/**
 显示带有成功图标的提示框

 @param type 提示的类型
 @param title 提示的信息
 @param view 即将显示在View上
 */
+(void)ep_showTipsWithType:(EPTipsType)type
                  title:(NSString *)title
                 toView:(UIView *)view{
    
    UIView * hudView = [[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    [view addSubview:hudView];
    
    CGFloat width = hudView.frame.size.width * 0.5866;
    CGFloat height = width * 0.575;
    CGRect frame = CGRectMake(0.0, 0.0, width, height);
    UIView * successView = [[UIView alloc]initWithFrame:frame];
    successView.backgroundColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.9];
    successView.clipsToBounds = YES;
    successView.layer.cornerRadius = 12.0;
    CGPoint point = CGPointMake(hudView.center.x, hudView.center.y*0.8);
    successView.center = point;//hudView.center;
    [hudView addSubview:successView];
    
    
    //获取图片资源
    static NSBundle *sourceBundle = nil;
    if (sourceBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        sourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[EPTipsView class]] pathForResource:@"EPTipsView" ofType:@"bundle"]];
    }
    
    
    UIImageView * imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_success"]];
    if(type == EPTipsTypeSuccess){
        imageView.image=[[UIImage imageWithContentsOfFile:[sourceBundle pathForResource:@"icon_success@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else{
        imageView.image=[[UIImage imageWithContentsOfFile:[sourceBundle pathForResource:@"icon_fail@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    imageView.frame = CGRectMake(width/2.0 - 27, 20, 54, 54);
    [successView addSubview:imageView];
    
    UILabel * titleLabel = [[UILabel alloc]init];
    titleLabel.frame = CGRectMake(0, 20 + 54 +15, width, 21);
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    titleLabel.font = [UIFont systemFontOfSize:15.0];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [successView addSubview:titleLabel];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(3.0*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [hudView removeFromSuperview];
        hudView.hidden = YES;
    });
}



#pragma mark - 显示成功或者错误提示并展示相关的详情：图标+提示标题+提示详情+底部按钮（一个）


/**
 显示成功或者错误提示并展示相关的详情：图标+提示标题+提示详情+底部按钮（一个）
 
 @param tips 提示标题
 @param details 成功或者错误详情
 @param buttonText 按钮的文本内容
 @param type EPTipsTypeSuccess：成功 EPTipsTypeFailed：失败
 @param view 显示在View上
 @param confirmBlock 点击提示下面按钮的回调
 @return HUDView
 */
+ (UIView *)ep_showTipsView:(NSString *)tips
                 details:(NSString *)details
              buttonText:(NSString *)buttonText
                    type:(EPTipsType)type
                  toView:(UIView *)view
            confirmBlock:(confirmBlock)confirmBlock{
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat hudWidth = screenFrame.size.width * 0.72;       //HUD的宽度,宽度根据不同手机而不同
    CGFloat detailsHeight = [self getHeightByString:details SizeOfFont:12.0 width:(hudWidth - 20.0)];
    CGFloat hudHeight = 15.0 + 55 + 10 +20 +10 + detailsHeight + 10 + 1 + 44;
    
    CGRect frame =  CGRectMake(screenFrame.size.width * 0.14, screenFrame.size.height *0.28, hudWidth, hudHeight);
    UIView * tipsView = [[UIView alloc]initWithFrame:frame];
    tipsView.backgroundColor = [UIColor whiteColor];
    tipsView.clipsToBounds = YES;
    tipsView.layer.cornerRadius = 15.0;
    [EPTipsView sharedTipsView].tipsView = tipsView;
    
    //获取图片资源
    static NSBundle *sourceBundle = nil;
    if (sourceBundle == nil) {
        // 这里不使用mainBundle是为了适配pod 1.x和0.x
        sourceBundle = [NSBundle bundleWithPath:[[NSBundle bundleForClass:[EPTipsView class]] pathForResource:@"EPTipsView" ofType:@"bundle"]];
    }
    
    //UIImageView
    CGRect imageFrame = CGRectMake(frame.size.width * 0.4, frame.size.height *0.08, frame.size.width * 0.198, frame.size.width * 0.198);
    UIImageView * imageView = [[UIImageView alloc]initWithFrame:imageFrame];
    if(type == EPTipsTypeSuccess){
        imageView.image=[[UIImage imageWithContentsOfFile:[sourceBundle pathForResource:@"icon_success@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }else{
        imageView.image=[[UIImage imageWithContentsOfFile:[sourceBundle pathForResource:@"icon_fail@2x" ofType:@"png"]] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        imageView.image = [imageView.image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    [tipsView addSubview:imageView];
    
    
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(0,15.0 + 55 + 10, frame.size.width, 30);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = tips;
    if([EPTipsView sharedTipsView].basetipsTitleColor == nil){
        tipsLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }else{
        tipsLabel.textColor = [EPTipsView sharedTipsView].basetipsTitleColor;
    }
    
    tipsLabel.font = [UIFont systemFontOfSize:15.0];
    [tipsView addSubview:tipsLabel];
    
    
    //DetailsLabel--错误详情
    CGRect detailsFrame = CGRectMake(10, 15.0 + 55 + 10 +20 +10, (hudWidth - 20.0), detailsHeight);
    UILabel *detailsLabel = [[UILabel alloc]initWithFrame:detailsFrame];
    detailsLabel.text = details;
    detailsLabel.numberOfLines = 0;
    detailsLabel.textAlignment = NSTextAlignmentCenter;
    if([EPTipsView sharedTipsView].baseDetailsColor == nil){
        detailsLabel.textColor = [UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0];
    }else{
        detailsLabel.textColor = [EPTipsView sharedTipsView].baseDetailsColor;
    }
    
    detailsLabel.font = [UIFont systemFontOfSize:12.0];
    [tipsView addSubview:detailsLabel];
    
    
    //分割线
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, frame.size.height * 0.80, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView];
    
    //按钮
    UIButton * reInputButton = [UIButton buttonWithType:UIButtonTypeCustom];
    reInputButton.frame = CGRectMake(0, frame.size.height * 0.80 + 1, frame.size.width, frame.size.height *0.20);
    [reInputButton setTitle:buttonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].baseButtonColor ==nil){
        [reInputButton setTitleColor:[UIColor colorWithRed:253.0/255.0 green:183.0/255.0 blue:49.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [reInputButton setTitleColor:[EPTipsView sharedTipsView].baseButtonColor forState:UIControlStateNormal];
    }
        
    
    [reInputButton addTarget:self action:@selector(confirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:reInputButton];
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:tipsView];
    [view addSubview:hudView];
    
    //设置Block回调
    [EPTipsView sharedTipsView].confirmBlock = ^{
        confirmBlock();
    };
    [EPTipsView ep_startAnimationWithView:[EPTipsView sharedTipsView].tipsView];
    [EPTipsView sharedTipsView].hudView = hudView;
    return [EPTipsView sharedTipsView].hudView;
}

+(void)confirmButtonClick:(UIButton *)confirmButton{
    
    [EPTipsView ep_hideTipsWithView:[EPTipsView sharedTipsView].tipsView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[EPTipsView sharedTipsView].hudView removeFromSuperview];
        [EPTipsView sharedTipsView].hudView.hidden = YES;
        [EPTipsView sharedTipsView].confirmBlock();
    });
}


#pragma mark - 弹出选择框：提示的内容+底部两个按钮

/**
 弹出选择框：提示的内容+底部两个按钮
 
 @param tips 提示
 @param leftButtonText 底部左边按钮
 @param rightButtonText 底部右边按钮
 @param view 即将显示在View上
 @param leftButtonBlock 底部左边按钮的回调
 @param rightButtonBlock 底部右边按钮的回调
 @return 返回弹出框
 */
+(UIView *)ep_showAlertView:(NSString *)tips
             leftButtonText:(NSString *)leftButtonText
            rightButtonText:(NSString *)rightButtonText
                     toView:(UIView *)view
            leftButtonBlock:(leftButtonBlock)leftButtonBlock
           rightButtonBlock:(rightButtonBlock)rightButtonBlock{
    
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat hudWidth = screenFrame.size.width * 0.72;       //HUD的宽度,宽度根据不同手机而不同
    CGFloat detailsHeight = [self getHeightByString:tips SizeOfFont:15.0 width:(hudWidth - 20.0)];
    CGFloat hudHeight = 20.0 + detailsHeight + 20 + 1 + 45;
    
    CGRect frame =  CGRectMake(screenFrame.size.width * 0.14, screenFrame.size.height *0.28, hudWidth, hudHeight);
    UIView * tipsView = [[UIView alloc]initWithFrame:frame];
    tipsView.backgroundColor = [UIColor whiteColor];
    tipsView.clipsToBounds = YES;
    tipsView.layer.cornerRadius = 15.0;
    [EPTipsView sharedTipsView].tipsView = tipsView;
    
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(10.0,20.0,(hudWidth - 20.0), detailsHeight);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = tips;
    tipsLabel.numberOfLines = 0;
    if([EPTipsView sharedTipsView].baseDetailsColor == nil){
        tipsLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }else{
        tipsLabel.textColor = [EPTipsView sharedTipsView].baseDetailsColor;
    }
    
    tipsLabel.font = [UIFont systemFontOfSize:15.0];
    [tipsView addSubview:tipsLabel];
    
    //分割线-横
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 20.0 + detailsHeight + 20, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView];
    
    
    //左边按钮
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 20.0 + detailsHeight + 20 + 1, (frame.size.width - 1.0)/2, 45.0);
    [leftButton setTitle:leftButtonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].leftButtonColor ==nil){
        [leftButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [leftButton setTitleColor:[EPTipsView sharedTipsView].leftButtonColor forState:UIControlStateNormal];
    }
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:leftButton];
    
    //分割线-竖
    UIView *seperatorView2 = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width - 1.0)/2.0, 20.0 + detailsHeight + 20 + 1, 1, 45)];
    seperatorView2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView2];
    
    //右边按钮
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake((frame.size.width - 1.0)/2 +1, 20.0 + detailsHeight + 20 + 1, (frame.size.width - 1.0)/2, 45.0);
    [rightButton setTitle:rightButtonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].rightButtonColor ==nil){
        [rightButton setTitleColor:[UIColor colorWithRed:253.0/255.0 green:183.0/255.0 blue:49.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [rightButton setTitleColor:[EPTipsView sharedTipsView].rightButtonColor forState:UIControlStateNormal];
    }
    
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:rightButton];
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:tipsView];
    [view addSubview:hudView];
    

    
    //设置Block回调
    [EPTipsView sharedTipsView].leftButtonBlock = ^{
        leftButtonBlock();
    };
    [EPTipsView sharedTipsView].rightButtonBlock = ^{
        rightButtonBlock();
    };
    
    [EPTipsView ep_startAnimationWithView:[EPTipsView sharedTipsView].tipsView];

   
    [EPTipsView sharedTipsView].hudView = hudView;
    return [EPTipsView sharedTipsView].hudView;
    
}

+(void)leftButtonClick:(UIButton *)leftButton{
    
    
    [EPTipsView ep_hideTipsWithView:[EPTipsView sharedTipsView].tipsView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[EPTipsView sharedTipsView].hudView removeFromSuperview];
        [EPTipsView sharedTipsView].hudView.hidden = YES;
        [EPTipsView sharedTipsView].leftButtonBlock();
    });
    
    
}

+(void)rightButtonClick:(UIButton *)rightButton{
    
    [EPTipsView ep_hideTipsWithView:[EPTipsView sharedTipsView].tipsView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[EPTipsView sharedTipsView].hudView removeFromSuperview];
        [EPTipsView sharedTipsView].hudView.hidden = YES;
        [EPTipsView sharedTipsView].rightButtonBlock();
    });
}


/**
 弹出选择框：提示的内容+底部一个按钮
 
 @param tips 提示
 @param buttonText 底部左边按钮
 @param view 即将显示在View上
 @param buttonBlock 底部按钮的回调
 @return 返回弹出框
 */
+(UIView *)ep_showAlertView:(NSString *)tips
                 buttonText:(NSString *)buttonText
                     toView:(UIView *)view
                buttonBlock:(leftButtonBlock)buttonBlock{
    
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat hudWidth = screenFrame.size.width * 0.72;       //HUD的宽度,宽度根据不同手机而不同
    CGFloat detailsHeight = [self getHeightByString:tips SizeOfFont:15.0 width:(hudWidth - 20.0)];
    CGFloat hudHeight = 20.0 + detailsHeight + 20 + 1 + 45;
    
    CGRect frame =  CGRectMake(screenFrame.size.width * 0.14, screenFrame.size.height *0.28, hudWidth, hudHeight);
    UIView * tipsView = [[UIView alloc]initWithFrame:frame];
    tipsView.backgroundColor = [UIColor whiteColor];
    tipsView.clipsToBounds = YES;
    tipsView.layer.cornerRadius = 10.0;
    [EPTipsView sharedTipsView].tipsView = tipsView;
    
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(10.0,20.0,(hudWidth - 20.0), detailsHeight);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = tips;
    tipsLabel.numberOfLines = 0;
    if([EPTipsView sharedTipsView].baseDetailsColor == nil){
        tipsLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }else{
        tipsLabel.textColor = [EPTipsView sharedTipsView].baseDetailsColor;
    }
    
    tipsLabel.font = [UIFont systemFontOfSize:15.0];
    [tipsView addSubview:tipsLabel];
    
    //分割线-横
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 20.0 + detailsHeight + 20, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView];
    
    
    //左边按钮
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 20.0 + detailsHeight + 20 + 1, frame.size.width , 45.0);
    [leftButton setTitle:buttonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].leftButtonColor ==nil){
        [leftButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [leftButton setTitleColor:[EPTipsView sharedTipsView].leftButtonColor forState:UIControlStateNormal];
    }
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [leftButton addTarget:self action:@selector(comfirmButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:leftButton];
    
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:tipsView];
    [view addSubview:hudView];
    
    
    
    //设置Block回调
    [EPTipsView sharedTipsView].confirmBlock = ^{
        buttonBlock();
    };
 
    [EPTipsView ep_startAnimationWithView:[EPTipsView sharedTipsView].tipsView];
    
    
    [EPTipsView sharedTipsView].hudView = hudView;
    return [EPTipsView sharedTipsView].hudView;
}

+(void)comfirmButtonClick:(UIButton *)comfirmButton{
    
    [EPTipsView ep_hideTipsWithView:[EPTipsView sharedTipsView].tipsView];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,(int64_t)(0.5*NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [[EPTipsView sharedTipsView].hudView removeFromSuperview];
        [EPTipsView sharedTipsView].hudView.hidden = YES;
        [EPTipsView sharedTipsView].confirmBlock();
    });
}



/**
 隐藏tipsView

 @param view tipsView(需要隐藏的View)
 */
+ (void)ep_hideTipsWithView:(UIView *)view{
    
    CGRect viewFrame = view.frame;

    view.frame = viewFrame;
    viewFrame.origin.y+=1000;
    
    //beginAnimations表示此后的代码要"参与到"动画中
    [UIView beginAnimations:nil context:nil];
    
    //设置动画时长
    [UIView setAnimationDuration:0.5];
    
    //修改按钮的frame
    view.frame = viewFrame;
    
    //commitAnimations,将beginAnimation之后的所有动画提交并生成动画
    [UIView commitAnimations];

}


/** start animation */
+(void)ep_startAnimationWithView:(UIView *)view{
    
    CGRect viewFrame = view.frame;
    viewFrame.origin.y -= 500;
    view.frame = viewFrame;
    viewFrame.origin.y+=500;
    
    //beginAnimations表示此后的代码要"参与到"动画中
    [UIView beginAnimations:nil context:nil];
    
    //设置动画时长
    [UIView setAnimationDuration:0.5];
    
    //修改按钮的frame
    view.frame = viewFrame;
    
    //commitAnimations,将beginAnimation之后的所有动画提交并生成动画
    [UIView commitAnimations];
    
}


/**
 宽度固定 计算字符串的高度

 @param string 字符串
 @param size 字体大小
 @param width 固定的宽度
 @return 计算出的字符串的高度
 */
+ (CGFloat)getHeightByString:(NSString *)string SizeOfFont:(CGFloat)size width:(CGFloat)width{
    CGRect frame = [string boundingRectWithSize:CGSizeMake(width, 0) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:size]} context:nil];
    return frame.size.height;
}





/**
 弹出选择框：提示+提示的详情+底部两个按钮
 
 @param tips 提示
 @param details 提示的详情
 @param leftButtonText 底部左边按钮
 @param rightButtonText 底部右边按钮
 @param view 即将显示在View上
 @param leftButtonBlock 底部左边按钮的回调
 @param rightButtonBlock 底部右边按钮的回调
 @return 返回弹出框
 */
+(UIView *)ep_showAlertView:(NSString *)tips
                    details:(NSString *)details
             leftButtonText:(NSString *)leftButtonText
            rightButtonText:(NSString *)rightButtonText
                     toView:(UIView *)view
            leftButtonBlock:(leftButtonBlock)leftButtonBlock
           rightButtonBlock:(rightButtonBlock)rightButtonBlock{
    
    CGRect screenFrame = [UIScreen mainScreen].bounds;
    CGFloat hudWidth = screenFrame.size.width * 0.76;       //HUD的宽度,宽度根据不同手机而不同
    CGFloat detailsHeight = [self getHeightByString:details SizeOfFont:15.0 width:(hudWidth - 35.0)];
    CGFloat hudHeight = 20.0 + 21 + 20 + detailsHeight + 20 + 1 + 45;
    
    CGRect frame =  CGRectMake(screenFrame.size.width * 0.12, screenFrame.size.height *0.28, hudWidth, hudHeight);
    UIView * tipsView = [[UIView alloc]initWithFrame:frame];
    tipsView.backgroundColor = [UIColor whiteColor];
    tipsView.clipsToBounds = YES;
    tipsView.layer.cornerRadius = 15.0;
    [EPTipsView sharedTipsView].tipsView = tipsView;
    
    
    //TipsLabel
    CGRect tipsFrame = CGRectMake(10.0,20.0,(hudWidth - 20.0), 21);
    UILabel *tipsLabel = [[UILabel alloc]initWithFrame:tipsFrame];
    tipsLabel.textAlignment = NSTextAlignmentCenter;
    tipsLabel.text = tips;
    tipsLabel.numberOfLines = 0;
    if([EPTipsView sharedTipsView].baseDetailsColor == nil){
        tipsLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }else{
        tipsLabel.textColor = [EPTipsView sharedTipsView].baseDetailsColor;
    }
    
    tipsLabel.font = [UIFont systemFontOfSize:18.0];
    [tipsView addSubview:tipsLabel];
    
    
    //DetailsLabel
    CGRect detailsFrame = CGRectMake(17.5,20.0 +21.0+20.0,(hudWidth - 35.0), detailsHeight);
    UILabel *detailsLabel = [[UILabel alloc]initWithFrame:detailsFrame];
    detailsLabel.textAlignment = NSTextAlignmentLeft;
    detailsLabel.text = details;
    detailsLabel.numberOfLines = 0;
    if([EPTipsView sharedTipsView].baseDetailsColor == nil){
        detailsLabel.textColor = [UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1.0];
    }else{
        detailsLabel.textColor = [EPTipsView sharedTipsView].baseDetailsColor;
    }
    detailsLabel.font = [UIFont systemFontOfSize:15.0];
    [tipsView addSubview:detailsLabel];
    
    //分割线-横
    UIView *seperatorView = [[UIView alloc]initWithFrame:CGRectMake(0, 20.0 +21+20+ +detailsHeight + 20, frame.size.width, 1)];
    seperatorView.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView];
    
    
    //左边按钮
    UIButton * leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    leftButton.frame = CGRectMake(0, 20.0 + 21 +20+ detailsHeight + 20 + 1, (frame.size.width - 1.0)/2, 45.0);
    [leftButton setTitle:leftButtonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].leftButtonColor ==nil){
        [leftButton setTitleColor:[UIColor colorWithRed:153/255.0 green:153/255.0 blue:153/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [leftButton setTitleColor:[EPTipsView sharedTipsView].leftButtonColor forState:UIControlStateNormal];
    }
    leftButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [leftButton addTarget:self action:@selector(leftButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:leftButton];
    
    //分割线-竖
    UIView *seperatorView2 = [[UIView alloc]initWithFrame:CGRectMake((frame.size.width - 1.0)/2.0, 20.0 + 21 +20+detailsHeight + 20 + 1, 1, 45)];
    seperatorView2.backgroundColor = [UIColor colorWithRed:238.0/255.0 green:238.0/255.0 blue:238.0/255.0 alpha:1.0];
    [tipsView addSubview:seperatorView2];
    
    //右边按钮
    UIButton * rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    rightButton.frame = CGRectMake((frame.size.width - 1.0)/2 +1, 20.0 + 21 +20+ detailsHeight + 20 + 1, (frame.size.width - 1.0)/2, 45.0);
    [rightButton setTitle:rightButtonText forState:UIControlStateNormal];
    if([EPTipsView sharedTipsView].rightButtonColor ==nil){
        [rightButton setTitleColor:[UIColor colorWithRed:253.0/255.0 green:183.0/255.0 blue:49.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    }else{
        [rightButton setTitleColor:[EPTipsView sharedTipsView].rightButtonColor forState:UIControlStateNormal];
    }
    
    rightButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [rightButton addTarget:self action:@selector(rightButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [tipsView addSubview:rightButton];
    
    //背景HUD
    UIView * hudView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, screenFrame.size.width, screenFrame.size.height)];
    hudView.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.6];
    [hudView addSubview:tipsView];
    [view addSubview:hudView];
    
    
    
    //设置Block回调
    [EPTipsView sharedTipsView].leftButtonBlock = ^{
        leftButtonBlock();
    };
    [EPTipsView sharedTipsView].rightButtonBlock = ^{
        rightButtonBlock();
    };
    
    [EPTipsView ep_startAnimationWithView:[EPTipsView sharedTipsView].tipsView];
    
    
    [EPTipsView sharedTipsView].hudView = hudView;
    return [EPTipsView sharedTipsView].hudView;
}




@end
