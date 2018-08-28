//
//  TTMeshManager.m
//  ttmeshlib
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "TTMeshManager.h"
#import "BTCentralManager.h"

#define GetLTKBuffer  \
Byte ltkBuffer[20]; \
memset(ltkBuffer, 0, 20); \
for (int j=0; j<16; j++) { \
if (j<8) { \
ltkBuffer[j] = 0xc0+j; \
}else{ \
ltkBuffer[j] = 0xd0+j; \
} \
}

@interface TTMeshManager()<BTCentralManagerDelegate>
{
    BTCentralManager *manager;
}

@end

@implementation TTMeshManager

+ (TTMeshManager*) shareManager {
    static TTMeshManager *manager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        manager = [[TTMeshManager alloc] init];
        [manager initData];
    });
    return manager;
}

-(void)initData {
    manager = [BTCentralManager shareBTCentralManager];
    manager.scanTimeout = 7;
    manager.delegate = self;
}

-(void)setScanTimeout:(NSInteger)scanTimeout
{
    manager.scanTimeout = scanTimeout;
}

-(BOOL)isLogin{
    return manager.isLogin;
}

-(BTDevItem*)connectedItem
{
    return manager.selConnectedItem;
}

-(void)stopConnected
{
    [manager stopConnected];
}

-(void)stopScan
{
    [manager stopScan];
}

/**
 When you control the mesh, you can pass this for control all the nodes in the network
 */
-(uint32_t)getAllMeshNodeAddress
{
    return 65535;
}

-(void)startScanWithName:(NSString *)name Pwd:(NSString *)password
{
    [manager startScanWithName:name Pwd:password AutoLogin:TRUE];
}

-(void)setCurrentTimeWithAddress:(uint32_t)address
                        withYear:(NSInteger)year
                       withMonth:(NSInteger)month
                         withDay:(NSInteger)day
                        withHour:(NSInteger)hour
                      withMinute:(NSInteger)minute
                      withSecond:(NSInteger)second
{
    [manager setCurrentTime:address withYear:year withMonth:month withDay:day withHour:hour withMinute:minute withSecond:second];
}

-(void)turnOnLightWithAddress:(uint32_t)address {
    [manager turnOnCertainLightWithAddress:address];
}

-(void)turnOffLightWithAddress:(uint32_t)address {
    [manager turnOffCertainLightWithAddress:address];
}

-(void)setLightLumWithAddress:(uint32_t)address WithLum:(NSInteger)lum {
    [manager setLightOrGroupLumWithDestinateAddress:address WithLum:lum withMode:FALSE];
}

-(void)setLightColorWithAddress:(uint32_t)address WithColorR:(float)red WithColorG:(float)green WithB:(float)blue {
    [manager setLightOrGroupRGBWithDestinateAddress:address WithColorR:red WithColorG:green WithB:blue];
}

-(void)setLightColorTemperatureWithAddress:(uint32_t)address withBrightness:(float)brightness withColdValue:(float)cold withWarmValue:(float)warm {
    [manager setColdWarmCTOfLightWithDestinationAddress:address AndBrightness:brightness AndColdValue:cold AndWarmValue:warm withMode:FALSE];
}

-(void)deleteAllAlarmWithAddress:(uint32_t )address
{
    [manager deleteAlarm:address withMode:FALSE];
}

-(void)addAlarmOnWithAddress:(uint32_t )address withCurrentMinutes:(NSInteger)time
{
    [manager addAlarmOn:address withMode:FALSE withTime:time];
}

-(void)addAlarmOffWithAddress:(uint32_t )address withCurrentMinutes:(NSInteger)time
{
    [manager addAlarmOff:address withMode:FALSE withTime:time];
}

-(void)setLightGroupWithAddress:(uint32_t)address withGroupID:(NSInteger)groupid
{
    [manager setGroupLightWithAdr:address withGroupID:groupid IsAdd:TRUE];
}

