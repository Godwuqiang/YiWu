//
//  YWRegistSuccessVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWRegistSuccessVC : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *negativeButton;
@property (weak, nonatomic) IBOutlet UIButton *positveButton;
/** 社会保障号 */
@property (nonatomic,strong) NSString *shbzh;
/** 姓名 */
@property (nonatomic,strong) NSString *name;
/** 年份 */
@property (nonatomic,strong) NSString *year;
/** 是否是大病医保 */
@property (nonatomic,assign) BOOL isSeriousIll;
/** 城乡居民医疗 */
@property (nonatomic,assign) BOOL isResidentTreatment;
/** 城乡居民养老 */
@property (nonatomic,assign) BOOL isResidentPension;


@end
