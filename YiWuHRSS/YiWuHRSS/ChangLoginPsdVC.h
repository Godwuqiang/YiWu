//
//  ChangLoginPsdVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/21.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChangLoginPsdVC : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *account;
@property (weak, nonatomic) IBOutlet UITextField *oldpsd;
@property (weak, nonatomic) IBOutlet UITextField *newpsd;
@property (weak, nonatomic) IBOutlet UITextField *confirmpsd;

@property (weak, nonatomic) IBOutlet UIButton *btnone;
@property (weak, nonatomic) IBOutlet UIButton *btntwo;
@property (weak, nonatomic) IBOutlet UIButton *btnthree;

- (IBAction)btnoneClicked:(id)sender;
- (IBAction)btntwoClicked:(id)sender;
- (IBAction)btnthreeClicked:(id)sender;
- (IBAction)YesBtnClicked:(id)sender;


@end
