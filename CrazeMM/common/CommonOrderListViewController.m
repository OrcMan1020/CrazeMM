//
//  CommonOrderListView.m
//  CrazeMM
//
//  Created by Mao Mao on 16/5/8.
//  Copyright © 2016年 189. All rights reserved.
//

#import "CommonOrderListViewController.h"
#import "SegmentedCell.h"
#import "CommonBottomView.h"
#import "MJRefresh.h"
#import "UIAlertView+AnyPromise.h"

#define kSegmentCellHeight (40.f+self.contentHeightOffset)
#define kTableViewInsetTopWithoutSegment (kSegmentCellHeight+64)

@interface CommonOrderListViewController()

@property (nonatomic) CGPoint ptLastOffset;
@property (nonatomic) BOOL isRefreshing;

@end

@implementation CommonOrderListViewController

@synthesize segmentCell = _segmentCell;
@synthesize bottomView = _bottomView;

-(instancetype)initWithSegmentIndex:(NSInteger)index
{
    self = [super init];
    if (self) {
        self.initSegmentIndex = index;
    }
    return self;
}


-(SegmentedCell*)segmentCell
{
    if (!_segmentCell) {
        _segmentCell = [[SegmentedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentedCell"];
        _segmentCell.buttonStyle = kButtonStyleB;
        _segmentCell.height = @(40.0f);
        [_segmentCell setTitles:self.segmentTitles];
        _segmentCell.segment.currentIndex = self.initSegmentIndex;
        _segmentCell.segment.delegate = self;
        
        [self.view addSubview:_segmentCell];
        
        if (self.hiddenSegment) {
            _segmentCell.hidden = YES;
        }
        
    }
    
    return _segmentCell;
}

-(void)setHiddenSegment:(BOOL)hiddenSegment
{
    _hiddenSegment = hiddenSegment;
    self.segmentCell.hidden = hiddenSegment;
    if(!hiddenSegment){
        self.tableView.contentInset = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
    }
    else {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
}

-(void)setSegmentTitles:(NSArray *)segmentTitles
{
    _segmentTitles = segmentTitles;
    [self.segmentCell setTitles:segmentTitles];
}

-(NSInteger)selectedSegmentIndex
{
    return self.segmentCell.segment.currentIndex;
}

-(CommonBottomView*)bottomView
{
    if(!_bottomView){
        _bottomView = (CommonBottomView*)[UINib viewFromNibByClass:[CommonBottomView class]];
        [self.view addSubview:_bottomView];

        [_bottomView.confirmButton addTarget:self action:@selector(bottomViewButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView.addtionalButton addTarget:self action:@selector(bottomViewAddtionalButtonClicked:) forControlEvents:UIControlEventTouchUpInside];

        
        _bottomView.selectAllCheckBox.delegate = self;
        
        if (self.hiddenBottomView) {
            _bottomView.hidden = YES;
        }
    }
    
    return _bottomView;
}

-(void)setHiddenBottomView:(BOOL)hiddenBottomView
{
    _hiddenBottomView = hiddenBottomView;
    self.bottomView.hidden = hiddenBottomView;
    [self.tableView reloadData];
}

-(void)bottomViewButtonClicked:(UIButton*)button
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                   message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)bottomViewAddtionalButtonClicked:(UIButton*)button
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                   message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void)setBottomViewButtonTitle:(NSString *)bottomViewButtonTitle
{
    [self.bottomView.confirmButton setTitle:bottomViewButtonTitle forState:UIControlStateNormal];
}

-(void)setBottomViewAddtionalButtonTitle:(NSString *)bottomViewAddtionalButtonTitle
{
    [self.bottomView.addtionalButton setTitle:bottomViewAddtionalButtonTitle forState:UIControlStateNormal];
}

//-(void)setActionForBottomViewButtonWithTarget:(id)target andAction:(SEL)action
//{
//    [self.bottomView.confirmButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
//}
//
//-(void)setActionForBottomViewAddtonalButtonWithTarget:(id)target andAction:(SEL)action
//{
//    [self.bottomView.addtionalButton addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
//
//}

-(NSArray*)selectedData
{
    return  [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.selected != NO"]];

}
-(NSArray*)unSelectedData
{
    return  [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.selected == NO"]];
    
}

-(HttpListQueryRequest*)makeListQueryRequest
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor light_Gray_Color];
    if (!self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
        @weakify(self)
        self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
            return [RACSignal empty];
        }];
    }
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = [UIColor UIColorFromRGB:0xf1f1f1];
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    self.segmentCell.frame = CGRectMake(0, 64.f, [UIScreen mainScreen].bounds.size.width, kSegmentCellHeight);
    self.tableView.frame = self.view.bounds;
    
    self.tableView.indicatorStyle = UIScrollViewIndicatorStyleDefault;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.showsVerticalScrollIndicator = NO;
    if (!self.hiddenSegment) {
        self.tableView.contentInset = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
    }
    else
    {
        self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    [self.tableView registerNib:[UINib nibWithNibName:@"CommonListCell" bundle:nil] forCellReuseIdentifier:@"CommonListCell"];
    
    
    @weakify(self);
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        @strongify(self);
        if (self.isRefreshing) {
            [self.tableView.mj_header endRefreshing];
            return ;
        }
        self.isRefreshing = YES;
        [self handleHeaderRefresh]
        .finally(^(){
            self.isRefreshing = NO;
            [self.tableView.mj_header endRefreshing];
        });
    }];
    
    self.tableView.mj_header.automaticallyChangeAlpha = YES;
    
    self.tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        if (self.isRefreshing) {
            [self.tableView.mj_footer endRefreshing];
            return ;
        }
        self.isRefreshing = YES;
        [self handleFooterRefresh]
        .finally(^(){
            self.isRefreshing = NO;
            [self.tableView.mj_footer endRefreshing];
        });

    }];
    self.tableView.mj_footer.automaticallyChangeAlpha = YES;
    
    self.dataSource = [[NSMutableArray alloc] init];
    self.isRefreshing = NO;
}

