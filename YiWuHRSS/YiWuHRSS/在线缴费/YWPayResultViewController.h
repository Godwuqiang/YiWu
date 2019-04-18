//
//  YWPayResultViewController.h
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/11/14.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YWPayResultViewController : UIViewController

/** 是否大病保险 */
@property (nonatomic,assign) BOOL  isSeariousIll;
/** 是否居民医疗 */
@property (nonatomic,assign) BOOL  isResidentTreatment;

/** 是否成功 */
@property (nonatomic,assign) BOOL  succeed;
/** 具体结果 */
@property (nonatomic,assign) NSString * reason;

@end

NS_ASSUME_NONNULL_END
