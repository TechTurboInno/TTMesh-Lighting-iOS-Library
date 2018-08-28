//
//  BaseViewController.h
//  MeshLight
//
//  Created by 朱彬 on 2018/3/22.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController

-(void)setNavigationLeftButton:(NSString*)title
                     withImage:(NSString*)imageName
           withHightlightImage:(NSString*)hightlightImageName;

-(void)setNavigationRightButton:(NSString*)title
                      withImage:(NSString*)imageName
            withHightlightImage:(NSString*)hightlightImageName;

-(void)leftButtonAction:(id)sender;
-(void)rightButtonAction:(id)sender;

@end
