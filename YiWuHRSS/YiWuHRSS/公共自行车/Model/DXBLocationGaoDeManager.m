//
//  DXBLocationGaoDeManager.m
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DXBLocationGaoDeManager.h"

@interface DXBLocationGaoDeManager ()

@end

@implementation DXBLocationGaoDeManager

+ (instancetype)sharedManager {
    
    static DXBLocationGaoDeManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[DXBLocationGaoDeManager alloc] init];
    });
    
    return manager;
}


@end
