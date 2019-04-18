//
//  HSDatePickerVC.h
//  HSPickerViewDemo
//
//  Created by husong on 2017/10/27.
//  Copyright © 2017年 husong. All rights reserved.
//

#import "HSBasePickerVC.h"
@class HSDatePickerVC;

@protocol HSDatePickerVCDelegate <NSObject>
- (void)datePicker:(HSDatePickerVC*)datePicker
              withYear:(NSString *)year
                 month:(NSString *)month
                   day:(NSString *)day;

@end

@interface HSDatePickerVC : HSBasePickerVC
@property (nonatomic, weak) id<HSDatePickerVCDelegate> delegate;
@end
