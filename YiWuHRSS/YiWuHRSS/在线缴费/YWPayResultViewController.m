//
//  YWPayResultViewController.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/11/14.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWPayResultViewController.h"

@interface YWPayResultViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailsLabel;

@end

@implementation YWPayResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if(self.isResidentTreatment){
        self.title = @"城乡居民医疗";
    }else if (self.isSeariousIll){
        self.title = @"大病保险";
    }
    
    
    
    if(self.succeed){
        
        self.imageView.image = [UIImage imageNamed:@"success"];
        self.titleLabel.text = @"缴费成功!";
        self.detailsLabel.text = @"";
        
    }else{
        
        self.imageView.image = [UIImage imageNamed:@"fail"];
        self.titleLabel.text = @"缴费失败!";
        if(_reason == nil){
            self.reason = [NSString stringWithFormat:@""];
        }
        self.detailsLabel.text = _reason;
    }
}



@end
