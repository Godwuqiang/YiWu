//
//  HSDatePickerVC.m
//  HSPickerViewDemo
//
//  Created by husong on 2017/10/27.
//  Copyright © 2017年 husong. All rights reserved.
//

#import "HSDatePickerVC.h"
#import "NSDate+Date.h"

@interface HSDatePickerVC ()
//设置日期最大最小年限
@property(nonatomic,assign) NSInteger maxYear;
@property(nonatomic,assign) NSInteger minYear;
//数据源数组
@property (strong, nonatomic) NSMutableArray *yearArray;//年
@property (strong, nonatomic) NSMutableArray *monthArray;//月
@property (strong, nonatomic) NSMutableArray *dayArray;//日
//记录位置
@property (assign, nonatomic)NSInteger yearIndex;
@property (assign, nonatomic)NSInteger monthIndex;
@property (assign, nonatomic)NSInteger dayIndex;
//当前年月日
@property (copy, nonatomic) NSString *currentYear;
@property (copy, nonatomic) NSString *currentMonth;
@property (copy, nonatomic) NSString *currentDay;
@end

@implementation HSDatePickerVC

- (instancetype)init{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.definesPresentationContext = YES;
//    self.pickerTitle = @"请选择出生日期";
    [self initData];// 初始化数据
    [self showCurrentDate];// 显示当前日期
}

-(void)initData{
//    self.maxYear = [[self getCurrentYear] integerValue];
//    self.minYear = 1900;
    
    self.maxYear = [[self getCurrentYear] integerValue] + 10;
    self.minYear = [[self getCurrentYear] integerValue];
    
    self.yearArray = [[NSMutableArray alloc] init];
    self.monthArray = [[NSMutableArray alloc] init];
    self.dayArray = [[NSMutableArray alloc] init];
    
    for (NSInteger i = _minYear; i < _maxYear + 1; i++) {
        NSString *num = [NSString stringWithFormat:@"%zd",i];
        [_yearArray addObject:num];
    }
    for (int i=0; i<30; i++) {
        NSString *num = [NSString stringWithFormat:@"%02d",i];
        if (i>0 && i<=12) [_monthArray addObject:num];
        if (i>0) {
            [_dayArray addObject:num];
        }
    }
    self.dataArray = @[_yearArray,_monthArray,_dayArray];
}

#pragma mark - UIPickerViewDelegate & UIPickerViewDataSource
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (component == 0) {
        _yearIndex = row;
        self.currentYear = [self.yearArray objectAtIndex:row];
    }
    if (component == 1) {
        _monthIndex = row;
        self.currentMonth = [self.monthArray objectAtIndex:row];
    }
    if (component == 2) {
        _dayIndex = row;
        self.currentDay = [self.dayArray objectAtIndex:row];
    }
    
    if (component == 0 || component == 1){
        // 根据年月 确定天数
        [self daysfromYear:[_yearArray[_yearIndex] integerValue] andMonth:[_monthArray[_monthIndex] integerValue]];
        // 刷新天数列表
        [self.pickView reloadComponent:2];
        // 由于天数是变动的，需刷新当前天数保存在_currentDay中
        NSInteger dayIndex = [self.pickView selectedRowInComponent:2];
        self.currentDay = self.dayArray[dayIndex];
    }
}

#pragma mark - privateMethods
-(void)cancleAction{
    [super cancleAction];
    NSLog(@"取消");
}

-(void)ensureAction{
    [super ensureAction];
    
    if ([self.delegate respondsToSelector:@selector(datePicker:withYear:month:day:)]) {
        [self.delegate datePicker:self withYear:_currentYear month:_currentMonth day:_currentDay];
    }
    
    
//    NSString *time = @"2015/10/15 9:00:00";
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
//    NSDate *date = [formatter dateFromString:time];
    
//    NSString *selectedTime = [NSString stringWithFormat:@"%@-%@-%@", _currentYear, _currentMonth, _currentDay];
//    NSLog(@"selectedTime : %@", selectedTime);
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:@"yyyy-MM-dd"];
//    NSDate *selectedDate = [formatter dateFromString:selectedTime];
//    NSLog(@"selectedDate: %@", selectedDate);
    
    
    // 当前时间
//    NSDate * nowDate = [NSDate date];
//    NSLog(@"当前时间:  %@", nowDate);
    
    // 若干年后的时间
//    NSDate *futureDate = [self dateStringAfterlocalDateForYear:3 Month:0 Day:0 Hour:0 Minute:0 Second:0];
//    NSLog(@"若干年后的时间: %@", futureDate);
//
//    int compare = [self compareOneDay:selectedDate withAnotherDay:futureDate];
//    NSLog(@"--------: %i", compare);
//    if (compare == 1) {
//
//        NSLog(@"666666666666");
//    }else {
//
//        NSLog(@"000000000000000000");
//    }
    
}

