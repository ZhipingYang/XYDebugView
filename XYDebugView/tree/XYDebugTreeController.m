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

@property (nonatomic, strong) NSArray <XYViewNode *> *dataSource;

@end

@implementation XYDebugTreeController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"TreeIndex";
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
}

- (void)setRootNode:(XYViewNode *)rootNode
{
    _rootNode = rootNode;
    _dataSource = [rootNode recurrenceAllChildNodes];
    
    int max = _dataSource.firstObject.deep;
    for (XYViewNode *node in _dataSource) {
        if (node.deep>max) {
            max = node.deep;
        }
    }
    [_dataSource enumerateObjectsUsingBlock:^(XYViewNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.maxDeep = max;
    }];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    XYDebugNodeCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([XYDebugNodeCell class])];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([XYDebugNodeCell class]) owner:nil options:nil] firstObject];
    }
    cell.node = [_dataSource objectAtIndex:indexPath.row];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 20;
}

@end
