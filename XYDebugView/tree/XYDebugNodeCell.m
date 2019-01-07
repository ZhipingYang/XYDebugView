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
#import "MethodListController.h"

@interface NSObject (Private)
- (NSString *)_methodDescription;
@end

CGFloat XYDebugNodeCellHeight = 20;

@interface XYDebugNodeCell ()

@property (nonatomic, strong) UILabel *classNameLabel;
@property (nonatomic, strong) TreeIndexView *treeIndexView;

@end


@implementation XYDebugNodeCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _treeIndexView = [[TreeIndexView alloc] initWithFrame:CGRectMake(0, 0, 100, XYDebugNodeCellHeight)];
        [self.contentView addSubview:_treeIndexView];
        
        _classNameLabel = [UILabel new];
        _classNameLabel.textColor = UIColor.darkGrayColor;
        _classNameLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_classNameLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setNode:(XYViewNode *)node
{
    _node = node;
    _treeIndexView.node = node;
    _classNameLabel.text = NSStringFromClass([node.resourceView class]);
    [self setNeedsLayout];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:NO animated:animated];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _classNameLabel.frame = CGRectMake(_treeIndexView.graphRight+4, 0, self.frame.size.width-_treeIndexView.graphRight, self.frame.size.height);
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
    [[XYDebugViewManager sharedInstance] showDebugView:_node.resourceView withDebugStyle:XYDebugStyle2D];
}

- (void)show3D:(id)sender
{
    [[XYDebugViewManager sharedInstance] showDebugView:_node.resourceView withDebugStyle:XYDebugStyle3D];
}

- (void)showInfo:(id)sender
{
    MethodListController *preview = [[MethodListController alloc] init];
    preview.string = [_node.resourceView _methodDescription];
    [(UINavigationController *)self.window.rootViewController pushViewController:preview animated:YES];
}

@end

