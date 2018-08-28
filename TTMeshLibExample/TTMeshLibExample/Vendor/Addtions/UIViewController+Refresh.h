////
////  UIViewController+Refresh.h
////  iOSAppArchitecture
////
////  Created by weienjie on 16/4/13.
////  Copyright © 2016年 weienjie. All rights reserved.
////
//
//#import <UIKit/UIKit.h>
//
///*
// *扩展UIViewController，统一处理上拉和下拉刷新
// *如果是UITableViewController和UICollectionViewController则直接设置即可。
// *如果是在UIViewController基础上手动添加tableView和collectionView，则轮训subview，如果一个vc里有多个tableview的话会有bug。
// */
//@interface UIViewController (Refresh)
//
///*
// *添加下拉刷新，block方式
// */
//- (void)addRefreshHeaderWithBlock:(void (^)())block;
//
///*
// *添加上拉刷新，block方式
// */
//- (void)addRefreshFooterWithBlock:(void (^)())block;
//
//- (void)removeRefreshHeader;
//
////
//- (void)removeRefreshFooter;
//
///*
// *启动下拉刷新,用户可以主动启动下拉刷新来获取首次数据，但上拉用于获取分页数据，由MJRefresh启动。
// */
//- (void)beginRefreshHeader;
//
///*
// *结束刷新，内部区分header和footer
// */
//- (void)endRefresh;
//
///*
// *结束刷新,并告知无更多数据，footer方法
// */
//- (void)endRefreshWithNoMoreData;
//
//@end

