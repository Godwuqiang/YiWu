//
//  NewsCell.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MsgBean.h"

@interface NewsCell : UITableViewCell

@property (nonatomic, strong) UIImageView *editIcon; // 编辑图标
@property (nonatomic, assign)    BOOL     isEdit;    // 是否处于编辑状态
@property (nonatomic, assign)    BOOL     isChoosed; // 是否选中
@property (nonatomic, strong) UIButton    *deleteBtn; // 删除按钮

//@property (nonatomic, strong) UIView *bgView;     //除了标签圆点外的区域
//
//@property (nonatomic, strong) UIImageView *point; // 小红点
//@property (nonatomic, strong) UILabel *titleLB;   // 新闻标题
//@property (nonatomic, strong) UILabel *timeLB;    // 时间标题
//@property (nonatomic, strong) UIImageView *arrow; // 箭头
@property (nonatomic, assign) BOOL isDelete;  // 是否删除

@property (nonatomic, strong)  MsgBean    *msgbean;

@end
