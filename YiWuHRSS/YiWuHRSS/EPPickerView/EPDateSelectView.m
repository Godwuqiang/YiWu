//
//  EPDateSelectView.m
//  PingHuHRSS
//
//  Created by shi on 2017/8/11.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "EPDateSelectView.h"
#import "AppDelegate.h"

@interface EPDateSelectView ()

@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation EPDateSelectView

+ (instancetype)showDateSelectView
{
    UIWindow *wd = [(AppDelegate *)[UIApplication sharedApplication].delegate window];
    EPDateSelectView *dateSelectView = [[EPDateSelectView alloc] init];
    dateSelectView.frame = wd.bounds;
    [wd addSubview:dateSelectView];
    return dateSelectView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)updateBeginDate:(NSDate *)beginData andEndDate:(NSDate *)endData{
    self.datePicker.minimumDate = beginData;
    self.datePicker.maximumDate = endData;
}

- (void)setupUI
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];
    
    UIDatePicker *pickerView = [[UIDatePicker alloc] initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT - kRatio_Scale_375(150), UI_SCREEN_WIDTH, kRatio_Scale_375(150))];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.date = [NSDate date];
    pickerView.datePickerMode = UIDatePickerModeDate;
    pickerView.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"GMT+0800"];
    pickerView.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh"];
    //pickerView.maximumDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*5];
    [self addSubview:pickerView];
    self.datePicker = pickerView;
    
    //工具条
    UIView *toolBar = [[UIView alloc] init];
    toolBar.backgroundColor = [UIColor colorWithHex:0xe0e0e0];
    toolBar.frame = CGRectMake(0, pickerView.frame.origin.y - kRatio_Scale_375(40), UI_SCREEN_WIDTH, kRatio_Scale_375(40));
    [self addSubview:toolBar];
    //取消
    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, kRatio_Scale_375(60), kRatio_Scale_375(40))];
    [cancleBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancleBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
    cancleBtn.titleLabel.font = [UIFont systemFontOfSize:kRatio_Scale_375(14)];
    [cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:cancleBtn];
    //确认
    UIButton *confirmBtn = [[UIButton alloc] initWithFrame:CGRectMake(UI_SCREEN_WIDTH - kRatio_Scale_375(60), 0, kRatio_Scale_375(50), kRatio_Scale_375(40))];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:kThemeColor forState:UIControlStateNormal];
    confirmBtn.titleLabel.font = [UIFont systemFontOfSize:kRatio_Scale_375(14)];
    [confirmBtn addTarget:self action:@selector(finishAction) forControlEvents:UIControlEventTouchUpInside];
    [toolBar addSubview:confirmBtn];
}

#pragma mark - 事件方法
- (void)finishAction
{
    if (self.selectDateFinishBlock) {
        self.selectDateFinishBlock(self.datePicker.date);
    }
    
    [self removeFromSuperview];
}

- (void)cancleAction
{
    [self removeFromSuperview];
}

@end
