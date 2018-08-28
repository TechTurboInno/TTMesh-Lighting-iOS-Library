//
//  ZoneDetailViewController.h
//  MeshLight
//
//  Created by 朱彬 on 2018/5/2.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "BaseViewController.h"
#import "TTDefine.h"


@interface ZoneDetailViewController : BaseViewController

@property (nonatomic, strong) NSMutableDictionary *info;

@property (nonatomic, copy) void(^UpdateData)(NSMutableDictionary *info, BOOL bNewInfo);
@property (nonatomic, copy) void(^deleteData)(NSMutableDictionary *info);

@end
