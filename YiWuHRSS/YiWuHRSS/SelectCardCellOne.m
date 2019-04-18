//
//  SelectCardCellOne.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/10/31.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "SelectCardCellOne.h"

@implementation SelectCardCellOne

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

//- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self setUpCell];
//    }
//    return self;
//}
//
//- (void) setUpCell{
//    __weak __typeof(self) weakSelf = self;
//    
//    int offsize,off,font1,font2,imgwidth,imgheight,titleoffsetl,titleoffsett,bgCardImgl,bgCardImgr;
//    
//    //区别屏幕尺寸
//    if ( SCREEN_HEIGHT > 667) //6p
//    {
//        offsize = 10;
//        off = 10;
//        font1 = 14;
//        font2 = 13;
//        imgwidth = 90;
//        imgheight = 90;
//        titleoffsetl = 15;
//        titleoffsett = 15;
//        bgCardImgl = 15;
//        bgCardImgr = -35;
//    }
//    else if (SCREEN_HEIGHT > 568)//6
//    {
//        offsize = 10;
//        off = 10;
//        font1 = 13;
//        font2 = 12;
//        imgwidth = 80;
//        imgheight = 80;
//        titleoffsetl = 15;
//        titleoffsett = 15;
//        bgCardImgl = 15;
//        bgCardImgr = -30;
//    }
//    else if (SCREEN_HEIGHT > 480)//5s
//    {
//        offsize = 10;
//        off = 10;
//        font1 = 12;
//        font2 = 11;
//        imgwidth = 70;
//        imgheight = 80;
//        titleoffsetl = 10;
//        titleoffsett = 10;
//        bgCardImgl = 15;
//        bgCardImgr = -5;
//    }
//    else //3.5寸屏幕
//    {
//        offsize = 10;
//        off = 7;
//        font1 = 11;
//        font2 = 10;
//        imgwidth = 60;
//        imgheight = 70;
//        titleoffsetl = 10;
//        titleoffsett = 10;
//        bgCardImgl = 15;
//        bgCardImgr = -15;
//    }
//    
//    self.bgImg = [[UIImageView alloc]init];
//    [self.contentView addSubview:self.bgImg];
//    [self.bgImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.contentView.mas_top);
//        make.left.equalTo(weakSelf.contentView.mas_left);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom);
//        make.right.equalTo(weakSelf.contentView.mas_right);
//    }];
//    
//    [self.bgImg setImage:[UIImage imageNamed:@"bg_mid1"]];
//    
//    
//    self.bgCardImg = [[UIImageView alloc]init];
//    [self.contentView addSubview:self.bgCardImg];
//    [self.bgCardImg mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.equalTo(weakSelf.contentView.mas_top).offset(10);
//        make.left.equalTo(weakSelf.contentView.mas_left).offset(bgCardImgl);
//        make.bottom.equalTo(weakSelf.contentView.mas_bottom).offset(-10);
//        make.right.equalTo(weakSelf.contentView.mas_right).offset(bgCardImgr);
//    }];
//    
//    [self.bgCardImg setImage:[UIImage imageNamed:@"bg_card"]];
//    
//    self.Title = [[UILabel alloc] init];
//    [self.contentView addSubview:self.Title];
//    self.Title.font = [UIFont systemFontOfSize:font1];
//    self.Title.text = @"宁波市社会保障卡";
//    self.Title.textColor = [UIColor colorWithHex:0x333333];
//    [self.Title mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(weakSelf.bgCardImg.mas_left).offset(titleoffsetl);
//        make.top.equalTo(weakSelf.bgCardImg.mas_top).offset(titleoffsett);
//    }];
//
//}

@end
