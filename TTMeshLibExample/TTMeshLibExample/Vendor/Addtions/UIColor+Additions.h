//
//  UIColor+Additions.h
//  YouShiKe
//
//  Created by amiee on 15/7/6.
//  Copyright (c) 2015年 Oolagame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (Additions)

+ (instancetype)colorWithHexString:(NSString *)hexString;
+ (NSString *)hexValuesFromUIColor:(UIColor *)color;

@end
