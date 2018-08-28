//
//  TTefine.h
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#ifndef TTefine_h
#define TTefine_h

#define RGBColor(r, g, b)               [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:1.0]
#define RGBAColor(r, g, b, a)           [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:a]
#define MainWindow                      [UIApplication sharedApplication].keyWindow

#define SCREEN_HEIGHT                   [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH                    [[UIScreen mainScreen] bounds].size.width

#define Storage_OldMeshInfo             @"oldmeshinfo"
#define Storage_CurrentMeshInfo         @"currentmeshinfo"
#define Storage_MeshInfo                @"meshinfo"
#define Storage_MeshName                @"meshname"
#define Storage_MeshPassword            @"meshpassword"

#define Storage_GroupInfo               @"groupinfo"
#define Storage_GroupID                 @"groupid"
#define Storage_GroupName               @"groupname"
#define Storage_GroupTimeFrom           @"grouptimefrom"
#define Storage_GroupTimeto             @"grouptimeto"
#define Storage_GroupBrightness         @"groupbrightness"
#define Storage_GroupCT                 @"groupct"
#define Storage_GroupColor              @"groupcolor"

struct BFDateInformation {
    NSInteger day;
    NSInteger month;
    NSInteger year;
    
    NSInteger weekday;
    
    NSInteger minute;
    NSInteger hour;
    NSInteger second;
    
};
typedef struct BFDateInformation BFDateInformation;

#endif /* TTefine_h */
