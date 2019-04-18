//
//  DTFPrivateMsgVC.m
//  YiWuHRSS
//
//  Created by Dabay on 2017/7/27.
//  Copyright © 2017年 许芳芳. All rights reserved.
//

#import "DTFPrivateMsgVC.h"
#import "DTFPrivateMessageCell.h"
#import "DTFPrivateMessageBean.h" //私信列表中，私信的数据模型
#import "FTPopOverMenu.h"
#import "HttpHelper.h"
#import "MJExtension.h"
#import "DTFLongPressGestureRecognizer.h"

#define  PUSH_MASSAGE_LSIT_URL                  @"news/getPushMsgSingele.json"              //获取个推消息列表(原生)
#define  UPDATE_SINGELE_MASSAGE_READ_URL        @"news/updateSingleOneRead.json"            //修改单条个推消息已读(原生)
#define  UPDATE_ALL_MASSAGE_READ_URL            @"news/updatePushSingleRead.json"           //修改个推列表全部已读(原生)
#define  DELETE_SELETE_MASSAGE_URL              @"news/deletePushSingleList.json"           //批量/单个删除个推消息列表(原生)
#define  DELETE_ALL_MASSAGE_URL                 @"news/deletePushSingle.json"               //删除全部个推消息(原生)





#define  BUTTON_TAG_PLUS 235
#define  DELETE_BUTTON_TAG_PLUS 466258


@interface DTFPrivateMsgVC ()<UIGestureRecognizerDelegate>

//tableView里面的数据模型数组
@property (nonatomic ,strong)   NSMutableArray<DTFPrivateMessageBean *> * privateMassagegList;

@property (nonatomic ,assign)   BOOL            isAllRead;                     // 是否全部已读

@property      BOOL     hasMoreData;  // 是否已经加载完全部数据

//删除按钮相关
@property (nonatomic ,strong)   NSIndexPath     * longPressToDeleteIndexPath;   //长按去删除的indexPath


//编辑相关--批量删除
@property (nonatomic, strong)   UIButton        * editBut;
@property (nonatomic ,assign)   BOOL            isEdit;                        // 是否处于批量删除状态


//网络请求相关
@property (nonatomic, assign)   NSInteger pageNum;//私信的页码



//全选的View
@property(nonatomic ,strong)    UIView          * selectAllView;                   //底部全选对应的View
@property (nonatomic ,strong)   UIButton        * selectAllButton;                 //底部全选对应的全选按钮
@property (nonatomic ,strong)   UIButton        * deleteSelectedMessageButton;     //底部全选对应的删除按钮


@property (nonatomic, weak)AFNetworkReachabilityManager *manger;


@property (nonatomic, strong)UIImageView *tipsImageView;
@property (nonatomic, strong)UILabel *tipsLabel;
@property (nonatomic, strong)UIButton *tipsButton;



@end

@implementation DTFPrivateMsgVC

//私信消息
static NSString *const DTFPrivateMessageCellId=@"DTFPrivateMessageCellId";


-(NSMutableArray<DTFPrivateMessageBean *> *)privateMassagegList{


    if(_privateMassagegList == nil){
    
        _privateMassagegList = [NSMutableArray array];
    
    }
    return _privateMassagegList;
}


