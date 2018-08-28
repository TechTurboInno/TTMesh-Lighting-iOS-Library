//
//  SelectGroupViewController.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/14.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "SelectGroupViewController.h"
#import "TTMeshManager.h"
#import "TTDefine.h"
#import "LightCollectionViewCell.h"
#import "SystemConfig.h"

#define CellIdentifier @"collectionCell"
#define CellWidthSpace   10
#define CellWidth       (SCREEN_WIDTH - 4 * CellWidthSpace - 3)/3
#define CellLineSpace   10

@interface SelectGroupViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
{
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UILabel *titleLAbel;
    
    TTMeshManager *manager;
}

@end

@implementation SelectGroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    manager = [TTMeshManager shareManager];
    
    [self setupUI];
}

-(void)setupUI{
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;//数据不够也可以垂直滑动
    [collectionView registerNib:[UINib nibWithNibName:@"LightCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 1);  //设置headerView大小
    [collectionView setCollectionViewLayout:flowLayout];
    
    collectionView.backgroundColor = [UIColor clearColor];
}

#pragma mark UICollectionView delegate
- (CGSize)collectionView:(UICollectionView *)collectionView  layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake(CellWidth, CellWidth);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(CellLineSpace, CellWidthSpace, CellLineSpace, CellWidthSpace);
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [SystemConfig shareConfig].collectionSource.count;
}

//设置Cell
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    LightCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
    
    DeviceModel *model = [SystemConfig shareConfig].collectionSource[indexPath.item];
    [cell setData:model];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

    DeviceModel *model = [SystemConfig shareConfig].collectionSource[indexPath.item];
    
    BFDateInformation timeInfo = [self dateInformationOf:[NSDate date]];
    
    [manager setCurrentTimeWithAddress:model.u_DevAdress withYear:timeInfo.year withMonth:timeInfo.month withDay:timeInfo.day withHour:timeInfo.hour withMinute:timeInfo.minute withSecond:timeInfo.second];
    
    // wait for some time
    sleep(0.1);
    
    NSInteger groupID = [self.info[Storage_GroupID] integerValue];
    
    // you can clear the groupinfo of the light first or not, and then set new group
    [manager deleteLightGroupWithAddress:model.u_DevAdress];
    
    // wait for some time
    sleep(0.1);
    
    [manager setLightGroupWithAddress:model.u_DevAdress withGroupID:groupID];
}

-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)doneAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
