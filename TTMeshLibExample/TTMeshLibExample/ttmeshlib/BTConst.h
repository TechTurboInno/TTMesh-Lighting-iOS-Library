//
//  BTConst.h
//  TelinkBlue
//
//  Created by Green on 11/14/15.
//  Copyright (c) 2015 Green. All rights reserved.
//

#ifndef TelinkBlue_BTConst_h
#define TelinkBlue_BTConst_h

#define BTDevInfo_Name @"Telink tLight"
#define BTDevInfo_UserNameDef @"telink_mesh1"
#define BTDevInfo_UserPasswordDef @"123"
#define BTDevInfo_UID  0x1102

#define BTDevInfo_ServiceUUID @"00010203-0405-0607-0809-0A0B0C0D1910"
#define BTDevInfo_FeatureUUID_Notify @"00010203-0405-0607-0809-0A0B0C0D1911"
#define BTDevInfo_FeatureUUID_Command @"00010203-0405-0607-0809-0A0B0C0D1912"
#define BTDevInfo_FeatureUUID_Pair @"00010203-0405-0607-0809-0A0B0C0D1914"
#define BTDevInfo_FeatureUUID_OTA  @"00010203-0405-0607-0809-0A0B0C0D1913"
#define Service_Device_Information @"0000180a-0000-1000-8000-00805f9b34fb"
#define Service_CustomData @"19200D0C-0B0A-0908-0706-050403020100"
#define Characteristic_CustomData @"19210D0C-0B0A-0908-0706-050403020100"
#define Characteristic_Firmware @"00002a26-0000-1000-8000-00805f9b34fb"
//#define Characteristic_Manufacturer @"00002a29-0000-1000-8000-00805f9b34fb"
//#define Characteristic_Model @"00002a24-0000-1000-8000-00805f9b34fb"
//#define Characteristic_Hardware @"00002a27-0000-1000-8000-00805f9b34fb"

#define CheckStr(A) (!A || A.length<1)

#define kEndTimer(timer) \
if (timer) { \
[timer invalidate]; \
timer = nil; \
}
//!<命令延时参数
//#define kDuration (500)
#endif
