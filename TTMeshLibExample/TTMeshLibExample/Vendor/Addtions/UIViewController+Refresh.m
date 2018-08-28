////
////  UIViewController+Refresh.m
////  iOSAppArchitecture
////
////  Created by weienjie on 16/4/13.
////  Copyright © 2016年 weienjie. All rights reserved.
////
//
//#import "UIViewController+Refresh.h"
//#import "MJRefresh.h"
//#import <objc/runtime.h>
//
//@implementation UIViewController (Refresh)
//
//+ (void)load {
//    method_exchangeImplementations(class_getInstanceMethod(self, @selector(viewDidLoad)), class_getInstanceMethod(self, @selector(SMMrefresh_viewDidLoad)));
//}
//
//- (void)SMMrefresh_viewDidLoad {
//    [self SMMrefresh_viewDidLoad];
//    if ([self isKindOfClass:[UINavigationController class]]) {
//        return;
//    }
//    //修复iphone使用第三方键盘导致的无限循环bug
//    if ([self isKindOfClass:NSClassFromString(@"_UIRemoteInputViewController")]) {
//        return;
//    }
//    UIScrollView *scroll;
//    if ([self isKindOfClass:[UITableViewController class]]) {
//        scroll = [(UITableViewController *)self tableView];
//    }else if ([self isKindOfClass:[UICollectionViewController class]]) {
//        scroll = [(UICollectionViewController *)self collectionView];
//    }else if ([self isKindOfClass:[UIViewController class]]) {
//        for (UIView *subview in self.view.subviews) {
//            if ([subview isKindOfClass:[UITableView class]] || [subview isKindOfClass:[UICollectionView class]]) {
//                scroll = (UIScrollView *)subview;
//                break;
//            }
//        }
//    }
//    self.refreshScrollView = scroll;
//}
//
//- (void)setRefreshScrollView:(UIScrollView *)refreshScrollView {
//    objc_setAssociatedObject(self, @selector(refreshScrollView), refreshScrollView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//}
//
//- (UIScrollView *)refreshScrollView {
//    return objc_getAssociatedObject(self, _cmd);
//}
//
//- (void)addRefreshHeaderWithBlock:(void (^)())block {
//    if (self.refreshScrollView.mj_header == nil) {
//        self.refreshScrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//            if (block) {
//                block();
//            }
//        }];
//        self.refreshScrollView.mj_header.backgroundColor = LightGrayColor;
//    }
//}
//
//- (void)addRefreshFooterWithBlock:(void (^)())block {
//    //存在重复添加的可能，故先置空。
//    if (self.refreshScrollView.mj_footer) {
//        [self removeRefreshFooter];
//    }
//    self.refreshScrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
//        if (block) {
//            block();
//        }
//    }];
//    self.refreshScrollView.mj_footer.backgroundColor = LightGrayColor;
//}
//
//- (void)removeRefreshHeader {
//    self.refreshScrollView.mj_header = nil;
//}
//
//- (void)removeRefreshFooter {
//    self.refreshScrollView.mj_footer = nil;
//}
//
//- (void)beginRefreshHeader {
//    [self.refreshScrollView.mj_header beginRefreshing];
//}
//
//- (void)endRefresh {
//    if ([self.refreshScrollView.mj_header isRefreshing]) {
//        [self.refreshScrollView.mj_header endRefreshing];
//    }else if ([self.refreshScrollView.mj_footer isRefreshing]) {
//        [self.refreshScrollView.mj_footer endRefreshing];
//    }
//}
//
//- (void)endRefreshWithNoMoreData {
//    [self.refreshScrollView.mj_footer endRefreshingWithNoMoreData];
//}
//
//@end

