//
//  GroupViewController.m
//  TTMeshLibExample
//
//  Created by 朱彬 on 2018/8/14.
//  Copyright © 2018年 朱彬. All rights reserved.
//

#import "GroupViewController.h"
#import "GroupInfoTableViewCell.h"
#import "SystemConfig.h"
#import "ZoneDetailViewController.h"
#import "SelectGroupViewController.h"

@interface GroupViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *dataSource;
    
}

@end

@implementation GroupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    dataSource = [[SystemConfig shareConfig] readGroupInfo];
    
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.backgroundView = nil;
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [tableView registerNib:[UINib nibWithNibName:@"GroupInfoTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    
}

-(IBAction)addAction:(id)sender
{
    // Do any additional setup after loading the view from its nib.
    ZoneDetailViewController *vc = [[ZoneDetailViewController alloc] initWithNibName:@"ZoneDetailViewController" bundle:nil];
    [vc setUpdateData:^(NSMutableDictionary *info, BOOL bNewInfo) {
        if (!bNewInfo) {
            [tableView reloadData];
        }
        else
        {
            [dataSource addObject:info];
            [tableView reloadData];
        }
        
        [[SystemConfig shareConfig] saveGroupInfo:dataSource];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [dataSource count];
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GroupInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSMutableDictionary *info = dataSource[indexPath.row];
    
    [cell setData:info];
    
    UILongPressGestureRecognizer * longPressGesture =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(cellLongPress:)];
    
//    longPressGesture.minimumPressDuration=1.5f;
    [cell addGestureRecognizer:longPressGesture];
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ZoneDetailViewController *vc = [[ZoneDetailViewController alloc] initWithNibName:@"ZoneDetailViewController" bundle:nil];
    NSMutableDictionary *info = dataSource[indexPath.row];
    vc.info = info;
    [vc setUpdateData:^(NSMutableDictionary *info, BOOL bNewInfo) {
        if (!bNewInfo) {
            [tableView reloadData];
        }
        else
        {
            [dataSource addObject:info];
            [tableView reloadData];
        }
        
        [[SystemConfig shareConfig] saveGroupInfo:dataSource];
    }];
    
    [vc setDeleteData:^(NSMutableDictionary *info) {
        [dataSource removeObject:info];
        [tableView reloadData];
        
        [[SystemConfig shareConfig] saveGroupInfo:dataSource];
    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)cellLongPress:(UILongPressGestureRecognizer *)longRecognizer{
    
    if (longRecognizer.state==UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        
        CGPoint location = [longRecognizer locationInView:tableView];
        NSIndexPath * indexPath = [tableView indexPathForRowAtPoint:location];
        NSMutableDictionary *info = dataSource[indexPath.row];
        
        SelectGroupViewController *vc = [[SelectGroupViewController alloc] initWithNibName:@"SelectGroupViewController" bundle:nil];
        vc.info = info;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
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
