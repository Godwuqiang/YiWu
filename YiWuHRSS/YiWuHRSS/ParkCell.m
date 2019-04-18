//
//  ParkCell.m
//  YiWuHRSS
//
//  Created by 许芳芳 on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "ParkCell.h"

@implementation ParkCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setParkbean:(ParkBean *)parkbean {
    
    if ([parkbean.type isEqualToString:@"A"]) {
        self.Img.image = [UIImage imageNamed:@"icon_parking2"];
    }else{
        self.Img.image = [UIImage imageNamed:@"icon_parking3"];
    }
    
    if ([Util IsStringNil:parkbean.parkname]) {
        self.Name.text = @"--";
    }else{
        self.Name.text = parkbean.parkname;
    }
    
    if ([Util IsStringNil:parkbean.address]) {
        self.Address.text = @"--";
    }else{
        self.Address.text = parkbean.address;
    }
    
    if ([Util IsStringNil:parkbean.distanceKm]) {
        self.Imgjuli.hidden = YES;
        self.Juli.hidden = YES;
//        self.Juli.text = @"暂无";
    }else{
        self.Imgjuli.hidden = NO;
        self.Juli.hidden = NO;
        if (parkbean.distanceKm.floatValue > 999.99) {
            self.Juli.text = @">999.99KM";
        }else if (parkbean.distanceKm.floatValue < 0.01) {
            self.Juli.text = @"<0.01KM";
        }else{
            self.Juli.text = [NSString stringWithFormat:@"%@KM",parkbean.distanceKm];
        }
        
        NSString *lat = nil==[CoreArchive strForKey:CURRENT_LON]?@"29.293017":[CoreArchive strForKey:CURRENT_LON];
        NSString *lng = nil==[CoreArchive strForKey:CURRENT_LAT]?@"120.063697": [CoreArchive strForKey:CURRENT_LAT];
        if([lat isEqualToString:@"29.293017"] && [lng isEqualToString:@"120.063697"]){
            self.Imgjuli.hidden = YES;
            self.Juli.hidden = YES;
        }
        
        if([lat isEqualToString:@"0.00000"] && [lng isEqualToString:@"0.00000"]){
            self.Imgjuli.hidden = YES;
            self.Juli.hidden = YES;
        }
    }
}

@end