-(void)setIsRefreshing:(BOOL)isRefreshing
{
    _isRefreshing = isRefreshing;
    
    for (UIButton* button in self.segmentCell.segment.buttons) {
        button.enabled = !isRefreshing;
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tabBarController setTabBarHidden:YES animated:YES];
    if (self.autoRefresh) {
        [self resetDataSource];
    }
    
}

-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.bottomView.frame = CGRectMake(0, self.view.height-[CommonBottomView cellHeight], self.view.bounds.size.width, [CommonBottomView cellHeight]);
    if (self.hiddenBottomView) {
        self.bottomView.hidden = YES;
    }
}



-(void)resetDataSource
{
    self.totalRow = 0;
    self.pageNumber = 0;
    self.totalPage = 0;
    self.pageSize = 0;
    
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    [self.bottomView reset];
    
    self.listQueryRequest = [self makeListQueryRequest];
    [self requestDataSource];
}

-(AnyPromise*)requestDataSource
{
    //return nil;
    [self showProgressIndicatorWithTitle:@"正在加载"];
    return
    [self.listQueryRequest request]
    .then(^(id responseObj){
        NSLog(@"%@", responseObj);
        HttpListQueryResponse *response = (HttpListQueryResponse*)self.listQueryRequest.response;
        if (response.ok) {
            if (response.dtos.count>0) {
                [self.dataSource addObjectsFromArray:response.dtos];
                self.totalPage = response.totalPage;
                self.pageNumber = response.pageNumber>=self.totalPage ? self.totalPage:response.pageNumber;
                [self.tableView reloadData];
                self.bottomView.selectAllCheckBox.on = NO;
            }
        }
        else{
            [self showAlertViewWithMessage:response.errorMsg];
        }

    })
    .catch(^(NSError* error){
        [self showAlertViewWithMessage:error.localizedDescription];
    })
    .finally(^(){
        [self dismissProgressIndicator];
    });
}

-(BaseListDTO*)dtoAtIndexPath:(NSIndexPath*)indexPath
{
    if (self.dataSource.count == 0) {
        return nil;
    }
    
    if (indexPath.row/2 < self.dataSource.count) {
        return self.dataSource[indexPath.row/2];
    }
    return nil;
}

-(AnyPromise*)handleHeaderRefresh
{
    self.listQueryRequest = [self makeListQueryRequest];
    if (self.listQueryRequest) {
        return [self requestDataSource];
    }
    else {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                       message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        return [alert promise];
    }
    
    
}

-(AnyPromise*)handleFooterRefresh
{
    self.listQueryRequest = [self makeListQueryRequest];

    if (self.listQueryRequest) {
        return [self requestDataSource];
    }
    else {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                       message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        return [alert promise];
    }

}

#pragma -- mark custom segment delegate

- (void)segment:(CustomSegment *)segment didSelectAtIndex:(NSInteger)index;
{
    self.listQueryRequest = [self makeListQueryRequest];

    if (self.listQueryRequest) {
        [self resetDataSource];
    }
    else {
        UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                       message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                      delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert promise];
    }
}

#pragma -- mark UIScroll view delegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    
    if (scrollView == self.tableView){
        
        if (scrollView.isTracking && scrollView.dragging)
        {
            CGPoint ptOffset = scrollView.contentOffset;
            
            if (scrollView.contentSize.height >= scrollView.size.height) //内容高度大于view高度
            {
                if (ptOffset.y >= scrollView.contentSize.height - scrollView.size.height) //已经到最下方
                    return;
            }
            
            
            
            if (scrollView.contentInset.top == kTableViewInsetTopWithoutSegment)
            {
                if (ptOffset.y > -kTableViewInsetTopWithoutSegment) //下滑
                {
                    if ((ptOffset.y - self.ptLastOffset.y) > 0)
                    {
                        [self hideTopBars];
                        
                        self.ptLastOffset = ptOffset;
                        self.tableView.showsVerticalScrollIndicator = YES;
                    }
                    else
                    {
                        [self showTopBars];
                        self.ptLastOffset = ptOffset;
                    }
                }
            }
            else if (scrollView.contentInset.top == 0)
            {
                if (ptOffset.y > 0)
                {
                    if ((ptOffset.y - self.ptLastOffset.y) > 0)
                    {
                        [self hideTopBars];
                        
                        self.ptLastOffset = ptOffset;
                    }
                    else if ((ptOffset.y - self.ptLastOffset.y) < 0)
                    {
                        [self showTopBars];
                        self.ptLastOffset = ptOffset;
                    }
                }
                else if (ptOffset.y < 0)
                {
                    [self showTopBars];
                    self.ptLastOffset = ptOffset;
                }
            }
        }
    }
}

