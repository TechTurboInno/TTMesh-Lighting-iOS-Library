//
//  MeshNetworkViewController.h
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface MeshNetworkViewController : BaseViewController

@property (nonatomic, copy) void(^reScanBlock)(NSMutableDictionary *meshInfo);

@end
