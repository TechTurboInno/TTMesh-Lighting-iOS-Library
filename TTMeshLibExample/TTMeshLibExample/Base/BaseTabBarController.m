//
//  BaseTabBarController.m
//  MeshLight
//
//  Created by 朱彬 on 2018/4/28.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "BaseTabBarController.h"
#import "BaseNavigationController.h"
#import "HomeViewController.h"
#import "GroupViewController.h"

@interface BaseTabBarController ()

@end

@implementation BaseTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [[UITabBar appearance] setBarTintColor:[UIColor blackColor]];
    
    [self setViewControllers];
}

- (void)viewWillLayoutSubviews{
    CGRect tabFrame = self.tabBar.frame;
    tabFrame.size.height = 60;
    tabFrame.origin.y = self.view.frame.size.height - 60;
    self.tabBar.frame = tabFrame;
}

- (void)setViewControllers
{
    HomeViewController *homeVC = [[HomeViewController alloc] initWithNibName:@"HomeViewController" bundle:nil];
    [self setupChildVc:homeVC title:@"" image:@"system.png" selectedImage:@"system-hover.png"];
    
    GroupViewController *zoneVC = [[GroupViewController alloc] initWithNibName:@"GroupViewController" bundle:nil];
    [self setupChildVc:zoneVC title:@"" image:@"zones.png" selectedImage:@"zone-hover.png"];
    
}

- (void)setupChildVc:(UIViewController *)vc title:(NSString *)title image:(NSString *)image selectedImage:(NSString *)selectedImage
{
    // 设置文字和图片
//    vc.navigationItem.title = title;
//    vc.tabBarItem.title = title;
    vc.tabBarItem.image = [self imageOriginalWithImageName:image];
    vc.tabBarItem.selectedImage = [self imageOriginalWithImageName:selectedImage];
    
    [self setTabbarAppernce:vc title:title];
    
    BaseNavigationController *nav = [[BaseNavigationController alloc] initWithRootViewController:vc];
    nav.navigationBar.hidden = YES;
    NSMutableArray *array = [NSMutableArray arrayWithArray:self.viewControllers];
    [array addObject:nav];
    [self setViewControllers:array];
}

-(void)setTabbarAppernce:(UIViewController *)vc title:(NSString *)title
{
    vc.tabBarItem.imageInsets = UIEdgeInsetsMake(6, 0, -6, 0);
}

- (UIImage *)imageOriginalWithImageName:(NSString *)imageName {
    UIImage *image = [UIImage imageNamed:imageName];
    return [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
