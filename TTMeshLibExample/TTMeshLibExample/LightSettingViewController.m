//
//  LightSettingViewController.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/14.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "LightSettingViewController.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "TTDefine.h"
#import "TTMeshManager.h"

@interface LightSettingViewController ()
{
    __weak IBOutlet UISlider *brightnessSilder;
    __weak IBOutlet UISlider *colorSilder;
    __weak IBOutlet UISlider *ctSilder;
    __weak IBOutlet UIView *bkView3;
    NSMutableArray *colorArray;
    TTMeshManager *manager;
    __weak IBOutlet UIImageView *colorBkImageView;
    __weak IBOutlet UIButton *kickoutButton;
}

@end

@implementation LightSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    manager = [TTMeshManager shareManager];
    
    [self setupUI];
}

-(void)setupUI
{
    brightnessSilder.value = 50;
    ctSilder.value = 50;
    colorSilder.value = 50;
    
    brightnessSilder.minimumTrackTintColor = RGBAColor(255, 255, 255, 0.2);
    brightnessSilder.maximumTrackTintColor = RGBAColor(255, 255, 255, 0.2);
    [brightnessSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    
    [ctSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    [ctSilder setMinimumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    [ctSilder setMaximumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    
    [colorSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    [colorSilder setMinimumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    [colorSilder setMaximumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    
    NSInteger width = 40;
    NSInteger totalWidth = bkView3.frame.size.width;
    NSInteger offset = (totalWidth - 5 * width) / 4;
    
    colorArray = [NSMutableArray arrayWithCapacity:0];
    [colorArray addObject:[UIColor colorWithHexString:@"d0021b"]];
    [colorArray addObject:[UIColor colorWithHexString:@"f5a623"]];
    [colorArray addObject:[UIColor colorWithHexString:@"f8e71c"]];
    [colorArray addObject:[UIColor colorWithHexString:@"8b572a"]];
    [colorArray addObject:[UIColor colorWithHexString:@"7ed321"]];
    [colorArray addObject:[UIColor colorWithHexString:@"417505"]];
    [colorArray addObject:[UIColor colorWithHexString:@"bd10e0"]];
    [colorArray addObject:[UIColor colorWithHexString:@"9013fe"]];
    [colorArray addObject:[UIColor colorWithHexString:@"4a90e2"]];
    [colorArray addObject:[UIColor colorWithHexString:@"ffffff"]];
    
    for (int i = 0; i < [colorArray count]; i++) {
        NSInteger column = i % 5;
        NSInteger row = i / 5;
        
        UIImage *image = [UIImage stretchableImageWithColor:colorArray[i] borderColor:[UIColor whiteColor] borderWidth:0 cornerRadius:width];
        UIImage *selectImage = [UIImage stretchableImageWithColor:colorArray[i] borderColor:[UIColor blueColor] borderWidth:5 cornerRadius:width];
        
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(column * (width + offset), row * (width + 10), width, width)];
        button.tag = i;
        [button setImage:image forState:UIControlStateNormal];
        [button setImage:selectImage forState:UIControlStateSelected];
        [button addTarget:self action:@selector(colorAction:) forControlEvents:UIControlEventTouchUpInside];
        
        [bkView3 addSubview:button];
    }
    
    if (self.selData == nil) {
        kickoutButton.hidden = YES;
    }
}

-(IBAction)brightnessValueChanged:(UISlider*)sender
{
    [manager setLightLumWithAddress:[self getDestAddress] WithLum:sender.value];
}

-(IBAction)ctValueChanged:(UISlider*)sender
{
    float coldValue = (float)((100.0f - sender.value) / 100.0f) * 255.0f;
    float warmValue = (float)(sender.value / 100.0f) * 255.0f;
    
    [manager setLightColorTemperatureWithAddress:[self getDestAddress] withBrightness:brightnessSilder.value withColdValue:coldValue withWarmValue:warmValue];
}

-(IBAction)colorValueChanged:(UISlider*)sender
{
    CGFloat x = sender.value / 100 * sender.frame.size.width;
    
    if (x >= colorBkImageView.frame.size.width) {
        x = colorBkImageView.frame.size.width - 1;
    }
    
    CGPoint point = CGPointMake(x, 0);
    
    CGFloat red, green, blue;
    UIColor *color = [self colorOfPoint:point withView:colorBkImageView];
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    [manager setLightColorWithAddress:[self getDestAddress] WithColorR:red WithColorG:green WithB:blue];
    
}

-(void)colorAction:(UIButton*)sender
{
    UIColor *color = colorArray[sender.tag];
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    [manager setLightColorWithAddress:[self getDestAddress] WithColorR:red WithColorG:green WithB:blue];
}

-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)kickOutAction:(id)sender
{
    if (self.selData != nil) {
        [manager kickOutWithAddress:self.selData.u_DevAdress];
    }
}

-(uint32_t)getDestAddress{
    if (self.selData != nil) {
        return self.selData.u_DevAdress;
    }
    
    return [[TTMeshManager shareManager] getAllMeshNodeAddress];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIColor *)colorOfPoint:(CGPoint)point withView:(UIView*)view{
    unsigned char pixel[4] = {0};
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pixel, 1, 1, 8, 4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGContextTranslateCTM(context, -point.x, -point.y);
    
    [view.layer renderInContext:context];
    
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    UIColor *color = [UIColor colorWithRed:pixel[0]/255.0 green:pixel[1]/255.0 blue:pixel[2]/255.0 alpha:pixel[3]/255.0];
    
    return color;
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
