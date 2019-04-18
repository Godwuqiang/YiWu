//
//  DTFNoticeVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DTFNoticeVC : UIViewController


/**
 同意选中按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *agreeSelectButton;

/**
 type: 1:异地安置登记  2:探亲登记  3:外派人员登记
 */
@property (nonatomic ,strong) NSString * type;


@end
