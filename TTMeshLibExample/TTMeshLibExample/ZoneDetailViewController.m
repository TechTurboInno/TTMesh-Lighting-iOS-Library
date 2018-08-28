//
//  ZoneDetailViewController.m
//  MeshLight
//
//  Created by 朱彬 on 2018/5/2.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "ZoneDetailViewController.h"
#import "UIImage+Additions.h"
#import "UIColor+Additions.h"
#import "SystemConfig.h"
#import "TTDefine.h"
#import "TTMeshManager.h"

@interface ZoneDetailViewController ()
{
    __weak IBOutlet UIScrollView *scrollView;
    __weak IBOutlet UIImageView *zoneImageView;
    __weak IBOutlet UILabel *zoneLabel;
    
    __weak IBOutlet UIView *bkView1;
    __weak IBOutlet UITextField *zoneNameTextField;
    __weak IBOutlet UILabel *timeLabel;
    __weak IBOutlet UIView *bkView2;
    __weak IBOutlet UITextField *zoneTimingTextField;
    __weak IBOutlet UISlider *brightnessSilder;
    __weak IBOutlet UISlider *colorSilder;
    __weak IBOutlet UISlider *ctSilder;
    __weak IBOutlet UIView *bkView3;
    __weak IBOutlet UIView *bkView4;
    IBOutlet UIView *contentView;
    NSMutableArray *colorArray;
    
    __weak IBOutlet UIImageView *ctBkImageView;
    __weak IBOutlet UIImageView *colorBkImageView;
    
    __weak IBOutlet UIButton *saveButton;
    __weak IBOutlet UIButton *deleteButton;
    NSInteger patternIndex;
    NSString *selectTimingString;
    BOOL bChangeTiming;
    __weak IBOutlet NSLayoutConstraint *colorTopCons;
    __weak IBOutlet UILabel *temperatureLabel;
    __weak IBOutlet UILabel *colorLabel;
    __weak IBOutlet UILabel *patternLAbel;
    IBOutlet UIView *desTopCons;
    __weak IBOutlet NSLayoutConstraint *desTopConss;
    
    __weak IBOutlet NSLayoutConstraint *rightCon;
    UIButton *selectButton;
    NSMutableArray *showTimingArray;
    
    
    __weak IBOutlet UIView *fromBkView;
    __weak IBOutlet UILabel *timeFromLabel;
    IBOutlet UIView *toBkView;
    __weak IBOutlet UILabel *timeToLabel;
    
    NSString *fromTimeValue;
    NSString *toTimeValue;
    
    TTMeshManager *manager;
}

@end

@implementation ZoneDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    manager = [TTMeshManager shareManager];
    
    [self setupUI];
}

