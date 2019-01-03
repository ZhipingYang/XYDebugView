//
//  XYDebugNodeCell.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYDebugNodeCell.h"
#import "TreeIndexView.h"
#import "XYDebugViewManager.h"

@interface NSObject (Private)
- (NSString *)_methodDescription;
@end

@interface XYDebugNodeCell ()

@property (nonatomic, strong) TreeIndexView *indexView;

@property (weak, nonatomic) IBOutlet UILabel *classNameLabel;
@property (weak, nonatomic) IBOutlet TreeIndexView *treeIndexView;

@end


@implementation XYDebugNodeCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                          action:@selector(handleTap:)];
    [self addGestureRecognizer:tap];
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

- (void)handleTap:(UIGestureRecognizer*)recognizer
{
    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    UIMenuItem *item2D = [[UIMenuItem alloc] initWithTitle:@"2D" action:@selector(show2D:)];
    UIMenuItem *item3D = [[UIMenuItem alloc] initWithTitle:@"3D" action:@selector(show3D:)];
    UIMenuItem *itemInfo = [[UIMenuItem alloc] initWithTitle:@"Info" action:@selector(showInfo:)];
    menu.menuItems = @[item2D, item3D, itemInfo];
    [menu setTargetRect:self.bounds inView:self];
    [menu setMenuVisible:YES animated:YES];
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return (action == @selector(show2D:)) || (action == @selector(show3D:)) || (action == @selector(showInfo:));
}

- (void)show2D:(id)sender
{
    [XYDebugViewManager showDebugInView:_node.resourceView withDebugStyle:XYDebugStyle2D];
}

- (void)show3D:(id)sender
{
    [XYDebugViewManager showDebugInView:_node.resourceView withDebugStyle:XYDebugStyle3D];
}

- (void)showInfo:(id)sender
{
    
    [[[UIAlertView alloc] initWithTitle:@"Info" message:[_node.resourceView _methodDescription] delegate:nil cancelButtonTitle:@"Sure" otherButtonTitles:nil] show];
}

@end

