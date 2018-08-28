//
//  BTCentralManager.m
//  TelinkBlue
//
//  Created by Green on 11/14/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#import "BTCentralManager.h"
#import "BTConst.h"
#import "BTDevItem.h"
#import "CryptoAction.h"
#import "DeviceModel.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "TranslateTool.h"    //需要导入到库里面


#define random(x) (rand()%x)
#define MaxSnValue  0xffffff
#define kLoginTimerout (4)

//#define BTLog(A,B) if (_isDebugLog) NSLog(A,B)
#define BTLog(A,B)
static NSUInteger addIndex;
static NSUInteger scanTime;
static NSUInteger getNotifytime;

typedef struct {
    unsigned char cmd : 4;
    unsigned char type : 3;
    unsigned char enabel : 1;
}parl;

@interface BTCentralManager() {
    CBCentralManager *centralManager;
    
    NSString *userName;
    NSString *userPassword;
    NSString *nUserName;
    NSString *nUserPassword;
    
    CBCharacteristic *commandFeature;
    CBCharacteristic *pairFeature;
    CBCharacteristic *notifyFeature;
    CBCharacteristic *otaFeature;
    CBCharacteristic *fireWareFeature;
    
    uint8_t loginRand[8];
    uint8_t sectionKey[16];
    
    @public
    uint8_t *_TBuffer;
    
    int snNo;
    int connectTime;
    NSInteger currSetIndex;
    
    BOOL isSetAll;
    BOOL isNeedScan;
    BOOL isEndAllSet;
    NSMutableArray *srcDevArrs;
    NSMutableArray *IdentifersArrs;
    BTDevItem *disconnectItem;
    NSUInteger otaPackIndex;
    
    uint8_t tempbuffer[20];
    BOOL flags;
    NSTimer *scanTimer;
    NSTimer *getNotifyTimer;
    NSTimer *connectTimer;
    NSThread    *_delayThread;
    CBService *dataService;
    
}

@property (nonatomic, strong) dispatch_source_t clickTimer;

@property (nonatomic, assign) NSTimeInterval containCYDelay;
@property (nonatomic, assign) NSTimeInterval exeCMDDate;
@property (nonatomic, assign) NSTimeInterval clickDate;

@property (nonatomic, strong) CBCentralManager *centralManager;
@property (nonatomic, strong) NSString *userName;
@property (nonatomic, strong) NSString *userPassword;
@property (nonatomic, assign, getter=isNeedScan) BOOL isNeedScan;
@property (nonatomic, strong) CBCharacteristic *commandFeature;
@property (nonatomic, strong) CBCharacteristic *pairFeature;
@property (nonatomic, strong) CBCharacteristic *otaFeature;
@property (nonatomic, strong) CBCharacteristic *customDataFeature;
@property (nonatomic, strong) CBCharacteristic *fireWareFeature;
@property (nonatomic, assign) NSInteger currSetIndex;
@property (nonatomic, strong) NSString *nUserName;
@property (nonatomic, strong) NSString *nUserPassword;
@property (nonatomic, strong) CBCharacteristic *notifyFeature;
@property (nonatomic, assign, getter=isEndAllSet) BOOL isEndAllSet;
@property (nonatomic, strong) NSMutableArray *srcDevArrs;
@property (nonatomic, strong)NSMutableArray *IdentifersArrs;
@property (nonatomic, assign) int snNo;
@property (nonatomic, assign, getter=isSetAll) BOOL isSetAll;
@property (nonatomic, assign)uint8_t *roadbytes;
@property (nonatomic, strong)BTDevItem *disconnectItem;
@property (nonatomic, strong)NSString *UUIDStr;
@property (nonatomic, assign)BOOL flags;
@property (nonatomic, strong)NSTimer *scanTimer;
@property (nonatomic, strong)NSTimer *getNotifyTimer;
@property (nonatomic, strong)NSTimer *connectTimer;
@property (nonatomic, strong)NSTimer *loginTimer;


@property (nonatomic, assign) BTStateCode stateCode;
@property (nonatomic, assign) BOOL isCanReceiveAdv;
@end

@implementation BTCentralManager
@synthesize centralManager=_centralManager;
@synthesize userName;
@synthesize userPassword;
@synthesize isNeedScan;
@synthesize commandFeature;
@synthesize pairFeature;
@synthesize currSetIndex;
@synthesize nUserName;
@synthesize nUserPassword;
@synthesize notifyFeature;
@synthesize otaFeature;
@synthesize fireWareFeature;
@synthesize isEndAllSet;
@synthesize srcDevArrs;
@synthesize IdentifersArrs;
@synthesize selConnectedItem=_selConnectedItem;
@synthesize isAutoLogin;
@synthesize snNo;
@synthesize isSetAll;
@synthesize disconnectItem;
@synthesize flags;
@synthesize scanTimer;
@synthesize getNotifyTimer;
@synthesize  connectTimer;

-(void)initData {
    _centralManager = [[CBCentralManager alloc] initWithDelegate:self queue:nil options:@{CBCentralManagerOptionShowPowerAlertKey:@NO}];

    self.srcDevArrs=[[NSMutableArray alloc] init];
    self.IdentifersArrs = [[NSMutableArray alloc]init];
    self.isNeedScan=NO;
    _isConnected=NO;
    _centerState=CBCentralManagerStateUnknown;
    _operaType=DevOperaType_Normal;
    self.currSetIndex=NSNotFound;
    memset(sectionKey, 0, 16);
    srand((int)time(0));
    self.snNo=random(MaxSnValue);
    otaPackIndex = 0;
    memset(tempbuffer, 0, 20);
}

#pragma mark - Private

//初始化连接状态
-(void)reInitData
{
    _isLogin=NO;
    _isConnected=NO;
    otaPackIndex = 0;
    self.isEndAllSet=NO;
    self.commandFeature=nil;
    self.pairFeature=nil;
    self.notifyFeature=nil;
    self.fireWareFeature = nil;
    self.otaFeature = nil;
    _operaStatus=DevOperaStatus_Normal;
    memset(loginRand,0, 8);
    memset(sectionKey,0, 16);
}

-(int)getNextSnNo {
    snNo++;
    if (snNo>MaxSnValue)
        snNo=1;
    return self.snNo;
}

-(uint32_t)getIntValueByHex:(NSString *)getStr
{
    NSScanner *tempScaner=[[NSScanner alloc] initWithString:getStr];
    uint32_t tempValue;
    [tempScaner scanHexInt:&tempValue];
    return tempValue;
}
-(BTDevItem *)getItemWithTag:(NSString *)getStr withAddress:(uint32_t)add
{
    BTDevItem *result=nil;
    for (BTDevItem *tempItem in srcDevArrs)
    {
        if ([tempItem.devIdentifier isEqualToString:getStr])
        {
            if (tempItem.u_DevAdress == add) {
                result=tempItem;
            }
            
            break;
        }
    }
    return result;
}

-(BTDevItem *)getDevItemWithPer:(CBPeripheral *)getPer
{
    BTDevItem *result=nil;
    for (BTDevItem *tempItem in srcDevArrs)
    {
        if ([tempItem.blDevInfo isEqual:getPer])
        {
            result=tempItem;
            break;
        }
    }
    return result;
}

-(void)writeValue:(CBCharacteristic *)characteristic Buffer:(uint8_t *)buffer Len:(int)len response:(CBCharacteristicWriteType)type {
    if (!characteristic)
        return;
    
    if (!self.selConnectedItem)
        return;
    
    if (self.selConnectedItem.blDevInfo.state!=CBPeripheralStateConnected)
        return;
    
    NSData *tempData=[NSData dataWithBytes:buffer length:len];
    [self.selConnectedItem.blDevInfo writeValue:tempData forCharacteristic:characteristic type:type];
}

//-(void)writeValue:(CBCharacteristic *)characteristic Buffer:(uint8_t *)buffer Len:(int)len
//{
//    if (!characteristic)
//        return;
//    
//    if (!self.selConnectedItem)
//        return;
//    
//    if (self.selConnectedItem.blDevInfo.state!=CBPeripheralStateConnected)
//        return;
//    
//    NSData *tempData=[NSData dataWithBytes:buffer length:len];
//    
//    [self.selConnectedItem.blDevInfo writeValue:tempData forCharacteristic:characteristic type:CBCharacteristicWriteWithResponse];
//}

-(void)readValue:(CBCharacteristic *)characteristic Buffer:(uint8_t *)buffer
{
    if (!characteristic)
        return;
    
    if (!self.selConnectedItem)
        return;
    
    if (self.selConnectedItem.blDevInfo.state!=CBPeripheralStateConnected)
        return;

    [self.selConnectedItem.blDevInfo readValueForCharacteristic:characteristic];
}


-(void)logByte:(uint8_t *)bytes Len:(int)len Str:(NSString *)str {
    NSMutableString *tempMStr=[[NSMutableString alloc] init];
    for (int i=0;i<len;i++)
        [tempMStr appendFormat:@"%0x ",bytes[i]];
    
    if (self.enableLog) {
//        NSLog(@"%@ == %@",str,tempMStr);
    }
}

-(void)pasterData:(uint8_t *)buffer IsNotify:(BOOL)isNotify
{
    
    uint8_t sec_ivm[8];
    uint32_t tempMac=self.selConnectedItem.u_Mac;
    
    sec_ivm[0]=(tempMac>>24) & 0xff;
    sec_ivm[1]=(tempMac>>16) & 0xff;
    sec_ivm[2]=(tempMac>>8) & 0xff;
    
    memcpy(sec_ivm+3, buffer, 5);
    
    if (!(buffer[0]==0 && buffer[1]==0 && buffer[2]==0))
    {
        if ([CryptoAction decryptionPpacket:sectionKey Iv:sec_ivm Mic:buffer+5 MicLen:2 Ps:buffer+7 Len:13]){
            NSLog(@"解密返回成功");
        }else{
            NSLog(@"解密返回失败");
        }
    }
    if (isNotify)
        [self sendDevNotify:buffer];
    else
        [self sendDevCommandReport:buffer];
}

-(BTDevItem *)getNextItemWith:(BTDevItem *)getItem
{
    if (srcDevArrs.count<2)
        return nil;
    
    BTDevItem *resultItem=nil;
    for (BTDevItem *tempItem in srcDevArrs)
    {
        if (tempItem==getItem)
            continue;
        resultItem=tempItem;
        break;
    }
    
    return resultItem;
}


#pragma  mark - Send Notify
-(void)sendDevChange:(BTDevItem *)item Flag:(DevChangeFlag)flag
{
    if (_delegate && [_delegate respondsToSelector:@selector(OnDevChange:Item:Flag:)])
    {
        [_delegate OnDevChange:self Item:item Flag:flag];
    }
}

