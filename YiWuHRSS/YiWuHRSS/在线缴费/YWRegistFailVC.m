//
//  YWRegistFailVC.m
//  YiWuHRSS
//
//  Created by Donkey-Tao on 2018/6/24.
//  Copyright © 2018年 许芳芳. All rights reserved.
//

#import "YWRegistFailVC.h"

@interface YWRegistFailVC ()

@end

@implementation YWRegistFailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.resonString.text = self.reson;
    if(self.isSeriousIll){
        self.title = @"大病医保";
    }
    if(self.isResidentTreatment){
        self.title = @"城乡居民医疗";
    }
    if(self.isResidentPension){
        self.title = @"城乡居民养老";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}



@end
