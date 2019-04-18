//
//  EPCardIssueView.h
//  ZjEsscSDK
//
//  Created by MacBook Pro on 2018/12/11.
//  Copyright © 2018年 HouXinbing. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol cardIssueView <NSObject>

- (void)didSelectedWithSignInfo:(NSString *)signInfo;

// 关闭发卡地选择
- (void)closeCardIssueView;

@end

@interface EPCardIssueView : UIViewController

@property (nonatomic, weak) id<cardIssueView> delegate;

/// 导航条背景颜色
@property (nonatomic, strong) UIColor *themeColor;

/// 标题颜色
@property (nonatomic, strong) UIColor *titleColor;

@property (nonatomic, strong) NSArray *dataArray;

@end
