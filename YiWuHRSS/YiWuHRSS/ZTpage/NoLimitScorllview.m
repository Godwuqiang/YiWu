//
//  NoLimitScorllview.m
//  ZTTableViewController
//
//  Created by 武镇涛 on 15/7/28.
//  Copyright (c) 2015年 wuzhentao. All rights reserved.
//

#import "NoLimitScorllview.h"
#import "UIView+Extension.h"
#import   "UIImageView+WebCache.h"

@interface NoLimitScorllview ()<UIScrollViewDelegate>

@property (nonatomic, strong) UILabel  *lable;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSArray *images;
@property (nonatomic, strong) NSArray *titals;
@property (nonatomic, assign) int  currentPage;
@property (nonatomic, assign) int  numberOfImages;
@property (nonatomic, strong) NSTimer  *timer;
@property (nonatomic, strong) NSMutableArray *currentView;
@end

@implementation NoLimitScorllview

- (NSArray *)images {
    if (!_images) {
        _images = [NSArray array];
    }
    return _images;
}

- (NSArray *)titals {
    if (!_titals) {
        _titals = [NSArray array];
    }
    return _titals;
}

- (NSMutableArray *)currentView {
    if (!_currentView) {
        _currentView = [NSMutableArray array];
    }
    return _currentView;
}

- (instancetype)initWithShowImages:(NSArray *)images AndTitals:(NSArray *)titals {
    
    if (self = [super init]) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
       
        self.width = width;
        self.height = 204;
        self.images = images;
        self.titals = titals;
        self.numberOfImages = (int)images.count;
        self.currentPage = 0;
        
       
        UIScrollView *main = [[UIScrollView alloc]init];
        [self addSubview:main];
        main.frame = CGRectMake(0, 0, width, self.height);
        main.showsVerticalScrollIndicator = NO;
        main.showsHorizontalScrollIndicator = NO;
        main.pagingEnabled = YES;
        main.delegate = self;
        main.contentSize = CGSizeMake(width * 3, 0);
        main.showsHorizontalScrollIndicator = NO;
        main.contentOffset = CGPointMake(width, 0);
        self.scrollView = main;
        
        UIView *lable_shaw = [[UIView alloc]init];
        [self addSubview:lable_shaw];
        lable_shaw.frame = CGRectMake(0, self.height- 40, width, 40);
        lable_shaw.backgroundColor = [UIColor colorWithHex:0x000000];
        lable_shaw.alpha = 0.5;
        
        UILabel *lable = [[UILabel alloc]init];
        [self addSubview:lable];
        lable.frame = CGRectMake(15, self.height - 30, width*0.75, 20);
        lable.text = titals[self.currentPage];
        lable.font = [UIFont fontWithName:@"Helvetica" size:14];
        lable.textColor = [UIColor whiteColor];
        self.lable = lable;
        
        UIPageControl *pageControl = [[UIPageControl alloc]init];
        [self addSubview:pageControl];
        pageControl.frame = CGRectMake(width*0.75+25, self.height-30, width*0.25-40, 20);
        pageControl.currentPageIndicatorTintColor = [UIColor colorWithHex:0x249dee ];
        pageControl.pageIndicatorTintColor = [UIColor colorWithHex:0xb2b3b1];
        self.pageControl = pageControl;
        self.pageControl.numberOfPages = images.count;
        
        [self loadData];
        [self addtimer];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addtimer) name:UIApplicationWillEnterForegroundNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(removetimer) name:UIApplicationDidEnterBackgroundNotification object:nil];
    }
    return self;
}

- (void)addtimer {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(next) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];
}

- (void)loadData {
    self.pageControl.currentPage = self.currentPage;
    self.lable.text = self.titals[self.currentPage];
    
    [self.scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self getDisplayImagesWithCurpage:self.currentPage];
    for (int i = 0; i < 3; i++) {
        UIImageView *imageView = [self.currentView objectAtIndex:i];
        imageView.userInteractionEnabled = YES;
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [imageView addGestureRecognizer:singleTap];
        imageView.frame = CGRectMake(i * self.width, 0, self.width, self.height);
        [self.scrollView addSubview:imageView];
    }
    [self.scrollView setContentOffset:CGPointMake(self.scrollView.width, 0)];
}

- (void)getDisplayImagesWithCurpage:(int)page {
    int previous = [self cycleImageIndex:page -1];
    int next = [self cycleImageIndex:page +1];
    [self.currentView removeAllObjects];
  
    [self.currentView addObject:[self pageAtIndex:previous]];
    [self.currentView addObject:[self pageAtIndex:page]];
    [self.currentView addObject:[self pageAtIndex:next]];
}

- (int)cycleImageIndex:(int)index {
    if (index == -1) {
        return self.numberOfImages - 1;
    }else if (index == self.numberOfImages){
        return 0;
    }else{
        return index;
    }
}

- (void)next {
    CGFloat index =  self.scrollView.contentOffset.x + self.width;
    [self.scrollView setContentOffset:CGPointMake(index, 0) animated:YES];
}

- (void)removetimer {
    [self.timer invalidate];
    self.timer = nil;
}

- (UIImageView *)pageAtIndex:(NSInteger)index {
    UIImageView *imageview = [[UIImageView alloc]init];
    NSURL *name = [self.images objectAtIndex:index];
    [imageview sd_setImageWithURL:name placeholderImage:[UIImage imageNamed:@"No-Picture"]];
    return imageview;
}

- (void)handleTap:(UITapGestureRecognizer *)tap {
    
    if ([self.delegate respondsToSelector:@selector(NoLimitScorllview:ImageDidSelectedWithIndex:)]) {
        [self.delegate NoLimitScorllview:self ImageDidSelectedWithIndex:self.currentPage];
    }
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat x = scrollView.contentOffset.x;
    //最后一张的后一张
    if(x >= (2*self.frame.size.width)) {
        self.currentPage = [self cycleImageIndex:self.currentPage + 1];
        [self loadData];
    }
    //第一张的前一张
    if(x <= 0) {
        self.currentPage = [self cycleImageIndex:self.currentPage - 1];
        [self loadData];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self removetimer];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self addtimer];
}

- (void)dealloc {
    [_timer invalidate];
    _timer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
@end
