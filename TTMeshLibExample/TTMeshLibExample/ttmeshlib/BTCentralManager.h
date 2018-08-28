//
//  BTCentralManager.h
//  TelinkBlue
//
//  Created by Green on 11/14/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import "DeviceModel.h"
#import "TTMacros.h"

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

//#define kCaiyang 0.32
#define kCMDInterval 0.32
#define kTestLog YES

@class BTDevItem;

@protocol BTCentralManagerDelegate <NSObject>

@optional


- (void)loginTimeout:(TimeoutType)type;
//收集error code
- (void)exceptionReport:(int)stateCode errorCode:(int)errorCode;

- (void)scanedLoginCharacteristic;
/**
 *手机蓝牙状态变化
 
 */
-(void)OnCenterStatusChange:(CBCentralManager*)centralManager;
/**
 *扫描设备变化
 */
-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag;

/**
 *收到设备上传信息,一般byte为20字节
 */
- (void)OnDevNofify:(id)sender Byte:(uint8_t *)byte;

/**
 *接收到设备的firewareVersion－－
 对应Service_Device_Information(UUID.fromString("0000180a-0000-1000-8000-00805f9b34fb"), "Device Information Service"),
 Characteristic_Firmware(UUID.fromString("00002a26-0000-1000-8000-00805f9b34fb"), "Firmware Revision"),
 */
-(void)OnConnectionDevFirmWare:(NSData *)data;


-(void)OnConnectionDevFirmWare:(NSData *)data Item:(BTDevItem *)item;

/**
 *Command口上传信息
 */
- (void)OnDevCommandReport:(id)sender Byte:(uint8_t *)byte;

/**
 *操作状态变化
 */
- (void)OnDevOperaStatusChange:(id)sender Status:(OperaStatus)status;

/**
 *扫描到一个设备
 */
- (void)scanResult:(BTDevItem *)item;

/**
 *因为断开连接导致逐个加灯失败情况处理
 */
-(void)settingForDisconnect:(BTDevItem *)item WithDisconectType:(DisconectType)type;

/**
 *直连灯被拔除或者换了直连灯的时候调用
 */
-(void)RevokeOfSelconnectItemChange:(BTDevItem *)item;

/**
 调用情形1-－扫描没有发现可以直连的设备的时候调用－－可在.m文件内部设置超时时间
 调用情形2-－直连灯被拔掉的时候短暂性的重新设置灯的显示状态为离线
 */
-(void)resetStatusOfAllLight;
/**
 *修改设备地址之后的notify解析
 */
-(void)resultOfReplaceAddress:(uint32_t )resultAddress;
/**
 *接收存储状态的对象－－－使用时候需要导入模型类DeviceModel－－－－必须要实现的部分
 */
-(void)getFirstStataFromNotify:(DeviceModel *)firstDevice;
-(void)getSecondStataFromNotify:(DeviceModel *)secondDevice;
//代替掉上面两个方法
- (void)notifyBackWithDevice:(DeviceModel *)model;
@end

@interface BTCentralManager : NSObject<CBCentralManagerDelegate, CBPeripheralDelegate>
{
    BTDevItem *selConnectedItem;//当前连接的设备
    BOOL isAutoLogin;//扫描到设备后自动连接登录、断开后自动连接登录
}
@property (nonatomic, strong,readonly) NSArray *devArrs;
@property (nonatomic, assign,readonly) CBManagerState centerState;//手机蓝牙状态
@property (nonatomic, assign,readonly) DevOperaType operaType;
@property (nonatomic, assign,readonly) OperaStatus operaStatus;
@property (nonatomic, strong,readonly) BTDevItem *selConnectedItem;//当前连接的设备
@property (nonatomic, assign, getter=isLogin,readonly) BOOL isLogin;
@property (nonatomic, assign, readonly) BOOL isConnected;
@property (nonatomic, assign, getter=isAutoLogin) BOOL isAutoLogin;//扫描到设备后自动连接登录、断开后自动连接登录
@property (nonatomic, assign) NSInteger scanTimeout;
@property (nonatomic, assign) BOOL enableLog;
@property (nonatomic, weak) id delegate;
@property (nonatomic, assign) BOOL isDebugLog;
@property (nonatomic, assign) BOOL isAddDevice;
@property(nonatomic,assign)NSUInteger timeOut;                    //特别指明，此处是一个一个设置全部设备mesh 从scan到默认已经全部设置完成的时间－－－具体数值根据项目调试－－－默认全部扫描并且设置完成在ScanAndSetAllDeviceFinished中通知
@property(nonatomic,assign)BOOL scanSetting;
@property(nonatomic,assign)DisconectType disconnectType;
@property(nonatomic,assign)BOOL scanWithOut_Of_Mesh;
@property(nonatomic,strong)NSString *connectType;