-(void)deleteLightGroupWithAddress:(uint32_t)address
{
    [manager setGroupLightWithAdr:address withGroupID:1 IsAdd:FALSE];
}

-(void)turnOnGroupWithGroupID:(NSInteger)groupID
{
    [manager setGroupOnOrOff:groupID withTurnOn:TRUE];
}

-(void)turnOffGroupWithGroupID:(NSInteger)groupID
{
    [manager setGroupOnOrOff:groupID withTurnOn:FALSE];
}

-(void)setGroupLumWithGroupID:(NSInteger)groupID WithLum:(NSInteger)lum
{
    [manager setGroupLumWithGroupID:groupID withLum:lum];
}

-(void)setGroupColorWithGroupID:(NSInteger)groupID WithColorR:(float)red WithColorG:(float)green WithB:(float)blue
{
    [manager setGroupRGB:groupID withRed:red withGreen:green withBlue:blue];
}

-(void)deleteGroupAllAlarmWithGroupID:(NSInteger )groupID
{
    [manager deleteGroupAlarm:groupID];
}

-(void)setGroupColorTemperatureWithGroupID:(NSInteger)groupID withBrightness:(NSInteger)brightness withColdValue:(float)cold withWarmValue:(float)warm
{
    [manager setGroupCWGroupID:groupID withCold:cold withWarm:warm withLum:brightness];
}

-(void)addGroupAlarmOnWithGroupID:(NSInteger )groupID withCurrentMinutes:(NSInteger)time
{
    [manager addGroupAlarmOn:groupID withMode:FALSE withTime:time];
}

-(void)addGroupAlarmOffWithGroupID:(NSInteger )groupID withCurrentMinutes:(NSInteger)time
{
    [manager addGroupAlarmOff:groupID withMode:FALSE withTime:time];
}

-(void)replaceDeviceAddress:(uint32_t)presentDevAddress newOrderAddress:(NSUInteger)newOrderAddress
{
    [manager replaceDeviceAddress:presentDevAddress WithNewDevAddress:newOrderAddress];
}

-(void)setOldMeshInfoToNewMeshInfo:(NSString*)oldMeshName
                   withOldPassword:(NSString*)oldMeshPassword
                   withNewMeshInfo:(NSString*)newMeshName
               withNewMeshPassword:(NSString*)newMeshPassword
                          withItem:(BTDevItem*)item
{
    GetLTKBuffer
    
    [manager setOut_Of_MeshWithName:oldMeshName PassWord:oldMeshPassword NewNetWorkName:newMeshName Pwd:newMeshPassword ltkBuffer:ltkBuffer ForCertainItem:item];
}

-(void)setNotifyOpenPro {
    [manager setNotifyOpenPro];
}

-(void)notifyBackWithDevice:(DeviceModel *)model {
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(notifyBackWithDevice:)] ) {
        [self.delegate notifyBackWithDevice:model];
    }
}

-(void)loginTimeout:(TimeoutType)type
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(loginTimeout)] ) {
        [self.delegate loginTimeout];
    }
}

-(void)OnCenterStatusChange:(CBCentralManager *)centralManager
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(OnCenterStatusChange:)] ) {
        [self.delegate OnCenterStatusChange:centralManager];
    }
}

-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(OnDevChange:Item:Flag:)] ) {
        [self.delegate OnDevChange:sender Item:item Flag:flag];
    }
}

-(void)OnDevOperaStatusChange:(id)sender Status:(OperaStatus)status
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(OnDevOperaStatusChange:Status:)] ) {
        [self.delegate OnDevOperaStatusChange:sender Status:status];
    }
}

-(void)resultOfReplaceAddress:(uint32_t )resultAddress
{
    if (self.delegate != nil && [self.delegate respondsToSelector:@selector(resultOfReplaceAddress:)] ) {
        [self.delegate resultOfReplaceAddress:resultAddress];
    }
}

-(void)kickOutWithAddress:(uint32_t)address
{
    [manager kickoutLightFromMeshWithDestinateAddress:address];
}

@end
