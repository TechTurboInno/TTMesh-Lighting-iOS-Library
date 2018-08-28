//
//  TTMeshManager.h
//  ttmeshlib
//
//  Created by techturbo on 2018/8/13.
//  Copyright © 2018年 techturbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DeviceModel.h"
#import "BTDevItem.h"
#import "TTMacros.h"

@protocol TTMeshManagerDelegate <NSObject>

@optional

/**
 When scan time out, this function will be invoked
 */
- (void)loginTimeout;

/**
 When bluetooth state changed, this function will be invoked
 */
-(void)OnCenterStatusChange:(CBCentralManager*)centralManager;

/**
 The mesh infomation will be delivered
 */
- (void)notifyBackWithDevice:(DeviceModel *)model;

/**
 When the address is set success, this function will be invoked
 */
-(void)resultOfReplaceAddress:(uint32_t )resultAddress;

/**
 when mesh network device status changed,
 it notify in this function
 */
-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag;

/**
 when some operation to mesh network
 it should tell the operation result
 */
- (void)OnDevOperaStatusChange:(id)sender Status:(OperaStatus)status;

@end

@interface TTMeshManager : NSObject


@property (nonatomic, weak) id<TTMeshManagerDelegate> delegate;

+ (TTMeshManager*) shareManager;

/**
 get current connecting device object
 */
-(BTDevItem*)connectedItem;

/**
 set the time of the tomeout when scan the meshnetwork
 */
-(void)setScanTimeout:(NSInteger)scanTimeout;

/**
 disconnect current connected device
 */
-(void)stopConnected;

/**
 stop bluetooth scan
 */
-(void)stopScan;

/**
 return state of the login state
 */
-(BOOL)isLogin;

/**
 When you control the mesh, you can pass this for control all the nodes in the network
 */
-(uint32_t)getAllMeshNodeAddress;

/**
 Start scan mesh network with the name and password.
 
 @param name The mesh network name.
 @param password The mesh network password.
 */
-(void)startScanWithName:(NSString *)name Pwd:(NSString *)password;

/**
 Get All Mesh status
 */
-(void)setNotifyOpenPro;

/**
 Set current time of the light with address.
 
 @param address The param could be one address of a device
 eg. 2018-02-12 14:36:02
 @param year The year of current time eg. 2018
 @param month The month of current time eg. 2
 @param day The day of current time eg. 12
 @param hour The hour of current time eg. 14
 @param minute The minute of current time eg. 36
 @param second The second of current time eg. 2
 */
-(void)setCurrentTimeWithAddress:(uint32_t)address
                        withYear:(NSInteger)year
                       withMonth:(NSInteger)month
                         withDay:(NSInteger)day
                        withHour:(NSInteger)hour
                      withMinute:(NSInteger)minute
                      withSecond:(NSInteger)second;

/**
 Turn on the light with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 */
-(void)turnOnLightWithAddress:(uint32_t)address;

/**
 Turn off the light with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 */
-(void)turnOffLightWithAddress:(uint32_t)address;

/**
 Set the light lum with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 
 @param lum The lum value
 */
-(void)setLightLumWithAddress:(uint32_t)address WithLum:(NSInteger)lum;

/**
 Set the light color with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 
 @param red The red value shoule be 0 - 1
 @param green The green value shoule be 0 - 1
 @param blue The blue value shoule be 0 - 1
 */
-(void)setLightColorWithAddress:(uint32_t)address WithColorR:(float)red WithColorG:(float)green WithB:(float)blue;

/**
 Set the light color temperature with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 
 @param brightness brightness of the light
 @param cold The cold part, the value refer the example
 @param warm The warm part, the value refer the example
 */
-(void)setLightColorTemperatureWithAddress:(uint32_t)address withBrightness:(float)brightness withColdValue:(float)cold withWarmValue:(float)warm;

/**
 Delete the light alarm clock with address
 
 @param address The param could be one address of a device
 */

-(void)deleteAllAlarmWithAddress:(uint32_t )address;

/**
 Set the light alarm clock with address, the light will auto turn on at that time.
 
 @param address The param could be one address of a device
 @param time the current minutes in a day
 such as: if you want the time is 6:00 AM, this value should be 360
 if you want the time is 5:00 PM, this value should be 1020
 */
-(void)addAlarmOnWithAddress:(uint32_t )address withCurrentMinutes:(NSInteger)time;