@property (nonatomic, assign) BTCommand btCMDType;
@property (nonatomic, copy) void(^PrintBlock)(NSString *con);
@property (nonatomic, copy) void(^UpdateDataBlock)(NSData *data);

/**
 *停止链接的外接
 */
-(void)stopConnected;

/**
 *第一次扫描name 和 password 可以填nil
 */
-(void)startScanWithName:(NSString *)nStr Pwd:(NSString *)pwd AutoLogin:(BOOL)autoLogin;
////停止连接、清空数据、等待下一次扫描
//
//-(void)startScanForOtaUpDate:(NSString *)scanName Pwd:(NSString*)scanPwd AutoLoginItem:(BTDevItem *)item;


-(void)stopScan;

-(void)deleteLoginTimer;

/**
 *当cItem为nil时默认连接devArr数组最后一个设备
 */
-(void)connectWithItem:(BTDevItem *)cItem;

-(void)loginWithPwd:(NSString *)pStr;

/**
 *发送命令
 */
-(void)sendCommand:(uint8_t *)cmd Len:(int)len;

/**
 *设置所有灯的meshname
 **************注意： 此处的ltk的buffer为方便没有设定默认值，传nil为设置为
 uint8_t tlkBuffer[20]={0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
 0x00,0x0,0x0,0x0,0x0};
 原来版本的默认值为    uint8_t tlkBuffer[20]={0xc0,0xc1,0xc2,0xc3,0xc4,0xc5,0xc6,0xc7,0xd8,
 0xd9,0xda,0xdb,0xdc,0xdd,0xde,0xdf,0x0,0x0,0x0,0x0};
 
 传入的参数buffer只需要填写：tlkBuffer
 */
-(void)setNewNetworkName:(NSString *)nName Pwd:(NSString *)nPwd ltkBuffer:(uint8_t *)buffer;

/**
 *此方法暂时专用与解决修改out_of_mesh的name  password 和ltk
 */
-(void)setOut_Of_MeshWithName:(NSString *)addName PassWord:(NSString *)addPassWord NewNetWorkName:(NSString *)nName Pwd:(NSString *)nPwd ltkBuffer:(uint8_t *)buffer ForCertainItem:(BTDevItem *)item;



/**
 *设置某一个灯的meshname-------长按cell修改时候－－－demo设置为name：tling   －－npwd：123
 */
-(void)setNewNetworkName:(NSString *)nName Pwd:(NSString *)nPwd WithItem:(BTDevItem *)item ltkBuffer:(uint8_t *)buffer;


+ (BTCentralManager*) shareBTCentralManager;

/**
 *获取灯的状态
 */
-(void)setNotifyOpenPro;

/**
 *全开接口
 */

-(void)turnOnAllLight;


/**
 *全开接口
 */

- (void)turnOffAllLight;

- (void)testCertainLightWithAddress:(uint32_t )u_DevAddress;

/**
 *单灯的开灯－－－传入设备地址
 */

- (void)turnOnCertainLightWithAddress:(uint32_t )u_DevAddress;


/**
 *单灯的关灯－－－传入设备地址
 */
-(void)turnOffCertainLightWithAddress:(uint32_t )u_DevAddress;


/**
 *组的开灯－－－传入组地址
 */
-(void)turnOnCertainGroupWithAddress:(uint32_t )u_GroupAddress;

/**
 *组的关灯－－－传入组地址
 */
-(void)turnOffCertainGroupWithAddress:(uint32_t )u_GroupAddress;


/**
 *重新设置设备的u_DevAdress－－传入目的地址和新地址
 */

-(void)replaceDeviceAddress:(uint32_t)presentDevAddress WithNewDevAddress:(NSUInteger)newDevAddress;

