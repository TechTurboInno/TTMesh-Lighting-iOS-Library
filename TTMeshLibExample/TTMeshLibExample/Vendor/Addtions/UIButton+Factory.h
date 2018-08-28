//
//  UIButton+Factory.h
//  QingWanKe
//
//  Created by weienjie on 16/1/21.
//  Copyright © 2016年 Oolagame. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIButton (Factory)

//background(image)
+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                                       target:(id)target
                                       action:(SEL)selector;

+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                 highlightBackGroundImageName:(NSString *)hname
                                       target:(id)target
                                       action:(SEL)selector;

//background＋title
+ (instancetype)buttonWithBackGroundImageName:(NSString *)name
                                       target:(id)target
                                       action:(SEL)selector
                                        title:(NSString *)title
                                   titleColor:(UIColor *)color
                                    titleFont:(UIFont *)font;

//background＋title
+ (instancetype)buttonWithBackGroundColor:(UIColor *)bcolor
                                   target:(id)target
                                   action:(SEL)selector
                                    title:(NSString *)title
                               titleColor:(UIColor *)color
                                titleFont:(UIFont *)font;

//image+title
+ (instancetype)buttonWithImageName:(NSString *)name
                 highlightImageName:(NSString *)hname
                             target:(id)target
                             action:(SEL)selector
                              title:(NSString *)title
                         titleColor:(UIColor *)color
                          titleFont:(UIFont *)font;
@end
