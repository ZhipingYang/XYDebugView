//
//  TreeIndexView.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "TreeIndexView.h"

@interface TreeIndexView ()

@property (nonatomic, strong) CALayer *hLine;

@property (nonatomic, strong) NSMutableArray <CALayer *> *vLines;

@end

@implementation TreeIndexView

- (instancetype)initWithNode:(XYViewNode *)node
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _vLines = @[].mutableCopy;
        self.node = node;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _vLines = @[].mutableCopy;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        _vLines = @[].mutableCopy;
    }
    return self;
}

- (void)setNode:(XYViewNode *)node
{
    _node = node;
    
    if (!_hLine) {
        _hLine = [CALayer layer];
        _hLine.backgroundColor = [UIColor grayColor].CGColor;
        [self.layer addSublayer:_hLine];
    }
    
    [_vLines makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
    
    for (int i=0; i<=_node.deep; i++) {
        CALayer *vLine = [CALayer layer];
        vLine.backgroundColor = [UIColor grayColor].CGColor;
        [self.layer addSublayer:vLine];
        [_vLines addObject:vLine];
    }

    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat const width =  self.frame.size.width;
    CGFloat const height =  self.frame.size.height;
    CGFloat const eachW = width/MAX(_node.maxDeep, 1);
    
    _hLine.frame = CGRectMake(eachW * (_node.deep-1), height/2.0, width-(eachW*_node.deep-1), 1);
    
    _vLines[self.node.deep-1].frame = CGRectMake(eachW*(self.node.deep-1), 0, 1, self.node.hasNext ? height : height/2.0);
    _vLines[self.node.deep].frame = CGRectMake(eachW*self.node.deep, height/2.0, 1, self.node.hasChild ? height/2.0 : 0);

    XYViewNode *parentNode = self.node.parentNode;
    while (parentNode!=nil) {
        _vLines[parentNode.deep-1].frame = CGRectMake(eachW*(parentNode.deep-1), 0, 1, height);
        _vLines[parentNode.deep-1].hidden = !parentNode.hasNext;
        parentNode = parentNode.parentNode;
    }
}

@end