-(void)sendDevNotify:(uint8_t *)bytes
{
    [self logByte:bytes Len:20 Str:@"Notify"];
    
    if (_delegate && [_delegate respondsToSelector:@selector(OnDevNofify:Byte:)])
    {
        [_delegate OnDevNofify:self Byte:bytes];
    }
    [self passUsefulMessageWithBytes:bytes];
    
}

-(void)passUsefulMessageWithBytes:(uint8_t *)bytes{
    
    //灯的显示状态解析
    DeviceModel *firstItem = [self getFristDeviceModelWithBytes:bytes];
    
    if ([_delegate respondsToSelector:@selector(notifyBackWithDevice:)]) {
        [_delegate notifyBackWithDevice:firstItem];
    }
    DeviceModel *secondItem = [self getSecondDeviceModelWithBytes:bytes];
    if ([_delegate respondsToSelector:@selector(notifyBackWithDevice:)]) {
        [_delegate notifyBackWithDevice:secondItem];
    }
    
    if (bytes[8]==0x11 && bytes[9]==0x02 && bytes[7] == 0xe1) {
        uint32_t address = [self analysisedAddressAfterSettingWithBytes:bytes];
        if ([_delegate respondsToSelector:@selector(resultOfReplaceAddress:)]) {
            [self printContentWithString:[NSString stringWithFormat:@"change address back: 0x%04x", [[srcDevArrs firstObject] u_DevAdress]]];
            [self logByte:bytes Len:20 Str:@"Setting_Address"];
            [_delegate resultOfReplaceAddress:address];
        }
    }
}


-(void)sendDevCommandReport:(uint8_t *)bytes
{
    if (_delegate && [_delegate respondsToSelector:@selector(OnDevCommandReport:Byte:)])
    {
        [_delegate OnDevCommandReport:self Byte:bytes];
    }
}

-(void)sendDevOperaStatusChange:(OperaStatus)oStatus
{
    if (_delegate && [_delegate respondsToSelector:@selector(OnDevOperaStatusChange:Status:)])
    {
        [_delegate OnDevOperaStatusChange:self Status:oStatus];
    }
}


#pragma mark - SetNameAndPassword
- (void)setNewNetworkDataPro {
    [self printContentWithString:[NSString stringWithFormat:@"ready set new mesh: 0x%04x", [[srcDevArrs firstObject] u_DevAdress]]];
//    self.nUserName = GEDATASOURCE.curPlaceModel.meshName;
//    self.nUserPassword = GEDATASOURCE.curPlaceModel.meshPassword.stringValue;
    uint8_t buffer[20];
    memset(buffer, 0, 20);
    
    self.operaStatus=DevOperaStatus_SetName_Start;
    [CryptoAction  getNetworkInfo:buffer Opcode:4 Str:self.nUserName Psk:sectionKey];
//    [self writeValue:self.pairFeature Buffer:buffer Len:20];
     [self writeValue:self.pairFeature Buffer:buffer Len:20 response:CBCharacteristicWriteWithResponse];
    
    self.operaStatus=DevOperaStatus_SetPassword_Start;
    memset(buffer, 0, 20);
    [CryptoAction  getNetworkInfo:buffer Opcode:5 Str:self.nUserPassword Psk:sectionKey];
     [self writeValue:self.pairFeature Buffer:buffer Len:20 response:CBCharacteristicWriteWithResponse];
//    [self writeValue:self.pairFeature Buffer:buffer Len:20];
    
    self.operaStatus=DevOperaStatus_SetLtk_Start;
    [CryptoAction  getNetworkInfoByte:buffer Opcode:6 Str:tempbuffer Psk:sectionKey];
//    [self writeValue:self.pairFeature Buffer:buffer Len:20];
    [self writeValue:self.pairFeature Buffer:buffer Len:20 response:CBCharacteristicWriteWithResponse];
}
-(void)setNewNetworkName:(NSString *)nName Pwd:(NSString *)nPwd ltkBuffer:(uint8_t *)buffer
{
    if (srcDevArrs.count<1)
        return;
    self.isSetAll = YES;
    
    self.nUserName=nName;
    self.nUserPassword=nPwd;
    _operaType=DevOperaType_Set;
    self.currSetIndex=NSNotFound;
    
    for (BTDevItem *tempItem in srcDevArrs)
        tempItem.isSeted=NO;
    
    self.isEndAllSet=NO;
    
    [self setNewNetworkNextPro];
    
    if (buffer != nil) {
        for (int i = 0;  i < 20 ; i++) {
            tempbuffer[i] = buffer[i];
        }
        
    }
    
}

-(void)setOut_Of_MeshWithName:(NSString *)addName PassWord:(NSString *)addPassWord NewNetWorkName:(NSString *)nName Pwd:(NSString *)nPwd ltkBuffer:(uint8_t *)buffer ForCertainItem:(BTDevItem *)item{
    if (!item) {
        return;
    }
    self.isSetAll = NO;
    self.nUserName=nName;
    self.nUserPassword=nPwd;                      //加灯时候的passwordnUserPassword
    self.userName = addName;
    self.userPassword = addPassWord;
    if (![_selConnectedItem isEqual:item]) {
        [self stopConnected];
    }
    _operaType = DevOperaType_Set;
    
    if (buffer != nil) {
        for (int i = 0;  i < 20 ; i++) {
            tempbuffer[i] = buffer[i];
        }
    }
    [self printContentWithString:[NSString stringWithFormat:@"change mesh name and set ltk: 0x%04x", [[srcDevArrs firstObject] u_DevAdress]]];
    [self setNewNetworkWithItem:item];
}




-(void)setNewNetworkName:(NSString *)nName Pwd:(NSString *)nPwd WithItem:(BTDevItem *)item ltkBuffer:(uint8_t *)buffer
{
    if (!item)
        return;
    self.isSetAll=NO;
    
    self.nUserName=nName;
    self.nUserPassword=nPwd;
    if ([[item u_Name]isEqualToString:@"telink_mesh1"]&& self.scanWithOut_Of_Mesh == YES) {
        self.userName = @"telink_mesh1";
        self.userPassword = @"123";
    }
    _operaType=DevOperaType_Set;
    if (![_selConnectedItem isEqual:item])
        [self stopConnected];
    [self setNewNetworkWithItem:item];
    if (buffer != nil) {
        for (int i = 0;  i < 20 ; i++) {
            tempbuffer[i] = buffer[i];
        }
    }
    [self printContentWithString:[NSString stringWithFormat:@"change mesh name and ltk: 0x%04x", [[srcDevArrs firstObject] u_DevAdress]]];
}
-(void)setNewNetworkNextPro
{
    BTDevItem *tempItem=nil;
    if (currSetIndex==NSNotFound)
    {
        if (_selConnectedItem)
        {
            tempItem=_selConnectedItem;
            currSetIndex=-1;
        }
        else
            currSetIndex=0;
    }
    
    if (!tempItem)
    {
        [self stopConnected];
        while (true){
            if (currSetIndex>=0 && currSetIndex<srcDevArrs.count){
                tempItem=srcDevArrs[currSetIndex];
            }
            else
                break;
            if (!tempItem.isSeted)
                break;
            currSetIndex++;
        }
        _selConnectedItem=tempItem;
    }
    
    if (!tempItem){
        self.isEndAllSet=YES;
        self.operaStatus=DevOperaStatus_SetNetwork_Finish;
        
        NSLog(@"1 ---------------- DevOperaStatus_SetNetwork_Finish");
        return;
    }
    
    if ((currSetIndex+1)==srcDevArrs.count)
        self.isEndAllSet=YES;
    
    [self setMeshNameAndPwdAndLtk:tempItem];
    
    currSetIndex++;
}

/**
 *有时会出现setItem的值相同的情况
 */

-(void)setMeshNameAndPwdAndLtk:(BTDevItem *)setItem{
    self.flags = YES;
    setItem.isSeted=YES;
    _selConnectedItem=setItem;
    for (int i=0; i<srcDevArrs.count; i++) {
        NSLog(@"[CoreBluetooth] srcDevArrs -> %@", [srcDevArrs[i] blDevInfo]);
    }
    [self.centralManager connectPeripheral:[setItem blDevInfo]
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnConnectionKey]];
    NSLog(@"[CoreBluetooth] setMeshNameAndPwdAndLtk: -> %@", [setItem blDevInfo]);
}

-(void)setNewNetworkWithItem:(BTDevItem *)setItem{
    _selConnectedItem=setItem;
    self.flags = YES;
    setItem.isSeted=YES;
    
    for (int i=0; i<srcDevArrs.count; i++) {
        NSLog(@"[CoreBluetooth] srcDevArrs -> %@", [srcDevArrs[i] blDevInfo]);
    }
    [self.centralManager connectPeripheral:[setItem blDevInfo]
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    NSLog(@"[CoreBluetooth] setNewNetworkWithItem: -> %@", [setItem blDevInfo]);
}


- (void)stopConnected {
    self.stateCode = BTStateCode_Normal;
    NSMutableArray *pers = [[NSMutableArray alloc] init];
    for (int i=0; i<srcDevArrs.count; i++) {
        [pers addObject:[srcDevArrs[i] blDevInfo].identifier.UUIDString];
    }
    //防止多个连接 
    CBUUID *uuid =  [CBUUID UUIDWithString:BTDevInfo_ServiceUUID];
    NSArray <CBPeripheral *>*arr =[_centralManager retrieveConnectedPeripheralsWithServices:@[uuid]];
    NSMutableArray *peruuids = [[NSMutableArray alloc] init];
    for (int j=0; j<arr.count; j++) {
        [peruuids addObject:arr[j].identifier.UUIDString];
    }
    if (arr.count) {
        for (CBPeripheral *peripheral in arr) {
            if (peripheral.state==CBPeripheralStateConnected||
                peripheral.state==CBPeripheralStateConnecting) {
                [_centralManager cancelPeripheralConnection:peripheral];
            }
        }
    }
    _selConnectedItem=nil;
    [self reInitData];
}



-(NSString *)replaceStr:(NSString *)resStr TagStr:(NSString *)tagStr WithStr:(NSString *)rStr{
    if CheckStr(resStr)
        return @"";
    if CheckStr(tagStr)
        return resStr;
    if (!rStr)
        return resStr;
    
    NSRange tempRan=NSMakeRange(0, resStr.length);
    resStr=[resStr stringByReplacingOccurrencesOfString:tagStr withString:rStr options:0 range:tempRan];
    return resStr;
}

-(void)setNotifyOpenProSevervalTimes{
    if (getNotifytime < 4) {
        [self setNotifyOpenPro];
        getNotifytime++;
    }else{
        getNotifytime = 0;
        [self.getNotifyTimer invalidate];
    }
}
//获取灯的状态数据
-(void)setNotifyOpenPro
{
    if (!self.isConnected) {
        return;
    }
    //NSLog(@"获取灯的状态");
    uint8_t buffer[1]={1};
    [self writeValue:self.notifyFeature Buffer:buffer Len:1 response:CBCharacteristicWriteWithResponse];
}

#pragma mark - BlueDelegate
- (void)centralManagerDidUpdateState:(CBCentralManager *)central {
    _centerState=central.state;
    if (central.state == CBCentralManagerStatePoweredOn)
    {
        if (isNeedScan)
            [self startScanWithName:self.userName Pwd:self.userPassword];
    }else if (central.state==CBCentralManagerStatePoweredOff){
        [self stopConnected];
        [self stopScan];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(OnCenterStatusChange:)]) {
        [_delegate OnCenterStatusChange:central];
    }
}

