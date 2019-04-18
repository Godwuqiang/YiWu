//
//  DXBSelectableOverlay.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/1.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MAMapKit/MAMapKit.h>

@interface DXBSelectableOverlay : NSObject<MAOverlay>

@property (nonatomic, assign) NSInteger routeID;

@property (nonatomic, assign, getter = isSelected) BOOL selected;
@property (nonatomic, strong) UIColor * selectedColor;
@property (nonatomic, strong) UIColor * regularColor;

@property (nonatomic, strong) id<MAOverlay> overlay;

- (id)initWithOverlay:(id<MAOverlay>) overlay;

@end
