//
//  GroupInfoTableViewCell.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/14.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "GroupInfoTableViewCell.h"
#import "TTDefine.h"

@interface GroupInfoTableViewCell ()
{
    
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UILabel *desLabel;
}

@end

@implementation GroupInfoTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    desLabel.textColor = RGBAColor(255, 255, 255, 0.4);
    desLabel.text = @"Long press to add lights";
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setData:(NSMutableDictionary*)info
{
    nameLabel.text = info[Storage_GroupName];
}

@end
