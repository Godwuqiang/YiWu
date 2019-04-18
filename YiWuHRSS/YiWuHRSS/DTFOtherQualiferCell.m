//
//  DTFOtherQualiferCell.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/9/25.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFOtherQualiferCell.h"
#import "DTFOtherQualiferBean.h"

@implementation DTFOtherQualiferCell

- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.lastNameLabel.clipsToBounds = YES;
    self.lastNameLabel.layer.cornerRadius = 25;
    self.lastNameLabel.layer.borderColor = [UIColor colorWithRed:253/255.0 green:183/255.0 blue:49/255.0 alpha:1.0].CGColor;
    self.lastNameLabel.layer.borderWidth = 1;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setQualiferBean:(DTFOtherQualiferBean *)qualiferBean{
    
    _qualiferBean = qualiferBean;
    self.nameLabel.text = _qualiferBean.name;
    self.insureNumberLabel.text = _qualiferBean.shbzh;
    self.lastNameLabel.text = [_qualiferBean.name substringToIndex:1];
    
    //是否处于批量删除状态
    if(_qualiferBean.isDeleting){
        self.ViewLeading.constant = 50;
        self.viewTrailing.constant = -50;
    }else{
        self.ViewLeading.constant = 0;
        self.viewTrailing.constant = 0;
    }
    
    //是否处于选中状态
    if(_qualiferBean.isSelected){
        self.selectButton.selected = YES;
    }else{
        self.selectButton.selected = NO;
    }
    
}

@end
