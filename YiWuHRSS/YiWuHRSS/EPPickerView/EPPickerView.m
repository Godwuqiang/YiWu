//
//  EPPickerView.m
//  PingHuHRSS
//
//  Created by shi on 2017/8/9.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "EPPickerView.h"
#import "AppDelegate.h"

#define kRowHeight kRatio_Scale_375(35)
#define kPickerHeight kRatio_Scale_375(150)

@implementation PickerViewModel

@end


@interface EPPickerView ()<UIPickerViewDelegate,UIPickerViewDataSource>

@property (strong, nonatomic) UIPickerView *pickerView;
///总共有多少组
@property (assign, nonatomic) NSInteger numberOfLevel;
///所有正在显示的分组的数据，key为分组的序号，value为该分组的数据
@property (strong, nonatomic) NSMutableDictionary<NSNumber *,NSArray<PickerViewModel *> *> *datasForAll;
///所有分组中选中的行，key为分组的序号，value为该分组中选中的行号
@property (strong, nonatomic) NSMutableDictionary<NSNumber *,NSNumber *> *selectRowsForAll;

@end

@implementation EPPickerView

+ (instancetype)showPickerViewWithNumberOfLevel:(NSInteger)num
{
    UIWindow *wd = [(AppDelegate *)[UIApplication sharedApplication].delegate window];
    EPPickerView *pickerView = [[EPPickerView alloc] init];
    pickerView.frame = wd.bounds;
    pickerView.numberOfLevel = num;
    [wd addSubview:pickerView];
    return pickerView;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

        self.numberOfLevel = 0;
        
        self.datasForAll = [[NSMutableDictionary alloc] init];
        self.selectRowsForAll = [[NSMutableDictionary alloc] init];

        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    self.userInteractionEnabled = YES;
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5];

    UIPickerView *pickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(0, UI_SCREEN_HEIGHT - kPickerHeight, UI_SCREEN_WIDTH, kPickerHeight)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.delegate = self;
    pickerView.dataSource = self;
    pickerView.showsSelectionIndicator=YES;
    [self addSubview:pickerView];
    self.pickerView = pickerView;
    
    UIView *line1 = [[UIView alloc] init];
    line1.backgroundColor = kThemeColor;
    [self addSubview:line1];
    line1.frame = CGRectMake(0, pickerView.center.y - kRowHeight / 2, UI_SCREEN_WIDTH, 0.5);
    
    UIView *line2 = [[UIView alloc] init];
    line2.backgroundColor = kThemeColor;
    [self addSubview:line2];
    line2.frame = CGRectMake(0, pickerView.center.y + kRowHeight / 2, UI_SCREEN_WIDTH, 0.5);
    
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

- (void)setDatas:(NSArray *)datas
{
    _datas = datas;
    
    [self setupDatasWithComponent:0 datas:datas];
    
    [self.pickerView reloadAllComponents];
}

- (void)setupDatasWithComponent:(NSInteger)component
                          datas:(NSArray<PickerViewModel *> *)componentDatas
{
    self.datasForAll[@(component)] = componentDatas;
    if (componentDatas.count > 0) {
        self.selectRowsForAll[@(component)] = @(0);
        [self.pickerView selectRow:0 inComponent:component animated:NO];
        if (component < self.numberOfLevel - 1) {
            NSArray<PickerViewModel *> *subDatas = componentDatas[0].subDatas;
            [self setupDatasWithComponent:component+1 datas:subDatas];
        }
    }else{
        for (int i = (int)component; i < self.numberOfLevel; i++) {
            self.selectRowsForAll[@(i)] = nil;
            self.datasForAll[@(i)] = nil;
        }
    }
}

#pragma mark - 协议方法
#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return self.numberOfLevel;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSArray<PickerViewModel *> *componentDatas = self.datasForAll[@(component)];
    return componentDatas.count;
}

#pragma mark UIPickerViewDelegate
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return UI_SCREEN_WIDTH / self.numberOfLevel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return kRowHeight;
}

- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSArray<PickerViewModel *> *componentDatas = self.datasForAll[@(component)];
    return componentDatas[row].title;
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(nullable UIView *)view
{
    UILabel *lb;
    if (view != nil && [view isKindOfClass:[UILabel class]]) {
        lb = (UILabel *)view;
    }else{
        lb = [[UILabel alloc] init];
        lb.textAlignment = NSTextAlignmentCenter;
        lb.textColor = kFontColor_Gray;
        lb.font = [UIFont systemFontOfSize:kRatio_Scale_375(12)];
    }
    
    lb.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    NSInteger selectedRow = [self.selectRowsForAll[@(component)] integerValue];
    if (selectedRow == row) {
        lb.textColor = kThemeColor;
        lb.font = [UIFont systemFontOfSize:kRatio_Scale_375(15)];
    }else{
        lb.textColor = kFontColor_Gray;
        lb.font = [UIFont systemFontOfSize:kRatio_Scale_375(12)];
    }

    return lb;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    //实际使用中发现，当某一级没有数据显示的时候，仍然可以点击来选中，这会导致数组越界。先判断当前点击的这级是否有数据，没有数据也就没有必要选中。
    NSArray<PickerViewModel *> *componentDatas = self.datasForAll[@(component)];
    if (componentDatas.count > 0) {
        self.selectRowsForAll[@(component)] = @(row);
    }else{
        self.selectRowsForAll[@(component)] = nil;
    }

    //设置后续几级的数据
    if (component < self.numberOfLevel - 1) {
//        NSArray<PickerViewModel *> *componentDatas = self.datasForAll[@(component)];
        PickerViewModel *subModel = componentDatas[row];
        [self setupDatasWithComponent:component + 1 datas:subModel.subDatas];
    }
    
    [self.pickerView reloadAllComponents];
}

#pragma mark - 事件方法
- (void)finishAction
{
    NSMutableArray *selectedDatas = [[NSMutableArray alloc] init];
    for (NSNumber *componentNumber in [self.selectRowsForAll allKeys]) {
        
        NSInteger component = [componentNumber integerValue];
        NSInteger row = [self.selectRowsForAll[@(component)] integerValue];
        
        NSArray *componentDatas = self.datasForAll[@(component)];
        [selectedDatas addObject:componentDatas[row]];
    }
    
    if (self.selectOptionFinishBlock) {
        self.selectOptionFinishBlock(selectedDatas);
    }
    
    [self removeFromSuperview];
}

- (void)cancleAction
{
    [self removeFromSuperview];
}

//测试例子
+ (NSArray *)getOptionDatas
{
    PickerViewModel *md0 = [[PickerViewModel alloc] init];
    md0.title = @"平湖";
    PickerViewModel *md00 = [[PickerViewModel alloc] init];
    md00.title = @"平湖小区0";
    PickerViewModel *md01 = [[PickerViewModel alloc] init];
    md01.title = @"平湖小区1";
    PickerViewModel *md02 = [[PickerViewModel alloc] init];
    md02.title = @"平湖小区2";
    md0.subDatas = @[md00,md01,md02];
    
    PickerViewModel *md1 = [[PickerViewModel alloc] init];
    md1.title = @"嘉兴嘉兴嘉兴嘉兴嘉兴";
    PickerViewModel *md10 = [[PickerViewModel alloc] init];
    md10.title = @"嘉兴小区0";
    PickerViewModel *md11 = [[PickerViewModel alloc] init];
    md11.title = @"嘉兴小区1";
    PickerViewModel *md12 = [[PickerViewModel alloc] init];
    md12.title = @"嘉兴小区2";
    md1.subDatas = @[md10,md11,md12];
    
    PickerViewModel *md2 = [[PickerViewModel alloc] init];
    md2.title = @"啦啦";
    PickerViewModel *md20 = [[PickerViewModel alloc] init];
    md20.title = @"啦啦0";
    PickerViewModel *md200 = [[PickerViewModel alloc] init];
    md200.title = @"啦啦00";
    PickerViewModel *md201 = [[PickerViewModel alloc] init];
    md201.title = @"啦啦01";
    md20.subDatas = @[md200,md201];
    
    PickerViewModel *md21 = [[PickerViewModel alloc] init];
    md21.title = @"啦啦1";
    PickerViewModel *md22 = [[PickerViewModel alloc] init];
    md22.title = @"啦啦2";
    md2.subDatas = @[md20,md21,md22];
    
    NSArray *arr = @[md0,md1,md2];
    
    return arr;
}

@end






