//
//  MeshInfoTableViewCell.h
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MeshInfoTableViewCell : UITableViewCell

@property (nonatomic, copy) void(^deleteBlock)(BOOL bResult);
@property (nonatomic, copy) void(^selectedBlock)(BOOL bResult);

-(void)setData:(NSDictionary*)info;

@end