-(UIView *)selectAllView{


    if(_selectAllView ==nil){
    
        _selectAllView = [[UIView alloc]initWithFrame:CGRectMake(0, [UIScreen mainScreen].bounds.size.height-60, [UIScreen mainScreen].bounds.size.width, 60)];
        _selectAllView.backgroundColor = [UIColor colorWithHex:0xfff3de];
        
        //分割线
        UIView *seperateView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 1)];
        seperateView.backgroundColor = [UIColor colorWithHex:0xfdb731];
        [_selectAllView addSubview:seperateView];
        
        
        //设置全选按钮
        UIButton * selectAllButton = [UIButton buttonWithType:UIButtonTypeCustom];
        selectAllButton.frame = CGRectMake(0, 0, 100, 60);
        [selectAllButton setImage:[UIImage imageNamed:@"message_select"] forState:UIControlStateNormal];
        [selectAllButton setImage:[UIImage imageNamed:@"message_select_on"] forState:UIControlStateSelected];
        [selectAllButton setImage:[UIImage imageNamed:@"message_select_on"] forState:UIControlStateHighlighted];
        [selectAllButton setTitle:@"全选" forState:UIControlStateNormal];
        [selectAllButton setTitle:@"全选" forState:UIControlStateSelected];
        [selectAllButton setTitle:@"全选" forState:UIControlStateHighlighted];
        [selectAllButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateNormal];
        [selectAllButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateSelected];
        [selectAllButton setTitleColor:[UIColor colorWithHex:0xfdb731] forState:UIControlStateHighlighted];
        [selectAllButton addTarget:self action:@selector(selectAllMessage) forControlEvents:UIControlEventTouchUpInside];
        [selectAllButton setImageEdgeInsets:UIEdgeInsetsMake(0, 20, 0, 30)];
        [selectAllButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 30, 0, 0)];
        self.selectAllButton = selectAllButton;
        [_selectAllView addSubview:selectAllButton];
        
        
        //设置删除按钮
        UIButton * deleteSelectedMessageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        deleteSelectedMessageButton.frame = CGRectMake(SCREEN_WIDTH-100-10, 8, 100, 46);
        [deleteSelectedMessageButton setTitle:@"删除" forState:UIControlStateNormal];
        [deleteSelectedMessageButton setTitle:@"删除" forState:UIControlStateSelected];
        [deleteSelectedMessageButton setTitle:@"删除" forState:UIControlStateHighlighted];
        [deleteSelectedMessageButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [deleteSelectedMessageButton setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
        deleteSelectedMessageButton.layer.cornerRadius = 5.0;
        deleteSelectedMessageButton.tag = 456;
        deleteSelectedMessageButton.clipsToBounds = YES;
        [deleteSelectedMessageButton addTarget:self action:@selector(deleteSelectedMessage) forControlEvents:UIControlEventTouchUpInside];
        self.deleteSelectedMessageButton = deleteSelectedMessageButton;
        [_selectAllView addSubview:deleteSelectedMessageButton];
        
        
        

    }
    return _selectAllView;
}


/** 选中所有的消息按钮点击事件 */
-(void)selectAllMessage{
    
    
    self.selectAllButton.selected = !self.selectAllButton.selected;
    
    if(self.selectAllButton.selected){
    
        for (DTFPrivateMessageBean * bean in self.privateMassagegList) {
            
            bean.isSelectedMessage = YES;
        }
    }else{
    
        for (DTFPrivateMessageBean * bean in self.privateMassagegList) {
            
            bean.isSelectedMessage = NO;
        }
    }
    
    [self.tableView reloadData];
}


/** 删除选中的消息 */
-(void)deleteSelectedMessage{
    

    BOOL isSelectedMessage = NO;
    
    NSMutableString * selectedMessageIDs = [NSMutableString string];
    
    for (DTFPrivateMessageBean * bean in self.privateMassagegList) {
        
        if(bean.isSelectedMessage){
        
            isSelectedMessage = YES;
            [selectedMessageIDs appendFormat:@"%@;",bean.msgId];//拼接要删除消息的ID
        }
    }
    
    
    if(!isSelectedMessage){//有选中的消息或者全选
    
        [MBProgressHUD showError:@"请选择需要删除的消息"];
        return ;
    }else{//
        
        NSString * deleteMessageIDs = [selectedMessageIDs substringToIndex:selectedMessageIDs.length-1];
    
        
        if(self.selectAllButton.selected){
        
            [self deleteAllMessage];//删除所有的消息
        
        }else{
            
            //删除选中的消息
            [self deleteSeleteMessages:deleteMessageIDs];
        
        }
        
        
    
    }
}


#pragma mark - 多选删除/全选删除 消息


/**
 批量/单个删除个推消息列表(原生)

 @param deleteMessageIDs 删除选中的消息
 */
-(void)deleteSeleteMessages:(NSString *)deleteMessageIDs{
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"msg_id_list"] = deleteMessageIDs;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,DELETE_SELETE_MASSAGE_URL];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
            [self.editBut setTitle:@"" forState:UIControlStateNormal];
            self.isEdit = NO;//取消编辑模式
            
            [self.tableView.header beginRefreshing];
            
            //请求最新的信息数据
            [self getNewPrivateMassageList];
            
        }else if ([dictData[@"resultCode"] integerValue] == 401){//401.未查询到该用户信息
            
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF--批量/单个删除个推消息列表(原生)--请求失败--%@",error);
    }];

}