- (void)hideTopBars
{
    if (self.tableView.contentSize.height < self.tableView.height)
        return;
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.segmentCell.transform = CGAffineTransformMakeTranslation(0, -300);
        
    } completion:^(BOOL finished) {
    }];
}

- (void)showTopBars
{
    self.tableView.contentInset = UIEdgeInsetsMake(kTableViewInsetTopWithoutSegment, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kTableViewInsetTopWithoutSegment, 0, 0, 0);
    
    [UIView animateWithDuration:0.5 animations:^{
        self.segmentCell.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
    
}

#pragma mark UITableView delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger num = self.dataSource.count;
    // add a last useless cell, or the last cell will be overlaped by CommonBottomView
    return num*2 + (self.hiddenBottomView? 0 : 1);
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == self.dataSource.count*2){
        return [CommonBottomView cellHeight];
    }
    else if(indexPath.row %2 ==0){
        return 12.f;
    }
    
    if (self.usingDefaultCell) {

        return [CommonListCell cellHeight];
    }
    return 0.f;
}


-(BOOL)hiddenCheckBox
{
    return NO;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = nil;
    if (indexPath.row%2 == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"UselessHeadCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UselessHeadCell"];
            cell.backgroundColor = RGBCOLOR(240, 240, 240);
        }
    }
    else if (indexPath.row == self.dataSource.count*2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"LastUselessCell"];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"lastUselessCell"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
        }
    }
    else {
        if (self.usingDefaultCell) {
            CommonListCell* listCell = [tableView dequeueReusableCellWithIdentifier:@"CommonListCell"];
            listCell.dto = self.dataSource[indexPath.row/2];
            listCell.delegate = self;
            listCell.checkBox.hidden = self.hiddenCheckBox;
            cell = listCell;

        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row%2 == 0) {
        
    }

    else {
        [self tableViewCellSelected:tableView andIndexPath:indexPath];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(UITableViewCell*)configCellByTableView:(UITableView*)tableView andIndexPath:(NSIndexPath*)indexPath
{
    NSAssert(NO, @"You should override this method %s", __FUNCTION__);
    return nil;
}

-(void)tableViewCellSelected:(UITableView *)tableView andIndexPath:(NSIndexPath *)indexPath
{
    
}

#pragma mark Common list cell delegate
-(void)didSelectedListCell:(CommonListCell *)cell
{
    
    NSArray* onArray = self.selectedData;
    if (onArray.count == self.dataSource.count) {
        self.bottomView.selectAllCheckBox.on = YES;
    }
    else {
        self.bottomView.selectAllCheckBox.on = NO;
    }
    
    [self updateBottomView];
}

-(void)updateBottomView
{
    __block float totalPrice = 0.f;
    [self.selectedData enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        BaseListDTO* dto = (BaseListDTO*)obj;
        totalPrice += dto.totalPrice;
    }];
    
    [self.bottomView setTotalPrice:totalPrice];
}

-(void)leftButtonClicked:(CommonListCell *)cell
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                   message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

}

-(void)rightButtonClicked:(CommonListCell *)cell
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                   message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];

}


-(void)topButtonClicked:(CommonListCell *)cell
{
    UIAlertView * alert=[[UIAlertView alloc] initWithTitle:@"Alert"
                                                   message:[NSString stringWithFormat:@"You should overwrite the API %@", [NSString stringWithUTF8String:__FUNCTION__]]
                                                  delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
}


#pragma -- mark BEMCheckBox Delegate
-(void)didTapCheckBox:(BEMCheckBox *)checkBox
{
    if (checkBox.on) {
        for(BaseListDTO* dto in self.unSelectedData){
            dto.selected = YES;
        }
    }
    else {
        for(BaseListDTO* dto in self.selectedData){
            dto.selected = NO;
        }
    }
    
    [self updateBottomView];
}


-(void)operationSuccessBack:(NSArray<BaseListDTO*>*)operatedDto
{
    [self resetDataSource];
}

#pragma - mark ListViewControllerDelegate

-(void)didOperatorSuccessWithIds:(NSArray*)ids
{
    if(self.dataSource){
        
       self.dataSource = [[self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"NOT (SELF.id IN %@)", ids]] mutableCopy];
        [self.tableView reloadData];
        [self updateBottomView];
    }
}




-(void)dealloc
{
    NSLog(@"dealloc %@", self.class);
}

@end
