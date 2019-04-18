//
//  BannerBean.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2016/11/16.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import "BannerBean.h"

@implementation BannerBean

-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self = [super init]){
        self.title = [aDecoder decodeObjectForKey:@"title"];
        self.pngurl = [aDecoder decodeObjectForKey:@"pngurl"];
        self.url = [aDecoder decodeObjectForKey:@"url"];
        self.remarks = [aDecoder decodeObjectForKey:@"remarks"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.title forKey:@"title"];
    [coder encodeObject:self.pngurl forKey:@"pngurl"];
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.remarks forKey:@"remarks"];
}

@end
