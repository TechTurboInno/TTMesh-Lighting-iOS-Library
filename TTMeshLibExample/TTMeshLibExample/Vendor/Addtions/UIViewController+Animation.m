//
//  UIViewController+Animation.m
//  Mirrorer
//
//  Created by wej on 2017/3/8.
//  Copyright © 2017年 mac. All rights reserved.
//

#import "UIViewController+Animation.h"
#import "AppDelegate.h"

@implementation UIViewController (Animation)

- (void)goBack:(BOOL)isAnimation
{
    if (isAnimation) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.type = kCATransitionPush;
        transition.subtype  = kCATransitionFromBottom;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController popViewControllerAnimated:NO];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)basePushViewController:(UIViewController*)nextVC animated:(BOOL)animated
{
    if (animated) {
        CATransition *transition = [CATransition animation];
        transition.duration = 0.25;
        transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        transition.type = kCATransitionPush;
        transition.subtype = kCATransitionFromTop;
        [self.navigationController.view.layer addAnimation:transition forKey:nil];
        [self.navigationController pushViewController:nextVC animated:NO];
    }else{
        [self.navigationController pushViewController:nextVC animated:YES];
    }
    
}

@end