//// 若干年后的时间
//- (NSDate *)dateStringAfterlocalDateForYear:(NSInteger)year Month:(NSInteger)month Day:(NSInteger)day Hour:(NSInteger)hour Minute:(NSInteger)minute Second:(NSInteger)second
//{
//    // 当前日期
//    NSDate *localDate = [NSDate date]; // 为伦敦时间
//    // 在当前日期时间加上 时间：格里高利历
//    NSCalendar *gregorian = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
//    NSDateComponents *offsetComponent = [[NSDateComponents alloc]init];
//
//    [offsetComponent setYear:year ];  // 设置开始时间为当前时间的前x年
//    [offsetComponent setMonth:month];
//    [offsetComponent setDay:day];
//    [offsetComponent setHour:(hour+8)]; // 中国时区为正八区，未处理为本地，所以+8
//    [offsetComponent setMinute:minute];
//    [offsetComponent setSecond:second];
//    // 当前时间后若干时间
//    NSDate *minDate = [gregorian dateByAddingComponents:offsetComponent toDate:localDate options:0];
//
//    return minDate;
//
////    NSString *dateString = [NSString stringWithFormat:@"%@",minDate];
////
////    return dateString;
//}
//
///****
//
// ios比较日期大小默认会比较到秒
//
// ****/
//
//- (int)compareOneDay:(NSDate *)oneDay withAnotherDay:(NSDate *)anotherDay
//
//{
//
//    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
//
//    [dateFormatter setDateFormat:@"dd-MM-yyyy"];
//
//    NSString *oneDayStr = [dateFormatter stringFromDate:oneDay];
//
//    NSString *anotherDayStr = [dateFormatter stringFromDate:anotherDay];
//
//    NSDate *dateA = [dateFormatter dateFromString:oneDayStr];
//
//    NSDate *dateB = [dateFormatter dateFromString:anotherDayStr];
//
//    NSComparisonResult result = [dateA compare:dateB];
//
//    NSLog(@"date1 : %@, date2 : %@", oneDay, anotherDay);
//
//    if (result == NSOrderedDescending) {
//
//        //NSLog(@"Date1  is in the future");
//
//        return 1;
//
//    }
//
//    else if (result ==NSOrderedAscending){
//
//        //NSLog(@"Date1 is in the past");
//
//        return -1;
//
//    }
//
//    //NSLog(@"Both dates are the same");
//
//    return 0;
//
//
//
//}

/** 获取当前年 */
- (NSString *)getCurrentYear {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy"];
    NSString *year = [formatter stringFromDate:[NSDate date]];
    
//    NSString *nowYear = [NSString stringWithFormat:@"%li", [year integerValue] + 2];
    return year;
//    return nowYear;
}

/** 显示当前日期 */
-(void)showCurrentDate{
    NSString *date = [NSDate stringWithDate:[NSDate date]];
    NSString *dateStr = [date substringToIndex:10];
    NSArray *dateArr = [dateStr componentsSeparatedByString:@"-"];
    self.currentYear = dateArr[0];
//    self.currentYear = [NSString stringWithFormat:@"%li", [dateArr[0] integerValue] + 2];
    self.currentMonth = dateArr[1];
    self.currentDay = dateArr[2];
    // 确定年 和 月
    _yearIndex= [self.yearArray indexOfObject:self.currentYear];
    _monthIndex = [self.monthArray indexOfObject:self.currentMonth];
    // 根据当前年月确定天数
    NSInteger currentMonthDays =  [self daysfromYear:[_yearArray[_yearIndex] integerValue] andMonth:[_monthArray[_monthIndex] integerValue]];
    [self setdayArray:currentMonthDays];
    _dayIndex = [self.dayArray indexOfObject:self.currentDay];
    // 滚动到当前日期
    [self.pickView selectRow:_yearIndex inComponent:0 animated:YES];
    [self.pickView selectRow:_monthIndex inComponent:1 animated:YES];
    [self.pickView selectRow:_dayIndex inComponent:2 animated:YES];
    // 刷新天数
    [self.pickView reloadComponent:2];
}

/** 通过年月求每月天数 */
- (NSInteger)daysfromYear:(NSInteger)year andMonth:(NSInteger)month
{
    NSInteger num_year  = year;
    NSInteger num_month = month;
    
    BOOL isrunNian = num_year%4==0 ? (num_year%100==0? (num_year%400==0?YES:NO):YES):NO;
    switch (num_month) {
        case 1:case 3:case 5:case 7:case 8:case 10:case 12:{
            [self setdayArray:31];
            return 31;
        }
        case 4:case 6:case 9:case 11:{
            [self setdayArray:30];
            return 30;
        }
        case 2:{
            if (isrunNian) {
                [self setdayArray:29];
                return 29;
            }else{
                [self setdayArray:28];
                return 28;
            }
        }
        default:
            break;
    }
    return 0;
}

/** 设置每月的天数数组 */
- (void)setdayArray:(NSInteger)num
{
    [_dayArray removeAllObjects];
    for (int i=1; i<=num; i++) {
        [_dayArray addObject:[NSString stringWithFormat:@"%02d",i]];
    }
}



@end
