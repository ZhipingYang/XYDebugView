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

#pragma mark - XYDebugViewManager

@interface XYDebugViewManager ()<XYDebugWindowDelegate>
{
	XYDebugStyle _debugStyle;
}
@property (nonatomic, strong) XYDebugWindow *assistiveWindow;

@property (nonatomic, weak, nullable) UIView *debugView;
@property (nonatomic, weak) UIWindow *keyWindow;

@property (nonatomic) BOOL isDebugging;
@property (nonatomic) BOOL isDebuggingBy2D;

@property (nonatomic, strong) NSHashTable <UIView *> *debuggedViews;

@end

@implementation XYDebugViewManager

+ (XYDebugViewManager *)sharedInstance
{
    static XYDebugViewManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
		instance.debuggedViews = [NSHashTable hashTableWithOptions:NSHashTableWeakMemory];
        instance.isDebugging = NO;
		instance.isDebuggingBy2D = NO;
		instance.keyWindow = [UIApplication sharedApplication].keyWindow;
    });
    return instance;
}

+ (void)showDebug
{
	[[self sharedInstance] showDebugView:XYDebugStyle2D];
}

+ (void)showDebugWithStyle:(XYDebugStyle)debugStyle
{
	[[self sharedInstance] showDebugView:debugStyle];
}

+ (void)showDebugInView:(UIView *)View withDebugStyle:(XYDebugStyle)debugStyle
{
	[[self sharedInstance] showDebugView:debugStyle];
	[self sharedInstance].debugView = View;
}

+ (void)dismissDebugView
{
	[[self sharedInstance] dismissDebugView];
}

+ (BOOL)isDebugging
{
	return [self sharedInstance].isDebugging;
}

- (void)showDebugView:(XYDebugStyle)debugStyle
{
	BOOL valide = (debugStyle == XYDebugStyle2D || debugStyle == XYDebugStyle3D);
	NSAssert(valide, @"XYDebugStyle 类型不匹配");
	
	_debugStyle = debugStyle;
	
	_assistiveWindow = [[XYDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
	_assistiveWindow.debugStyle = debugStyle;
	_assistiveWindow.delegate = self;
	_assistiveWindow.windowLevel = CGFLOAT_MAX;
	_assistiveWindow.targetView = nil;
	[_assistiveWindow makeKeyAndVisible];
	if (_keyWindow) {
		[_keyWindow makeKeyWindow];
	}
	
	[self cleanDebugLayerIn2D];
	_isDebugging = YES;
}

- (void)dismissDebugView
{
	[_assistiveWindow resignKeyWindow];
	_assistiveWindow = nil;
	[_keyWindow makeKeyAndVisible];
	
	[self cleanDebugLayerIn2D];
	_isDebugging = NO;
	_isDebuggingBy2D = NO;
	_debugView = nil;
}

- (void)drawDebugLayerIn2DViews
{
	if (self.debugView) {
		[self traverseSubviewIn:self.debugView];
	} else {
		for (UIWindow *w in [UIApplication sharedApplication].windows) {
			if (w != _assistiveWindow && w != [UIApplication sharedApplication].keyWindow) {
				[self traverseSubviewIn:w];
			}
		}
		[self traverseSubviewIn:[UIApplication sharedApplication].keyWindow];
	}
}

- (void)traverseSubviewIn:(UIView *)parentView
{
    NSMutableArray <UIView *>* allViews = parentView.debug_recurrenceAllSubviews.mutableCopy;
    // 移除第一个view（window）
    [allViews removeObjectAtIndex:0];
	
	// 追加debug
	for (UIView *subview in allViews) {
		// 添加view的frame边框
		if (!subview.debug_colorSublayer.superlayer) {
			[subview.layer addSublayer:subview.debug_colorSublayer];
		}
		[_debuggedViews addObject:subview];
	}
}

- (void)cleanDebugLayerIn2D
{
	[_debuggedViews.allObjects enumerateObjectsUsingBlock:^(UIView * _Nonnull subview, NSUInteger idx, BOOL * _Nonnull stop) {
		[subview debug_resetView];
	}];
	
	[_debuggedViews removeAllObjects];
}

#pragma mark - XYDebugWindowDelegate

- (void)debugWindowTopButtonClick:(XYDebugWindow *)window is3DDebugging:(BOOL)is3DDebugging
{
	if (_debugStyle == XYDebugStyle2D) {
		if (_isDebuggingBy2D) {
			[self cleanDebugLayerIn2D];
		} else {
			[self drawDebugLayerIn2DViews];
		}
		_isDebuggingBy2D = !_isDebuggingBy2D;
		
	} else if (is3DDebugging) {
		self.assistiveWindow.targetView = nil;
	} else {
		_assistiveWindow.targetView = _debugView ?: [UIApplication sharedApplication].keyWindow;
	}
}

@end
