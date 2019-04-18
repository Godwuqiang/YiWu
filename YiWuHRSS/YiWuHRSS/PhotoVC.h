//
//  PhotoVC.h
//  YiWuHRSS
//
//  Created by 许芳芳 on 16/10/24.
//  Copyright © 2016年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>


@class PhotoVC;
@protocol PhotoVCDelegate <NSObject>
@optional
- (void)didSelectedImage:(UIImage *)image andImagePath:(NSString *)imagepath andType:(NSString *)type;
- (void)didSelectedImageData:(NSData *)imagedata andType:(NSString *)type;

@end



@interface PhotoVC : UIViewController
{
    UILabel      *titlb;
    
    UIImageView  *smkaImg;
    UIImageView  *ckaImg;
}

@property (nonatomic, strong)  NSString  *type;
@property (nonatomic, weak)  id<PhotoVCDelegate> imgDelegate;

@end
