//
//  YWRegistZMVC.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/5/20.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YWRegistZMVC : UIViewController

/** 姓名 */
@property (nonatomic,strong) NSString * name;
/** 社会保障号 */
@property (nonatomic,strong) NSString * shbzh;
/** 手机号 */
@property (nonatomic,strong) NSString * appMobile;
/** 密码 */
@property (nonatomic,strong) NSString * password;

/** 认证类型21：iOS实人认证 */
@property (nonatomic,strong) NSString * business_types;

/** biz_no */
@property (nonatomic,strong) NSString * biz_no;
/** transaction_id */
@property (nonatomic,strong) NSString * transaction_id;
/** serNum */
@property (nonatomic,strong) NSString * serNum;

@end