- (void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)advertisementData RSSI:(NSNumber *)RSSI {
    self.isCanReceiveAdv = YES;
    
    NSString *tempUserName=[advertisementData objectForKey:@"kCBAdvDataLocalName"]; //广播包名字LocalName
    BOOL scanContainOut_of_mesh = self.scanWithOut_Of_Mesh;
    BOOL scanOption1 = [tempUserName isEqualToString:self.userName];
    BOOL scanOption2 = [tempUserName isEqualToString:@"telink_mesh1"];
    BOOL options;
//    options = scanContainOut_of_mesh ? (scanOption1 || scanOption2) : scanOption1;
    //要求扫描out_of_mesh;
    if (scanContainOut_of_mesh) {
        options = scanOption1 || scanOption2;
    }
    //不要求扫描out_of_mesh;
    else{
        options = scanOption1;
    }
    
    if (!options)
        return; //不符合扫描过滤条件
    NSString *tempName=[peripheral name];
    NSString *tempParStr=[[advertisementData objectForKey:@"kCBAdvDataManufacturerData"] description];

    [self printContentWithString:[NSString stringWithFormat:@"kCBAdvDataManufacturerData :  %@",advertisementData[@"kCBAdvDataManufacturerData"]]];
    NSLog(@"advertisementData -> %@", advertisementData);
    if (tempParStr.length>=30){
        //Uid
        
        kEndTimer(self.loginTimer)
        
        NSRange tempRange=NSMakeRange(1, 4);
        NSString *tempStr=[tempParStr substringWithRange:tempRange];
        uint32_t tempVid=[self getIntValueByHex:tempStr];
        if (tempVid==BTDevInfo_UID) {
            NSString *tempUuid=[[peripheral identifier] UUIDString];
            [self.IdentifersArrs addObject:peripheral];
            //ios9--<11021102 2211ffff 11022211 ffff0500 010f0000 01020304 05060708 090a0b0c 0d0e0f>
            NSString *deviceAddStr = [tempParStr substringWithRange:NSMakeRange(tempParStr.length-41, 4)];
            uint32_t deviceAdd = (uint32_t)strtoul([deviceAddStr UTF8String], 0, 16);
            BTDevItem *tempItem=[self getItemWithTag:tempUuid withAddress:deviceAdd];
            NSLog(@"deviceadd %04X -> %@",deviceAdd, deviceAddStr);
            BOOL isNew=NO;
            if (!tempItem) {
                isNew=YES;
                tempItem=[[BTDevItem alloc] init];
            }
            
            tempItem.devIdentifier=[[peripheral identifier] UUIDString];
            tempItem.name=tempName;
            tempItem.blDevInfo=peripheral;
            tempItem.u_Name=tempUserName;
            tempItem.u_Vid=tempVid;
            tempItem.rssi=[RSSI intValue];
            
            tempRange=NSMakeRange(5, 4);
            tempStr=[tempParStr substringWithRange:tempRange];
            tempItem.u_meshUuid=[self getIntValueByHex:tempStr];
            
            tempRange=NSMakeRange(10, 8);
            tempStr=[tempParStr substringWithRange:tempRange];
            tempItem.macAddress = [tempStr uppercaseString];
            tempItem.u_Mac=[self getIntValueByHex:tempStr];
            
            // 新的mac地址取值范围
//            NSString *s = @"<11021102 0a16024f 11020a16 024f0a00 010a000a 16024fff ff000000 00000000 000000>";
//            tempRange=NSMakeRange(43, 14);
//            tempStr=[s substringWithRange:tempRange];
            
            //PId
            if (tempParStr.length>=23) {
                tempRange=NSMakeRange(19, 4);
                tempStr=[tempParStr substringWithRange:tempRange];
                tempItem.u_Pid =[self getIntValueByHex:tempStr];
            }
            if (tempParStr.length>=25) {
                tempRange=NSMakeRange(23, 2);
                tempStr=[tempParStr substringWithRange:tempRange];
                tempItem.u_Status =[self getIntValueByHex:tempStr];
            }
            if (tempParStr.length>=41) {
                //目前了解ios 9.0以上时候
                
                tempRange=NSMakeRange(19, 4);
                NSString *tempString=[tempParStr substringWithRange:tempRange];
                if ([tempString isEqualToString:@"1102"]) {
                    tempRange=NSMakeRange(39, 2);
                    tempStr=[tempParStr substringWithRange:tempRange];
                    
                    tempStr = [NSString stringWithFormat:@"%@00",tempStr];
                    tempStr=[self replaceStr:tempStr TagStr:@" " WithStr:@""];
                    
                    if (tempParStr.length >= 36) {
                        NSRange Part1=NSMakeRange(32, 2);
                        NSRange Part2 = NSMakeRange(34, 2);
                        NSString *header = [tempParStr substringWithRange:Part1];
                        NSString *tailer = [tempParStr substringWithRange:Part2];
                        NSString *detailProductID = [NSString stringWithFormat:@"%@%@",tailer,header];
                        uint32_t ProductID = [self getIntValueByHex:detailProductID];
                        tempItem.productID = ProductID;
                    }
                }else{
                    tempStr=[self replaceStr:tempStr TagStr:@" " WithStr:@""];
                    tempItem.u_DevAdress =[self getIntValueByHex:tempStr];
                    tempRange=NSMakeRange(25, 5);
                    tempStr=[tempParStr substringWithRange:tempRange];
                    tempStr=[self replaceStr:tempStr TagStr:@" " WithStr:@""];
                    tempItem.u_DevAdress =[self getIntValueByHex:tempStr];
                    NSRange Part1=NSMakeRange(19, 2);
                    NSRange Part2 = NSMakeRange(21, 2);
                    NSString *header = [tempParStr substringWithRange:Part1];
                    NSString *tailer = [tempParStr substringWithRange:Part2];
                    NSString *detailProductID = [NSString stringWithFormat:@"%@%@",tailer,header];
                    uint32_t ProductID = [self getIntValueByHex:detailProductID];
                    tempItem.productID = ProductID;
                }
                tempItem.u_DevAdress =[self getIntValueByHex:tempStr];
            }
            if (isNew) {
                
                //正常模式
                [self.srcDevArrs addObject:tempItem];
        
                scanTime = 0;          //扫描超时清零
                [self.scanTimer invalidate];
                self.scanTimer = nil;
                [self sendDevChange:tempItem Flag:DevChangeFlag_Add];
                NSString *tip = [NSString stringWithFormat:@"scaned new device with address: 0x%04x", tempItem.u_DevAdress];
                [self printContentWithString:tip];
                
                if ([_delegate respondsToSelector:@selector(scanResult:)]) {
                    [[BTCentralManager shareBTCentralManager]stopScan];
                    self.disconnectType = DisconectType_SequrenceSetting;
                    [_delegate scanResult:tempItem];
                }
            }

            if (srcDevArrs.count==1 && isAutoLogin) {
                //NSLog(@"AutoLogining");
                _operaType=DevOperaType_AutoLogin;
                [self stopConnected];
                [[BTCentralManager shareBTCentralManager].centralManager stopScan];
                [self connectPro];

            }
        }
    }
}

- (void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral {
    NSLog(@"[CoreBluetooth] 0.7 连接上设备的回调");
    [self.centralManager stopScan];
    [self.connectTimer invalidate];
    connectTime = 0;
    peripheral.delegate=self;
    _isConnected=YES;
    [self printContentWithString:[NSString stringWithFormat:@"did connect address: 0x%04x", self.selConnectedItem.u_DevAdress]];
    
    if (self.scanWithOut_Of_Mesh == YES) {
        BTDevItem *connectedItem = [[BTDevItem alloc]init];
        connectedItem.blDevInfo = peripheral;
        if (connectedItem)
            [self sendDevChange:connectedItem Flag:DevChangeFlag_Connected];
        
    }else if(self.scanWithOut_Of_Mesh == NO){
        BTDevItem *tempItem=[self getDevItemWithPer:peripheral];
        if (tempItem) {
            [self sendDevChange:tempItem Flag:DevChangeFlag_Connected];
        }
    }
    NSLog(@"[CoreBluetooth] 0.71 调用发现设备Service方法");
    
    kEndTimer(self.loginTimer)
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeScanServices) repeats:NO];
    [peripheral discoverServices:nil];
}
- (void)loginT:(NSTimer *)timer {
    
    TimeoutType type = [timer.userInfo intValue];
    
    [self stateCodeAndErrorCodeAnasisly:type];
    if ([self.delegate respondsToSelector:@selector(loginTimeout:)]) {
        [self.delegate loginTimeout:(TimeoutType)[timer.userInfo intValue]];
    }
    kEndTimer(timer)
}

-(void)deleteLoginTimer {
    if (self.loginTimer != nil) {
        [self.loginTimer invalidate];
        self.loginTimer = nil;
    }
    
}

