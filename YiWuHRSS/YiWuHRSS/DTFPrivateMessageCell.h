//
//  DTFPrivateMessageCell.h
//  YiWuHRSS
//
//  Created by Dabay on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>



@class DTFPrivateMsgVC,DTFPrivateMessageBean;


@interface DTFPrivateMessageCell : UITableViewCell


@property (weak, nonatomic) IBOutlet UIView *cellDeleteView;//cell中的删除View
@property (weak, nonatomic) IBOutlet UIButton *cellDeleteButton;//cell中的删除按钮


@property (weak, nonatomic) IBOutlet UIImageView *separatorLineImageView;



@property (weak, nonatomic) IBOutlet UILabel *timeLabel;//时间的label
@property (weak, nonatomic) IBOutlet UILabel *noticeTitleLabel;//通知的标题label
@property (weak, nonatomic) IBOutlet UIButton *foldButton;//折叠消息的Button
@property (weak, nonatomic) IBOutlet UILabel *noticeDetailLabel;//通知详情label
@property (weak, nonatomic) IBOutlet UIView *noticeContentView;//通知的内容的View
@property (weak, nonatomic) IBOutlet UIView *cellContentView;//cell上面覆盖的一层总View
@property (weak, nonatomic) IBOutlet UIImageView *bgImageView;//背景图片
@property (weak, nonatomic) IBOutlet UIButton *editButton;//批量编辑时选中的按钮
@property (weak, nonatomic) IBOutlet UIImageView *readStatusImageView;



@property (nonatomic ,strong) DTFPrivateMsgVC * privateMessageVC;//tabelView控制器
@property (nonatomic ,strong) DTFPrivateMessageBean * messageBean;//消息的数据模型
@property (nonatomic ,assign) BOOL isEditing;//在处于编辑状态
@property (nonatomic ,strong) NSIndexPath  * indexPath;//在cell中的编号


@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellContentViewLeadingConstraints;//总的View距离左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *cellContentViewTrainlingConstraints;//总的View距离左边的距离
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noticeViewHeight;//通知的View的高度




+(instancetype)privateMassageCell;



@end
