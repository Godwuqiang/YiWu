//
//  DXBResettlementhospitalVC.h
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/4.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DXBResettlementhospitalVC : UIViewController

@property (weak, nonatomic) IBOutlet UIView *bgView;

/// 输入框底部的背景图片
@property (weak, nonatomic) IBOutlet UIImageView *input_entryImgView;



/// bgView离顶部的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bgTopConstraints;

/// 左边搜索按钮
@property (weak, nonatomic) IBOutlet UIButton *search1Btn;

/// 右边搜索按钮
@property (weak, nonatomic) IBOutlet UIButton *search2Btn;

@property (weak, nonatomic) IBOutlet UIView *lineView;


/// 输入按钮
@property (weak, nonatomic) IBOutlet UIButton *inputBtn;

/// 输入框
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

/// 没有医院时的图片
@property (weak, nonatomic) IBOutlet UIImageView *no_hospitalImgView;
/// 没有医院时的label
@property (weak, nonatomic) IBOutlet UILabel *no_hospitalLabel;

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 添加按钮
@property (weak, nonatomic) IBOutlet UIButton *addBtn;
/// 医院所在省编码
@property (nonatomic, strong) NSString *yyszs;

/// 选择的医院列表
@property (nonatomic, strong) NSMutableArray *selectedhospital;





@end
