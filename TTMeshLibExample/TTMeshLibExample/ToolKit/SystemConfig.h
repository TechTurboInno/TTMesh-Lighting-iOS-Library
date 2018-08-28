//
//  SystemConfig.h
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTDefine.h"
#import "DeviceModel.h"

@interface SystemConfig : NSObject

+ (SystemConfig*)shareConfig;

@property(nonatomic, strong) NSMutableArray <DeviceModel *>*collectionSource;
@property(nonatomic, strong) NSDictionary *currentMeshInfo;

-(NSMutableArray*)readMeshInfo;
-(void)saveMeshInfo:(NSMutableArray*)array;
-(NSMutableArray*)readGroupInfo;
-(void)saveGroupInfo:(NSMutableArray*)array;

-(NSString*)createGroupID;
-(NSString*)createMeshID;

-(NSDictionary*)readCurrentMeshInfo;
-(void)saveCurrentMeshInfo:(NSDictionary*)info;

-(NSDictionary*)readOldMeshInfo;
-(void)saveOldMeshInfo:(NSDictionary*)info;

@end
