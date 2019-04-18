//
//  EPPickerView.h
//  PingHuHRSS
//
//  Created by shi on 2017/8/9.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerViewModel : NSObject
///选项对应的标题
@property (strong, nonatomic) NSString *title;
///选项对应的下一级数据
@property (strong, nonatomic) NSArray<PickerViewModel *> *subDatas;
///选项对应的数据(可选，可通过该字段来携带额外的信息，如title=汉族，extraObj=001 )
@property (strong, nonatomic) id extraObj;

@end

@interface EPPickerView : UIView
///EPPickerView的数据源
@property (strong, nonatomic) NSArray<PickerViewModel *> *datas;
///选择完成后回调，selectedOptionArray数组中会按顺序存放选中的选项数据(PickerViewModel)
@property (copy) void(^selectOptionFinishBlock)(NSArray<PickerViewModel *> *selectedOptionArray);

/**
 *  创建一个EPPickerView并显示
 *  @param num 要显示多少组数据
 */
+ (instancetype)showPickerViewWithNumberOfLevel:(NSInteger)num;

///测试例子
+ (NSArray *)getOptionDatas;

@end
