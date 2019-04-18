//
//  HSBasePickerVC.m
//  HSPickerViewDemo
//
//  Created by husong on 2017/10/27.
//  Copyright © 2017年 husong. All rights reserved.
//

#import "HSBasePickerVC.h"

#define kWindowH   [UIScreen mainScreen].bounds.size.height //应用程序的屏幕高度
#define kWindowW    [UIScreen mainScreen].bounds.size.width  //应用程序的屏幕宽度

@interface HSBasePickerVC ()<UIPickerViewDelegate,UIPickerViewDataSource>
@property (strong, nonatomic) UIView *selectView;
@property (strong, nonatomic) UIView *lineView;
@property (strong, nonatomic) UIView * selectViewBac;
@property (strong, nonatomic) UIButton *cancleBtn;
@property (strong, nonatomic) UIButton *ensureBtn;
@property (strong, nonatomic) UILabel *pickerTitleLabel;

/** 内容视图 */
@property (nonatomic, strong) UIView *contentView;


/** 内容高度 */
@property (nonatomic, assign) CGFloat contentHeight;
/** barViewHeight */
@property (nonatomic, assign) CGFloat barViewHeight;
/** btnWidth */
@property (nonatomic, assign) CGFloat btnWidth;

@end

@implementation HSBasePickerVC

- (instancetype)init{
    if (self = [super init]) {
        
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
    self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    
    self.contentHeight = 274;
    self.barViewHeight = 40;
    self.btnWidth = 50;
    
    [self initUI];
    
    // 收到下线通知的消息
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tokenInvalid) name:@"token_invalid" object:nil];
}

- (void)tokenInvalid {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)initUI{
    
    UIColor *btnColor = [UIColor colorWithHex:0x249dee];
    
    _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, kWindowH - self.contentHeight, kWindowW, self.contentHeight)];
    _contentView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:_contentView];
    
    self.selectView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kWindowW, self.barViewHeight)];
    [self.contentView addSubview:self.selectView];
    
    self.lineView = [[UIView alloc] initWithFrame:CGRectMake(0, self.barViewHeight - 1, kWindowW, 1)];
    self.lineView.backgroundColor = [UIColor colorWithHex:0xd1d3d5];
    [self.selectView addSubview:self.lineView];
    
    
    self.cancleBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_cancleBtn setTitle:@"取消" forState:0];
    [_cancleBtn setTitleColor:btnColor forState:0];
    _cancleBtn.frame = CGRectMake(0, 0, 60, 40);
    [_cancleBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_cancleBtn addTarget:self action:@selector(cancleAction) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_cancleBtn];
    
    self.ensureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_ensureBtn setTitle:@"完成" forState:0];
    _ensureBtn.frame = CGRectMake(kWindowW - 60, 0, 60, 40);
    [_ensureBtn setTitleColor:btnColor forState:0];
    [_ensureBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_ensureBtn addTarget:self action:@selector(ensureAction) forControlEvents:UIControlEventTouchUpInside];
    [_selectView addSubview:_ensureBtn];
    
    self.pickerTitleLabel = [[UILabel alloc] init];
    _pickerTitleLabel.text = @"";
    [_pickerTitleLabel setFont:[UIFont systemFontOfSize:15]];
    _pickerTitleLabel.textAlignment = NSTextAlignmentCenter;
    [_selectView addSubview:_pickerTitleLabel];
    
    //_pickerview的背景色为透明,在选中的那行上面放一层view,然后设置view的背景色
    self.selectViewBac = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 51)];
    self.selectViewBac.backgroundColor = [UIColor colorWithHex:0xfdb731];
    [self.contentView addSubview:self.selectViewBac];
    
    self.pickView = [[UIPickerView alloc] init];
    self.pickView.frame = CGRectMake(0, self.barViewHeight, kWindowW, self.contentHeight - self.barViewHeight);
    self.selectViewBac.center = self.pickView.center;
    _pickView.delegate   = self;
    _pickView.dataSource = self;
    _pickView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:_pickView];
}

-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [UIView animateWithDuration:0.1 animations:^{
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    } completion:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    
    for(UIView *speartorView in pickerView.subviews)
    {
        if (speartorView.frame.size.height < 1)//取出分割线view
        {
            speartorView.backgroundColor = [UIColor clearColor];//隐藏分割线
        }
    }
    
    
    UILabel* pickerLabel = (UILabel*)view;
    if (!pickerLabel){
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setBackgroundColor:[UIColor clearColor]];
//        [pickerLabel setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:15]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    
    
    if (component == 0) {
        
        if (row == [CoreArchive intForKey:PROVICE_COMPONENT_INDEX]) {
            
            pickerLabel.textColor = [UIColor whiteColor];
        }
        
    }else if (component == 1) {
        
        if (row == [CoreArchive intForKey:CITY_COMPONENT_INDEX]) {
            
            pickerLabel.textColor = [UIColor whiteColor];
        }
    }else if (component == 2) {
        
        if (row == [CoreArchive intForKey:AREA_COMPONENT_INDEX]) {
            
            pickerLabel.textColor = [UIColor whiteColor];
        }
    }
    
    return pickerLabel;
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return _dataArray.count;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return _dataArray[component].count;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return _dataArray[component][row];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
    return [UIScreen mainScreen].bounds.size.width / _dataArray.count;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{

    return 51;
}

//- (nullable NSAttributedString *)pickerView:(UIPickerView *)pickerView attributedTitleForRow:(NSInteger)row forComponent:(NSInteger)component{
//    return nil;
//}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    
    
}

#pragma mark - privateMethods
/** 点击空白收回 */
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.view];
    if (point.y < CGRectGetMinY(self.selectView.frame)) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

/** 取消 */
-(void)cancleAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

/** 确认 */
-(void)ensureAction{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - getter & setter
-(void)setPickerTitle:(NSString *)pickerTitle{
    _pickerTitle = pickerTitle;
    self.pickerTitleLabel.text = _pickerTitle;
}

-(void)setDataArray:(NSArray *)dataArray{
    _dataArray = dataArray;
    [self.pickView reloadAllComponents];
}


@end
