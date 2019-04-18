//
//  DWPopView.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/28.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DWPopView.h"

@interface  DWPopView()
@property(nonatomic,retain)UIView *alterView;
@property(nonatomic,retain)UILabel *titleLb;
@property(nonatomic,retain)UILabel *contentLb;
@property(nonatomic,retain)UIButton *cancelBt;
@property(nonatomic,retain)UIButton *sureBt;

@property(nonatomic, retain)UIImageView *bgimg;
@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *content;
@property(nonatomic,copy)NSString *cancel;
@property(nonatomic,copy)NSString *sure;

@end

@implementation DWPopView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        // 背景图片
        _bgimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 280, 150)];
        _bgimg.image = [UIImage imageNamed:@"bg_tab7"];
        [self addSubview:_bgimg];
        _bgimg.backgroundColor = [UIColor clearColor];
        _bgimg.layer.cornerRadius = 5.0;
        _bgimg.layer.masksToBounds=YES;
        //        _bgimg.layer.cornerRadius = 10.0;
        //标题
        _titleLb = [[UILabel alloc] init];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgimg.mas_top).offset(20);
            make.left.equalTo(_bgimg.mas_left).offset(5);
            make.right.equalTo(_bgimg.mas_right).offset(-5);
            make.height.equalTo(@30);
        }];
        _titleLb.font = [UIFont systemFontOfSize:16];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor colorWithHex:0x333333];
        
        //内容
        _contentLb = [[UILabel alloc] init];
        [self addSubview:_contentLb];
        [_contentLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLb.mas_bottom).offset(10);
            make.left.equalTo(_bgimg.mas_left).offset(5);
            make.right.equalTo(_bgimg.mas_right).offset(-5);
            make.height.equalTo(@20);
        }];
        _contentLb.font = [UIFont systemFontOfSize:14];
        _contentLb.textAlignment = NSTextAlignmentCenter;
        _contentLb.textColor = [UIColor colorWithHex:0x666666];
        
        //取消按钮
        _cancelBt=[[UIButton alloc]init];
        [self addSubview:_cancelBt];
        [_cancelBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bgimg.mas_bottom);
            make.left.equalTo(_bgimg.mas_left);
            make.width.equalTo(@140);
            make.height.equalTo(@50);
        }];
        _cancelBt.layer.borderColor=[UIColor colorWithHex:0xeeeeee].CGColor;
        _cancelBt.layer.borderWidth=0.5;
        _cancelBt.layer.cornerRadius = 5.0;
        _cancelBt.layer.masksToBounds=YES;
        [_cancelBt setTitleColor:[UIColor colorWithHex:0x333333] forState:UIControlStateNormal];
        _cancelBt.titleLabel.font = [UIFont systemFontOfSize:15];
        [_cancelBt addTarget:self action:@selector(cancelBtClick) forControlEvents:UIControlEventTouchUpInside];
        
        //确定按钮
        _sureBt=[[UIButton alloc]init];
        [self addSubview:_sureBt];
        [_sureBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bgimg.mas_bottom);
            make.right.equalTo(_bgimg.mas_right);
            make.width.equalTo(@140);
            make.height.equalTo(@50);
        }];
        _sureBt.layer.borderColor=[UIColor colorWithHex:0xeeeeee].CGColor;
        _sureBt.layer.borderWidth=0.5;
        _sureBt.layer.cornerRadius = 5.0;
        _sureBt.layer.masksToBounds=YES;
        [_sureBt setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
        _sureBt.titleLabel.font = [UIFont systemFontOfSize:15];
        [_sureBt addTarget:self action:@selector(sureBtClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}
#pragma mark----实现类方法
+(instancetype)alterViewWithTitle:(NSString *)title
                          content:(NSString *)content
                           cancel:(NSString *)cancel
                             sure:(NSString *)sure
                    cancelBtClcik:(cancelBlock)cancelBlock
                      sureBtClcik:(sureBlock)sureBlock;
{
    DWPopView *popView=[[DWPopView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    popView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.2];
    popView.center=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    popView.bgimg.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    popView.title=title;
    popView.content=content;
    popView.cancel=cancel;
    popView.sure=sure;
    popView.cancel_block=cancelBlock;
    popView.sure_block=sureBlock;
    return popView;
}
#pragma mark--给属性重新赋值
-(void)setTitle:(NSString *)title
{
    _titleLb.text=title;
}
-(void)setContent:(NSString *)content
{
    _contentLb.text=content;
}
-(void)setSure:(NSString *)sure
{
    [_sureBt setTitle:sure forState:UIControlStateNormal];
}
-(void)setCancel:(NSString *)cancel
{
    [_cancelBt setTitle:cancel forState:UIControlStateNormal];
}

#pragma mark----取消按钮点击事件
-(void)cancelBtClick
{
    [self removeFromSuperview];
    self.cancel_block();
}
#pragma mark----确定按钮点击事件
-(void)sureBtClick
{
    [self removeFromSuperview];
    self.sure_block();
    
}

@end
