//
//  UIButton+Factory.m
//  QingWanKe
//
//  Created by weienjie on 16/1/21.
//  Copyright © 2016年 Oolagame. All rights reserved.
//

#import "UIButton+Factory.h"

@implementation UIButton (Factory)

//background(image)
+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                                       target:(id)target
                                       action:(SEL)selector {
    return [self buttonWithBackGroundImageName:name highlightBackGroundImageName:name target:target action:selector];
}

+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                 highlightBackGroundImageName:(NSString *)hname
                                       target:(id)target
                                       action:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:hname] forState:UIControlStateHighlighted];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//background＋title
+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                                       target:(id)target
                                       action:(SEL)selector
                                        title:(NSString *)title
                                   titleColor:(UIColor *)color
                                    titleFont:(UIFont *)font {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [[button titleLabel] setFont:font];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//background＋title
+ (instancetype)buttonWithBackGroundColor:(UIColor *)bcolor
                                   target:(id)target
                                   action:(SEL)selector
                                    title:(NSString *)title
                               titleColor:(UIColor *)color
                                titleFont:(UIFont *)font {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundColor:bcolor];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:color forState:UIControlStateNormal];
    [[button titleLabel] setFont:font];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

//image+title
+ (instancetype)buttonWithImageName:(NSString *)name
                 highlightImageName:(NSString *)hname
                             target:(id)target
                             action:(SEL)selector
                              title:(NSString *)title
                         titleColor:(UIColor *)color
                          titleFont:(UIFont *)font {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:hname] forState:UIControlStateHighlighted];
    [button setTitle:title forState:UIControlStateNormal];
    [[button titleLabel] setFont:font];
    [button setTitleColor:color forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}
@end
