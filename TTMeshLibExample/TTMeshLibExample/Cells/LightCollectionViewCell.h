//
//  LightCollectionViewCell.h
//  MeshLight
//
//  Created by 朱彬 on 2018/3/23.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DeviceModel.h"

@interface LightCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) DeviceModel *model;
@property (nonatomic, copy) void(^deleteBlock)(DeviceModel *model);

-(void)setData:(DeviceModel*)model;

@end
