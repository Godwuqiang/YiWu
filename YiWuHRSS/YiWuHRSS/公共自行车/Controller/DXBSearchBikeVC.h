//
//  DXBSearchBikeVC.h
//  YiWuHRSS
//
//  Created by 大白 on 2017/8/2.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DXBMAPointAnnotation.h"

@protocol SearchBikeDelegate <NSObject>

- (void)searchBikeVC:(BOOL)searchBikeVC MapointAnnotation:(DXBMAPointAnnotation *)annotation andSearchkey:(NSString*)searchkey andSearchList:(NSMutableArray *)list_array;

- (void)goBackVC;

@end

@interface DXBSearchBikeVC : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *tf_search;

@property (weak, nonatomic) IBOutlet UIImageView *img_nobike;

@property (weak, nonatomic) IBOutlet UILabel *lb_nobike;

@property (weak, nonatomic) IBOutlet UITableView *tableView;


//CLLocationCoordinate2D
@property (nonatomic, assign) CLLocationCoordinate2D coordinate2D;

@property (nonatomic, strong)  NSString *key;

@property (nonatomic, strong) NSMutableArray *searchDataArr;

@property(nonatomic, assign)id<SearchBikeDelegate>delegate;

@end
