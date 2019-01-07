//
//  XYDebugTreeController.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYDebugTreeController.h"
#import "XYDebugNodeCell.h"

@interface XYDebugTreeController ()

@property (nonatomic, strong) NSMutableArray<NSArray<XYViewNode *> *> *dataSources;

@end

@implementation XYDebugTreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TreeIndex";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setRootNodes:(NSArray<XYViewNode *> *)rootNodes
{
    _rootNodes = rootNodes;
    _dataSources = @[].mutableCopy;
    
    [rootNodes enumerateObjectsUsingBlock:^(XYViewNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<XYViewNode *> *dataSource = [obj recurrenceAllChildNodes];
        [self.dataSources addObject:dataSource];
        
        int max = dataSource.firstObject.deep;
        for (XYViewNode *node in dataSource) {
            if (node.deep>max) {
                max = node.deep;
            }
        }
        [dataSource enumerateObjectsUsingBlock:^(XYViewNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.maxDeep = max;
        }];
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSources.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSources[section].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XYDebugNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([XYDebugNodeCell class])];
    if (!cell) {
        cell = [[XYDebugNodeCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([XYDebugNodeCell class])];
    }
    cell.node = self.dataSources[indexPath.section][indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return XYDebugNodeCellHeight;
}

@end
