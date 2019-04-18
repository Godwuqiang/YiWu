//
//  DXBBikeShowView.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBBikeShowView.h"

@implementation DXBBikeShowView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor colorWithHex:0xffffff];
        
        // 站点名称
        self.label_name = [[UILabel alloc] init];
        self.label_name.text = @"稠州西路站点";
        self.label_name.font = [UIFont systemFontOfSize:15];
        self.label_name.textColor = [UIColor colorWithHex:0x333333];
        [self addSubview:self.label_name];
        [self.label_name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(@12);
            make.left.equalTo(@15);
            make.width.equalTo(@200);
            make.height.equalTo(@18);
        }];
        
        // 车桩总数
        self.label_carPileTotal = [[UILabel alloc] init];
        self.label_carPileTotal.text = @"车桩总数：155";
        self.label_carPileTotal.font = [UIFont systemFontOfSize:14];
        self.label_carPileTotal.textColor = [UIColor colorWithHex:0x333333];
        [self addSubview:self.label_carPileTotal];
        [self.label_carPileTotal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_name.mas_bottom).offset(10);
            make.left.equalTo(@15);
            make.width.equalTo(@120);
            make.height.equalTo(@18);
        }];
        
        
        
        // 可借数
        UILabel *label2 = [[UILabel alloc] init];
        label2.text = @"可借数：";
        label2.font = [UIFont systemFontOfSize:14];
        label2.textAlignment = NSTextAlignmentRight;
        label2.textColor = [UIColor colorWithHex:0x333333];
        [self addSubview:label2];
        [label2 mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_name.mas_bottom).offset(10);
            make.left.equalTo(self.label_carPileTotal.mas_right).offset(20);
            make.width.equalTo(@60);
            make.height.equalTo(@18);
        }];
        
        
        // 可借数量
        self.label_availTotal = [[UILabel alloc] init];
        self.label_availTotal.text = @"--";
        self.label_availTotal.font = [UIFont systemFontOfSize:14];
        self.label_availTotal.textAlignment = NSTextAlignmentLeft;
        self.label_availTotal.textColor = [UIColor colorWithHex:0xfdb731];
        [self addSubview:self.label_availTotal];
        [self.label_availTotal mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_name.mas_bottom).offset(10);
            make.left.equalTo(label2.mas_right).offset(0);
            make.width.equalTo(@40);
            make.height.equalTo(@18);
        }];
        
        
        
        // 距离
        self.label_distance = [[UILabel alloc] init];
        self.label_distance.text = @"2.30KM";
        self.label_distance.font = [UIFont systemFontOfSize:14];
        self.label_distance.textColor = [UIColor colorWithHex:0xfdb731];
        [self addSubview:self.label_distance];
        [self.label_distance mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_name.mas_bottom).offset(10);
            make.right.equalTo(self.mas_right).offset(0);
            make.width.equalTo(@70);
            make.height.equalTo(@18);
        }];
        
        /// 大头针
        UIImageView *pointImgView = [[UIImageView alloc] init];
        pointImgView.image = [UIImage imageNamed:@"icon_mappin"];
        [self addSubview:pointImgView];
        [pointImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_name.mas_bottom).offset(8);
            make.right.equalTo(self.label_distance.mas_left).offset(-5);
            make.width.equalTo(@20);
            make.height.equalTo(@20);
        }];
        
//        // 地址
//        self.label_address = [[UILabel alloc] init];
//        self.label_address.text = @"金华稠州街道稠州西路127号（南方联东站旁）";
//        self.label_address.font = [UIFont systemFontOfSize:13];
//        self.label_address.textColor = [UIColor colorWithHex:0x333333];
//        [self addSubview:self.label_address];
//        [self.label_address mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.top.equalTo(self.label_carPileTotal.mas_bottom).offset(10);
//            make.left.equalTo(@15);
//            make.right.equalTo(@-15);
//            make.height.equalTo(@18);
//        }];
        
        // 去这里
        UIButton *button = [[UIButton alloc] init];
        button.backgroundColor = [UIColor colorWithHex:0xfdb731];
        [button setTitle:@"去这里" forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_navig2"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"icon_navig2"] forState:UIControlStateHighlighted];
        
        button.titleLabel.font = [UIFont systemFontOfSize:15];
        [button addTarget:self action:@selector(gotoPlace) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.label_carPileTotal.mas_bottom).offset(15);
            make.left.equalTo(@0);
            make.bottom.equalTo(@0);
            make.right.equalTo(@0);
        }];
        
    }
    return self;
}

- (void)gotoPlace {
    
    self.gotoOtherPlace();
}

@end



