- (void)stateCodeAndErrorCodeAnasisly:(TimeoutType)type {
    if (![self.delegate respondsToSelector:@selector(exceptionReport:errorCode:)]) return;
    switch (type) {
        case TimeoutTypeScanDevice:{
            BTErrorCode errorCode = BTErrorCode_UnKnow;
            if (_centerState != CBCentralManagerStatePoweredOn) {
                errorCode = BTErrorCode_BLE_Disable;
            }else{
                errorCode = self.isCanReceiveAdv ? BTErrorCode_NO_Device_Scaned : BTErrorCode_NO_ADV;
            }
            [self.delegate exceptionReport:BTStateCode_Scan errorCode:errorCode%100];
        }   break;
        case TimeoutTypeConnectting: {
            [self.delegate exceptionReport:BTStateCode_Connect errorCode:BTErrorCode_Cannot_CreatConnectRelation%100];
        }   break;
        case TimeoutTypeScanServices:
        case TimeoutTypeScanCharacteritics: {
            [self.delegate exceptionReport:BTStateCode_Connect errorCode:BTErrorCode_Cannot_ReceiveATTList%100];
        }   break;
        case TimeoutTypeWritePairFeatureBack:{
            [self.delegate exceptionReport:BTStateCode_Login errorCode:BTErrorCode_WriteLogin_NOResponse%100];
        }   break;
        case TimeoutTypeReadPairFeatureBack:{
            [self.delegate exceptionReport:BTStateCode_Login errorCode:BTErrorCode_ReadLogin_NOResponse%100];
        }   break;
        case TimeoutTypeReadPairFeatureBackFailLogin:{
            [self.delegate exceptionReport:BTStateCode_Login errorCode:BTErrorCode_ValueCheck_LoginFail%100];
        }   break;
        default:    break;
    }
}


- (void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSLog(@"[CoreBluetooth] 0.7.2 连接设备失败的回调 %@ %d", error, error.code);

    //NSLog(@"Fail To Connect");
    [self reInitData];
    if (_operaType==DevOperaType_Set)
        [self setNewNetworkNextPro];
    else
    {
        BTDevItem *tempItem=[self getDevItemWithPer:peripheral];
        if (tempItem)
            [self sendDevChange:tempItem Flag:DevChangeFlag_ConnecteFail];
        
        if (isAutoLogin && [self.selConnectedItem.blDevInfo isEqual:peripheral])
        {
            _operaType=DevOperaType_AutoLogin;
            [self connectNextPro];
            //NSLog(@"ReConnecting Due TO Fail To Connect -%@",peripheral.description);
            
        }
    }
    
}

- (void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    
    BTDevItem *item = [self getDevItemWithPer:peripheral];
    [self printContentWithString:[NSString stringWithFormat:@"did disconnect address: 0x%04x", item.u_DevAdress]];
    NSLog(@"[CoreBluetooth] 0.7.2 设备断开连接");
    //对断开连接的灯进行设置
    if ([_delegate respondsToSelector:@selector(scanResult:)]) {
        [[BTCentralManager shareBTCentralManager]connectWithItem:item];
        [_delegate scanResult:item];
    }
    if ([_delegate respondsToSelector:@selector(settingForDisconnect:WithDisconectType:)]) {
        [_delegate settingForDisconnect:item WithDisconectType:DisconectType_SequrenceSetting];
        
    }
    self.disconnectType = DisconectType_Normal;
    [self reInitData];
    
    if (_operaType==DevOperaType_Set){
        [self selConnectedItem];
        if (self.flags == YES) {
            self.flags = NO;
        }else{
            NSLog(@"[CoreBluetooth] 从设备断开连接的回调调用连接设备的方法");
            [self connectPro];
            NSLog(@"[CoreBluetooth] 从设备断开连接的回调调用连接设备的方法结束");
        }
    }else {
        BTDevItem *tempItem=[self getDevItemWithPer:peripheral];
        if (tempItem){
            [self sendDevChange:tempItem Flag:DevChangeFlag_DisConnected];
        }
        if (isAutoLogin && [self.selConnectedItem.blDevInfo isEqual:peripheral] && !self.scanWithOut_Of_Mesh){
            _operaType=DevOperaType_AutoLogin;
            [self scanconnect];
        }
    }
//    BTLog(@"%@",@"Disconnect");
//    [self reInitData];
}

-(void)scanconnect{
    if ([_delegate respondsToSelector:@selector(resetStatusOfAllLight)]) {
        [_delegate resetStatusOfAllLight];
    }
    [self startScanWithName:self.userName Pwd:self.userPassword AutoLogin:YES];
    self.scanTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calulateTime) userInfo:nil repeats:YES];
}

-(void)calulateTime{
    if (scanTime == 6) {
        [self.scanTimer invalidate];
        self.scanTimer = nil;
        
        if ([_delegate respondsToSelector:@selector(resetStatusOfAllLight)]) {
            [_delegate resetStatusOfAllLight];
        }
    }
}

#pragma mark - Peripheral Delegate

- (void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error
{
    NSLog(@"[CoreBluetooth] 0.80 发现到设备Service回调");
    self.operaStatus=DevOperaStatus_ScanSrv_Finish;
    if (error) {
        BTLog(@"扫描服务错误: %@", [error localizedDescription]);
        //        [self setNewNetworkNextPro];
        return;
    }
    
    for (CBService *tempSer in peripheral.services)
    {
        if ([tempSer.UUID isEqual:[CBUUID UUIDWithString:BTDevInfo_ServiceUUID]]){
            NSLog(@"[CoreBluetooth] 0.82 找到里面含有设备信息的Service，然后调用发现该Service的特征");
            [self printContentWithString:[NSString stringWithFormat:@"did discover services for address: 0x%04x", self.selConnectedItem.u_DevAdress]];
            [peripheral discoverCharacteristics:nil forService:tempSer];
            
            kEndTimer(self.loginTimer)
            self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeScanCharacteritics) repeats:NO];
        }
        if ([tempSer.UUID isEqual:[CBUUID UUIDWithString:Service_Device_Information]]) {
            [peripheral discoverCharacteristics:nil forService:tempSer];
        }
        if ([tempSer.UUID isEqual:[CBUUID UUIDWithString:Service_CustomData]]) {
            dataService = tempSer;
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error {
    
    NSLog(@"[CoreBluetooth] 0.9 找到服务的特征的回调");
    
    if (![service isEqual:dataService]) {
        self.operaStatus=DevOperaStatus_ScanChar_Finish;
    }
    
    if (error) {
        [self setNewNetworkNextPro];
        return;
    }
    [self printContentWithString:[NSString stringWithFormat:@"did discover characteristics for address: 0x%04x", self.selConnectedItem.u_DevAdress]];
    
    for (CBCharacteristic *tempCharac in service.characteristics)
    {
        if ([tempCharac.UUID isEqual:[CBUUID UUIDWithString:BTDevInfo_FeatureUUID_Notify]])
        {
            [peripheral setNotifyValue:YES forCharacteristic:tempCharac];
            self.notifyFeature=tempCharac;
        }
        else if ([tempCharac.UUID isEqual:[CBUUID UUIDWithString:BTDevInfo_FeatureUUID_Command]])
        {
            self.commandFeature=tempCharac;
        }
        else if ([tempCharac.UUID isEqual:[CBUUID UUIDWithString:BTDevInfo_FeatureUUID_Pair]])
        {
            NSLog(@"[CoreBluetooth]0.91 这个是写登录的特征值 %@ ", tempCharac);
            self.pairFeature = tempCharac;
            if ([self.delegate respondsToSelector:@selector(scanedLoginCharacteristic)]) {
                [self.delegate scanedLoginCharacteristic];
            }
            
            if (_operaType == DevOperaType_Set || _operaType == DevOperaType_AutoLogin){
                NSLog(@"[CoreBluetooth] 1.0 调用登录");
                [self loginWithPwd:self.userPassword];      //    self.userName = addName;//扫描
            }
        }else if([tempCharac.UUID isEqual:[CBUUID UUIDWithString:BTDevInfo_FeatureUUID_OTA]]){
            self.otaFeature = tempCharac;
        }
        else if([tempCharac.UUID isEqual:[CBUUID UUIDWithString:Characteristic_Firmware]]){
            self.fireWareFeature = tempCharac;
//            [peripheral readValueForCharacteristic:tempCharac];
        }
        else if ([tempCharac.UUID isEqual:[CBUUID UUIDWithString:Characteristic_CustomData]]){
            self.customDataFeature = tempCharac;
            NSLog(@"[CoreBluetooth]0.91 这个是写客户数据的特征值 %@ ", tempCharac);
            [peripheral setNotifyValue:YES forCharacteristic:tempCharac];
        }
    }
    NSLog(@"[CoreBluetooth] pairFeature %@", self.pairFeature);
    
}

-(void)reloadState:(CBCharacteristic *)characteristic{
    
}


- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error) {
        BTLog(@"收到数据错误: %@", [error localizedDescription]);
        return;
    }
    if ([characteristic isEqual:self.pairFeature]) {
        
        NSLog(@"[CoreBluetooth] 1.3.1 pairFeature back");
        
        uint8_t *tempData=(uint8_t *)[characteristic.value bytes];
        
        if (_operaStatus==DevOperaStatus_Login_Start) {
            kEndTimer(self.loginTimer)
            if (!tempData) return;
            if (tempData[0]==13) {
                uint8_t buffer[16];
                
                NSLog(@"[CoreBluetooth] %d", (OperaStatus)DevOperaStatus_Login_Start);
                
                if ([CryptoAction encryptPair:self.userName
                                          Pas:self.userPassword
                                        Prand:tempData+1
                                      PResult:buffer]) {
                    [self logByte:buffer Len:16 Str:@"CheckBuffer"];
                    memset(buffer, 0, 16);
                    [CryptoAction getSectionKey:self.userName
                                            Pas:self.userPassword
                                         Prandm:loginRand
                                         Prands:tempData+1
                                        PResult:buffer];
                    
                    memcpy(sectionKey, buffer, 16);
                    [self logByte:buffer Len:16 Str:@"SectionKey"];
                    
                    _isLogin=YES;
                    
                    if (dataService != nil) {
                        [peripheral discoverCharacteristics:nil forService:dataService];
                    }
                    
                    self.stateCode = BTStateCode_Normal;
                    
                    if ([_delegate respondsToSelector:@selector(OnDevChange:Item:Flag:)]) {
                        [_delegate OnDevChange:self Item:[self getDevItemWithPer:peripheral] Flag:DevChangeFlag_Login];
                    }
                    if (!self.scanWithOut_Of_Mesh) {
                        [self.getNotifyTimer invalidate];
                        self.getNotifyTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(setNotifyOpenProSevervalTimes) userInfo:nil repeats:YES];
                    }
                }
            }else{
                if (self.stateCode == BTStateCode_Login){
                    [self stateCodeAndErrorCodeAnasisly:TimeoutTypeReadPairFeatureBackFailLogin];
                }
                    
            }
            
            if (!_isLogin) {
                [self printContentWithString:[NSString stringWithFormat:@"login fail with address: 0x%04x", self.selConnectedItem.u_DevAdress]];
                [self stopConnected];//重置BUG
            }else{
                self.operaStatus=DevOperaStatus_Login_Finish;
                [self printContentWithString:[NSString stringWithFormat:@"login success with address: 0x%04x", self.selConnectedItem.u_DevAdress]];
            }
            if (_operaType==DevOperaType_Set)
            {
                if (_isLogin){
                    [self setNewNetworkDataPro];
                }else{
                    [self setNewNetworkNextPro];
                }
            }
        }
        else if (_operaStatus==DevOperaStatus_SetLtk_Start)
        {
            if (tempData[0]==7)
            {
                BTLog(@"%@",@"Set Success");
                _selConnectedItem.isSetedSuff=YES;
            }
            if (isSetAll && !self.isEndAllSet)
                [self setNewNetworkNextPro];
            else
            {
                self.operaStatus=DevOperaStatus_SetNetwork_Finish;
                NSLog(@"2 ---------------- DevOperaStatus_SetNetwork_Finish");
            }
        }
    } else if ([characteristic isEqual:self.commandFeature]){
        
        NSLog(@"[CoreBluetooth] 1.3.2 commandFeature back");
        
        if (_isLogin){
            BTLog(@"%@",@"Command 数据解析");
            uint8_t *tempData=(uint8_t *)[characteristic.value bytes];
            [self pasterData:tempData IsNotify:NO];
        }
    } else if ([characteristic isEqual:self.notifyFeature]){
        
        NSLog(@"[CoreBluetooth] 1.3.3 notifyFeature back");
        
        BTLog(@"Recieve_Notify_Data%@",characteristic.value);
        if (_isLogin)
        {
            BTLog(@"%@",@"Notify_Data_Analyses");
            uint8_t *tempData=(uint8_t *)[characteristic.value bytes];
            [self pasterData:tempData IsNotify:YES];
            //打印log
            NSString *noti = [NSString stringWithFormat:@"notify back:%@",characteristic.value];
//            if (noti.length>38) {
//                NSString *h = [noti substringToIndex:26];
//                NSString *l = [noti substringFromIndex:noti.length-12];
//                noti = [NSString stringWithFormat:@"%@....%@",h,l];
//            }
            [self printContentWithString:noti];
        }
    } else if ([characteristic isEqual:self.fireWareFeature]){
        
        NSLog(@"[CoreBluetooth] 1.3.4 fireWareFeature back");
        
        NSData *tempData = [characteristic value];
        if ([_delegate respondsToSelector:@selector(OnConnectionDevFirmWare:)] && tempData) {
            [_delegate OnConnectionDevFirmWare:tempData];
        }
        if ([_delegate respondsToSelector:@selector(OnConnectionDevFirmWare:Item:)]) {
            BTDevItem *item= [self getDevItemWithPer:peripheral];
            [_delegate OnConnectionDevFirmWare:tempData Item:item];
        }
    }
    else if ([characteristic isEqual:self.customDataFeature]){
        NSData *tempData = [characteristic value];
        
        NSLog(@"custom data receive" );
        
        if (self.UpdateDataBlock != nil) {
            self.UpdateDataBlock(tempData);
        }
    }
}


