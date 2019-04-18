//
//  ShareView.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/9.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ShareView.h"

@interface ShareView()

@property(nonatomic,retain)  UIView *shareView;
@property(nonatomic, retain)UIImageView *bgimg;
@property(nonatomic,retain) UILabel *titleLb;
@property(nonatomic,retain) UILabel *WechatSessionLb;
@property(nonatomic,retain) UILabel *WechatTimeLineLb;
@property(nonatomic,retain)UIButton *cancelBt;
@property(nonatomic,retain)UIButton *WechatSessionBt;
@property(nonatomic,retain)UIButton *WechatTimeLineBt;

@property(nonatomic,copy)NSString *title;
@property(nonatomic,copy)NSString *cancel;

@end


@implementation ShareView

-(instancetype)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        // 背景图片
        _bgimg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 158)];
//        _bgimg.image = [UIImage imageNamed:@"bg_tab7"];
        _bgimg.backgroundColor = [UIColor colorWithHex:0xebeef3];
        [self addSubview:_bgimg];
//        _bgimg.backgroundColor = [UIColor clearColor];
//        _bgimg.layer.cornerRadius = 5.0;
//        _bgimg.layer.masksToBounds=YES;
        
        //标题
        _titleLb = [[UILabel alloc] init];
        [self addSubview:_titleLb];
        [_titleLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_bgimg.mas_top).offset(20);
            make.left.equalTo(_bgimg.mas_left).offset(5);
            make.right.equalTo(_bgimg.mas_right).offset(-5);
            make.height.equalTo(@16);
        }];
        _titleLb.font = [UIFont systemFontOfSize:16];
        _titleLb.textAlignment = NSTextAlignmentCenter;
        _titleLb.textColor = [UIColor colorWithHex:0x333333];
        
        //微信好友按钮
        _WechatSessionBt=[[UIButton alloc]init];
        [self addSubview:_WechatSessionBt];
        [_WechatSessionBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLb.mas_bottom).offset(10);
            make.right.equalTo(_titleLb.mas_centerX).offset(-40);
            make.width.equalTo(@46);
            make.height.equalTo(@46);
        }];
        [_WechatSessionBt setImage:[UIImage imageNamed:@"logo_weixin"] forState:UIControlStateNormal];
        [_WechatSessionBt addTarget:self action:@selector(WechatSessionBtClick) forControlEvents:UIControlEventTouchUpInside];
        
        //微信好友标签
        _WechatSessionLb = [[UILabel alloc] init];
        [self addSubview:_WechatSessionLb];
        [_WechatSessionLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_WechatSessionBt.mas_bottom).offset(4);
            make.centerX.equalTo(_WechatSessionBt.mas_centerX);
            make.width.equalTo(@60);
            make.height.equalTo(@12);
        }];
        _WechatSessionLb.font = [UIFont systemFontOfSize:12];
        _WechatSessionLb.textAlignment = NSTextAlignmentCenter;
        _WechatSessionLb.textColor = [UIColor colorWithHex:0x666666];
        _WechatSessionLb.text = @"微信好友";
        
        //微信朋友圈按钮
        _WechatTimeLineBt=[[UIButton alloc]init];
        [self addSubview:_WechatTimeLineBt];
        [_WechatTimeLineBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_titleLb.mas_bottom).offset(10);
            make.left.equalTo(_titleLb.mas_centerX).offset(40);
            make.width.equalTo(@46);
            make.height.equalTo(@46);
        }];
        [_WechatTimeLineBt setImage:[UIImage imageNamed:@"logo_pengyou"] forState:UIControlStateNormal];
        [_WechatTimeLineBt addTarget:self action:@selector(WechatTimeLineBtClick) forControlEvents:UIControlEventTouchUpInside];
        
        //微信朋友圈标签
        _WechatTimeLineLb = [[UILabel alloc] init];
        [self addSubview:_WechatTimeLineLb];
        [_WechatTimeLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_WechatTimeLineBt.mas_bottom).offset(4);
            make.centerX.equalTo(_WechatTimeLineBt.mas_centerX);
            make.width.equalTo(@70);
            make.height.equalTo(@12);
        }];
        _WechatTimeLineLb.font = [UIFont systemFontOfSize:12];
        _WechatTimeLineLb.textAlignment = NSTextAlignmentCenter;
        _WechatTimeLineLb.textColor = [UIColor colorWithHex:0x666666];
        _WechatTimeLineLb.text = @"微信朋友圈";
        
        //取消按钮
        _cancelBt=[[UIButton alloc]init];
        [self addSubview:_cancelBt];
        [_cancelBt mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_bgimg.mas_bottom);
            make.left.equalTo(_bgimg.mas_left);
            make.right.equalTo(_bgimg.mas_right);
            make.height.equalTo(@36);
        }];
        _cancelBt.layer.borderColor=[UIColor colorWithHex:0xeeeeee].CGColor;
        _cancelBt.backgroundColor = [UIColor colorWithHex:0xf6fafd];
        _cancelBt.layer.borderWidth=0.5;
        _cancelBt.layer.cornerRadius = 5.0;
        _cancelBt.layer.masksToBounds=YES;
        [_cancelBt setTitleColor:[UIColor colorWithHex:0x666666] forState:UIControlStateNormal];
        _cancelBt.titleLabel.font = [UIFont systemFontOfSize:14];
        [_cancelBt addTarget:self action:@selector(cancelBtClick) forControlEvents:UIControlEventTouchUpInside];
        
        
    }
    return self;
}
#pragma mark----实现类方法
+(instancetype)shareViewWithTitle:(NSString *)title
                           cancel:(NSString *)cancel
                    cancelBtClcik:(cancelBlock)cancelBlock
             WechatSessionBtClcik:(WechatSessionBlock)WechatSessionBlock
            WechatTimeLineBtClcik:(WechatTimeLineBlock)WechatTimeLineBlock;
{
    ShareView *shareView=[[ShareView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT)];
    shareView.backgroundColor=[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.4];
    shareView.center=CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT/2);
    shareView.bgimg.center = CGPointMake(SCREEN_WIDTH/2, SCREEN_HEIGHT-79);
    shareView.title=title;
    shareView.cancel=cancel;
    shareView.cancel_block=cancelBlock;
    shareView.WechatSession_Block=WechatSessionBlock;
    shareView.WechatTimeLine_Block=WechatTimeLineBlock;
    return shareView;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self removeFromSuperview];
}

#pragma mark--给属性重新赋值
-(void)setTitle:(NSString *)title
{
    _titleLb.text=title;
}
-(void)setCancel:(NSString *)cancel
{
    [_cancelBt setTitle:cancel forState:UIControlStateNormal];
}

#pragma mark----取消分享按钮点击事件
-(void)cancelBtClick
{
    [self removeFromSuperview];
    self.cancel_block();
}
#pragma mark----微信好友按钮点击事件
-(void)WechatSessionBtClick
{
    [self removeFromSuperview];
    self.WechatSession_Block();
}
#pragma mark----微信朋友圈按钮点击事件
-(void)WechatTimeLineBtClick
{
    [self removeFromSuperview];
    self.WechatTimeLine_Block();
}

@end
