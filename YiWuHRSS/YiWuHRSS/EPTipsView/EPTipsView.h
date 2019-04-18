//
//  EPTipsView.h
//  EPTools
//
//  Created by Donkey-Tao on 2018/1/9.
//  Copyright © 2018年 Donkey-Tao. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 EP提示的类型

 - EPTipsTypeSuccess: 成功提示：标题+详情+底部一个按钮
 - EPTipsTypeFailed: 失败提示：标题+详情+底部一个按钮
 */
typedef NS_ENUM(NSInteger,EPTipsType)
{
    EPTipsTypeSuccess   = 1,
    EPTipsTypeError  = 2,
};

/** 成功或者失败提示框下面按钮的点击事件回调 */
typedef void(^confirmBlock)(void);
/** 底部左边按钮的回调 */
typedef void(^leftButtonBlock)(void);
/** 底部右边按钮的回调 */
typedef void(^rightButtonBlock)(void);









@interface EPTipsView : UIView



#pragma mark - EPTipsView的属性

/** 成功或者失败提示下面按钮的点击事件回调 */
@property (nonatomic,strong) void (^confirmBlock)(void);
/** 成功或者失败提示下面按钮的点击事件回调 */
@property (nonatomic,strong) void (^leftButtonBlock)(void);
/** 成功或者失败提示下面按钮的点击事件回调 */
@property (nonatomic,strong) void (^rightButtonBlock)(void);
/** 底部按钮的颜色 */
@property (nonatomic,strong) UIColor  * baseButtonColor;
/** 提示标题的颜色 */
@property (nonatomic,strong) UIColor  * basetipsTitleColor;
/** 提示详情的的颜色 */
@property (nonatomic,strong) UIColor  * baseDetailsColor;
/** 底部左边按钮的颜色 */
@property (nonatomic,strong) UIColor  * leftButtonColor;
/** 底部右边按钮的颜色 */
@property (nonatomic,strong) UIColor  * rightButtonColor;


#pragma mark - EPTipsView的方法

/**
 EPTipsView的单例

 @return EPTipsView的单例对象
 */
+ (EPTipsView *)sharedTipsView;


/**
 显示带有成功图标的提示框：成功图标+提示
 
 @param title 提示成功的信息
 @param view 即将显示在View上
 */
+ (void)ep_showSuccessViewWithTitle:(NSString *)title toView:(UIView *)view;


/**
 显示带有失败图标的提示框：失败图标+提示
 
 @param title 提示失败的信息
 @param view 即将显示在View上
 */
+ (void)ep_showErrorViewWithTitle:(NSString *)title toView:(UIView *)view;


/**
 显示带有成功或者失败图标的提示框：图标+提示
 
 @param type 提示的类型
 @param title 提示的信息
 @param view 即将显示在View上
 */
+(void)ep_showTipsWithType:(EPTipsType)type
                     title:(NSString *)title
                    toView:(UIView *)view;



/**
 显示成功或者错误提示并展示相关的详情：图标+提示+提示详情+底部按钮（一个）

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
            confirmBlock:(confirmBlock)confirmBlock;



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
           rightButtonBlock:(rightButtonBlock)rightButtonBlock;

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
            buttonBlock:(leftButtonBlock)buttonBlock;



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
           rightButtonBlock:(rightButtonBlock)rightButtonBlock;

@end