- (void)peripheral:(CBPeripheral *)peripheral didWriteValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    if (error && ![characteristic isEqual:self.otaFeature]) {
        //NSLog(@"Write___Error: %@<--> %@", [error localizedFailureReason],[[NSString alloc]initWithData:characteristic.value encoding:NSUTF8StringEncoding]);
        return;
    }
    BTLog(@"%@",@"Write Successed");
    if ([characteristic isEqual:self.pairFeature]){
        [self.selConnectedItem.blDevInfo readValueForCharacteristic:self.pairFeature];
        kEndTimer(self.loginTimer)
        self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeReadPairFeatureBack) repeats:NO];
    }
    else if ([characteristic isEqual:self.customDataFeature])
    {
        NSLog(@"customDataFeature Write Successed");
    }
}

#pragma mark Public
-(void)startScanWithName:(NSString *)nStr Pwd:(NSString *)pwd{
    
    NSLog(@"[CoreBluetooth] 0 进入扫描设备方法");
    NSLog(@"[CoreBluetooth] Mesh -> %@, %@", nStr, pwd);
    [self stopScan];
    [self stopConnected];
    self.userName=nStr;
    self.userPassword=pwd;
    self.isNeedScan=YES;
    if (_centerState == CBCentralManagerStatePoweredOn) {
        [self printContentWithString:@"ready scan devices "];
        [_centralManager scanForPeripheralsWithServices:nil options:nil];
    }
    kEndTimer(self.loginTimer)
    self.isCanReceiveAdv = NO;
    
    self.stateCode = BTStateCode_Scan;
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:self.scanTimeout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeScanDevice) repeats:NO];
}

-(void)startScanWithName:(NSString *)nStr Pwd:(NSString *)pwd AutoLogin:(BOOL)autoLogin{
    self.isAutoLogin=autoLogin;
    [self startScanWithName:nStr Pwd:pwd];
}

-(void)stopScan{
    @synchronized (self) {
        if (self.selConnectedItem && self.selConnectedItem.blDevInfo && _isConnected) {
            NSMutableArray *pers = [[NSMutableArray alloc] init];
            for (int i=0; i<srcDevArrs.count; i++) {
                [pers addObject:[srcDevArrs[i] blDevInfo].identifier.UUIDString];
            }
            BOOL contain = NO;
            for (int jj=0; jj<pers.count; jj++) {
                if ([pers[jj] isEqualToString:self.selConnectedItem.blDevInfo.identifier.UUIDString]) {
                    contain = YES;
                    break;
                }
            }
            if (contain) {
                if (self.selConnectedItem.blDevInfo.state==CBPeripheralStateConnected||
                    self.selConnectedItem.blDevInfo.state==CBPeripheralStateConnecting) {
                    [_centralManager cancelPeripheralConnection:[self.selConnectedItem blDevInfo]];
                }
            }
        }
        _selConnectedItem=nil;
        [self.srcDevArrs removeAllObjects];
        [self.IdentifersArrs removeAllObjects];
        [self reInitData];
        [_centralManager stopScan];
    }
}

-(void)connectPro {
    if ([srcDevArrs count]<1)
        return;
    BTDevItem *item = nil;
    if ([srcDevArrs lastObject] == _selConnectedItem) {
        item = srcDevArrs[0];
    }else{
        item = [srcDevArrs lastObject];
    }
    
    //扫描连接的时候
    if ([item.u_Name isEqualToString:@"telink_mesh1"]&& self.scanWithOut_Of_Mesh == YES) {
        self.userName = @"telink_mesh1";
        self.userPassword = @"123";
    }
    _selConnectedItem=item;
    
    
    [self.centralManager connectPeripheral:[item blDevInfo]
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    NSString *tip = [NSString stringWithFormat:@"send connect request for address: 0x%04x", self.selConnectedItem.u_DevAdress];
    [self printContentWithString:tip];
    
    kEndTimer(self.loginTimer)
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeConnectting) repeats:NO];
}

-(void)connectNextPro
{
    if ([srcDevArrs count]<2)
        return;
    
    BTDevItem *tempItem=[self getNextItemWith:self.selConnectedItem];
    if (!tempItem)
        return;
    [self printContentWithString:[NSString stringWithFormat:@"connect next device : 0x%04x", tempItem.u_DevAdress]];
    _selConnectedItem=tempItem;
    [self.centralManager connectPeripheral:[tempItem blDevInfo]
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
}

-(void)connectWithItem:(BTDevItem *)cItem
{
    [self stopConnected];
    if (!cItem)
        return;
    [self printContentWithString:[NSString stringWithFormat:@"connect device directly : 0x%04x", cItem.u_DevAdress]];
    _selConnectedItem=cItem;
    [self.centralManager connectPeripheral:[cItem blDevInfo]
                                   options:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:CBConnectPeripheralOptionNotifyOnDisconnectionKey]];
    kEndTimer(self.loginTimer)
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeConnectting) repeats:NO];
}

-(void)loginWithPwd:(NSString *)pStr {
    if (!pStr) {
        pStr = userPassword;
    }
    if (!self.pairFeature) return;
    if (!_isConnected)  return;
    //NSLog(@"Logining");
    self.operaStatus=DevOperaStatus_Login_Start;
    
    
    self.userPassword=pStr;
    uint8_t buffer[17];
    [CryptoAction getRandPro:loginRand Len:8];
    
    for (int i=0;i<8;i++)
        loginRand[i]=i;
    
    buffer[0]=12;
    
    [CryptoAction encryptPair:self.userName
                          Pas:self.userPassword
                        Prand:loginRand
                      PResult:buffer+1];
    
    [self logByte:buffer Len:17 Str:@"Login_String"];
//    NSLog(@"[CoreBluetooth] 1.2 写特征值");
    
    kEndTimer(self.loginTimer)
    self.loginTimer = [NSTimer scheduledTimerWithTimeInterval:kLoginTimerout target:self selector:@selector(loginT:) userInfo:@(TimeoutTypeWritePairFeatureBack) repeats:NO];
    self.stateCode = BTStateCode_Login;
    [self printContentWithString:[NSString stringWithFormat:@"ready login device with address: 0x%04x", self.selConnectedItem.u_DevAdress]];
    [self writeValue:self.pairFeature Buffer:buffer Len:17 response:CBCharacteristicWriteWithResponse];
}

-(void)SetSelConnectedItem:(BTDevItem *)setTag {
    _selConnectedItem=setTag;
    [self reInitData];
}

-(BTDevItem *)selConnectedItem {
    return _selConnectedItem;
}

-(NSArray *)devArrs {
    return [NSArray arrayWithArray:self.srcDevArrs];
}

-(void)setOperaStatus:(OperaStatus)setTag {
    if (_operaStatus!=setTag) {
        _operaStatus=setTag;
        [self sendDevOperaStatusChange:_operaStatus];
        if (_operaType==DevOperaType_AutoLogin && _operaStatus==DevOperaStatus_Login_Finish) {
            _operaType=DevOperaType_Normal;
        }
        if (_operaType==DevOperaType_Set && _operaStatus==DevOperaStatus_SetNetwork_Finish && (isEndAllSet || !isSetAll)) {
            _operaType=DevOperaType_Normal;
        }
    }
}

-(NSString *)userName
{
    if CheckStr(userName)
        self.userName=BTDevInfo_UserNameDef;
    return userName;
}

-(NSString *)userPassword
{
    if CheckStr(userPassword)
        self.userPassword=BTDevInfo_UserPasswordDef;
    return userPassword;
}

