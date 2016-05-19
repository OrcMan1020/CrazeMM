//
//  AddressListViewController.m
//  CrazeMM
//
//  Created by saix on 16/4/26.
//  Copyright © 2016年 189. All rights reserved.
//

#import "AddressListViewController.h"
#import "SelectdAddrCell.h"
#import "AddressListCell.h"
#import "AddressEditViewController.h"
#import "AddressDTO.h"
#import "HttpAddress.h"


typedef NS_ENUM(NSInteger, MineAddressListSection){
    kSectionRecommand = 0,
    kSectionAllAddress = 1,
    kSectionNumber
};

@interface AddressListViewController ()

@property (nonatomic, strong) UITableView* tableView;
@property (nonatomic, strong) SelectdAddrCell* recommandCell;

@end


@implementation AddressListViewController

-(SelectdAddrCell*)recommandCell
{
    if (!_recommandCell) {
        _recommandCell = [[[NSBundle mainBundle]loadNibNamed:@"SelectdAddrCell" owner:nil options:nil] firstObject];

    }
    
    return _recommandCell;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = @"选择收货地址";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"addr_add_icon"] style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationItem.rightBarButtonItem.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal* (id x) {
        
        AddressEditViewController* addrEditVC = [[AddressEditViewController alloc] init];
        [self.navigationController pushViewController:addrEditVC animated:YES];
        
        return [RACSignal empty];
    }];
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.backgroundColor = RGBCOLOR(240, 240, 240);
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [self.tableView setTableFooterView:view];
    
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerNib:[UINib nibWithNibName:@"AddressListCell" bundle:nil] forCellReuseIdentifier:@"AddressListCell"];
}



-(void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
}

-(void)getOrderAddresses
{
    HttpAddressRequest* request = [[HttpAddressRequest alloc] init];
    [request request]
    .then(^(id responseObj){
        NSLog(@"%@", responseObj);
        HttpAddressResponse* response = (HttpAddressResponse*)request.response;
        if (response.ok) {
            self.addresses = response.addresses;
            [self.tableView reloadData];
        }
        else {
            [self showAlertViewWithMessage:response.errorMsg];
        }
    })
    .catch(^(NSError* error){
        [self showAlertViewWithMessage:error.localizedDescription];
    });
}



-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self getOrderAddresses];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kSectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    switch (section) {
        case kSectionRecommand:
        {
            return 1;
        }
            break;
        case kSectionAllAddress:
        {
            return 2;
        }
            break;
        default:
            break;
    }
    
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell* cell;
    
    switch (indexPath.section) {
        case kSectionRecommand:
        {
            cell = self.recommandCell;
        }
            
            break;
        case kSectionAllAddress:
        {
            AddressListCell* addressCell = [tableView dequeueReusableCellWithIdentifier:@"AddressListCell"];
            addressCell.addrDto = self.addresses[indexPath.row];
            if(addressCell.editButton.rac_command == nil){
                addressCell.editButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^RACSignal* (id x) {
                    
                    AddressEditViewController* addrEditVC = [[AddressEditViewController alloc] initWithAddress:addressCell.addrDto];
                    [self.navigationController pushViewController:addrEditVC animated:YES];
                    
                    return [RACSignal empty];
                }];
            }
            
            cell = addressCell;
        }
            break;
        default:
            break;
    }
    //cell.selectionStyle = UITableViewCellSelectionStyleNone;
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    return cell;
}



-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 12.f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kSectionRecommand:
        {
            return 100.f;
        }
            break;
        case kSectionAllAddress:
        {
            return 85.f;
        }
            break;
        default:
            break;
    }
    
    return 80.f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


@end
