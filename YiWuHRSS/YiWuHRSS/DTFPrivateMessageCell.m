//
//  DTFPrivateMessageCell.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFPrivateMessageCell.h"
#import "DTFPrivateMsgVC.h"
#import "DTFPrivateMessageBean.h"

@interface DTFPrivateMessageCell()

@property(nonatomic,strong) UIView * deleteView;

@end

@implementation DTFPrivateMessageCell

+(instancetype)privateMassageCell{
    return  [[[NSBundle mainBundle] loadNibNamed:@"DTFPrivateMessageCell" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.timeLabel.layer.cornerRadius = 5.0;
    self.timeLabel.clipsToBounds = YES;
    [self.cellDeleteButton setImageEdgeInsets:UIEdgeInsetsMake(5, 0, 0, 10)];
    [self.cellDeleteButton setTitleEdgeInsets:UIEdgeInsetsMake(5, 10, 0, 0)];

    

}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}


/**
 设置Cell中的数据

 @param messageBean cell中内容的数据模型
 */
-(void)setMessageBean:(DTFPrivateMessageBean *)messageBean{
    
    _messageBean = messageBean;
    self.timeLabel.text = _messageBean.update_time;
    self.noticeTitleLabel.text = _messageBean.title;
    self.noticeDetailLabel.text = _messageBean.content;
    self.foldButton.selected = _messageBean.isFoldMessage;
    
    
    //1.已读与未读
    if([_messageBean.readStatus integerValue] == 1){
    
        self.readStatusImageView.hidden = YES;
    }else{
        
        self.readStatusImageView.hidden = NO;
    }
    
    //2.是否是选中的消息
    if(self.messageBean.isSelectedMessage){
    
        self.editButton.selected = YES;
    }else{
        
        self.editButton.selected = NO;
    }
    
    //3.是折叠的消息
    if(_messageBean.isFoldMessage){
        
        self.foldButton.selected = NO;
        self.noticeDetailLabel.hidden = YES;
        self.separatorLineImageView.hidden = YES;
        
        CGFloat titleHeight = [_messageBean.title getHeightBySizeOfFont:14 width:([UIScreen mainScreen].bounds.size.width-90)];
        self.noticeViewHeight.constant = titleHeight + 25;
        
        //修改背景图片
        self.bgImageView.image = [UIImage imageNamed:@"message_dialog1"];
        
    
    }else{//展开的消息
    
        self.foldButton.selected = YES;
        self.noticeDetailLabel.hidden = NO;
        self.separatorLineImageView.hidden = NO;
        
        CGFloat titleHeight = [_messageBean.title getHeightBySizeOfFont:14 width:([UIScreen mainScreen].bounds.size.width-90)];
        
        self.noticeViewHeight.constant = titleHeight + 25 + [_messageBean.content getHeightBySizeOfFont:13 width:([UIScreen mainScreen].bounds.size.width-40)] + 20 + 10;
        
        //修改背景图片
        self.bgImageView.image = [UIImage imageNamed:@"message_dialog3"];
    }
    
    
    //4.删除按钮是否显示
    
    if(_messageBean.isCellDeleteViewShow){
    
    
        self.cellDeleteButton.hidden = NO;
        self.cellDeleteView.hidden = NO;
        
        if(_messageBean.isFoldMessage){
        
            self.bgImageView.image = [UIImage imageNamed:@"message_dialog_mask1c"];
        
        }else{
        
            self.bgImageView.image = [UIImage imageNamed:@"message_dialog_mask3-1"];//message_dialog_mask3-1
        
        }
    
    }else{
        
        if(_messageBean.isFoldMessage){
            
            self.bgImageView.image = [UIImage imageNamed:@"message_dialog1"];
            
        }else{
            
            self.bgImageView.image = [UIImage imageNamed:@"message_dialog3-1"];
            
        }
    
        self.cellDeleteButton.hidden = YES;
        self.cellDeleteView.hidden = YES;
    
    }
    
    if(_messageBean.isFoldButtonHidden){
    
    
        self.foldButton.hidden =YES;
    }else{
    
    
        self.foldButton.hidden = NO;
    }
    
    
}


/**
 设置处于编辑模式的时候整个cell的内容向右偏移

 @param isEditing 正处于编辑模式
 */
-(void)setIsEditing:(BOOL)isEditing{

    _isEditing = isEditing;
    
    if(_isEditing){//编辑模式--批量操作
    
        self.cellContentViewLeadingConstraints.constant = 35;
        self.cellContentViewTrainlingConstraints.constant = -35;
    
    }else{//编辑模式--没有进入批量删除
        
        self.cellContentViewLeadingConstraints.constant = 0;
        self.cellContentViewTrainlingConstraints.constant = 0;
    
    }
}




@end
