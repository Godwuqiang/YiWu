//
//  DXBLocationGaoDeManager.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/7/31.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DXBLocationGaoDeManager : NSObject

+ (instancetype)sharedManager;

@property (nonatomic, strong) NSString *current_city;


@end
