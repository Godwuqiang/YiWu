//
//  DXBSelecteHospitalView.m
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBSelecteHospitalView.h"

@interface DXBSelecteHospitalView ()

@end


@implementation DXBSelecteHospitalView

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        self.listArray = [NSMutableArray array];
        self.backgroundColor = [UIColor whiteColor];
    }
    
    return self;
}

- (void)setListArray:(NSMutableArray *)listArray {
    
    CGFloat labelWidth = (SCREEN_WIDTH - 45) / 2;
    
    for(UIView *view in [self subviews])
    {
        [view removeFromSuperview];
    }
    
    for (NSInteger i=0; i<listArray.count; i++) {
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15+(i%2)*(labelWidth+15), (i/2)*60+10, labelWidth, 50)];
//        label.text = listArray[i];
        label.text = [[listArray[i] componentsSeparatedByString:@";"] firstObject];
        
        
        label.layer.borderWidth = 1;
        label.layer.borderColor = [UIColor colorWithHex:0x249dee].CGColor;
        label.textColor = [UIColor colorWithHex:0x249dee];
        label.font = [UIFont systemFontOfSize:14];
        label.numberOfLines = 0;
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        
        UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [closeBtn setFrame:CGRectMake(label.frame.origin.x + labelWidth - 8.5, label.frame.origin.y - 8.5, 17, 17)];
        [closeBtn setBackgroundImage:[UIImage imageNamed:@"icon_close2"] forState:UIControlStateNormal];
        closeBtn.tag = i;
        [closeBtn addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:closeBtn];
    }
}

- (void)closeButtonClick:(UIButton *)button {
    
    if ([self.delegate respondsToSelector:@selector(deleteSelectedHospitalList:)]) {
        [self.delegate deleteSelectedHospitalList:button.tag];
    }
    
}

@end
