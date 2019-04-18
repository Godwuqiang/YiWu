//
//  YWSeriousIllnessVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWSeriousIllnessVC : UIViewController

/** 姓名 */
@property (nonatomic,strong) NSString * name;
/** 身份证号 */
@property (nonatomic,strong) NSString * shbzh;
/** 年份 */
@property (nonatomic,strong) NSString * year;
/** 参保年份 */
@property (nonatomic,strong) NSString * cblx;
/** 到账状态 */
@property (nonatomic,strong) NSString * dzbz;
/** 缴费档次 */
@property (nonatomic,strong) NSString * jfdc;
/** 缴费档次id */
@property (nonatomic,strong) NSString * jfdcid;
/** 已缴金额 */
@property (nonatomic,strong) NSString * yjje;
/** 未缴金额 */
@property (nonatomic,strong) NSString * wjje;
/** 缴费档次字典 */
@property (nonatomic,strong) NSDictionary * jfdcDict;

/** 来自在线缴费 */
@property (nonatomic,assign) BOOL isFromGotoPay;

@end
