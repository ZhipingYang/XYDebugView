//
//  XYViewNode.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYViewNode.h"

@implementation XYViewNode

- (instancetype)initWithView:(__kindof UIView *)view parent:(XYViewNode *)parent
{
    if (![view isKindOfClass:[UIView class]]) return nil;
    
    self = [super init];
    if (self) {
        _resourceView = view;
        _parentNode = parent;
        _deep = parent ? (parent.deep + 1) : 1;
                
        NSMutableArray *mArr = @[].mutableCopy;
        for (UIView *subview in view.subviews) {
            XYViewNode *child = [[XYViewNode alloc] initWithView:subview parent:self];
            if (!child) continue;
            [mArr addObject:child];
        }
        self.childNodes = [NSArray arrayWithArray:mArr];
    }
    return self;
}

@end

@implementation XYViewNode (XYDebug)

- (NSArray<XYViewNode *> *)recurrenceAllChildNodes
{
    NSMutableArray<XYViewNode *> *all = [NSMutableArray array];
    NSMutableArray<XYViewNode *> *stack = [NSMutableArray arrayWithObject:self];
    while (stack.count > 0) {
        XYViewNode *current = stack.lastObject;
        [stack removeLastObject];
        [all addObject:current];
        NSEnumerator<XYViewNode *> *reverseEnumerator = current.childNodes.reverseObjectEnumerator;
        for (XYViewNode *child in reverseEnumerator) {
            [stack addObject:child];
        }
    }
    return all.copy;
}

- (XYViewNodePosition)position
{
    if (self.parentNode.childNodes.firstObject == self) {
        return XYViewNodePositionHead;
    } else if (self.parentNode.childNodes.lastObject == self) {
        return XYViewNodePositionTail;
    }
    return XYViewNodePositionMiddle;
}

- (BOOL)hasChild
{
    return _childNodes.count>0;
}

- (BOOL)hasNext
{
    if (self.parentNode.childNodes.count<=0) return NO;
    
    NSUInteger index = [self.parentNode.childNodes indexOfObject:self];
    if (index != NSNotFound && self.parentNode.childNodes.count>(index+1)) {
        return YES;
    }
    return NO;
}
@end
