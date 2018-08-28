//
//  UILabel+Factory.m
//  QingWanKe
//
//  Created by weienjie on 16/1/15.
//  Copyright © 2016年 Oolagame. All rights reserved.
//

#import "UILabel+Factory.h"

@implementation UILabel (Factory)

+ (instancetype)labelWithFont:(UIFont *)font {
    return [self labelWithFont:font textColor:[UIColor blackColor]];
}

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor {
    return [self labelWithFont:font textColor:txtColor textAlignment:NSTextAlignmentLeft];
}

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor textAlignment:(NSTextAlignment)alignment {
    return [self labelWithFont:font textColor:txtColor textAlignment:alignment text:nil];
}

+ (instancetype)labelWithFont:(UIFont *)font textColor:(UIColor *)txtColor textAlignment:(NSTextAlignment)alignment text:(NSString *)text {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = txtColor;
    label.textAlignment = alignment;
    label.text = text;
    return label;
}

@end
