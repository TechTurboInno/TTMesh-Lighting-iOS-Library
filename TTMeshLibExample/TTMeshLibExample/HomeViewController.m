//
//  ViewController.m
//  MeshLight
//
//  Created by 朱彬 on 2018/3/22.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "HomeViewController.h"
#import "TTMeshManager.h"
#import "LightCollectionViewCell.h"
#import "MeshNetworkViewController.h"
#import "LightSettingViewController.h"
#import "SystemConfig.h"
#import "MBProgressHUD.h"

#define CellIdentifier @"collectionCell"
#define CellWidthSpace   10
#define CellWidth       (SCREEN_WIDTH - 4 * CellWidthSpace - 3)/3
#define CellLineSpace   10
#define Login_Time_Out 10                   //登录超时
#define SetMesh_Time_Out 20                 //加灯超时
#define Finished_Time_Out 24
#define ReplaceAddr_Time_Out  5            //分配地址
#define SCREEN_HEIGHT [[UIScreen mainScreen] bounds].size.height
#define SCREEN_WIDTH [[UIScreen mainScreen] bounds].size.width

@interface HomeViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,TTMeshManagerDelegate>
{
    TTMeshManager *manager;
    MBProgressHUD *hud;
    BOOL isAddDevice;
    BOOL isSetMesh;
    BTDevItem *settingItem;
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UIButton *titleButton;
    
}

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    manager = [TTMeshManager shareManager];
    [manager setScanTimeout:7];
    manager.delegate = self;
    
    [self setupUI];
    
    NSDictionary *meshInfo = [[SystemConfig shareConfig] readCurrentMeshInfo];
    
    [self startScan:meshInfo[Storage_MeshName] withPassword:meshInfo[Storage_MeshPassword]];
}

-(void)startScan:(NSString*)name withPassword:(NSString*)password{
    [self showHub];
    isAddDevice = FALSE;
    [[SystemConfig shareConfig].collectionSource removeAllObjects];
    [collectionView reloadData];
    
    [titleButton setTitle:name forState:UIControlStateNormal];
    [manager startScanWithName:name Pwd:password];
}

-(void)addLightWithOldname:(NSString*)oldName withPassword:(NSString*)oldPassword
{
    [self showHub];
    isAddDevice = TRUE;
    isSetMesh = NO;
    [manager startScanWithName:oldName Pwd:oldPassword];
}

-(void)OnCenterStatusChange:(CBCentralManager *)centralManager
{
    if (centralManager.state != CBCentralManagerStatePoweredOn) {
        [self removeHub];
        [self showAlert:@"The bluetooth is off"];
    }

}

-(void)loginTimeout{
    
    if (!isAddDevice) {
        [self removeHub];
        
        [self showAlert:@"Scan timeout"];
    }
    
}

