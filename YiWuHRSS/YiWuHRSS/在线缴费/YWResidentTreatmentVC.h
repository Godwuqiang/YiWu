//
//  YWResidentTreatmentVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/25.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWResidentTreatmentVC : UIViewController

/** 姓名 */
@property (nonatomic,strong) NSString * name;
/** 身份证号 */
@property (nonatomic,strong) NSString * shbzh;
/** 年份 */
@property (nonatomic,strong) NSString * year;
/** 参保 */
@property (nonatomic,strong) NSString * cblx;
/** 档次标志 */
@property (nonatomic,strong) NSString * dzbz;
/** 参保类型 */
@property (nonatomic,strong) NSString * type;
/** 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
/** 身份证号 */
@property (weak, nonatomic) IBOutlet UILabel *idNumberLabel;
/** 年份 */
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
/** 到账状态 */
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
/** 类型 */
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
/** 确认参保按钮 */
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

/** 参保类型字典 */
@property (nonatomic,strong) NSDictionary * cblxDict;

/** 是否来自在线付款 */
@property (nonatomic,assign) BOOL isFromGotoPay;


@end
