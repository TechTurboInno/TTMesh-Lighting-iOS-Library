//
//  UIViewController+Animation.h
//  Mirrorer
//
//  Created by wej on 2017/3/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Animation)

- (void)goBack:(BOOL)isAnimation;

- (void)basePushViewController:(UIViewController*)nextVC animated:(BOOL)animated;

@end