/**
 *设置亮度值lum－－传入目的地址和亮度值---可以是单灯或者组的地址
 */
-(void)setLightOrGroupLumWithDestinateAddress:(uint32_t)destinateAddress WithLum:(NSInteger)lum withMode:(BOOL)bAllModel;

/**
 *设置RGB－－－传入目的地址和R.G.B值－－-可以是单灯或者组的地址
 */

-(void)setLightOrGroupRGBWithDestinateAddress:(uint32_t)destinateAddress WithColorR:(float)R WithColorG:(float)G WithB:(float)B;

-(void)setGroupLightWithAdr:(uint32_t)destinateAddress withGroupID:(NSInteger)groupid IsAdd:(BOOL)isAdd;

/**
 *加组－－－传入待加灯的地址，和 待加入的组的地址
 */

-(void)addDevice:(uint32_t)targetDeviceAddress ToDestinateGroupAddress:(uint32_t)groupAddress;

/**
 *删组－－－传入待加灯的地址，和 待加入的组的地址
 */

-(void)deleteDevice:(uint32_t)targetDeviceAddress ToDestinateGroupAddress:(uint32_t)groupAddress;


/**
 *kick-out---传入待处置的灯的地址－－－地址目前建议只针对组；；；
 */
-(void)kickoutLightFromMeshWithDestinateAddress:(uint32_t)destinateAddress;


/**
 *设置CT－－－传入设备的地址和CT值--CT的传入取值为0---1的浮点值；
 */
-(void)setCTOfLightWithDestinationAddress:(uint32_t)destinationAddress AndCT:(float)CT;

-(void)setColdWarmCTOfLightWithDestinationAddress:(uint32_t)destinationAddress AndBrightness:(float)bright AndColdValue:(float)cold AndWarmValue:(float)warm withMode:(BOOL)bAllModel;

//获取所在组信息
- (void)getGroupAddressWithDeviceAddress:(uint32_t)destinationAddress;

-(void)setGroupPower:(NSInteger)groupid withPower:(BOOL)on;

-(void)setGroupLumWithGroupID:(NSInteger)groupid withLum:(NSInteger)lum;

-(void)setGroupCWGroupID:(NSInteger)groupid withCold:(NSInteger)cold withWarm:(NSInteger)warm withLum:(NSInteger)lum;

-(void)setGroupRGB:(NSInteger)groupid withRed:(float)R withGreen:(float)G withBlue:(float)B;

-(void)setGroupOnOrOff:(NSInteger)groupid withTurnOn:(BOOL)on;

-(void)deleteGroupAlarm:(NSInteger)groupid;

-(void)addGroupAlarmOn:(NSInteger)groupid withMode:(BOOL)bAllModel withTime:(NSInteger)time;

-(void)addGroupAlarmOff:(NSInteger)groupid withMode:(BOOL)bAllModel withTime:(NSInteger)time;

-(void)setCurrentTime:(uint32_t )destinationAddress
             withYear:(NSInteger)year
            withMonth:(NSInteger)month
              withDay:(NSInteger)day
             withHour:(NSInteger)hour
           withMinute:(NSInteger)minute
           withSecond:(NSInteger)second;

-(void)setGroupCurrentTime:(NSInteger)groupid withMode:(BOOL)bAllModel;

-(void)getCurrentTime:(uint32_t )destinationAddress withMode:(BOOL)bAllModel;

-(void)addAlarmOn:(uint32_t )destinationAddress withMode:(BOOL)bAllModel withTime:(NSInteger)time;

-(void)addAlarmOff:(uint32_t )destinationAddress withMode:(BOOL)bAllModel withTime:(NSInteger)time;

-(void)getAlarm:(uint32_t )destinationAddress withMode:(BOOL)bAllModel;

-(void)deleteAlarm:(uint32_t )destinationAddress withMode:(BOOL)bAllModel;

/**
 *OTA数据包发送－－－data为分配之后的包
 */
-(void)sendPack:(NSData *)data;

-(void)sendCustomData:(NSDictionary*)params;

/**
 *读取当前直连灯属性值
 */
- (void)readFeatureOfselConnectedItem;

-(void)connectPro;
@end
