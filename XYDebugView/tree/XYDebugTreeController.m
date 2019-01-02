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
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    [self.tableView registerNib:[UINib nibWithNibName:NSStringFromClass([XYDebugNodeCell class]) bundle:nil] forCellReuseIdentifier:NSStringFromClass([XYDebugNodeCell class])];
}

- (void)setRootNode:(XYViewNode *)rootNode
{
    _rootNode = rootNode;
    _dataSource = [rootNode recurrenceAllChildNodes];
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
    return 40;
}

@end