- (NSArray *)changeCommandToArray:(uint8_t *)cmd len:(int)len {
    NSMutableArray *arr = [NSMutableArray array];
    for (int i=0; i<len; i++) {
        [arr addObject:[NSString stringWithFormat:@"%02X",cmd[i]]];
    }
    return arr;
}
- (void)sendCommand:(uint8_t *)cmd Len:(int)len {
    NSArray *cmdArr = [self changeCommandToArray:cmd len:len];
    [self printContentWithString:[NSString stringWithFormat:@"   ready cmd: %@",[cmdArr componentsJoinedByString:@" "]]];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970]; //
    if (_clickDate>current) _clickDate = 0;//修复手机修改时间错误造成的命令延时执行错误的问题；
//    NSLog(@"[CoreBluetoothh] 执行 ? : %f %@", current,[[self changeCommandToArray:cmd len:len] componentsJoinedByString:@"-"]);
    //if cmd is nil , return;
    if (!cmdArr) return;
    //if _clickDate is equal 0,it means the first time to executor command
    NSTimeInterval count = 0;
    
    if (cmd[7]==0xd0||cmd[7]==0xd2||cmd[7]==0xe2) {
        self.containCYDelay = YES;
        self.btCMDType = BTCommandCaiYang;
        if ((current - _clickDate)<kCMDInterval) {
            if (_clickTimer) {
                dispatch_cancel(_clickTimer);
                //                [_clickTimer invalidate];
                _clickTimer = nil;
                addIndex--;
            }
            //            count = kCMDInterval+self.clickDate-current;
            count = (uint64_t)((kCMDInterval+self.clickDate-current) * NSEC_PER_SEC);
            dispatch_queue_t quen = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            _clickTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, quen);
            dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(count));
            uint64_t interv = (int64_t)(kCMDInterval * NSEC_PER_SEC);
            dispatch_source_set_timer(_clickTimer, start, interv, 0);
//            NSLog(@"执行 ？ 采样: %f %@", current,[[self changeCommandToArray:cmd len:len] componentsJoinedByString:@"-"]);
            dispatch_source_set_event_handler(_clickTimer, ^{
                [self cmdTimer:cmdArr];
            });
            dispatch_resume(_clickTimer);
        }else{
//            NSLog(@"执行 ？ 采样直接发出: %f %@", current,[[self changeCommandToArray:cmd len:len] componentsJoinedByString:@"-"]);
            [self cmdTimer:cmdArr];
        }
    }
    else {
        self.btCMDType = BTCommandInterval;
        double temp = current-self.exeCMDDate;
//        NSLog(@"执行 ？其他 %@\n", [[self changeCommandToArray:cmd len:len] componentsJoinedByString:@"-"]);
        if (((temp<kCMDInterval)&&(temp>0))||temp<0) {
            if (self.exeCMDDate==0) {
                self.exeCMDDate=current;
            }
            self.exeCMDDate = self.exeCMDDate + kCMDInterval;
            count = self.exeCMDDate + kCMDInterval-current;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self performSelector:@selector(cmdTimer:) withObject:cmdArr afterDelay:count];
            });
        } else {
            [self cmdTimer:cmdArr];
        }
    }
}

- (void)cmdTimer:(id)temp {
    @synchronized (self) {
        if (_clickTimer) {
            dispatch_cancel(_clickTimer);
            //        [_clickTimer invalidate];
            _clickTimer = nil;
            addIndex--;
        }
        int len = (int)[temp count];
        uint8_t cmd[len];
        for (int i = 0; i < len; i++) {
            cmd[i] = strtoul([temp[i] UTF8String], 0, 16);
        }
        NSTimeInterval current = [[NSDate date] timeIntervalSince1970];//
        _clickDate = current;
        [self exeCMD:cmd len:len];
    }
}

- (void)exeCMD:(Byte *)cmd len:(int)len {
    if (!_isConnected ||!_isLogin ||!self.selConnectedItem) return;
    [self printContentWithString:[NSString stringWithFormat:@"execute cmd: %@",[[self changeCommandToArray:cmd len:len] componentsJoinedByString:@" "]]];
    NSTimeInterval current = [[NSDate date] timeIntervalSince1970];//
    //保存执行某次命令的时间戳
//    NSLog(@"[CoreBluetoothh] 执行 : %f %@", current,[[self changeCommandToArray:cmd len:len] componentsJoinedByString:@"-"]);
    
    if (self.exeCMDDate<current) {
        self.exeCMDDate = current;
    }
    
    uint8_t buffer[20];
    uint8_t sec_ivm[8];
    
    memset(buffer, 0, 20);
    memcpy(buffer, cmd, len);
    memset(sec_ivm, 0,8);
    
    [self getNextSnNo];
    buffer[0]=snNo & 0xff;
    buffer[1]=(snNo>>8) & 0xff;
    buffer[2]=(snNo>>16) & 0xff;
    
    uint32_t tempMac=self.selConnectedItem.u_Mac;
    
    sec_ivm[0]=(tempMac>>24) & 0xff;
    sec_ivm[1]=(tempMac>>16) & 0xff;
    sec_ivm[2]=(tempMac>>8) & 0xff;
    sec_ivm[3]=tempMac & 0xff;
    
    sec_ivm[4]=1;
    sec_ivm[5]=buffer[0];
    sec_ivm[6]=buffer[1];
    sec_ivm[7]=buffer[2];
    [self logByte:buffer Len:20 Str:@"Command"];
    [CryptoAction encryptionPpacket:sectionKey Iv:sec_ivm Mic:buffer+3 MicLen:2 Ps:buffer+5 Len:15];
    [self writeValue:self.commandFeature Buffer:buffer Len:20 response:CBCharacteristicWriteWithoutResponse];
}

+ (BTCentralManager*) shareBTCentralManager {
    static BTCentralManager *shareBTCentralManager = nil;
    static dispatch_once_t tempOnce=0;
    dispatch_once(&tempOnce, ^{
        shareBTCentralManager = [[BTCentralManager alloc] init];
        [shareBTCentralManager initData];
    });
    return shareBTCentralManager;
}


/**
 *一个mesh内部所有灯的all_on
 */

-(void)turnOnAllLight{
    uint8_t cmd[13]={0x11,0x11,0x11,0x00,0x00,0xff,0xff,0xd0,0x11,0x02,0x01,0x01,0x00};
    [self logByte:cmd Len:13 Str:@"All_On"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

/**
 *一个mesh内部所有灯的all_off
 */
-(void)turnOffAllLight{
    uint8_t cmd[13]={0x11,0x11,0x12,0x00,0x00,0xff,0xff,0xd0,0x11,0x02,0x00,0x01,0x00};
    [self logByte:cmd Len:13 Str:@"All_Off"];
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
    
}

- (void)testCertainLightWithAddress:(uint32_t )u_DevAddress
{
    uint8_t cmd[20]={0x11,0x71,0x11,0x00,0x00,0x66,0x00,0xea,0x11,0x02,0x10,0x00,0xff,0x00,0x00,0x00,0x32,0x01,0x00,0xe3};
    cmd[5]=(u_DevAddress>>8) & 0xff;
    cmd[6]=u_DevAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Turn_On"];   //控制台日志
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:20];
}

/**
 *单灯的开－--------开灯--squrence no＋2
 */
//
-(void)turnOnCertainLightWithAddress:(uint32_t )u_DevAddress{
    uint8_t cmd[13]={0x11,0x71,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x01,0x01,0x00};
    cmd[5]=(u_DevAddress>>8) & 0xff;
    cmd[6]=u_DevAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Turn_On"];   //控制台日志
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

/**
 *单灯的关－－－关灯--squrence no＋1
 
 */
-(void)turnOffCertainLightWithAddress:(uint32_t )u_DevAddress{
    uint8_t cmd[13]={0x11,0x11,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x00,0x01,0x00};
    cmd[5]=(u_DevAddress>>8) & 0xff;
    cmd[6]=u_DevAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Turn_Off"];   //控制台日志
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
    
}

/**
 *组的开灯－－－传入组地址
 */
-(void)turnOnCertainGroupWithAddress:(uint32_t )u_GroupAddress
{
    uint8_t cmd[13]={0x11,0x51,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x01,0x01,0x00};
    cmd[6]=(u_GroupAddress>>8) & 0xff;
    cmd[5]=u_GroupAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Group_On"];   //控制台日志
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

/**
 *组的关灯－－－传入组地址
 */
-(void)turnOffCertainGroupWithAddress:(uint32_t )u_GroupAddress
{
    uint8_t cmd[13]={0x11,0x31,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x00,0x01,0x00};
    cmd[6]=(u_GroupAddress>>8) & 0xff;
    cmd[5]=u_GroupAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Group_Off"];   //控制台日志
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}



-(void)replaceDeviceAddress:(uint32_t)presentDevAddress WithNewDevAddress:(NSUInteger)newDevAddress{
    uint8_t cmd[12]={0x11,0x11,0x70,0x00,0x00,0x00,0x00,0xe0,0x11,0x02,0x00,0x00};
    cmd[5]=(presentDevAddress>>8) & 0xff;
    cmd[6]=presentDevAddress & 0xff;
    cmd[10]=newDevAddress;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    [self logByte:cmd Len:13 Str:@"Distribute_Address"];   //控制台日志
    [self printContentWithString:[NSString stringWithFormat:@"发出修改地址命令: 0x%04x", [[srcDevArrs firstObject] u_DevAdress]]];
    [[BTCentralManager shareBTCentralManager]sendCommand:cmd Len:12];
    
}

-(void)setGroupLumWithGroupID:(NSInteger)groupid withLum:(NSInteger)lum
{
    uint8_t cmd[13]={0x11,0x61,0x21,0x00,0x00,0x66,0x00,0xd2,0x11,0x02,0x0A};
    cmd[5] = groupid;
    cmd[6] = 0x80;
    cmd[10] = lum;
    [self logByte:cmd Len:11 Str:@"亮度"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:11];
}

-(void)setGroupPower:(NSInteger)groupid withPower:(BOOL)on
{
    uint8_t cmd[13]={0x11,0x31,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x00,0x01,0x00};
    cmd[5]=groupid;
    cmd[6]=0x80;
    cmd[2]=cmd[2]+addIndex;
    
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    if (on) {
        cmd[10]=0x01;
    }
    else
    {
        cmd[10]=0x00;
    }
    
    addIndex++;

    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

-(void)setGroupRGB:(NSInteger)groupid withRed:(float)R withGreen:(float)G withBlue:(float)B
{
    CGFloat red, green, blue;
    red = (CGFloat)R;
    green = (CGFloat)G;
    blue = (CGFloat)B;
    
    uint8_t cmd[14]={0x11,0x61,0x31,0x00,0x00,0x66,0x00,0xe2,0x11,0x02,0x04,0x0,0x0,0x0};
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    
    cmd[5]=groupid;
    cmd[6]=0x80;
    cmd[11]=red*255.f;
    cmd[12]=green*255.f;
    cmd[13]=blue*255.f;
    [self logByte:cmd Len:11 Str:@"RGB"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:14];
}

-(void)setGroupCWGroupID:(NSInteger)groupid withCold:(NSInteger)cold withWarm:(NSInteger)warm withLum:(NSInteger)lum
{
    uint8_t cmd[14]={0x11,0x11,0x88,0x00,0x00,0x00,0x00,0xe2,0x11,0x02,0x06,0x00,0x00,0x00};
    
    cmd[5] = groupid;
    cmd[6] = 0x80;
    
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    cmd[11] = lum;
    cmd[12] = cold;
    cmd[13] = warm;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:14];
}

-(void)setGroupOnOrOff:(NSInteger)groupid withTurnOn:(BOOL)on
{
    uint8_t cmd[13]={0x11,0x11,0x11,0x00,0x00,0x66,0x00,0xd0,0x11,0x02,0x00,0x01,0x00};
    
    if (on) {
        cmd[10] = 0x01;
    }
    
    cmd[5]=groupid;
    cmd[6]=0x80;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    
    addIndex++;
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

/**
 *设置亮度值lum－－传入目的地址和亮度值---可以是单灯或者组的地址
 */
-(void)setLightOrGroupLumWithDestinateAddress:(uint32_t)destinateAddress WithLum:(NSInteger)lum withMode:(BOOL)bAllModel{
    
    uint8_t cmd[11]={0x11,0x11,0x50,0x00,0x00,0x00,0x00,0xd2,0x11,0x02,0x0A};
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinateAddress>>8) & 0xff;
        cmd[6]=destinateAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    //设置亮度值
    cmd[10]=lum;
//    [self logByte:cmd Len:13 Str:@"Change_Brightness"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:11];
}
/**
 *设置RGB－－－传入目的地址和R.G.B值－－-可以是单灯或者组的地址
 */

-(void)setLightOrGroupRGBWithDestinateAddress:(uint32_t)destinateAddress WithColorR:(float)R WithColorG:(float)G WithB:(float)B{
    CGFloat red, green, blue;
    red = (CGFloat)R;
    green = (CGFloat)G;
    blue = (CGFloat)B;
    
    uint8_t cmd[14]={0x11,0x61,0x31,0x00,0x00,0x66,0x00,0xe2,0x11,0x02,0x04,0x0,0x0,0x0};
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    cmd[5]=(destinateAddress>>8) & 0xff;
    cmd[6]=destinateAddress & 0xff;
    cmd[11]=red*255.f;
    cmd[12]=green*255.f;
    cmd[13]=blue*255.f;
    [self logByte:cmd Len:11 Str:@"RGB"];
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:14];
    
    
}

-(void)setGroupLightWithAdr:(uint32_t)destinateAddress withGroupID:(NSInteger)groupid IsAdd:(BOOL)isAdd
{
    uint8_t cmd[13]={0x11,0x71,0x11,0x00,0x00,0x66,0x00,0xd7,0x11,0x02,0x01,0x01,0x80};
    cmd[5] = (destinateAddress>>8) & 0xff;
    cmd[6] = destinateAddress & 0xff;
    
    cmd[11]=groupid;
    
    if (isAdd)
    {
        cmd[10]=0x01;
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==250) {
            cmd[2]=4;
        }
        
        addIndex++;
    }
    else
    {
        cmd[10]=0x00;
        cmd[12]=0xff;
        cmd[11]=0xff;
        cmd[2]=cmd[2]+addIndex;
        if (cmd[2]==250) {
            cmd[2]=1;
        }
        
        addIndex++;
    }
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
}

/**
 *加组－－－传入待加灯的地址，和 待加入的组的地址
 */
-(void)addDevice:(uint32_t)targetDeviceAddress ToDestinateGroupAddress:(uint32_t)groupAddress{
    
    uint8_t cmd[13]={0x11,0x61,0x11,0x00,0x00,0x00,0x00,0xd7,0x11,0x02,0x01,0x02,0x80};
    cmd[5]=(targetDeviceAddress>>8) & 0xff;
    cmd[6]=targetDeviceAddress & 0xff;
    
    cmd[12]=(groupAddress>>8) & 0xff;
    
    cmd[11]=groupAddress & 0xff;
    
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]>=254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
    
}

