//
//  XYDebugNodeCell.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYDebugNodeCell.h"

@interface XYDebugNodeCell ()
@property (weak, nonatomic) IBOutlet UIView *vLineTop;
@property (weak, nonatomic) IBOutlet UIView *vLineBottom;

@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *graphLeadingContraint;

@end


@implementation XYDebugNodeCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setNode:(XYViewNode *)node
{
    _node = node;
//    _vLineTop.hidden = node.position == XYViewNodePositionTail;
    _vLineBottom.hidden = node.position == XYViewNodePositionTail;
    _graphLeadingContraint.constant = 8 + node.deep * 5;
    _classNameLabel.text = [NSString stringWithFormat:@"%d %@",node.deep, NSStringFromClass([node.resourceView class])];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

@end
