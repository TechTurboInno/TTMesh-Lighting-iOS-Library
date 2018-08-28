//
//  LightCollectionViewCell.m
//  MeshLight
//
//  Created by 朱彬 on 2018/3/23.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "LightCollectionViewCell.h"

@interface LightCollectionViewCell () {
    
    __weak IBOutlet UIImageView *bkImageView;
    __weak IBOutlet UIImageView *stateImageView;
    __weak IBOutlet UILabel *nameLabel;
    __weak IBOutlet UIImageView *flagImageView;
    BOOL bShowCircleLine;
}

@end

@implementation LightCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
//    bkImageView.backgroundColor = [UIColor redColor];
//    bkImageView.layer.cornerRadius = bkImageView.frame.size.width / 2;
//    bkImageView.layer.masksToBounds = YES;
//
//    bShowCircleLine = FALSE;
//
//    bkImageView.hidden = YES;
}

-(void)setData:(DeviceModel*)model{
    self.model = model;
    NSString *tempImgName = nil;
    switch (model.stata) {
        case LightStataTypeOutline:
            tempImgName  =@"bulb_offline.png";
            
            flagImageView.hidden = NO;
            break;
        case LightStataTypeOff:
            tempImgName=@"bulb_off.png";
            
            flagImageView.hidden = YES;
            break;
        case LightStataTypeOn:
            tempImgName=@"bulb_on.png";
            
            flagImageView.hidden = YES;
            break;
        default:
            break;
    }
    stateImageView.image = [UIImage imageNamed:tempImgName];
    nameLabel.text = [NSString stringWithFormat:@"bulb %u",model.orderAddress];;
}


@end
