//
//  ModifyCardView.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/29.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "ModifyCardView.h"

@interface  ModifyCardView()

@property(nonatomic,retain)UIView *alterView;
@property(nonatomic,retain)UILabel *contentLb;
@property(nonatomic,retain)UIButton *sureBt;

@property(nonatomic, retain)UIImageView *bgimg;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *sure;

@end


@implementation ModifyCardView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        // 背景图片
        _bgimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
        _bgimg.image = [UIImage imageNamed:@"bg_tab7"];
        [self addSubview:_bgimg];
        _bgimg.backgroundColor = [UIColor clearColor];
        _bgimg.layer.cornerRadius = 10.0;
        _bgimg.layer.masksToBounds=YES;
        
        //内容
        _contentLb = [[UILabel alloc] init];
        [self addSubview:_contentLb];
        [_contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgimg.mas_top).offset(30);
            make.left.equalTo(_bgimg.mas_left).offset(30);
            make.right.equalTo(_bgimg.mas_right).offset(-30);
        }];
//        _contentLb.textAlignment = NSTextAlignmentCenter;
        _contentLb.numberOfLines = 0;
        _contentLb.font = [UIFont systemFontOfSize:15];
        _contentLb.textColor = [UIColor colorWithHex:0x666666];
        
        //确定按钮
        _sureBt=[[UIButton alloc]init];
        [self addSubview:_sureBt];
        [_sureBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bgimg.mas_bottom);
            make.right.equalTo(_bgimg.mas_right);
            make.left.equalTo(_bgimg.mas_left);
            make.height.equalTo(@50);
        }];
        _sureBt.layer.borderColor=[UIColor colorWithHex:0xeeeeee].CGColor;
        _sureBt.layer.borderWidth=0.5;
        _sureBt.layer.cornerRadius = 10.0;
        _sureBt.layer.masksToBounds=YES;
        [_sureBt setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
        _sureBt.titleLabel.font = [UIFont systemFontOfSize:18];
        [_sureBt addTarget:self action:@selector(sureBtClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

#pragma mark----实现类方法
+(instancetype)alterViewWithcontent:(NSString *)content
                               sure:(NSString *)sure
                        sureBtClcik:(sureBlock)sureBlock;
{
    ModifyCardView *alterView=[[ModifyCardView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    alterView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    alterView.center=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    alterView.bgimg.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    alterView.content=content;
    alterView.sure=sure;
    alterView.sure_block=sureBlock;
    return alterView;
}

#pragma mark--给属性重新赋值
-(void)setContent:(NSString *)content
{
    // textview 改变字体的行间距
//    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
//    paragraphStyle.lineSpacing = 10;// 字体的行间距
//    
//    NSDictionary *attributes = @{
//                                 NSForegroundColorAttributeName:[UIColor colorWithHex:0x666666],
//                                 NSFontAttributeName:[UIFont systemFontOfSize:14],
//                                 NSParagraphStyleAttributeName:paragraphStyle
//                                 };
//    _contentLb.attributedText = [[NSAttributedString alloc] initWithString:content attributes:attributes];
    _contentLb.text = content;
}
-(void)setSure:(NSString *)sure
{
    [_sureBt setTitle:sure forState:UIControlStateNormal];
}

#pragma mark----确定按钮点击事件
-(void)sureBtClick
{
    [self removeFromSuperview];
    self.sure_block();
    
}

@end
