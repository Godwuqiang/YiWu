//
//  DTFOtherQualiferBean.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/25.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DTFOtherQualiferBean : NSObject

/** 姓名 */
@property (nonatomic ,strong) NSString * name;
/** ID */
@property (nonatomic ,strong) NSString * ID;
/** 社会保障号 */
@property (nonatomic ,strong) NSString * shbzh;
/** 是否处于正在删除状态 */
@property (nonatomic ,assign) BOOL isDeleting;
/** 是否处于选中状态 */
@property (nonatomic ,assign) BOOL isSelected;

@end
