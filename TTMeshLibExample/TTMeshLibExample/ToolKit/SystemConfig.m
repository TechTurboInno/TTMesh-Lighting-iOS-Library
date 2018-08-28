//
//  SystemConfig.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "SystemConfig.h"

static SystemConfig* instance = nil;

@implementation SystemConfig

+ (SystemConfig*)shareConfig
{
    if(!instance)
    {
        @synchronized(self)
        {
            if(!instance)
            {
                instance = [[SystemConfig alloc] init];
            }
        }
    }
    
    return instance;
}

+(id) allocWithZone:(NSZone *)zone
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [super allocWithZone:zone];
            return instance;
        }
    }
    
    return nil;
}

- (id)init
{
    if(self = [super init])
    {
        self.collectionSource = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return self;
}

-(NSMutableArray*)readMeshInfo
{
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:Storage_MeshInfo];
    
    if (array == nil || [array count] == 0 ) {
        array = [NSMutableArray arrayWithCapacity:0];
        
        NSDictionary *dic = @{
                              Storage_MeshName : @"P1_Mesh",
                              Storage_MeshPassword : @"123"
                              };
        
        [array addObject:dic];
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dic in array) {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:dic];
        
        [result addObject:info];
    }
    
    return result;
}

-(void)saveMeshInfo:(NSMutableArray*)array
{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:Storage_MeshInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSMutableArray*)readGroupInfo
{
    NSMutableArray *array = [[NSUserDefaults standardUserDefaults] objectForKey:Storage_GroupInfo];
    
    if (array == nil || [array count] == 0 ) {
        array = [NSMutableArray arrayWithCapacity:0];
        
        NSDictionary *dic = @{
                              Storage_GroupID: @"1",
                              Storage_GroupName : @"Group 1",
                              Storage_GroupTimeto : @"1080",
                              Storage_GroupTimeFrom : @"360",
                              Storage_GroupBrightness : @"50",
                              Storage_GroupCT : @"50",
                              Storage_GroupColor : @"50"
                              };
        
        [array addObject:dic];
    }
    
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:0];
    
    for (NSDictionary *dic in array) {
        NSMutableDictionary *info = [[NSMutableDictionary alloc] initWithDictionary:dic];
        
        [result addObject:info];
    }
    
    return result;
}

-(void)saveGroupInfo:(NSMutableArray*)array
{
    [[NSUserDefaults standardUserDefaults] setObject:array forKey:Storage_GroupInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDictionary*)readCurrentMeshInfo
{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:Storage_CurrentMeshInfo];
    
    if (info == nil) {
        NSMutableArray *meshInfoArray = [self readMeshInfo];
        
        info = [meshInfoArray firstObject];
    }
    
    return info;
}

-(void)saveCurrentMeshInfo:(NSDictionary*)info
{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:Storage_CurrentMeshInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSDictionary*)readOldMeshInfo
{
    NSDictionary *info = [[NSUserDefaults standardUserDefaults] objectForKey:Storage_OldMeshInfo];

    return info;
}

-(void)saveOldMeshInfo:(NSDictionary*)info
{
    [[NSUserDefaults standardUserDefaults] setObject:info forKey:Storage_OldMeshInfo];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

-(NSString*)createGroupID
{
    // During A Mesh Network, the max group account is 16
    for (int i = 1; i <= 16; i++) {
        BOOL bUsed = TRUE;
        
        for (NSMutableDictionary *info in [[SystemConfig shareConfig] readGroupInfo]) {
            NSInteger groupid = [info[Storage_GroupID] integerValue];
            
            if (groupid == i) {
                bUsed = FALSE;
                break;
            }
        }
        
        if (bUsed) {
            return [NSString stringWithFormat:@"%d", i];
        }
    }
    
    return @"1";
}

-(NSString*)createMeshID
{
    // During A Mesh Network, the max node account is 255
    for (int i = 1; i <= 255; i++) {
        BOOL bUsed = TRUE;
        
        for (DeviceModel *model in [SystemConfig shareConfig].collectionSource) {
            NSInteger meshid = model.orderAddress;
            
            if (meshid == i) {
                bUsed = FALSE;
                break;
            }
        }
        
        if (bUsed) {
            return [NSString stringWithFormat:@"%d", i];
        }
    }
    
    return @"1";
}

@end
