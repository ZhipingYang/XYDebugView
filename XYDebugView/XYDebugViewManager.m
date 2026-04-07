//
//  XYDebugViewManager.m
//  QueryViolations
//
//  Created by XcodeYang on 02/05/2017.
//  Copyright © 2017 eclicks. All rights reserved.
//

#import "XYDebugViewManager.h"
#import "XYDebugWindow.h"
#import "XYDebugCategory.h"
#import "XYDebugTreeController.h"

#pragma mark - XYDebugViewManager

@interface XYDebugViewManager ()<XYDebugWindowDelegate>
{
	XYDebugStyle _debugStyle;
}

@property (nonatomic, strong) XYDebugWindow *assistiveWindow;
@property (nonatomic, weak, nullable) UIView *debugView;
@property (nonatomic, weak, nullable) UIWindow *previousKeyWindow;
@property (nonatomic, strong) NSHashTable<UIView *> *debuggedViews;
@property (nonatomic, weak, nullable) UIViewController *indexController;

@end

@implementation XYDebugViewManager

+ (XYDebugViewManager *)sharedInstance
{
    static XYDebugViewManager *instance = nil;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.debuggedViews = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
    });
    return instance;
}

- (void)showDebug
{
	[self showDebugStyle:XYDebugStyle2D];
}

- (void)closeDebug
{
    [self dismissDebugView];
}

- (void)showDebugStyle:(XYDebugStyle)debugStyle
{
	[self showDebugView:nil withDebugStyle:debugStyle];
}

- (void)showDebugView:(UIView *)view withDebugStyle:(XYDebugStyle)debugStyle
{
    BOOL valid = (debugStyle >= XYDebugStyleNone && debugStyle <= XYDebugStyle3D);
    NSAssert(valid, @"XYDebugStyle 类型不匹配");

    [self dismissDebugView];
    if (debugStyle == XYDebugStyleNone) {
        return;
    }

    UIView *resolvedView = view ?: UIApplication.sharedApplication.debug_keyWindow;
    _debugStyle = debugStyle;
    _debugView = resolvedView;

    if (debugStyle == XYDebugStyleIndex) {
        [self presentIndexDebuggerForRequestedView:view];
        return;
    }

    if (!resolvedView) {
        _debugStyle = XYDebugStyleNone;
        return;
    }

    self.previousKeyWindow = UIApplication.sharedApplication.debug_keyWindow;
    self.assistiveWindow = [self buildAssistiveWindowForView:resolvedView];
    self.assistiveWindow.debugStyle = debugStyle;
    self.assistiveWindow.delegate = self;
    self.assistiveWindow.windowLevel = UIWindowLevelAlert + 1;
    self.assistiveWindow.targetView = nil;
    [self.assistiveWindow makeKeyAndVisible];
    [self restoreWindow:self.previousKeyWindow];

    if (debugStyle == XYDebugStyle2D) {
        [self drawDebugLayerIn2DViews];
    } else if (debugStyle == XYDebugStyle3D) {
        self.assistiveWindow.targetView = resolvedView;
    }
}

#pragma mark - private

- (NSArray<UIWindow *> *)eligibleApplicationWindows
{
    NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
    for (UIWindow *window in UIApplication.sharedApplication.debug_activeWindows) {
        if (window == self.assistiveWindow || window.hidden || window.alpha <= 0.01) {
            continue;
        }
        [windows addObject:window];
    }
    return windows.copy;
}

