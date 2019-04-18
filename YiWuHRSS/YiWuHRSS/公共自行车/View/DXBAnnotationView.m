//
//  DXBAnnotationView.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/7.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBAnnotationView.h"


@interface DXBAnnotationView ()

@property (nonatomic, strong) UIImageView *bubbleImgView;
@property (nonatomic, strong) UILabel *label;

@end


@implementation DXBAnnotationView

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    if (self.selected == selected) {
        return;
    }
    
    if (selected) {
        if (!self.bubbleImgView) {
            
            
            self.bubbleImgView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 78, 32)];
            self.bubbleImgView.image = [UIImage imageNamed:@"label_bike2"];
            _label=[[UILabel alloc]initWithFrame:CGRectMake(0, 0, 78, 26)];
            _label.textColor = [UIColor colorWithHex:0xffffff];
            _label.font = [UIFont systemFontOfSize:12];
            _label.textAlignment=NSTextAlignmentCenter;
            [self.bubbleImgView addSubview:_label];
        }
        
        self.bubbleImgView.center = CGPointMake(CGRectGetWidth(self.bounds) / 2.f + self.calloutOffset.x,
                                             -CGRectGetHeight(self.bubbleImgView.bounds) / 2.f + self.calloutOffset.y-5);
        
    } else {
        
        [self.bubbleImgView removeFromSuperview];
        self.bubbleImgView=nil;
        return;
    }
    
    [super setSelected:selected animated:animated];
}



-(void)setSelfInitString:(NSString*)string
{
    
    if (string.length>0) {
        
        _label.text = string;
        [self addSubview:self.bubbleImgView];
    }else {
        
        [self.bubbleImgView removeFromSuperview];
    }
}


/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
