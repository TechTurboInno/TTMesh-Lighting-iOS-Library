//
//  UILabel+Factory.h
//  QingWanKe
//
//  Created by weienjie on 16/1/15.
//  Copyright © 2016年 Oolagame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (Factory)

+ (instancetype)labelWithFont:(UIFont *)font;

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor;

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor textAlignment:(NSTextAlignment)alignment;

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor textAlignment:(NSTextAlignment)alignment text:(NSString *)text;

@end