/**
 Set the light alarm clock with address, the light will auto turn off at that time.
 
 @param address The param could be one address of a device
 @param time the current minutes in a day
 such as: if you want the time is 6:00 AM, this value should be 360
 if you want the time is 5:00 PM, this value should be 1020
 */
-(void)addAlarmOffWithAddress:(uint32_t )address withCurrentMinutes:(NSInteger)time;

/**
 Set the light group with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 
 @param groupid the groupid which you want to set
 */
-(void)setLightGroupWithAddress:(uint32_t)address withGroupID:(NSInteger)groupid;

/**
 delete the light group with address.
 
 @param address The param could be one address of a device
 If you want turn on all devices in the mesh network, you can pass "getAllMeshNodeAddress" to the param.
 
 */
-(void)deleteLightGroupWithAddress:(uint32_t)address;

/**
 Turn on the light in a group with groupID.
 
 @param groupID The param could be one address of a group.
 */
-(void)turnOnGroupWithGroupID:(NSInteger)groupID;

/**
 Turn off the light in a group with groupID.
 
 @param groupID The param could be one address of a group.
 */
-(void)turnOffGroupWithGroupID:(NSInteger)groupID;

/**
 Set the light lum in a group with groupID.
 
 @param groupID The param could be one address of a group
 
 @param lum The lum value
 */
-(void)setGroupLumWithGroupID:(NSInteger)groupID WithLum:(NSInteger)lum;

/**
 Set the light color in a group with groupID.
 
 @param groupID The param could be one address of a group
 
 @param red The red value shoule be 0 - 1
 @param green The green value shoule be 0 - 1
 @param blue The blue value shoule be 0 - 1
 */
-(void)setGroupColorWithGroupID:(NSInteger)groupID WithColorR:(float)red WithColorG:(float)green WithB:(float)blue;

/**
 Set the light color in a group temperature with groupID.
 
 @param groupID The param could be one address of a group
 
 @param brightness brightness of the light
 @param cold The cold part, the value refer the example
 @param warm The warm part, the value refer the example
 */
-(void)setGroupColorTemperatureWithGroupID:(NSInteger)groupID withBrightness:(NSInteger)brightness withColdValue:(float)cold withWarmValue:(float)warm;

/**
 Delete the light in a group alarm clock with groupID
 
 @param groupID The param could be one address of a group
 */

-(void)deleteGroupAllAlarmWithGroupID:(NSInteger )groupID;

/**
 Set the light in a group alarm clock with groupID, the light will auto turn on at that time.
 
 @param groupID The param could be one address of a group
 @param time the current minutes in a day
 such as: if you want the time is 6:00 AM, this value should be 360
 if you want the time is 5:00 PM, this value should be 1020
 */
-(void)addGroupAlarmOnWithGroupID:(NSInteger )groupID withCurrentMinutes:(NSInteger)time;

/**
 Set the light in a group alarm clock with address, the light will auto turn off at that time.
 
 @param groupID The param could be one address of a device
 @param time the current minutes in a day
 such as: if you want the time is 6:00 AM, this value should be 360
 if you want the time is 5:00 PM, this value should be 1020
 */
-(void)addGroupAlarmOffWithGroupID:(NSInteger )groupID withCurrentMinutes:(NSInteger)time;

/**
 Set the light with New mesh orderAddress
 
 @param presentDevAddress the dest light address
 @param newOrderAddress the orderAddress eg 1-255
 */
-(void)replaceDeviceAddress:(uint32_t)presentDevAddress newOrderAddress:(NSUInteger)newOrderAddress;

/**
 Change the item from old MeshInfo to new MeshInfo
 
 @param oldMeshName the old MeshInfo name
 @param oldMeshPassword the old MeshInfo password
 @param newMeshName the new MeshInfo name
 @param newMeshPassword the new MeshInfo password
 @param item the current device which you want set
 */
-(void)setOldMeshInfoToNewMeshInfo:(NSString*)oldMeshName
                   withOldPassword:(NSString*)oldMeshPassword
                   withNewMeshInfo:(NSString*)newMeshName
               withNewMeshPassword:(NSString*)newMeshPassword
                          withItem:(BTDevItem*)item;

/**
 Kick out the light from the mesh network with address.
 When kickout success, the light's mesh name and password will revert to factory settings
 
 @param address the dest light address
 */
-(void)kickOutWithAddress:(uint32_t)address;

@end