//删出组
-(void)deleteDevice:(uint32_t)targetDeviceAddress ToDestinateGroupAddress:(uint32_t)groupAddress
{
    uint8_t cmd[13]={0x11,0x61,0x11,0x00,0x00,0x00,0x00,0xd7,0x11,0x02,0x00,0x02,0x80};
    cmd[5]=(targetDeviceAddress>>8) & 0xff;
    cmd[6]=targetDeviceAddress & 0xff;
    cmd[12]=(groupAddress>>8) & 0xff;
    cmd[11]=groupAddress & 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]>=254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:13];
    
}

/**
 *kick-out---传入待处置的灯的地址－－－地址目前建议只针对组；；；
 目前的功能是,删除灯的所有参数(mac地址除外),并把password、ltk恢 复为出厂值,mesh name设置为“out_of_mesh”
 */

-(void)kickoutLightFromMeshWithDestinateAddress:(uint32_t)destinateAddress {
    uint8_t cmd[10]={0x11,0x61,0x31,0x00,0x00,0x00,0x00,0xe3,0x11,0x02,};
    cmd[5]=(destinateAddress>>8) & 0xff;
    cmd[6]=destinateAddress& 0xff;
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:10];
}

-(void)setCTOfLightWithDestinationAddress:(uint32_t)destinationAddress AndCT:(float)CT{
    uint8_t cmd[12]={0x11,0x11,0x88,0x00,0x00,0x00,0x00,0xe2,0x11,0x02,0x05,0x00};
    cmd[5]=(destinationAddress>>8) & 0xff;
    cmd[6]=destinationAddress & 0xff;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    cmd[10] = CT;
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:12];
    
}

-(void)setColdWarmCTOfLightWithDestinationAddress:(uint32_t)destinationAddress AndBrightness:(float)bright AndColdValue:(float)cold AndWarmValue:(float)warm withMode:(BOOL)bAllModel{
    
    uint8_t cmd[14]={0x11,0x11,0x88,0x00,0x00,0x00,0x00,0xe2,0x11,0x02,0x06,0x00,0x00,0x00};
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    cmd[11] = bright;
    cmd[12] = cold;
    cmd[13] = warm;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:14];
}

- (void)getGroupAddressWithDeviceAddress:(uint32_t)destinationAddress {
    uint8_t cmd[12]={0x11,0x12 ,0x88,0x00,0x00,0x00,0x00,0xdd,0x11,0x02,0x10,0x01};
    cmd[5]=(destinationAddress>>8) & 0xff;
    cmd[6]=destinationAddress & 0xff;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:12];
}

-(void)addGroupAlarmOn:(NSInteger)groupid withMode:(BOOL)bAllModel withTime:(NSInteger)time
{
    uint8_t cmd[19]={0x11,0x11,0x5c,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    
    parl p;
    p.cmd = 1;
    p.type = 1;
    p.enabel = 1;
    
    cmd[5]=groupid;
    cmd[6]=0x80;
    
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    uint8_t num;
    memcpy((void*)(&num), (void*)&p, sizeof(p));
    
    NSInteger hour = time / 60;
    NSInteger min = time % 60;
    
    cmd[12] = num;
    cmd[13] = 0x01;
    cmd[14] = 0x7f;
    cmd[15] = hour;           // hour
    cmd[16] = min;            // min
    cmd[17] = 0;            // second
    cmd[18] = 0x00;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:19];
}

-(void)deleteGroupAlarm:(NSInteger)groupid
{
    uint8_t cmd[18]={0x11,0x11,0x5d,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x01,0xff,0x00,0x00,0x00,0x00,0x00,0x00};
    
    cmd[5]=groupid;
    cmd[6]=0x80;
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:18];
}

-(void)addGroupAlarmOff:(NSInteger)groupid withMode:(BOOL)bAllModel withTime:(NSInteger)time
{
    uint8_t cmd[19]={0x11,0x11,0x5c,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    
    parl p;
    p.cmd = 0;
    p.type = 1;
    p.enabel = 1;
    
    cmd[5]=groupid;
    cmd[6]=0x80;
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    uint8_t num;
    memcpy((void*)(&num), (void*)&p, sizeof(p));
    
    NSInteger hour = time / 60;
    NSInteger min = time % 60;
    
    cmd[12] = num;
    cmd[13] = 0x01;
    cmd[14] = 0x7f;
    cmd[15] = hour;         // hour
    cmd[16] = min;          // min
    cmd[17] = 0;          // second
    cmd[18] = 0x00;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:19];
}

-(void)setGroupCurrentTime:(NSInteger)groupid withMode:(BOOL)bAllModel
{
//    uint8_t cmd[17]={0x11,0x11,0x5a,0x00,0x00,0x00,0x00,0xe4,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
//
//    NSDate *today = [NSDate date];
//    BFDateInformation info = [today dateInformation];
//
//    cmd[5]=groupid;
//    cmd[6]=0x80;
//
//    cmd[2] = cmd[2]+addIndex;
//    if (cmd[2]==254) {
//        cmd[2]=1;
//    }
//    addIndex++;
//    cmd[10] = info.year & 0xff;
//    cmd[11] = (info.year>>8) & 0xff;
//    cmd[12] = info.month;
//    cmd[13] = info.day;
//    cmd[14] = info.hour;
//    cmd[15] = info.minute;
//    cmd[16] = info.second;
//
//    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:17];
}

-(void)setCurrentTime:(uint32_t )destinationAddress
             withYear:(NSInteger)year
            withMonth:(NSInteger)month
              withDay:(NSInteger)day
             withHour:(NSInteger)hour
           withMinute:(NSInteger)minute
           withSecond:(NSInteger)second
{
    uint8_t cmd[17]={0x11,0x11,0x5a,0x00,0x00,0x00,0x00,0xe4,0x11,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

    NSDate *today = [NSDate date];

    cmd[5]=(destinationAddress>>8) & 0xff;
    cmd[6]=destinationAddress & 0xff;

    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    cmd[10] = year & 0xff;
    cmd[11] = (year>>8) & 0xff;
    cmd[12] = month;
    cmd[13] = day;
    cmd[14] = hour;
    cmd[15] = minute;
    cmd[16] = second;

    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:17];
}

-(void)getCurrentTime:(uint32_t )destinationAddress withMode:(BOOL)bAllModel
{
    uint8_t cmd[11]={0x11,0x11,0x57,0x00,0x00,0x00,0x00,0xe8,0x11,0x02,0x10};
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:11];
}

