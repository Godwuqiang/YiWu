//
//  YWPaymentOrderVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWPaymentOrderVC : UIViewController

/** 缴款金额 */
@property (nonatomic,strong) NSString * jfje;
/** 医保缴款单号 */
@property (nonatomic,strong) NSString * ybjkdh;
/** 业务类别 */
@property (nonatomic,strong) NSString * ywlb;
/** 社会保障号 */
@property (nonatomic,strong) NSString * shbzh;

@property (weak, nonatomic) IBOutlet UILabel *projectNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *orderNumerLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectButton;
@property (weak, nonatomic) IBOutlet UIView *yueView;

/** 是否是大病医保 */
@property (nonatomic,assign) BOOL isSeriousIll;
/** 城乡居民医疗 */
@property (nonatomic,assign) BOOL isResidentTreatment;
/** 城乡居民养老 */
@property (nonatomic,assign) BOOL isResidentPension;


@end