#pragma mark - 删除所有的个推消息
/** 删除所有的个推消息 */
-(void)deleteAllMessage{
    
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,DELETE_ALL_MASSAGE_URL];
    
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
            [self.editBut setTitle:@"" forState:UIControlStateNormal];
            self.isEdit = NO;//取消编辑模式
            
            [self.tableView.header beginRefreshing];
            
            //请求最新的信息数据
            [self getNewPrivateMassageList];
            
        }else if ([dictData[@"resultCode"] integerValue] == 401){//401.未查询到该用户信息
            
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF--删除所有的个推消息--请求失败--%@",error);
    }];
}



- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的私信";
    
    //自定义左边 的按钮
    UIButton *leftButton = [[UIButton alloc]init];
    leftButton.frame = CGRectMake(0, 10, 20, 20);
    [leftButton setBackgroundImage:[UIImage imageNamed:@"arrow_return"] forState:UIControlStateNormal];
    [leftButton addTarget:self action:@selector(doclickLeftButton) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItems = [[UIBarButtonItem alloc]initWithCustomView:leftButton];
    //解决按钮不靠左 靠右的问题.
    UIBarButtonItem *nagetiveSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    nagetiveSpacer.width = -12;//这个值可以根据自己需要自己调整
    self.navigationItem.leftBarButtonItems = @[nagetiveSpacer, leftBarButtonItems];
    
    [self initData];
    
    
    [self afn];
    
    self.view.backgroundColor = [UIColor colorWithHex:0xeeeeee];
    
    //tap手势，小时之前弹出的删除按钮
//    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapToDismissDeleteButton)];
//    [self.view addGestureRecognizer:tap];
    
    
    //初始化tableView
    [self setupTableview];
    
    self.editBut = [UIButton buttonWithType:UIButtonTypeCustom];
    self.editBut.frame = CGRectMake(0, 0, 40, 19);
    [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
    self.editBut.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.editBut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.editBut addTarget:self action:@selector(onNavButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.editBut];
    self.editBut.hidden = YES;
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self.tableView.header beginRefreshing];
    [self setupNavigationBarStyle];
}

- (void)setupNavigationBarStyle{
    // 更改导航栏字体颜色为白色
    NSDictionary * dict = @{NSForegroundColorAttributeName: [UIColor whiteColor],
                            NSFontAttributeName:[UIFont boldSystemFontOfSize:20.0]};
    [self.navigationController.navigationBar setTitleTextAttributes:dict];
    [self.navigationController.navigationBar setBackgroundImage:nil
                                                 forBarPosition:UIBarPositionAny
                                                     barMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHex:0xfdb731]];
    // 去除 navigationBar 下面的线
    [self.navigationController.navigationBar setShadowImage:[UIImage new]];
}


-(void)viewDidDisappear:(BOOL)animated{
    [self.manger stopMonitoring];
    self.manger = nil;
}


/**
 tap手势显示先前显示的删除按钮
 */
-(void)tapToDismissDeleteButton{
    
    for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
        bean.isCellDeleteViewShow = NO;
    }
    
    [self.tableView reloadData];

}

#pragma mark - 初始化数据
- (void)initData{

    self.isEdit = NO;
    self.isAllRead = NO;
    self.hasMoreData = YES;
}

#pragma mark -  返回按钮
-(void)doclickLeftButton{
    
    if ([self.type isEqualToString:@"消息中心"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }else if ([self.type isEqualToString:@"推送"]) {
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}

#pragma mark - 下拉显示功能按钮
-(void)onNavButtonTapped:(UIBarButtonItem *)sender event:(UIEvent *)event {
    
    if (_isEdit) {
        self.isEdit = NO;
        [self.editBut setImage:[UIImage imageNamed:@"icon_message_plus"] forState:UIControlStateNormal];
        [self.editBut setTitle:@"" forState:UIControlStateNormal];

    }else{
        [FTPopOverMenu showFromEvent:event
                       withMenuArray:@[@"全部已读",@"批量删除"]
                          imageArray:@[@"icon_message_read",@"icon_message_delete"]
                           doneBlock:^(NSInteger selectedIndex) {
                               if (selectedIndex==0) {   // 全部已读
                                   self.isAllRead = YES;
                                   //设置全部消息为已读网络请求
                                   [self changeAllPrivateMsgRead];

                               }else{       // 批量删除
                                   [self.editBut setImage:nil forState:UIControlStateNormal];
                                   [self.editBut setTitle:@"取消" forState:UIControlStateNormal];
                                   self.isEdit = YES;//进入编辑模式

                               }
                           } dismissBlock:^{
                               
                           }];
    }
}



/**
 批量删除--编辑（多选或者全选）

 @param isEdit 是否批量删除
 */
-(void)setIsEdit:(BOOL)isEdit{

    _isEdit = isEdit;
    
    
    if(_isEdit){
    
        //隐藏所有的折叠按钮
        for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
            
            bean.isFoldButtonHidden =YES;
        }
    
    }else{
        
        //显示所有的折叠按钮
        for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
            
            bean.isFoldButtonHidden =NO;
        }
    
    
    }
    
    
    
    
    for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
        bean.isCellDeleteViewShow = NO;
    }
    
    [self.tableView reloadData];
    
    
    if(_isEdit){//编辑模式
    
        self.selectAllButton.selected = NO;
        CGRect tableViewFrame = self.tableView.frame;
        self.tableView.frame = CGRectMake(0, 0, tableViewFrame.size.width, tableViewFrame.size.height-60);
        [self.view.superview addSubview:self.selectAllView];
    }else{//非编辑模式
        self.selectAllButton.selected = NO;
        CGRect tableViewFrame = self.tableView.frame;
        self.tableView.frame = CGRectMake(0, 0, tableViewFrame.size.width, tableViewFrame.size.height+60);
        [self.selectAllView removeFromSuperview];
        
        //取消之前选中的标识
        for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
            bean.isSelectedMessage = NO;
        }

    }
    
    [self.tableView reloadData];

}





