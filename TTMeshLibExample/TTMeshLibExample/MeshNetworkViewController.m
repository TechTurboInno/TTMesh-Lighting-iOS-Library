//
//  MeshNetworkViewController.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/13.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "MeshNetworkViewController.h"
#import "SystemConfig.h"
#import "MeshInfoTableViewCell.h"

@interface MeshNetworkViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *dataSource;
    
}
@end

@implementation MeshNetworkViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    dataSource = [[SystemConfig shareConfig] readMeshInfo];
    
    // Do any additional setup after loading the view from its nib.
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView registerNib:[UINib nibWithNibName:@"MeshInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [[SystemConfig shareConfig] saveMeshInfo:dataSource];
}

-(IBAction)backAction:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)addAction:(id)sender
{
    NSMutableDictionary *newInfo = [[NSMutableDictionary alloc] init];
    [newInfo setObject:@"" forKey:Storage_MeshName];
    [newInfo setObject:@"" forKey:Storage_MeshPassword];
    
    [dataSource addObject:newInfo];
    
    [tableView reloadData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataSource.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MeshInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    NSMutableDictionary *info = dataSource[indexPath.row];
    
    [cell setData:info];
    [cell setDeleteBlock:^(BOOL bResult) {
        [self deleteMeshInfo:info];
    }];
    
    [cell setSelectedBlock:^(BOOL bResult) {
        self.reScanBlock(info);
        [self.navigationController popViewControllerAnimated:YES];
    }];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160.0f;
}

-(void)deleteMeshInfo:(NSMutableDictionary*)info {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:@"Delete This Mesh Info" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *deleteAction = [UIAlertAction actionWithTitle:@"Delete" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [dataSource removeObject:info];
        [tableView reloadData];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    }];
    
    [alert addAction:deleteAction];
    [alert addAction:cancelAction];
    
    [self presentViewController:alert animated:YES completion:^{ }];
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