- (XYDebugWindow *)buildAssistiveWindowForView:(UIView *)view
{
    if (@available(iOS 13.0, *)) {
        UIWindowScene *windowScene = [self windowSceneForView:view];
        if (windowScene) {
            XYDebugWindow *window = [[XYDebugWindow alloc] initWithWindowScene:windowScene];
            window.frame = windowScene.screen.bounds;
            return window;
        }
    }
    return [[XYDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
}

- (nullable UIWindowScene *)windowSceneForView:(nullable UIView *)view API_AVAILABLE(ios(13.0))
{
    if ([view isKindOfClass:[UIWindow class]]) {
        return ((UIWindow *)view).windowScene;
    }
    if (view.window.windowScene) {
        return view.window.windowScene;
    }
    return UIApplication.sharedApplication.debug_keyWindow.windowScene;
}

- (void)presentIndexDebuggerForRequestedView:(nullable UIView *)requestedView
{
    NSArray<XYViewNode *> *rootNodes = [self indexRootNodesForRequestedView:requestedView];
    if (rootNodes.count == 0) {
        _debugStyle = XYDebugStyleNone;
        _debugView = nil;
        return;
    }

    UIViewController *presenter = [self topViewController];
    if (!presenter) {
        _debugStyle = XYDebugStyleNone;
        _debugView = nil;
        return;
    }

    XYDebugTreeController *controller = [[XYDebugTreeController alloc] initWithStyle:UITableViewStyleGrouped];
    controller.rootNodes = rootNodes;
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];
    if (@available(iOS 13.0, *)) {
        navigationController.modalPresentationStyle = UIModalPresentationAutomatic;
    } else {
        navigationController.modalPresentationStyle = UIModalPresentationFullScreen;
    }
    [presenter presentViewController:navigationController animated:YES completion:nil];
    self.indexController = navigationController;
}

- (NSArray<XYViewNode *> *)indexRootNodesForRequestedView:(nullable UIView *)requestedView
{
    NSMutableArray<XYViewNode *> *rootNodes = [NSMutableArray array];
    if (requestedView && ![requestedView isKindOfClass:[UIWindow class]]) {
        XYViewNode *node = [[XYViewNode alloc] initWithView:requestedView parent:nil];
        if (node) {
            [rootNodes addObject:node];
        }
        return rootNodes.copy;
    }

    for (UIWindow *window in [self eligibleApplicationWindows]) {
        XYViewNode *node = [[XYViewNode alloc] initWithView:window parent:nil];
        if (node) {
            [rootNodes addObject:node];
        }
    }
    return rootNodes.copy;
}

- (nullable UIViewController *)topViewController
{
    UIViewController *controller = UIApplication.sharedApplication.debug_keyWindow.rootViewController;
    while (controller.presentedViewController) {
        controller = controller.presentedViewController;
    }
    if ([controller isKindOfClass:[UINavigationController class]]) {
        return ((UINavigationController *)controller).visibleViewController ?: controller;
    }
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UIViewController *selected = ((UITabBarController *)controller).selectedViewController;
        if ([selected isKindOfClass:[UINavigationController class]]) {
            return ((UINavigationController *)selected).visibleViewController ?: selected;
        }
        return selected ?: controller;
    }
    return controller;
}

- (void)restoreWindow:(nullable UIWindow *)window
{
    if (!window || window == self.assistiveWindow) {
        return;
    }
    if (window.hidden) {
        [window makeKeyAndVisible];
    } else {
        [window makeKeyWindow];
    }
}

- (void)dismissDebugView
{
	[self.assistiveWindow resignKeyWindow];
    self.assistiveWindow.delegate = nil;
    self.assistiveWindow.targetView = nil;
    self.assistiveWindow.hidden = YES;
	self.assistiveWindow = nil;

    if (self.indexController.presentingViewController) {
        [self.indexController dismissViewControllerAnimated:NO completion:nil];
    }

    UIWindow *windowToRestore = self.previousKeyWindow ?: self.debugView.window ?: UIApplication.sharedApplication.debug_keyWindow;
    [self restoreWindow:windowToRestore];
	[self cleanDebugLayerIn2D];
	self.indexController = nil;
	self.debugView = nil;
    self.previousKeyWindow = nil;
    _debugStyle = XYDebugStyleNone;
}

- (void)drawDebugLayerIn2DViews
{
	if (self.debugView) {
		[self traverseSubviewIn:self.debugView];
		return;
	}

    for (UIWindow *window in [self eligibleApplicationWindows]) {
        [self traverseSubviewIn:window];
    }
}

- (void)traverseSubviewIn:(UIView *)parentView
{
    if (!parentView) {
        return;
    }

    NSMutableArray<UIView *> *allViews = parentView.debug_recurrenceAllSubviews.mutableCopy;
    if ([parentView isKindOfClass:[UIWindow class]] && allViews.count > 0) {
        [allViews removeObjectAtIndex:0];
    }

	for (UIView *subview in allViews) {
		if (!subview.debug_colorSublayer.superlayer) {
			[subview.layer addSublayer:subview.debug_colorSublayer];
		}
		[self.debuggedViews addObject:subview];
	}
}

- (void)cleanDebugLayerIn2D
{
	[self.debuggedViews.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
		[subview debug_resetView];
	}];

	[self.debuggedViews removeAllObjects];
}

#pragma mark - XYDebugWindowDelegate

- (void)debugWindowTopButtonClick:(XYDebugWindow *)window is3DDebugging:(BOOL)is3DDebugging
{
    (void)window;
    (void)is3DDebugging;
    [self closeDebug];
}

@end