#pragma mark - 设置私信消息为全部已读


/** 设置私信消息为全部已读 */
-(void)setAllMessageRead{

    DMLog(@"设置私信为全部已读");
}




#pragma mark - 初始化tableView
-(void)setupTableview{

    self.tableView = [[UITableView alloc]initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    self.tableView.allowsMultipleSelectionDuringEditing = YES;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"DTFPrivateMessageCell" bundle:nil] forCellReuseIdentifier:DTFPrivateMessageCellId];
    self.tableView.header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getNewPrivateMassageList)];
    self.tableView.footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(getMorePrivateMassageList)];


    //开始刷新
    [self.tableView.header beginRefreshing];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    for (DTFPrivateMessageBean *bean  in self.privateMassagegList) {
        bean.isCellDeleteViewShow = NO;
    }
    [self.tableView reloadData];
}

#pragma mark - 私信列表的数据源代理方法的实现

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.privateMassagegList.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (self.hasMoreData) {
        return 0.1;
    }else{
        return 30;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    DTFPrivateMessageCell *cell = [DTFPrivateMessageCell privateMassageCell];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    DTFPrivateMessageBean * messageBean = self.privateMassagegList[indexPath.row];
    
    cell.foldButton.tag = indexPath.row + BUTTON_TAG_PLUS;//设置折叠按钮的tag
    [cell.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    
    
    
    //Cell添加长按手势实现
    DTFLongPressGestureRecognizer *longPressedToDelete = [[DTFLongPressGestureRecognizer alloc]initWithTarget:self action:@selector(deleteSinglePrivateMessage:)];
    longPressedToDelete.indexPath = indexPath;//设置长按手势对应的indexPath
    longPressedToDelete.delegate = self;
    [cell addGestureRecognizer:longPressedToDelete];
    
    //设置cell中删除按钮的点击事件
    [cell.cellDeleteButton addTarget:self action:@selector(deleteCell:) forControlEvents:UIControlEventTouchUpInside];
    cell.cellDeleteButton.tag = indexPath.row + DELETE_BUTTON_TAG_PLUS;
    
    

    //是否处于编辑模式，即为批量删除
    if(self.isEdit){
    
        cell.isEditing = YES;
    }else{
    
        cell.isEditing = NO;
    }

    cell.messageBean = messageBean;
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    
    if (self.hasMoreData) {
        return nil;
    }else{
        UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
        footerView.backgroundColor = [UIColor colorWithHex:0xeeeeee];
        
        UILabel *Lb = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH/2 - 100, 10, 200, 16)];
        Lb.font = [UIFont systemFontOfSize:13];
        Lb.textColor = [UIColor colorWithHex:0x999999];
        Lb.text = @"没有更多私信了~";
        Lb.textAlignment = NSTextAlignmentCenter;
        
        [footerView addSubview:Lb];
        return footerView;
    }
}


