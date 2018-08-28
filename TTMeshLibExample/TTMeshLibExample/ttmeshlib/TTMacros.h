//
//  TTMacros.h
//  ttmeshlib
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#ifndef TTMacros_h
#define TTMacros_h


typedef enum {
    BTCommandCaiYang,
    BTCommandInterval
} BTCommand;

typedef enum {
    DevChangeFlag_Add=1,
    DevChangeFlag_Remove,//暂时不会用到
    DevChangeFlag_Connected,
    DevChangeFlag_DisConnected,
    DevChangeFlag_ConnecteFail,
    DevChangeFlag_Login
}DevChangeFlag;

typedef enum {
    DevOperaType_Normal=1,
    DevOperaType_Login,
    DevOperaType_Set,
    DevOperaType_Com,
    DevOperaType_AutoLogin
}DevOperaType;


typedef enum {
    DevOperaStatus_Normal=1,
    DevOperaStatus_ScanSrv_Finish,//完成扫描服务uuid
    DevOperaStatus_ScanChar_Finish,//完成扫描特征
    DevOperaStatus_Login_Start,
    DevOperaStatus_Login_Finish,
    DevOperaStatus_SetName_Start,
    DevOperaStatus_SetPassword_Start,
    DevOperaStatus_SetLtk_Start,
    DevOperaStatus_SetNetwork_Finish,
    DevOperaStatus_FireWareVersion
    //添加部分
}OperaStatus;

typedef enum {
    DisconectType_Normal = 1,
    DisconectType_SequrenceSetting,
}DisconectType;

typedef NS_ENUM(NSUInteger, TimeoutType) {
    TimeoutTypeScanDevice = 1<<0,
    TimeoutTypeConnectting = 1<<1,
    TimeoutTypeScanServices = 1<<2,
    TimeoutTypeScanCharacteritics = 1<<3,
    TimeoutTypeWritePairFeatureBack = 1<<4,
    TimeoutTypeReadPairFeatureBack = 1<<5,
    TimeoutTypeReadPairFeatureBackFailLogin = 1<<6
};

typedef NS_ENUM(NSUInteger, BTStateCode) {
    BTStateCode_Normal = 0,//不会上报
    BTStateCode_Scan = 1,
    BTStateCode_Connect = 2,
    BTStateCode_Login = 3
};

typedef NS_ENUM(NSUInteger, BTErrorCode) {
    BTErrorCode_UnKnow = 0,//不会上报
    BTErrorCode_NO_ADV = 101,
    BTErrorCode_BLE_Disable,
    BTErrorCode_NO_Device_Scaned,//can receive adv
    
    BTErrorCode_Cannot_CreatConnectRelation = 201,
    BTErrorCode_Cannot_ReceiveATTList,
    
    BTErrorCode_WriteLogin_NOResponse = 301,
    BTErrorCode_ReadLogin_NOResponse,
    BTErrorCode_ValueCheck_LoginFail
};

#define ScanTimeout (7.0)

#endif /* TTMacros_h */
