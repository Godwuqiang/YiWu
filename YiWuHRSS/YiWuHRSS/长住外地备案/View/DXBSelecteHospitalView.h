//
//  DXBSelecteHospitalView.h
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/5.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DXBSelecteHospitalViewDelegate <NSObject>


/**
 删除选择的医院

 @param indexItem index
 */
- (void)deleteSelectedHospitalList:(NSInteger)indexItem;

@end


@interface DXBSelecteHospitalView : UIView

@property (nonatomic, weak) id<DXBSelecteHospitalViewDelegate> delegate;

/// 选择的医院列表
@property (nonatomic, strong) NSMutableArray *listArray;

@end
