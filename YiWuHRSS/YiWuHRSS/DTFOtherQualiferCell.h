//
//  DTFOtherQualiferCell.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/25.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DTFOtherQualiferBean;

@interface DTFOtherQualiferCell : UITableViewCell

/** 姓 */
@property (weak, nonatomic) IBOutlet UILabel *lastNameLabel;

/** 姓名 */
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

/** 社会保障号 */
@property (weak, nonatomic) IBOutlet UILabel *insureNumberLabel;
/** 选中的按钮 */
@property (weak, nonatomic) IBOutlet UIButton *selectButton;

/** 整个View离左边的间距约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *ViewLeading;
/** 整个View离右边的间距约束 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *viewTrailing;


/** 其他认证人员数据模型 */
@property (strong, nonatomic) DTFOtherQualiferBean * qualiferBean;

@end