-(void)addAlarmOn:(uint32_t )destinationAddress withMode:(BOOL)bAllModel withTime:(NSInteger)time{
    uint8_t cmd[19]={0x11,0x11,0x5c,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    
    parl p;
    p.cmd = 1;
    p.type = 1;
    p.enabel = 1;
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2]=cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    uint8_t num;
    memcpy((void*)(&num), (void*)&p, sizeof(p));
    
    NSInteger hour = time / 60;
    NSInteger min = time % 60;
    
    cmd[12] = num;
    cmd[13] = 0x01;
    cmd[14] = 0x7f;
    cmd[15] = hour;           // hour
    cmd[16] = min;            // min
    cmd[17] = 0;            // second
    cmd[18] = 0x00;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:19];
}

-(void)addAlarmOff:(uint32_t )destinationAddress withMode:(BOOL)bAllModel withTime:(NSInteger)time{
    uint8_t cmd[19]={0x11,0x11,0x5c,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,
        0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    
    parl p;
    p.cmd = 0;
    p.type = 1;
    p.enabel = 1;
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    uint8_t num;
    memcpy((void*)(&num), (void*)&p, sizeof(p));
    
    NSInteger hour = time / 60;
    NSInteger min = time % 60;
    
    cmd[12] = num;
    cmd[13] = 0x01;
    cmd[14] = 0x7f;
    cmd[15] = hour;         // hour
    cmd[16] = min;          // min
    cmd[17] = 0;          // second
    cmd[18] = 0x00;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:19];
}

-(void)getAlarm:(uint32_t )destinationAddress withMode:(BOOL)bAllModel
{
    uint8_t cmd[12]={0x11,0x11,0x5b,0x00,0x00,0x00,0x00,0xe6,0x11,0x02,0x10,0x06};
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:12];
}

-(void)deleteAlarm:(uint32_t )destinationAddress withMode:(BOOL)bAllModel
{
    uint8_t cmd[18]={0x11,0x11,0x5d,0x00,0x00,0x00,0x00,0xe5,0x11,0x02,0x01,0xff,0x00,0x00,0x00,0x00,0x00,0x00};
    
    if(bAllModel == NO)
    {
        cmd[5]=(destinationAddress>>8) & 0xff;
        cmd[6]=destinationAddress & 0xff;
    }
    else
    {
        cmd[5]=0xff;
        cmd[6]=0xff;
    }
    
    cmd[2] = cmd[2]+addIndex;
    if (cmd[2]==254) {
        cmd[2]=1;
    }
    addIndex++;
    
    [[BTCentralManager shareBTCentralManager] sendCommand:cmd Len:18];
}


/**
 *NewMethod
 
 
 */
- (void)sendPack:(NSData *)data {
    if (!_isConnected || !_isLogin ||
        !self.selConnectedItem ||
        !self.otaFeature ||
        (self.selConnectedItem.blDevInfo.state!=CBPeripheralStateConnected))
        return;
    
    Byte *tempBytes = (Byte *)[data bytes];
    Byte resultBytes[20];
    memset(resultBytes, 0xff, 20);      //初始化
    memcpy(resultBytes+2, tempBytes, data.length); //copy传过来的data
    memcpy(resultBytes, &otaPackIndex, 2); //设置索引
    uint16_t crc = crc16(resultBytes, (int)data.length+2);
    memcpy(resultBytes+18, &crc, 2); //设置crc校验值
    NSData *writeData = [NSData dataWithBytes:resultBytes length:data.length + 4];
    NSLog(@"otaPackIndex -> %04lx %@", (unsigned long)otaPackIndex,writeData);
    [self.selConnectedItem.blDevInfo writeValue:writeData forCharacteristic:self.otaFeature type:CBCharacteristicWriteWithoutResponse];
    otaPackIndex++;
}
extern unsigned short crc16 (unsigned char *pD, int len)
{
    static unsigned short poly[2]={0, 0xa001};              //0x8005 <==> 0xa001
    unsigned short crc = 0xffff;
    int i,j;
    for(j=len; j>0; j--)
    {
        unsigned char ds = *pD++;
        for(i=0; i<8; i++)
        {
            crc = (crc >> 1) ^ poly[(crc ^ ds ) & 1];
            ds = ds >> 1;
        }
    }
    return crc;
}

/**
 *返回灯的模型－此方法的调用必须调用BTCentralManager的代理方法并且已经扫描登录
 （state－0离线状态-1在线关灯状态-2在线开灯状态）
 */
-(void)readFeatureOfselConnectedItem{
    if (!self.isConnected) {
        return;
    }
    //读取Firmware Revision
    [self readValue:self.fireWareFeature Buffer:nil];
}

-(DeviceModel *)getFristDeviceModelWithBytes:(uint8_t *)bytes{
    DeviceModel *btItem=nil;
    if (bytes[8]==0x11 && bytes[9]==0x02){
        int com=bytes[7];
        int devAd=0;
        
        //状态220
        if (com==0xdc){
            devAd=bytes[10];
            if (devAd == 0) {
                return nil;
            }
            devAd = bytes[10];
            //根据地址得到BTDevItem
            btItem = [self getDeviceWithAddress:devAd];
            if (!btItem) {
                return nil;
            }else{
//                [self logByte:bytes Len:20 Str:@"First_Status"];
                
                if (bytes[11] == 0) {
                    btItem.stata = LightStataTypeOutline;
                    btItem.brightness = 0;
                }else{
                    btItem.brightness = bytes[12];
                    if (bytes[12] == 0) {
                        btItem.stata = LightStataTypeOff;
                    }else{
                        btItem.stata = LightStataTypeOn;
                    }
                    
                }
            }
        }
    }
    
    return  btItem;
}

-(DeviceModel *)getSecondDeviceModelWithBytes:(uint8_t *)bytes{
    DeviceModel *btItem=nil;
    if (bytes[8]==0x11 && bytes[9]==0x02){
        int com=bytes[7];
        int devAd=0;
        //状态220
        if (com==0xdc){
            devAd=bytes[14];
            if (devAd == 0) {
                return nil;
            }
//            [self logByte:bytes Len:20 Str:@"Second_Status"];
            devAd = bytes[14];
            //根据地址得到BTDevItem
            btItem = [self getDeviceWithAddress:devAd];
            if (bytes[15] == 0) {
                btItem.stata = LightStataTypeOutline;
                btItem.brightness = 0;
            }else{
                btItem.brightness = bytes[16];
                if (bytes[16] == 0) {
                    btItem.stata = LightStataTypeOff;
                }else{
                    btItem.stata = LightStataTypeOn;
                }
            }
        }
    }
    
    return  btItem;
}

-(DeviceModel *)getDeviceWithAddress:(uint32_t)address{
    if (address != 0) {
        DeviceModel *devItem = [[DeviceModel alloc]init];
        //类型转换
        uint32_t newAddress = address << 8;
        devItem.u_DevAdress = newAddress;
        devItem.orderAddress = address;
        
        return devItem;
    }else{
        return nil;
    }
}

//地址更改解析
-(uint32_t)analysisedAddressAfterSettingWithBytes:(uint8_t *)bytes{
    uint32_t result[2];
    [self logByte:bytes Len:20 Str:@"DistributeAddress"];
    result[0] = bytes[10];
    result[1] = bytes[11];
    return *result;
}

- (void)printContentWithString:(NSString *)content {
    if (!kTestLog) return;
    NSDate *date = [NSDate date];
    NSDateFormatter *fo = [[NSDateFormatter alloc] init];
    fo.dateFormat = @"HH:mm:ss";
    fo.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
    
    NSString *con = [fo stringFromDate:date];
    NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"content"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    NSMutableString *temp = [[NSMutableString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    if (!temp) {
        temp = [[NSMutableString alloc] init];
    }
    [temp appendFormat:@"%@ %@\n", con, content];
    NSString *cons = [NSString stringWithFormat:@"%@ %@\n", con, content];
    if (self.PrintBlock) {
        self.PrintBlock(cons);
    }
    NSData *dataO = [temp dataUsingEncoding:NSUTF8StringEncoding];
    [dataO writeToFile:path atomically:YES];
}

-(void)sendCustomData:(NSDictionary*)params
{
    //S,C,E
    NSString *json = nil;
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSInteger totalDataLength = [json length];
    NSInteger packetLen = 18;
    NSInteger packetNum = totalDataLength / packetLen;
    NSInteger lastPacketCharNum =  totalDataLength % packetLen;
    
    NSMutableData *mData = [[NSMutableData alloc] init];
    
    for (NSInteger i = 0; i < packetNum + 1; i++) {
        Byte byte[20];
        
        if (i == 0)
        {
            byte[0] = 'S';
            byte[1] = packetLen;
            
            for (NSInteger k = 0; k < 18; k++) {
                byte[k + 2] = [json characterAtIndex:k];
            }
            
            NSData *data =  [[NSData alloc] initWithBytes:byte length:20];
            [mData appendData:data];
        }
        else if (i == packetNum) {
            byte[0] = 'E';
            byte[1] = lastPacketCharNum;
            
            for (NSInteger k = 0; k < lastPacketCharNum; k++) {
                byte[k + 2] = [json characterAtIndex:packetNum * packetLen + k];
            }
            
            NSData *data =  [[NSData alloc] initWithBytes:byte length:lastPacketCharNum + 2];
            [mData appendData:data];
        }
        else
        {
            byte[0] = 'C';
            byte[1] = packetLen;
            
            for (NSInteger k = 0; k < 18; k++) {
                byte[k + 2] = [json characterAtIndex:i * packetLen + k];
            }
            
            NSData *data =  [[NSData alloc] initWithBytes:byte length:20];
            [mData appendData:data];
        }
    }
    
    Byte *allByte1 = (Byte *)[mData bytes];
    printf("alltestByte = %s\n",allByte1);
    
    Byte* allByte = (Byte*)mData.bytes;
    uint8_t BLELen = 20,sendLen = 0;
    NSInteger n = 1;
    while (sendLen < [mData length])
    {
        NSInteger levelLength = [mData length] - sendLen;
        NSInteger sendLength = levelLength < BLELen ? levelLength : BLELen;
        
        NSData *data = [[NSData alloc]initWithBytes:allByte + sendLen length:sendLength];
        
//        NSLog(@"第%ld包数据", (long)n);
        Byte *testByte1 = (Byte *)[data bytes];
        printf("testByte = %s\n",testByte1);
        
        [self.selConnectedItem.blDevInfo writeValue:data forCharacteristic:self.customDataFeature type:CBCharacteristicWriteWithResponse];
        sendLen += sendLength;
        n++;
        sleep(0.05);
    }
    
}

@end
