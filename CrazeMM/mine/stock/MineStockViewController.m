//
//  MineStockViewController.m
//  CrazeMM
//
//  Created by Mao Mao on 16/5/30.
//  Copyright © 2016年 189. All rights reserved.
//

#import "MineStockViewController.h"
#import "SegmentedCell.h"
#import "CommonBottomView.h"
#import "SupplyListCell.h"
#import "HttpMineSupply.h"
#import "MineSupplyProductDTO.h"
#import "HttpMineSupplyShelve.h"
#import "MineStockEditViewController.h"
#import "MineStockDTO.h"
#import "MineStockSellViewController.h"
#import "HttpSaveSupplyInfo.h"
#import "MIneStockInfoViewController.h"


@interface MineStockViewController()

@property (nonatomic) SupplyListCellStyle cellStyle;

@property (nonatomic) NSInteger pageNumber;
@property (nonatomic) NSInteger totalPage;

@end

@implementation MineStockViewController

-(SegmentedCell*)segmentCell
{
    if (!_segmentCell) {
        _segmentCell = [[SegmentedCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SegmentedCell"];
        _segmentCell.buttonStyle = kButtonStyleB;
        _segmentCell.height = @(40.0f);
        [_segmentCell setTitles:@[@"待入库", @"已入库", @"待出库", @"历史"]];
        _segmentCell.segment.delegate = self;
        _segmentCell.segment.currentIndex = 1;
        [self.view addSubview:_segmentCell];
    }
    return _segmentCell;
}


-(CommonBottomView*)bottomView
{
    if(!_bottomView){
        _bottomView = [super bottomView];
        [_bottomView.confirmButton setTitle:@"批量出货" forState:UIControlStateNormal];
        [_bottomView.totalPriceLabel setText:@""];
        
    }
    
    return _bottomView;
}


-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"我的库存";
    self.view.backgroundColor = [UIColor light_Gray_Color];
    
    self.dataSource = [[NSMutableArray alloc] init];
    
    if (!self.navigationItem.leftBarButtonItem) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
        @weakify(self)
        self.navigationItem.leftBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal *(id input) {
            @strongify(self);
            [self.navigationController popViewControllerAnimated:YES];
            return [RACSignal empty];
        }];
    }
    
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[@"addr_add_icon" image] style:UIBarButtonItemStylePlain target:self action:@selector(addStock:)];
    //disable segmentCell
#define kSegmentCellHeight (40.f+self.contentHeightOffset)

    self.tableView.contentInset = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
    self.tableView.scrollIndicatorInsets = UIEdgeInsetsMake(kSegmentCellHeight, 0, 0, 0);
    
    self.segmentCell.frame = CGRectMake(0, 64.f, [UIScreen mainScreen].bounds.size.width, kSegmentCellHeight);
    
    self.pageNumber = 0;
    self.cellStyle = kOffShelfStyle;
    [self getMineStock];
}


-(void)addStock:(id)sender
{
    MineStockEditViewController* editVC = [[MineStockEditViewController alloc] init];
    editVC.delegate = self;
    [self.navigationController pushViewController:editVC animated:YES];
}

-(AnyPromise*)handleHeaderRefresh
{
    return [self getMineStock];
}

-(AnyPromise*)handleFooterRefresh
{
    return [self getMineStock];
}

-(void)bottomViewButtonClicked:(UIButton*)button
{
    
    if (button == self.bottomView.confirmButton) {
        
            [self shippingProducts];

        }
    
}

-(void)shippingProducts
{
    NSMutableArray* selectedDtos = [[NSMutableArray alloc] init];
    
    for (MineStockDTO* dto in self.dataSource) {
        if (dto.selected) {
            [selectedDtos addObject:dto];
        }
    }
    MineStockSellViewController* stockSellVc = [[MineStockSellViewController alloc]initWith:selectedDtos];
    stockSellVc.delegate = self;
    [self.navigationController pushViewController:stockSellVc animated:YES];
    
}

