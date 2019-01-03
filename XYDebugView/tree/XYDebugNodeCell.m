//
//  XYDebugNodeCell.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYDebugNodeCell.h"
#import "TreeIndexView.h"

@interface XYDebugNodeCell ()

@property (nonatomic, strong) TreeIndexView *indexView;

@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet TreeIndexView *treeIndexView;

@end


@implementation XYDebugNodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setNode:(XYViewNode *)node
{
    _node = node;
    _treeIndexView.node = node;
    _classNameLabel.text = [NSString stringWithFormat:@"%d %@",node.deep, NSStringFromClass([node.resourceView class])];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

@end
