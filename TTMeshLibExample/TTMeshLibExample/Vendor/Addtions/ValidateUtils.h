//
//  ValidateUtils.h
//  TomatoLive
//
//  Created by amiee on 15/9/8.
//  Copyright (c) 2015年 Amiee Robot. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, ValidateType) {
    ValidateTypeValid,
    ValidateTypeInvalidBlank,
    ValidateTypeInvalidTooShort,
    ValidateTypeInvalidTooLong,
    ValidateTypeInvalidFormat,
};

@interface ValidateUtils : NSObject

+ (ValidateType)validatePhoneNumber:(NSString *)phoneNumber;
+ (ValidateType)validatePassword:(NSString *)password;
+ (ValidateType)validateVerifyCode:(NSString *)code;
+ (ValidateType)validateEmail:(NSString *)email;
+ (ValidateType)validateChineseName:(NSString *)name;
+ (ValidateType)validateWithdrawPassword:(NSString *)password;

@end
