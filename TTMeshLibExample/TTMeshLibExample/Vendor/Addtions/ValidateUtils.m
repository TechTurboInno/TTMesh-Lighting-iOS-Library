//
//  ValidateUtils.m
//  TomatoLive
//
//  Created by amiee on 15/9/8.
//  Copyright (c) 2015年 Amiee Robot. All rights reserved.
//

#import "ValidateUtils.h"

static NSString * const kPhoneNumberRegex = @"^(1[3-8])\\d{9}$";
static NSString * const kPasswordRegex = @"^[A-Za-z0-9\\@\\!\\#\\$\\%\\^\\&\\*\\.\\~]{6,24}$";
static NSString * const kVerifyCodeRegex = @"^\\d{4}$";
static NSString * const kEmailRegex = @"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}$";
static NSString * const kChineseNameRegex = @"^[\u4E00-\u9FA5]{2,5}(?:·[\u4E00-\u9FA5]{2,5})*$";
static NSString * const kWithdrawPasswordRegex = @"^\\d{6}$";

@implementation ValidateUtils

+ (ValidateType)validatePhoneNumber:(NSString *)phoneNumber {
    if (phoneNumber.length == 0) {
        return ValidateTypeInvalidBlank;
    } else if (![self validateString:phoneNumber regex:kPhoneNumberRegex]) {
        return ValidateTypeInvalidFormat;
    } else {
        return ValidateTypeValid;
    }
}

+ (ValidateType)validatePassword:(NSString *)password {
    if (password.length == 0) {
        return ValidateTypeInvalidBlank;
    } else if (![self validateString:password regex:kPasswordRegex]) {
        return ValidateTypeInvalidFormat;
    } else {
        return ValidateTypeValid;
    }
}

+ (ValidateType)validateVerifyCode:(NSString *)code {
    if (code.length == 0) {
        return ValidateTypeInvalidBlank;
    } else if (![self validateString:code regex:kVerifyCodeRegex]) {
        return ValidateTypeInvalidFormat;
    } else {
        return ValidateTypeValid;
    }
}

+ (ValidateType)validateEmail:(NSString *)email {
    if (email.length == 0) {
        return ValidateTypeInvalidBlank;
    }else if (![self validateString:email regex:kEmailRegex]){
        return ValidateTypeInvalidFormat;
    }else{
        return ValidateTypeValid;
    }
}

+ (ValidateType)validateChineseName:(NSString *)name {
    if (name.length == 0) {
        return ValidateTypeInvalidBlank;
    } else if (![self validateString:name regex:kChineseNameRegex]) {
        return ValidateTypeInvalidFormat;
    } else {
        return ValidateTypeValid;
    }
}

+ (ValidateType)validateWithdrawPassword:(NSString *)password {
    if (password.length == 0) {
        return ValidateTypeInvalidBlank;
    } else if (![self validateString:password regex:kWithdrawPasswordRegex]) {
        return ValidateTypeInvalidFormat;
    } else {
        return ValidateTypeValid;
    }
}

#pragma mark - Private Methods

+ (BOOL)validateString:(NSString *)string regex:(NSString *)regex {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:string];
}

@end
