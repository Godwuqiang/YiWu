//
//  DXBresetReasonView.h
//  YiWuHRSS
//
//  Created by MacBook on 2017/12/8.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void (^selectedType)(NSString *type);

@interface DXBresetReasonView : UIView

@property (nonatomic, copy) selectedType type;

@property (weak, nonatomic) IBOutlet UIButton *button1;

@property (weak, nonatomic) IBOutlet UIButton *button2;

@property (weak, nonatomic) IBOutlet UIButton *button3;


/**
 安置原因 011回原籍居住；012户籍异地落户居住；013随直系亲属异地居住；
 */
@property (nonatomic, strong) NSString *reasonType;

@end
