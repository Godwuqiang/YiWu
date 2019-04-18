//
//  RegistFinishVC.h
//  YiWuHRSS
//
//  Created by 大白开发电脑 on 16/10/14.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RegistFinishVC : UIViewController
@property (strong, nonatomic) IBOutlet UILabel  *Label_Account;
@property (strong, nonatomic) IBOutlet UILabel *Label_Tile;
@property(strong,nonatomic) NSString            *Label_title;
@property(strong,nonatomic) NSString            *mobile;
@property(strong,nonatomic) NSString            *psd;
@property(nonatomic, strong)   MBProgressHUD    *HUD;

//实人认证的点击事件
- (IBAction)OnClickDeAction:(id)sender;

@property (strong, nonatomic) IBOutlet UIImageView *Icon_regist;

@end
