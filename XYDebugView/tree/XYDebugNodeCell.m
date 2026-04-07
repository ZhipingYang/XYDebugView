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
#import <objc/runtime.h>

CGFloat XYDebugNodeCellHeight = 20;

static NSString *XYDebugMethodSectionTitle(NSString *title, NSArray<NSString *> *methods)
{
    NSMutableString *section = [NSMutableString stringWithFormat:@"%@\n", title];
    if (methods.count == 0) {
        [section appendString:@"  (none)\n"];
        return section.copy;
    }
    for (NSString *methodName in methods) {
        [section appendFormat:@"  %@\n", methodName];
    }
    return section.copy;
}

static NSArray<NSString *> *XYDebugMethodNamesForClass(Class cls)
{
    unsigned int count = 0;
    Method *methods = class_copyMethodList(cls, &count);
    NSMutableArray<NSString *> *names = [NSMutableArray arrayWithCapacity:count];
    for (unsigned int idx = 0; idx < count; idx++) {
        [names addObject:NSStringFromSelector(method_getName(methods[idx]))];
    }
    free(methods);
    [names sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    return names.copy;
}

static NSString *XYDebugInfoStringForView(UIView *view)
{
    NSMutableString *info = [NSMutableString string];
    [info appendFormat:@"Class: %@\n", NSStringFromClass(view.class)];
    [info appendFormat:@"Superclass: %@\n", NSStringFromClass(class_getSuperclass(view.class))];
    [info appendFormat:@"Frame: %@\n", NSStringFromCGRect(view.frame)];
    [info appendFormat:@"Bounds: %@\n", NSStringFromCGRect(view.bounds)];
    [info appendFormat:@"Center: %@\n", NSStringFromCGPoint(view.center)];
    [info appendFormat:@"Hidden: %@\n", view.isHidden ? @"YES" : @"NO"];
    [info appendFormat:@"Alpha: %.2f\n", view.alpha];
    [info appendFormat:@"Subviews: %lu\n", (unsigned long)view.subviews.count];
    [info appendString:@"\n"];
    [info appendString:XYDebugMethodSectionTitle(@"Instance Methods:", XYDebugMethodNamesForClass(view.class))];
    [info appendString:@"\n"];
    [info appendString:XYDebugMethodSectionTitle(@"Class Methods:", XYDebugMethodNamesForClass(object_getClass(view.class)))];
    return info.copy;
}

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
    [menu showMenuFromView:self rect:self.bounds];
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
    preview.string = XYDebugInfoStringForView(_node.resourceView);

    UIViewController *owner = [self owningViewController];
    if (owner.navigationController) {
        [owner.navigationController pushViewController:preview animated:YES];
        return;
    }

    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:preview];
    [owner presentViewController:navigationController animated:YES completion:nil];
}

- (UIViewController *)owningViewController
{
    UIResponder *responder = self;
    while ((responder = responder.nextResponder)) {
        if ([responder isKindOfClass:[UIViewController class]]) {
            return (UIViewController *)responder;
        }
    }
    return self.window.rootViewController;
}

@end
