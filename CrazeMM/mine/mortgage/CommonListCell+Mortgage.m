//
//  CommonListCell+Mortgage.m
//  CrazeMM
//
//  Created by Mao Mao on 16/7/3.
//  Copyright © 2016年 189. All rights reserved.
//

#import "CommonListCell+Mortgage.h"
#import "MortgageDTO.h"


@implementation CommonListCell (Mortgage)

-(MortgageDTO*)mortgageDto
{
    return (MortgageDTO*)self.dto;
}

-(void)setMortgageDTO:(MortgageDTO*)dto
{
    [self formatOrderLabel:dto.id];
    [self formatTimeLabel:dto.createTime];
    [self formatStatusLabel:dto.stateLabel];
    [self formatGoodNameLabel:dto.goodName];
    //[self fo
    [self formatQuantityLabel];
    [self formatPriceLabel];
    [self formatTotalPriceLabel];
    
    self.rightButton.hidden = NO;
    self.leftButton.hidden = YES;
    [self formatRightButton:dto.state];
}

-(void)formatQuantityLabel
{
    NSString* firstComponent = [NSString stringWithFormat:@"总数: %ld台 ",  self.mortgageDto.quantity];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString: firstComponent
                                           attributes:@{
                                                        NSFontAttributeName: [UIFont systemFontOfSize:14.f]
                                                        }];
    
    
    if (self.mortgageDto.stockId>0 && self.mortgageDto.depotName.length>0) {
        
        NSString* secondComopent = [NSString stringWithFormat:@"(%@)", self.mortgageDto.depotName];
        [attributedText appendAttributedString:[[NSAttributedString alloc] initWithString:secondComopent attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:13.f]}]];
    }
    
    self.firstLabel.attributedText = attributedText;
}

-(void)formatPriceLabel
{
    NSString* firstComponent = [NSString stringWithFormat:@"抵押单价: "];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString: firstComponent
                                           attributes:@{
                                                        NSFontAttributeName: [UIFont systemFontOfSize:14.f]
                                                        }];
    
    
    
    NSString* secondComopent = [NSString stringWithFormat:@"￥%.02f", self.mortgageDto.price];
    [attributedText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:secondComopent attributes:@{
                                                                                       NSFontAttributeName: [UIFont systemFontOfSize:13.f],
                                                                                       NSForegroundColorAttributeName: [UIColor redColor]                                             }]];
    
    self.secondLabel.attributedText = attributedText;
}

-(void)formatTotalPriceLabel
{
    NSString* firstComponent = [NSString stringWithFormat:@"总金额: "];
    NSMutableAttributedString *attributedText =
    [[NSMutableAttributedString alloc] initWithString: firstComponent
                                           attributes:@{
                                                        NSFontAttributeName: [UIFont systemFontOfSize:14.f]
                                                        }];
    NSArray* formatedPrice = [NSString formatePrice:self.mortgageDto.price*self.mortgageDto.quantity];
    NSString* secondComopent = [NSString stringWithFormat:@"￥%@", [formatedPrice componentsJoinedByString:@""]];
    [attributedText appendAttributedString:[[NSAttributedString alloc]
                                            initWithString:secondComopent attributes:@{
                                                                                       NSFontAttributeName: [UIFont systemFontOfSize:13.f],
                                                                                       NSForegroundColorAttributeName: [UIColor redColor]                                             }]];
    
    self.thirdLabel.attributedText = attributedText;
}

-(void)formatRightButton:(NSInteger)state
{
    
    switch (state) {
        case 100:
            [self.rightButton setTitle:@"删除" forState:UIControlStateNormal ];
            [self.rightButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal ];
           break;
            
        case 200:
            [self.rightButton setTitle:@"撤销" forState:UIControlStateNormal ];
            [self.rightButton setImage:[UIImage imageNamed:@"down"] forState:UIControlStateNormal ];
            break;
            
        case 300:
            [self.rightButton setTitle:@"还款" forState:UIControlStateNormal ];
            [self.rightButton setImage:[UIImage imageNamed:@"up"] forState:UIControlStateNormal ];
            break;
            
        default:

            break;
    }
    
    CGSize fontSize = [self.rightButton.titleLabel.text sizeWithAttributes:@{NSFontAttributeName: self.rightButton.titleLabel.font}];
    [self.rightButton setTitleEdgeInsets:UIEdgeInsetsMake(0, -self.rightButton.imageView.frame.size.width-4.f, 0, self.rightButton.imageView.frame.size.width+4.f)];
    [self.rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, fontSize.width, 0, -fontSize.width)];

}

@end
