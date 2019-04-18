//
//  DXBAddMaterialVC.h
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/6.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>


@class DTFRegistModel;

@interface DXBAddMaterialVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *label;


@property (weak, nonatomic) IBOutlet UIView *bgView;


@property (weak, nonatomic) IBOutlet UILabel *attentionLabel;


@property (weak, nonatomic) IBOutlet UIButton *hukouButton;

@property (nonatomic, strong) NSString *noPotoMessage;


/** 登记的数据模型 */
@property (nonatomic,strong) DTFRegistModel * registModel;

@end
