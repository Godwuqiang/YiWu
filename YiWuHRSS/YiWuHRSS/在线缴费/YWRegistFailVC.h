//
//  YWRegistFailVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWRegistFailVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *resonString;
@property (strong, nonatomic) NSString  *reson;


/** 是否是大病医保 */
@property (nonatomic,assign) BOOL isSeriousIll;
/** 城乡居民医疗 */
@property (nonatomic,assign) BOOL isResidentTreatment;
/** 城乡居民养老 */
@property (nonatomic,assign) BOOL isResidentPension;

@end
