//
//  ZTTableViewController.m
//  ZTTableViewController
//
//  Created by 武镇涛 on 15/7/28.
//  Copyright (c) 2015年 wuzhentao. All rights reserved.
//

#import "ZTTableViewController.h"
#import "NewsInfoCell.h"
#import "ZTPage.h"
#import "NoLimitScorllview.h"
#import "UIImageView+WebCache.h"


@interface ZTTableViewController ()<NoLimitScorllviewDelegate,UITableViewDelegate,UITableViewDataSource>{
    UITableView    *ItemForeTable;
    NSMutableArray *NewsArray;
    NSMutableArray *images;
    NSMutableArray *titlles;
    NSInteger       currentPage;
    NSString        *keyword;

}

@property(nonatomic, strong)   MBProgressHUD    *HUD;

@end

@implementation ZTTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NewsArray = [NSMutableArray array];
    images = [NSMutableArray array];
    titlles = [NSMutableArray array];
    
    self.tableView.frame = CGRectMake(0, 0, SCREEN_WIDTH,SCREEN_HEIGHT - 50);
    [self.tableView registerNib:[UINib nibWithNibName:@"NewsInfoCell" bundle:nil] forCellReuseIdentifier:@"NewsInfoCell"];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self SetImageDefault];
        // 上拉加载更多
//        self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(QureDataMore)];
//      [self QuerNewsList];
}

/**
 *  显示加载中动画
 */
- (void)showLoadingUI{
    [MBProgressHUD hideAllHUDsForView:self.navigationController.view animated:YES];
    self.HUD = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    self.HUD.labelText = @"数据加载中...";
}

//下拉加载更多
-(void)QureDataMore{
    currentPage = currentPage + 1;
//     [NewsBL QureNewsFoucesList:currentPage Page_size:MAX_PAGE_COUNT App_type:@"1" Key_words:keyword];
}


//第一次请求数据  写出来是因为后期搜索按钮相应事件的时候的传递字段
-(void)QuerNewsList{
//    [self showLoadingUI];
     currentPage =1;//默认加载第一页
//    [NewsBL QureNewsFoucesImagesList:@"5" Png_type:@"1"];
//    [NewsBL QureNewsFoucesList:currentPage Page_size:MAX_PAGE_COUNT App_type:@"1" Key_words:keyword];
}



//-(void)QureNewsListSuccess:(NSMutableArray *)NewsList{
//    self.HUD.hidden = YES;
//    if (currentPage == 1) {//第一页数据
//        [NewsArray removeAllObjects];
//    }
//   
//    
//    [self.tableView.footer endRefreshing];
//    if (NewsList.count != 0) {
//        [NewsArray addObjectsFromArray:NewsList];
//    }else [MBProgressHUD showError:@"没有更多数据了"];
//    [self.tableView reloadData];
//}
//-(void)QureNewsListFail:(NSString *)error{
//    [MBProgressHUD showError:error];
//    self.HUD.hidden = YES;
//     [self.tableView.footer endRefreshing];
//}
//
//
//-(void)QureNewsImagesListFail:(NSString *)error{
//    [MBProgressHUD showError:error];
//     self.HUD.hidden = YES;
//     [self SetImageDefault];
//}
//
//-(void)QureNewsImagesListSuccess:(NSMutableArray *)ImagesList{
//      self.HUD.hidden = YES;
//    [images removeAllObjects];
//    [titlles removeAllObjects];
//    for (int i = 0; i < ImagesList.count; i++) {
//        NewsFocusImageBean * bean =ImagesList[i];
//        [images addObject:bean.pngurl==nil?@"":bean.pngurl];
//        [titlles addObject:bean.pngtitle==nil?@"":bean.pngtitle];
//    }
//    NoLimitScorllview *view = [[NoLimitScorllview alloc]initWithShowImages:images AndTitals:titlles];
//    view.delegate = self;
//    self.tableView.tableHeaderView = view;
//}

//设置轮播图的默认设置
-(void)SetImageDefault{
    NSArray *images_defaut = @[@"banner",@"banner",@"banner",@"banner"];
    NSArray *titlles_defaut = @[@"新闻信息",@"新闻信息",@"新闻信息",@"新闻信息"];
    NoLimitScorllview *view = [[NoLimitScorllview alloc]initWithShowImages:images_defaut AndTitals:titlles_defaut];
    view.delegate = self;
    self.tableView.tableHeaderView = view;
}



-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    NewsBean * bean = NewsArray[indexPath.row];
//    UIStoryboard *UB = [UIStoryboard storyboardWithName: @"Information" bundle: nil];
//    NewsDetailVC *VC = [UB instantiateViewControllerWithIdentifier:@"NewsDetailVC"];
//    [VC setValue:bean forKey:@"newbean"];
//    VC.hidesBottomBarWhenPushed = YES;
//    [self.navigationController pushViewController:VC animated:YES];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
//    return NewsArray.count;
    return 8;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 90;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    NewsBean *bean  = [NewsArray objectAtIndex:indexPath.row];
//    InfoItemFiveCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InfoItemFiveCell"];
//    if ( nil == cell ){
//        cell = [[InfoItemFiveCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"InfoItemFiveCell"];
//    }
//    cell.Title.text = bean.title;
//    NSString * time = [bean.cretime substringToIndex:11];
//    cell.Time.text = time;
//    
//    NSArray *  igArray = [bean.attachimage componentsSeparatedByString:@";"]; //从字符 ; 中分隔成n个元素的数组
//    if (igArray.count > 0) {
//        NSURL *URL = [NSURL URLWithString:igArray[0]];
//        [cell.ig_imageview sd_setImageWithURL:URL placeholderImage:[UIImage imageNamed:@"No-Picture_s"]];
//    }
//    if([Util IsStringNil:bean.subdoctitle]){//是否显示文号
//        cell.ig_Hot.hidden = YES;
//    }else cell.ig_Hot.hidden = NO;
    
    // 创建单元格
    static NSString *InfoID = @"NewsInfoCell";
    NewsInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:InfoID];
    if ( nil == cell ){
        cell = [[NewsInfoCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:InfoID];
    }
    
    return cell;
}

//- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
//    return YES;
//}

- (void)NoLimitScorllview:(NoLimitScorllview *)scorllview ImageDidSelectedWithIndex:(int)index {
    DMLog(@"点击了焦点的轮播图的第%d图片",index);
}

@end
