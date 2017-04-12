//
//  ListTableViewCell.h
//  Punch
//
//  Created by 邵晓飞 on 2017/4/11.
//  Copyright © 2017年 邵晓飞. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ListTableViewCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *timeLabel;

@property (nonatomic, weak) IBOutlet UILabel *countryCodeLabel;

@property (nonatomic, weak) IBOutlet UILabel *nameLabel;

@property (nonatomic, weak) IBOutlet UILabel *formattedAddressLineLabel;

@end