-(void)deleteCell:(UIButton *)deleteButton{
    
    NSLog(@"cell中的删除按钮被点击--%li",deleteButton.tag-DELETE_BUTTON_TAG_PLUS);
    
    
    
    //删除按钮被点击，删除单条删除
    [self toDeletePrivateMsg:deleteButton];



}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    //消除弹出的删除按钮
    for (DTFPrivateMessageBean *bean  in self.privateMassagegList) {
        bean.isCellDeleteViewShow = NO;
    }
    [self.tableView reloadData];

    if(self.isEdit){
    
        self.privateMassagegList[indexPath.row].isSelectedMessage = !self.privateMassagegList[indexPath.row].isSelectedMessage;
    }
    
    
    
    //如果有没选中的cell，全选按钮为未选中;
    
    
    for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
        
        if(!bean.isSelectedMessage){
        
            self.selectAllButton.selected = NO;
        
        }
    }
    
    //如果没有全部选中，全选按钮被取消选中
    BOOL isAllSelected = YES;
    for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
        
        if(!bean.isSelectedMessage){//如果有没有选中的cell
        
            isAllSelected =  NO;
        }
    }
    
    
    if(isAllSelected){
    
        self.selectAllButton.selected = YES;
    }
    
    

    [self.tableView reloadData];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
    
    if(self.privateMassagegList[indexPath.row].isFoldMessage){//折叠的cell

    CGFloat titleHeight = [self.privateMassagegList[indexPath.row].title getHeightBySizeOfFont:14 width:([UIScreen mainScreen].bounds.size.width-90)];
        
        return 50.0 + titleHeight +20;
    }else{//展开的cell
        
        CGFloat titleHeight = [self.privateMassagegList[indexPath.row].title getHeightBySizeOfFont:14 width:([UIScreen mainScreen].bounds.size.width-90)];

        return titleHeight + 70 + [self.privateMassagegList[indexPath.row].content getHeightBySizeOfFont:13 width:[UIScreen mainScreen].bounds.size.width-40] +30;
    }
}







/**
 获取最新的私信数据列表
 */
-(void)getNewPrivateMassageList{

//    初始化请求页数为第一页
    self.pageNum = 1;
    self.selectAllButton.selected = NO;
    self.hasMoreData = YES;
    [self.tableView.footer endRefreshing];
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"page_num"] = [NSString stringWithFormat:@"%li",self.pageNum];
    param[@"page_size"] = @"10";//每次请求10条数据
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,PUSH_MASSAGE_LSIT_URL];

    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        DMLog(@"%@",dictData);
        
        if([dictData[@"resultCode"] integerValue] == 200){//查询成功
        
            if(dictData[@"data"] == nil){
            
                //没有数据时就直接返回
                return ;
            }
            
            self.privateMassagegList = [DTFPrivateMessageBean mj_objectArrayWithKeyValuesArray:dictData[@"data"]];
            [self.tableView reloadData];
            [self.tableView.header endRefreshing];
        
            for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
                
                if([bean.readStatus integerValue] == 0){//未读消息
                
                
                    bean.isFoldMessage = YES;
                }else{//已读消息
                
                    bean.isFoldMessage = NO;
                }
            }
            
            if(self.privateMassagegList.count == 0){
        
                self.editBut.hidden = YES;
                [self showNoDataView];//显示无数据页面
            }else{
            
            
                self.editBut.hidden = NO;
            }
        
        }else if ([dictData[@"resultCode"] integerValue] == 5001 || [dictData[@"resultCode"] integerValue] == 5002) { //登录失效
            self.editBut.hidden = YES;
            
            [self.tableView.header endRefreshing];
            [self.privateMassagegList removeAllObjects];
            [self.tableView reloadData];
            [self showNoLoginView];//显示登录失效页面
            
            
        }else{
            self.editBut.hidden = YES;
            
            
            [self.tableView.header endRefreshing];
            [self.privateMassagegList removeAllObjects];
            [self.tableView reloadData];
            [self showBusyView];//显示系统繁忙页面
            
        }
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----获取最新的私信数据列表--请求失败--%@",error);
        self.editBut.hidden = YES;
        [self.tableView.header endRefreshing];
        [self.privateMassagegList removeAllObjects];
        [self.tableView reloadData];
        [self showBusyView];//显示系统繁忙页面
    }];

}


