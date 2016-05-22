//
//  AddressListCell.h
//  CrazeMM
//
//  Created by saix on 16/4/26.
//  Copyright © 2016年 189. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AddressDTO.h"
#import "AddressInfo.h"

@interface AddressListCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UILabel *addressLabel;

@property (nonatomic, strong) AddressDTO* addrDto;
@property (nonatomic, strong) AddressInfo* addrInfo;

@end