-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setupUI
{
    zoneNameTextField.text = @"Group";
    brightnessSilder.value = 50;
    ctSilder.value = 50;
    colorSilder.value = 50;
    timeLabel.backgroundColor = [UIColor clearColor];
    
    bkView1.backgroundColor = RGBAColor(255, 255, 255, 0.2);
    bkView2.backgroundColor = RGBAColor(255, 255, 255, 0.2);
    bkView4.backgroundColor = RGBAColor(255, 255, 255, 0.2);
    toBkView.backgroundColor = RGBAColor(255, 255, 255, 0.2);
    fromBkView.backgroundColor = RGBAColor(255, 255, 255, 0.2);
    bkView3.backgroundColor = [UIColor clearColor];
    
    timeFromLabel.userInteractionEnabled = YES;
    timeToLabel.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *ges = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFrom:)];
    [timeFromLabel addGestureRecognizer:ges];
    
    UITapGestureRecognizer *ges2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTo:)];
    [timeToLabel addGestureRecognizer:ges2];
    
    
    brightnessSilder.minimumTrackTintColor = RGBAColor(255, 255, 255, 0.2);
    brightnessSilder.maximumTrackTintColor = RGBAColor(255, 255, 255, 0.2);
    [brightnessSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    
    [ctSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    [ctSilder setMinimumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    [ctSilder setMaximumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    
    [colorSilder setThumbImage:[UIImage imageNamed:@"silderthumb.png"] forState:UIControlStateNormal];
    [colorSilder setMinimumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    [colorSilder setMaximumTrackImage:[UIImage imageWithColor:RGBAColor(255, 255, 255, 0.0)] forState:UIControlStateNormal];
    
    
    scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, 1000);
    CGRect frame = contentView.frame;
    frame.size.width = SCREEN_WIDTH;
    contentView.frame = frame;
    [scrollView addSubview:contentView];
    
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
    
    deleteButton.hidden = YES;
    
    if (self.info != nil) {
        
        zoneNameTextField.text = self.info[Storage_GroupName];
        fromTimeValue = self.info[Storage_GroupTimeFrom];
        toTimeValue = self.info[Storage_GroupTimeto];
        timeFromLabel.text = [self getTimingDesByMin:fromTimeValue];
        timeToLabel.text = [self getTimingDesByMin:toTimeValue];
        
        brightnessSilder.value = [self.info[Storage_GroupBrightness] integerValue];
        ctSilder.value = [self.info[Storage_GroupCT] integerValue];
        colorSilder.value = [self.info[Storage_GroupColor] integerValue];
        
        deleteButton.hidden = NO;
    }else
    {
        fromTimeValue = @"360";
        toTimeValue = @"1080";
        
        timeFromLabel.text = [self getTimingDesByMin:fromTimeValue];
        timeToLabel.text = [self getTimingDesByMin:toTimeValue];
        
        rightCon.constant = -50;
    }
}

-(void)tapFrom:(UITapGestureRecognizer*)sender
{
    UILabel *label = (UILabel*)sender.view;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    datePicker.center = CGPointMake(alert.view.frame.size.width / 2, datePicker.center.y);
    
    [alert.view addSubview:datePicker];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        BFDateInformation timeInfo = [self dateInformationOf:datePicker.date];
        NSInteger currentMinsInToday = timeInfo.hour * 60 + timeInfo.minute;
        NSString *value = [NSString stringWithFormat:@"%d", currentMinsInToday];
        
        label.text = [self getTimingDesByMin:value];
        fromTimeValue = value;
    }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(void)tapTo:(UITapGestureRecognizer*)sender
{
    UILabel *label = (UILabel*)sender.view;
    
    UIDatePicker *datePicker = [[UIDatePicker alloc] init];
    datePicker.datePickerMode = UIDatePickerModeTime;
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"\n\n\n\n\n\n\n\n\n\n\n\n" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    datePicker.center = CGPointMake(alert.view.frame.size.width / 2, datePicker.center.y);
    
    [alert.view addSubview:datePicker];
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Done" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        BFDateInformation timeInfo = [self dateInformationOf:datePicker.date];
        NSInteger currentMinsInToday = timeInfo.hour * 60 + timeInfo.minute;
        NSString *value = [NSString stringWithFormat:@"%d", currentMinsInToday];
        
        label.text = [self getTimingDesByMin:value];
        toTimeValue = value;
    }];
    
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(IBAction)saveAction:(id)sender
{
    BOOL bNew = FALSE;
    
    if (self.info == nil) {
        bNew = TRUE;
        self.info = [[NSMutableDictionary alloc] initWithCapacity:0];
        self.info[Storage_GroupID] = [[SystemConfig shareConfig] createGroupID];
    }
    
    self.info[Storage_GroupName] = zoneNameTextField.text;
    self.info[Storage_GroupTimeFrom] = fromTimeValue;
    self.info[Storage_GroupTimeto] = toTimeValue;
    self.info[Storage_GroupBrightness] = [NSString stringWithFormat:@"%ld",(long)brightnessSilder.value];
    self.info[Storage_GroupCT] = [NSString stringWithFormat:@"%ld",(long)ctSilder.value];
    self.info[Storage_GroupColor] = [NSString stringWithFormat:@"%ld",(long)colorSilder.value];
    
    self.UpdateData(self.info, bNew);
    
    if (!bNew) {
        [manager deleteGroupAllAlarmWithGroupID:[self.info[Storage_GroupID] integerValue]];
        
        sleep(0.1);
        
        [manager addGroupAlarmOnWithGroupID:[self.info[Storage_GroupID] integerValue] withCurrentMinutes:[fromTimeValue integerValue]];
        
        sleep(0.1);
        
        [manager addGroupAlarmOffWithGroupID:[self.info[Storage_GroupID] integerValue] withCurrentMinutes:[toTimeValue integerValue]];
    }
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Save Success" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(IBAction)deleteAction:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Delete This Group?" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        self.deleteData(self.info);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{ }];
    
}

-(IBAction)brightnessValueChanged:(UISlider*)sender
{
    NSInteger lum = sender.value;
    [manager setGroupLumWithGroupID:[self.info[Storage_GroupID] integerValue] WithLum:lum];
}

-(IBAction)ctValueChanged:(UISlider*)sender
{
    float coldValue = (float)((100.0f - sender.value) / 100.0f) * 255.0f;
    float warmValue = (float)(sender.value / 100.0f) * 255.0f;
    
    
    [manager setGroupColorTemperatureWithGroupID:[self.info[Storage_GroupID] integerValue] withBrightness:brightnessSilder.value withColdValue:coldValue withWarmValue:warmValue];
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
    
    [manager setGroupColorWithGroupID:[self.info[Storage_GroupID] integerValue] WithColorR:red WithColorG:green WithB:blue];
}

-(void)colorAction:(UIButton*)sender
{
    UIColor *color = colorArray[sender.tag];
    CGFloat red, green, blue;
    [color getRed:&red green:&green blue:&blue alpha:NULL];
    
    [manager setGroupColorWithGroupID:[self.info[Storage_GroupID] integerValue] WithColorR:red WithColorG:green WithB:blue];
}

-(IBAction)turnOnOrOffAction:(id)sender
{
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSString*)getTimingDesByMin:(NSString*)minitues
{
    NSInteger hour = [minitues integerValue]/ 60;
    NSInteger min = [minitues integerValue] % 60;
    
    return [NSString stringWithFormat:@"%02d:%02d", hour, min];
}

- (BFDateInformation)dateInformationOf:(NSDate*)date
{
    BFDateInformation info;
    
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comp = [gregorian components:(NSCalendarUnitMonth | NSCalendarUnitMinute | NSCalendarUnitYear | NSCalendarUnitDay | NSCalendarUnitWeekday | NSCalendarUnitHour | NSCalendarUnitSecond) fromDate:date];
    info.day = [comp day];
    info.month = [comp month];
    info.year = [comp year];
    
    info.hour = [comp hour];
    info.minute = [comp minute];
    info.second = [comp second];
    
    info.weekday = [comp weekday];
    
    return info;
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