-(void)setupUI{
    collectionView.delegate = self;
    collectionView.dataSource = self;
    collectionView.alwaysBounceVertical = YES;
    [collectionView registerNib:[UINib nibWithNibName:@"LightCollectionViewCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.headerReferenceSize = CGSizeMake(SCREEN_WIDTH, 1);
    [collectionView setCollectionViewLayout:flowLayout];
    
    collectionView.backgroundColor = [UIColor clearColor];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                               initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [collectionView addGestureRecognizer:longPress];
}

-(IBAction)titleAction:(id)sender
{
    NSMutableArray *meshInfoArray = [[SystemConfig shareConfig] readMeshInfo];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"select mesh" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSDictionary *info in meshInfoArray) {
        UIAlertAction *action = [UIAlertAction actionWithTitle:info[Storage_MeshName] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            
            [[SystemConfig shareConfig] saveCurrentMeshInfo:info];
            [self startScan:info[Storage_MeshName] withPassword:info[Storage_MeshPassword]];
            
        }];
        
        [alert addAction:action];
    }
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        
    }];
    
    [alert addAction:cancel];
    
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(IBAction)addAction:(id)sender
{
    NSDictionary *oldMeshInfo = [[SystemConfig shareConfig] readOldMeshInfo];
    
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:nil
                                                                   message:@"Fill the old mesh info"
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault
                                                     handler:^(UIAlertAction * action) {
                                                         //响应事件
                                                         //得到文本信息
                                                         for(UITextField *text in alert.textFields){
                                                             NSLog(@"text = %@", text.text);
                                                         }
                                                         
                                                         NSDictionary *info = @{
                                                                                Storage_MeshName : alert.textFields[0].text,
                                                                                Storage_MeshPassword : alert.textFields[1].text
                                                                                };
                                                         [[SystemConfig shareConfig] saveOldMeshInfo:info];
                                                         
                                                         [self addLightWithOldname:alert.textFields[0].text withPassword:alert.textFields[1].text];
                                                        
                                                     }];
    UIAlertAction* cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel
                                                         handler:^(UIAlertAction * action) {
                                                             //响应事件
                                                            
                                                         }];
    
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"mesh name";
        
        if (oldMeshInfo != nil) {
            textField.text = oldMeshInfo[Storage_MeshName];
        }
    }];
    [alert addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"mesh password";
        
        if (oldMeshInfo != nil) {
            textField.text = oldMeshInfo[Storage_MeshPassword];
        }
    }];
    
    [alert addAction:okAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(IBAction)setNetworkAction:(id)sender
{
    MeshNetworkViewController *vc = [[MeshNetworkViewController alloc] initWithNibName:@"MeshNetworkViewController" bundle:nil];
    
    [vc setReScanBlock:^(NSMutableDictionary *meshInfo) {
        [[SystemConfig shareConfig] saveCurrentMeshInfo:meshInfo];
        [self startScan:meshInfo[Storage_MeshName] withPassword:meshInfo[Storage_MeshPassword]];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)turnOnAllDevicesAction:(id)sender
{
    [manager turnOnLightWithAddress:[manager getAllMeshNodeAddress]];
}

-(IBAction)turnOffAllDevicesAction:(id)sender
{
    [manager turnOffLightWithAddress:[manager getAllMeshNodeAddress]];
}

-(IBAction)allColorsAction:(id)sender
{
    LightSettingViewController *vc = [[LightSettingViewController alloc] initWithNibName:@"LightSettingViewController" bundle:nil];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)longPressGestureRecognized:(UILongPressGestureRecognizer *)longPress {
    if (!manager.isLogin) return;
    
    if (longPress.state==UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [collectionView indexPathForItemAtPoint:[longPress locationInView:collectionView]];
        if (![SystemConfig shareConfig].collectionSource||!indexPath)  return;
        
        LightSettingViewController *vc = [[LightSettingViewController alloc] initWithNibName:@"LightSettingViewController" bundle:nil];
        vc.selData = [[SystemConfig shareConfig].collectionSource objectAtIndex:indexPath.item];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark UICollectionView delegate
//设置每个Cell 的宽高
- (CGSize)collectionView:(UICollectionView *)collectionView  layout:(nonnull UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(nonnull NSIndexPath *)indexPath
{
    return CGSizeMake(CellWidth, CellWidth);
}

//设置Cell 之间的间距 （上，左，下，右）
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
    //得到灯现在的状态
    DeviceModel *pathModel = [SystemConfig shareConfig].collectionSource[indexPath.row];
    switch (pathModel.stata) {
        case LightStataTypeOutline: return; break;
        case LightStataTypeOff:
            [manager turnOnLightWithAddress:pathModel.u_DevAdress];
            break;
        case LightStataTypeOn:
            [manager turnOffLightWithAddress:pathModel.u_DevAdress];
            break;
        default: break;
    }
}

-(void)notifyBackWithDevice:(DeviceModel *)model {
    if (!model || isAddDevice) return;
    
    [self removeHub];
    
    NSLog(@"orderAddress ******************* %d",model.orderAddress);
    NSMutableArray *macs = [[NSMutableArray alloc] init];
    
    for (int i=0; i < [SystemConfig shareConfig].collectionSource.count; i++) {
        [macs addObject:@([SystemConfig shareConfig].collectionSource[i].u_DevAdress)];
    }
    //更新既有设备状态
    if ([macs containsObject:@(model.u_DevAdress)]) {
        NSUInteger index = [macs indexOfObject:@(model.u_DevAdress)];
        DeviceModel *tempModel =[[SystemConfig shareConfig].collectionSource objectAtIndex:index];
        [tempModel updataLightStata:model];
        [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
    }
    //添加新设备
    else{
        DeviceModel *omodel = [[DeviceModel alloc] initWithModel:model];
        [[SystemConfig shareConfig].collectionSource addObject:omodel];
        [collectionView reloadData];
    }
}

-(void)showAlert:(NSString*)msg{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:msg preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    [alert addAction:okAction];
    
    [self presentViewController:alert animated:YES completion:^{ }];
}

-(void)OnDevChange:(id)sender Item:(BTDevItem *)item Flag:(DevChangeFlag)flag{
        
    if (flag == DevChangeFlag_Login && isAddDevice && isSetMesh == NO) {
        NSString *meshID = [[SystemConfig shareConfig] createMeshID];
        
        if ([meshID integerValue] >= 255) {
            NSLog(@"-Click_Address overflow-");
            return;
        }
        
        NSLog(@"net id --- %d", [meshID integerValue]);
        [manager replaceDeviceAddress:[manager connectedItem].u_DevAdress newOrderAddress:[meshID integerValue]];
        
        settingItem = item;
    }
}

-(void)resultOfReplaceAddress:(uint32_t )resultAddress{
    
    NSLog(@"resultOfReplaceAddress success");
    
    NSString *result = [NSString stringWithFormat:@"%u",resultAddress];
    NSString *meshID = [[SystemConfig shareConfig] createMeshID];
    
    //设置成功的时候
    if ([result isEqualToString:meshID]){
        [manager stopScan];
        isSetMesh = YES;
        
        NSDictionary *oldMeshInfo = [[SystemConfig shareConfig] readOldMeshInfo];
        NSDictionary *newMeshInfo = [[SystemConfig shareConfig] readCurrentMeshInfo];
        
        [manager setOldMeshInfoToNewMeshInfo:oldMeshInfo[Storage_MeshName] withOldPassword:oldMeshInfo[Storage_MeshPassword] withNewMeshInfo:newMeshInfo[Storage_MeshName] withNewMeshPassword:newMeshInfo[Storage_MeshPassword] withItem:settingItem];
        
//        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//            [self removeHub];
//
//            NSDictionary *currentMeshInfo = [[SystemConfig shareConfig] readCurrentMeshInfo];
//
//            [self startScan:currentMeshInfo[Storage_MeshName] withPassword:currentMeshInfo[Storage_MeshPassword]];
//        });
        
    }else{
        
    }
    
}

-(void)OnDevOperaStatusChange:(id)sender Status:(OperaStatus)status{
    
    if (status == DevOperaStatus_SetNetwork_Finish && isAddDevice) {
        isSetMesh = NO;
        NSLog(@"DevOperaStatus_SetNetwork_Finish success");

        [manager stopConnected];
        [manager stopScan];

        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeHub];

            NSDictionary *currentMeshInfo = [[SystemConfig shareConfig] readCurrentMeshInfo];

            [self startScan:currentMeshInfo[Storage_MeshName] withPassword:currentMeshInfo[Storage_MeshPassword]];
        });
    }
    
}

-(void)showHub
{
    if (hud == nil) {
        hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    }
}

-(void)removeHub
{
    if (hud != nil) {
        [hud removeFromSuperview];
        hud = nil;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