-(void)getMorePrivateMassageList{
    
    if (self.hasMoreData) {
        self.pageNum ++;
        
        NSMutableDictionary *param = [NSMutableDictionary dictionary];
        param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
        param[@"device_type"] = @"2";
        param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
        param[@"page_num"] = [NSString stringWithFormat:@"%li",self.pageNum];
        param[@"page_size"] = @"10";//每次请求10条数据
        
        NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,PUSH_MASSAGE_LSIT_URL];
        
        
        [HttpHelper post:url params:param success:^(id responseObj) {
            
            NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
            
            if([dictData[@"resultCode"] integerValue] == 200){//查询成功
                
                NSArray * moreMessageArray = [DTFPrivateMessageBean mj_objectArrayWithKeyValuesArray:dictData[@"data"]];
                [self.tableView reloadData];
                [self.tableView.header endRefreshing];
                
                for (DTFPrivateMessageBean *bean in moreMessageArray) {
                    
                    if([bean.readStatus integerValue] == 0){//未读消息
                        
                        
                        bean.isFoldMessage = YES;
                    }else{//已读消息
                        
                        bean.isFoldMessage = NO;
                    }
                }
                
                [self.privateMassagegList addObjectsFromArray:moreMessageArray];
                
                //如果没有数据了
                
                DMLog(@"moreMessageArray  -- %li",moreMessageArray.count);
                if(moreMessageArray.count == 0){
                    self.hasMoreData = NO;
                    self.pageNum --;
                    [self.tableView.footer endRefreshing];
                    [self.tableView.footer noticeNoMoreData];
                    [MBProgressHUD showSuccess:@"没有更多私信了~"];
                    
                }
                
            }
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            [self.tableView reloadData];
            
        } failure:^(NSError *error) {
            self.pageNum --;
            
            [self.tableView.header endRefreshing];
            [self.tableView.footer endRefreshing];
            [self.tableView reloadData];
            DMLog(@"DTF----获取最新的私信数据列表--请求失败--%@",error);
        }];
    }else{
    
        [self.tableView.footer endRefreshing];
        [self.tableView.footer noticeNoMoreData];
    
    }
}



#pragma mark - 显示无数据页面
/** 显示无数据页面 */
-(void)showNoDataView{

    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    
    self.editBut.hidden = YES;
    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_nodata"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 100, 223, 206);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH -30.0))*0.5, 100+206, (SCREEN_WIDTH -30.0), 30);
    noDataTipsLabel.font = [UIFont systemFontOfSize:15];
    noDataTipsLabel.textColor = [UIColor colorWithHex:0x999999];
    noDataTipsLabel.text = @"当前暂无消息~";
    noDataTipsLabel.textColor = [UIColor darkGrayColor];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.tipsLabel];

}

#pragma mark - 显示登录失效页面
/** 显示无数据页面 */
-(void)showNoLoginView{
    
    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    
    self.editBut.hidden = YES;
    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_busy"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 100, 223, 191);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - ((SCREEN_WIDTH -30.0)))*0.5, 100+191, (SCREEN_WIDTH -30.0), 40);
    noDataTipsLabel.font = [UIFont systemFontOfSize:15];
    noDataTipsLabel.numberOfLines = 0;
    noDataTipsLabel.textColor = [UIColor colorWithHex:0X999999];
    noDataTipsLabel.text = @"找不到您的登录信息，请重新登录试试~";
    noDataTipsLabel.textColor = [UIColor darkGrayColor];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.tipsLabel];
    
}


#pragma mark - 折叠按钮的点击

-(void)foldButtonClick:(UIButton *)foldButton{

    DMLog(@"tableView中--折叠按钮的点击--选中cell的index：%li",foldButton.tag-BUTTON_TAG_PLUS);
    
    
    //判断之前有弹出删除按钮
    BOOL hasDeleteViewShow = NO;
    
    for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
        
        if(bean.isCellDeleteViewShow){
        
            hasDeleteViewShow = YES;
        }
    }
    
    //之前有弹出删除按钮的时候，此时点击折叠按钮的时候，消除之前弹出的删除按钮，不改变折叠状态
    if(hasDeleteViewShow){
        
        for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
            bean.isCellDeleteViewShow = NO;
        }
        return ;
    }
    
    
    
    
    DTFPrivateMessageBean *massageBean = self.privateMassagegList[foldButton.tag-BUTTON_TAG_PLUS];//展开按钮对应的cell的数据模型
    massageBean.isFoldMessage = !massageBean.isFoldMessage;//修改数据模型中的是否折叠消息状态
    massageBean.isCellDeleteViewShow = NO;
    
    if(!massageBean.isFoldMessage){//如果改变后为展开的消息
        massageBean.readStatus = @"1";//修改数据模型中的标识为已读
        [self changeSinglePrivateMsgRead:massageBean.msgId];//网络请求修改单条消息为已读
    }
    
    self.privateMassagegList[foldButton.tag-BUTTON_TAG_PLUS] = massageBean;//修改数组中的数据模型
    [self.tableView reloadData];//刷新表格
    
}




