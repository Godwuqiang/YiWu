//
//  YWQueryWIthYearVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>



@interface YWQueryWIthYearVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *nameView;
@property (weak, nonatomic) IBOutlet UIView *idNumberView;
@property (weak, nonatomic) IBOutlet UIView *yearView;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;
@property (weak, nonatomic) IBOutlet UITextField *idNumberTextField;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;

/** 是否大病保险 */
@property (nonatomic,assign) BOOL isSeriousIllness;
/** 是否居民医疗 */
@property (nonatomic,assign) BOOL isResidentTreatment;
/** 是否居民养老 */
@property (nonatomic,assign) BOOL isJMYangLao;
/** 是否在线缴费 */
@property (nonatomic,assign) BOOL isOnlinePay;

@end
