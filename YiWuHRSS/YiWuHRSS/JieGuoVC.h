//
//  JieGuoVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/5/16.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface JieGuoVC : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *jgImg;
@property (weak, nonatomic) IBOutlet UILabel *jgLb;
@property (weak, nonatomic) IBOutlet UILabel *cgts;
- (IBAction)KnowBtnClicked:(id)sender;

@property  BOOL  jg;

@end