#pragma mark - 长按出现删除按钮

-(void)deleteSinglePrivateMessage:(DTFLongPressGestureRecognizer *)longPress{
    
    
    
    NSLog(@"cell--长按手势添加--%li",longPress.indexPath.row);
    if (self.isEdit) {
        return;
    }
    
    //1.消除上次长按手势的背景阴影
    if(self.longPressToDeleteIndexPath != nil){
        
        DTFPrivateMessageCell * preCell = [self.tableView cellForRowAtIndexPath:self.longPressToDeleteIndexPath];

        //将之前显示的删除按钮进行隐藏
        preCell.messageBean.isCellDeleteViewShow = NO;
        
        
        if(preCell.messageBean.isFoldMessage){//是折叠的消息
        
            
            preCell.bgImageView.image = [UIImage imageNamed:@"message_dialog1"];
        
        }else{//展开的消息
        
            preCell.bgImageView.image = [UIImage imageNamed:@"message_dialog3"];
        }
    
    }
    
    //1.获取长按手势对应的Cell
    DTFPrivateMessageCell *cell = [self.tableView cellForRowAtIndexPath:longPress.indexPath];
    
    
    
    
    
    //2.设置要删除的消息的indexPath
    self.longPressToDeleteIndexPath = longPress.indexPath;
    
    DTFPrivateMessageBean * bean = self.privateMassagegList[longPress.indexPath.row];
    bean.isCellDeleteViewShow = YES;
    
    [self.tableView reloadData];
    
    
    
    
    //4.长按弹出删除按钮时cell背景的改变
    [self showDeleteButtonChangeCellImage:cell];
    
}



/**
 显示删除按钮时，cell背景图片的改变

 @param cell cell
 */
-(void)showDeleteButtonChangeCellImage:(DTFPrivateMessageCell *)cell{
    
    
    //1.改变长按的Cell的背景图片
    if(cell.messageBean.isFoldMessage){//折叠的消息背景
        
        cell.bgImageView.image = [UIImage imageNamed:@"message_dialog_mask1c"];
        
    }else{//展开的消息背景
        
        cell.bgImageView.image = [UIImage imageNamed:@"message_dialog_mask3"];
    }
    
    cell.noticeContentView.backgroundColor = [UIColor clearColor];



}


#pragma mark - 删除单条消息
-(void)toDeletePrivateMsg:(UIButton *)button{
    
    DMLog(@"删除按钮被点击--%li",self.longPressToDeleteIndexPath.row);
    
    
    
    //发送网络请求，删除选中的消息
    [self deleteSeleteMessages:self.privateMassagegList[self.longPressToDeleteIndexPath.row].msgId];
    
    
    //删除本控制器列表中的数据
    [self.privateMassagegList removeObjectAtIndex:self.longPressToDeleteIndexPath.row];
    
    
    [self.tableView reloadData];
}




#pragma mark - 修改单条消息为已读网络请求

-(void)changeSinglePrivateMsgRead:(NSString *)msg_id{

    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    param[@"msg_id"] = msg_id;
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UPDATE_SINGELE_MASSAGE_READ_URL];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
        }
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----修改单条消息问已读--请求失败--%@",error);
    }];
}


#pragma mark - 修改全部消息为已读网络请求

-(void)changeAllPrivateMsgRead{
    
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"access_token"] = [CoreArchive strForKey:LOGIN_ACCESS_TOKEN];
    param[@"device_type"] = @"2";
    param[@"app_version"] = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    NSString *url = [NSString stringWithFormat:@"%@/%@",HOST_TEST,UPDATE_ALL_MASSAGE_READ_URL];
    
    [HttpHelper post:url params:param success:^(id responseObj) {
        
        NSDictionary *dictData = [NSJSONSerialization JSONObjectWithData:responseObj options:kNilOptions error:nil];
        
        if([dictData[@"resultCode"] integerValue] == 200){//操作成功
            
            DMLog(@"修改全部消息为已读网络请求");
            
            for (DTFPrivateMessageBean *bean in self.privateMassagegList) {
                bean.readStatus= @"1";
                bean.isFoldMessage = NO;
                [self.tableView reloadData];
            }
        }else if ([dictData[@"resultCode"] integerValue] == 402){//402.未查询到未读信息
        
            [MBProgressHUD showSuccess:[NSString stringWithFormat:@"%@",dictData[@"message"]]];
        }
        
        
    } failure:^(NSError *error) {
        
        DMLog(@"DTF----修改全部消息为已读网络请求--请求失败--%@",error);
    }];
}

