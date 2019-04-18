//
//  YWRegistAndPaymentVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 在线缴费
 
 - EPRegistAndPaymentSeriousIllness: 大病保险
 - EPRegistAndPaymentResidentTreatment: 城乡居民医疗
 - EPRegistAndPaymentResidentPension: 城乡居民养老
 */
typedef NS_ENUM(NSInteger,EPRegistAndPayment)
{
    EPRegistAndPaymentSeriousIllness = 1,
    EPRegistAndPaymentResidentTreatment = 2,
    EPRegistAndPaymentResidentPension = 3,
};









@interface YWRegistAndPaymentVC : UIViewController
/** 参保登记 */
@property (weak, nonatomic) IBOutlet UIView *registeView;
/** 在线缴费 */
@property (weak, nonatomic) IBOutlet UIView *paymentView;
/** 背景图片 */
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;

/** 在线缴费-类型 */
@property (nonatomic,assign) EPRegistAndPayment registAndPaymentType;


@end