-(void)shippingProductsWithSid:(NSInteger)sid
{
    
    NSMutableArray* selectedDtos = [[NSMutableArray alloc] init];
    
    for (MineStockDTO* dto in self.dataSource) {
        if (sid == dto.id) {
            [selectedDtos addObject:dto];
            break;
        }
    }
    
    MineStockSellViewController* stockSellVc = [[MineStockSellViewController alloc]initWith:selectedDtos];
    stockSellVc.delegate = self;
    [self.navigationController pushViewController:stockSellVc animated:YES];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    
    
    if(!cell) {
        // we should use this style for cell reuse to support iOS8
        cell = [tableView dequeueReusableCellWithIdentifier:@"StockListCell"];
        if (cell==nil) {
            cell= [[[NSBundle mainBundle]loadNibNamed:@"StockListCell" owner:nil options:nil] firstObject];
        }
        //TBD
//        ((StockListCell*)cell).style = self.cellStyle;
        ((StockListCell*)cell).mineStockDto = self.dataSource[indexPath.row/2];
        ((StockListCell*)cell).selectCheckBox.tag = 10000 + indexPath.row/2;
        ((StockListCell*)cell).selectCheckBox.delegate = self;
        ((StockListCell*)cell).delegate = self;
//        [((StockListCell*)cell).offButton setTitle:@"出货" forState:UIControlStateNormal];
//        [((StockListCell*)cell).shareButton setTitle:(((MineStockDTO *)self.dataSource[indexPath.row/2]).depotDto.name) forState:UIControlStateNormal];
        
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row %2 == 0) {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
    
    else {
        if (self.segmentCell.segment.currentIndex != 2) {
            return [StockListCell cellHeight];
            
        }
        else {
            return [StockListCell cellHeight] - 30;
        }
        
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MineSupplyProductDTO* dto = self.dataSource[indexPath.row/2];
    MIneStockInfoViewController* mVc = [[MIneStockInfoViewController alloc] initWithId:dto.id];
    [self.navigationController pushViewController:mVc animated:YES];
}


-(AnyPromise*)getMineStock
{
    NSInteger currentSelectedSegment = self.segmentCell.segment.currentIndex;
    NSString* status = @"100";
    switch (currentSelectedSegment) {
        case 0:
            status = [NSString stringWithFormat:@"%d", 100];
            break;
        case 1:
            status = [NSString stringWithFormat:@"%d", 200];;
            break;
        case 2:
            status = [NSString stringWithFormat:@"%d", 300];;
            break;
        case 3:
            status = [NSString stringWithFormat:@"%d,%d", 400, 500];;
            break;
        default:
            break;
    }
    
    HttpMineStockRequest * request = [[HttpMineStockRequest alloc]initWithPageNumber:self.pageNumber+1 andStatus:status];
    
    return [request request]
    .then(^(id responseObj){
        NSLog(@"%@", responseObj);
        HttpMineStockResponse * response = (HttpMineStockResponse*)request.response;
        if (response.ok) {
            if (response.stockDTOs.count>0) {
                [self.dataSource addObjectsFromArray:response.stockDTOs];
                self.totalPage = response.totalPage;
                self.pageNumber = response.pageNumber>=self.totalPage?self.totalPage:response.pageNumber;
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
        
    });
}


#pragma -- mark BEMCheckBox Delegate
-(void)didTapCheckBox:(BEMCheckBox *)checkBox
{
    if (checkBox != self.bottomView.selectAllCheckBox) {
        NSInteger index = checkBox.tag - 10000;
        MineStockDTO* dto = self.dataSource[index];
        dto.selected = checkBox.on;
        
        NSArray* onArray = [self.dataSource filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"SELF.selected != NO"]];
        if (onArray.count == self.dataSource.count) {
            self.bottomView.selectAllCheckBox.on = YES;
        }
        else {
            self.bottomView.selectAllCheckBox.on = NO;
        }
    }
    else {
        for (NSInteger index = 0; index<self.dataSource.count; ++index) {
            MineStockDTO* dto = self.dataSource[index];
            dto.selected = checkBox.on;
        }
        [self.tableView reloadData];
    }
    
}


#pragma -- mark SupplyListCell delegate
-(void)buttonClicked:(UIButton *)sender andSid:(NSInteger)sid
{
        [self shippingProductsWithSid:sid];
}


#pragma -- mark MineSupplyEditViewController Delegate
-(void)editSupplyGoodSuccess
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    self.pageNumber = 0;
    [self getMineStock];
    
}

#pragma -- mark MineStockSellViewControllerDelegate Delegate
-(void)sendStockSellSuccess
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    
    self.pageNumber = 0;
    [self getMineStock];
    
}

#pragma -- mark custom segment delegate

- (void)segment:(CustomSegment *)segment didSelectAtIndex:(NSInteger)index;
{
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    self.pageNumber = 0;
    self.totalPage = 0;

    [self getMineStock];
}


@end