#pragma mark UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    
        for (id button in touch.view.subviews) {
        
        if ([button isKindOfClass:[UIButton class]]) {//按钮被点击

            
            return NO;
        }else {
            return YES;
        }
    }
    
    
    return YES;
}

#pragma mark - 监听网络状态
-(void)afn{
    //1.创建网络状态监测管理者
    //    AFNetworkReachabilityManager *manger = [AFNetworkReachabilityManager sharedManager];
    self.manger = [AFNetworkReachabilityManager sharedManager];
    //开启监听，记得开启，不然不走block
    [self.manger startMonitoring];
    //2.监听改变
    [self.manger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusReachableViaWWAN||status==AFNetworkReachabilityStatusReachableViaWiFi) {
            DMLog(@"3G|4G|wifi");
        }else{

            [self showNoNetworkView];
        }
    }];
}


#pragma mark - 显示网络异常界面
/** 显显示网络异常界面 */
-(void)showNoNetworkView{
    
    
    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    self.editBut.hidden = YES;
    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_noweb"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 100, 223, 206);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - 200)*0.5, 100+206, 200, 30);
    noDataTipsLabel.font = [UIFont systemFontOfSize:15];
    noDataTipsLabel.text = @"服务暂不可用，请稍后重试";
    noDataTipsLabel.textColor = [UIColor colorWithHex:0x999999];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    //刷新按钮
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake((SCREEN_WIDTH - 150)*0.5, 100+206 + 30 +20, 150, 45);
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateNormal];
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateHighlighted];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [refreshButton setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    refreshButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    refreshButton.clipsToBounds = YES;
    refreshButton.layer.cornerRadius = 3;
    [refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.tipsButton = refreshButton;
    
    
   
    
    
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.tipsButton];
    
}

#pragma mark - 显示服务繁忙界面
-(void)showBusyView{
    
    [self.tipsImageView removeFromSuperview];
    [self.tipsLabel removeFromSuperview];
    [self.tipsButton removeFromSuperview];
    
    [self.tableView.header endRefreshing];
    [self.tableView.footer endRefreshing];
    self.editBut.hidden = YES;
    
    //无数据图片
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"img_noweb"]];
    imageView.frame = CGRectMake((SCREEN_WIDTH - 223)*0.5, 100, 223, 175);
    self.tipsImageView = imageView;
    
    //无数据提示
    UILabel * noDataTipsLabel = [[UILabel alloc]init];
    noDataTipsLabel.frame = CGRectMake((SCREEN_WIDTH - (SCREEN_WIDTH -30.0))*0.5, 100 + 175, (SCREEN_WIDTH -30.0), 40);
    noDataTipsLabel.font = [UIFont systemFontOfSize:15];
    noDataTipsLabel.numberOfLines = 0;
    noDataTipsLabel.text = @"当前网络不可用，请检查网络设置";
    noDataTipsLabel.textColor = [UIColor colorWithHex:0x999999];
    noDataTipsLabel.textAlignment = NSTextAlignmentCenter;
    self.tipsLabel = noDataTipsLabel;
    
    //刷新按钮
    UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    refreshButton.frame = CGRectMake((SCREEN_WIDTH - 150)*0.5, 100+206 + 30 +20, 150, 45);
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateNormal];
    [refreshButton setTitle:@"重新刷新" forState:UIControlStateHighlighted];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [refreshButton setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [refreshButton setBackgroundColor:[UIColor colorWithHex:0xfdb731]];
    refreshButton.clipsToBounds = YES;
    refreshButton.layer.cornerRadius = 3;
    refreshButton.titleLabel.font = [UIFont systemFontOfSize:15.0];
    [refreshButton addTarget:self action:@selector(refreshButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.tipsButton = refreshButton;
    
    
    
    
    
    [self.view addSubview:self.tipsImageView];
    [self.view addSubview:self.tipsLabel];
    [self.view addSubview:self.tipsButton];
    
}



/**
 点击重新刷新按钮
 */
-(void)refreshButtonClick{

    [self getNewPrivateMassageList];
}




@end
