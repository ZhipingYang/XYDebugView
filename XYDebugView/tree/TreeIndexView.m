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

- (instancetype)initWithTreeDeep:(NSInteger)deep
{
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _vLines = @[].mutableCopy;
        _deep = deep;
        
        _hLine = [CALayer layer];
        _hLine.backgroundColor = [UIColor grayColor].CGColor;
        [self.layer addSublayer:_hLine];
        
        for (int i=0; i<deep; i++) {
            CALayer *vLine = [CALayer layer];
            vLine.backgroundColor = [UIColor grayColor].CGColor;
            [self.layer addSublayer:vLine];
            [_vLines addObject:vLine];
        }
    }
    return self;
}

- (void)setNode:(XYViewNode *)node
{
    _node = node;
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat const width =  self.frame.size.width;
    CGFloat const height =  self.frame.size.height;
    CGFloat const eachW = width/MAX(_deep, 1);
    int index = _node.deep;
    
    _hLine.frame = CGRectMake(eachW * _deep, height/2.0, width-(eachW*_deep), 1);
    
    for (int i=0; i<_deep; i++) {
        [_vLines objectAtIndex:i].hidden = i > _deep;
        if (_node.deep==1) {
            _vLines.firstObject.hidden = YES;
        }
    }
    
    for (int i=0; i<index; i++) {
        
    }
}

@end
