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

@interface XYDebugViewManager ()

@property (nonatomic, strong) XYDebugWindow *assistiveWindow;
@property (nonatomic, weak) UIWindow *keyWindow;
@property (nonatomic, assign) DebugViewState debugState;

@end

@implementation XYDebugViewManager

+ (XYDebugViewManager *)sharedInstance
{
    static XYDebugViewManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.isDebugging = NO;
        instance.debugState = DebugViewStateNone;
        instance.keyWindow = [UIApplication sharedApplication].keyWindow;
    });
    return instance;
}

- (void)setIsDebugging:(BOOL)isDebugging
{
    if (!_assistiveWindow) {
        _assistiveWindow = [[XYDebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _assistiveWindow.frameManager = self;
        [_assistiveWindow.statusBarButton addTarget:self action:@selector(debugViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _assistiveWindow.windowLevel = isDebugging ? CGFLOAT_MAX:UIWindowLevelNormal;
    _assistiveWindow.statusBarButton.hidden = !isDebugging;
    _assistiveWindow.souceView = nil;

    if (isDebugging) {
        [_assistiveWindow makeKeyAndVisible];
        if (_keyWindow) {
            [_keyWindow makeKeyWindow];
        }
    } else {
        [_assistiveWindow resignKeyWindow];
        _assistiveWindow = nil;
        [_keyWindow makeKeyAndVisible];
    }
    
    [self currentWindowsShowDebugView:NO];
    _debugState = DebugViewStateNone;
    _isDebugging = isDebugging;
}

- (void)debugViewBtnClick
{
    switch (self.debugState) {
        case DebugViewStateNone: {
            [self currentWindowsShowDebugView:YES];
            self.debugState = DebugViewState2D;
        }
            break;
        case DebugViewState2D:{
            _assistiveWindow.souceView = [UIApplication sharedApplication].keyWindow;
            self.debugState = DebugViewState3D;
        }
            break;
        case DebugViewState3D:{
            [self currentWindowsShowDebugView:NO];
            self.assistiveWindow.souceView = nil;
            self.debugState = DebugViewStateNone;
        }
            break;
            
        default:
            break;
    }
}

- (void)currentWindowsShowDebugView:(BOOL)showDebugView
{
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w != _assistiveWindow && w != [UIApplication sharedApplication].keyWindow) {
            [self traverseSubviewIn:w shouldRecoverBackColor:!showDebugView];
        }
    }
    [self traverseSubviewIn:[UIApplication sharedApplication].keyWindow shouldRecoverBackColor:!showDebugView];
}

- (void)traverseSubviewIn:(UIView *)parentView shouldRecoverBackColor:(BOOL)shouldRecoverBackColor
{
    NSMutableArray <UIView *>* allViews = parentView.debug_recurrenceAllSubviews.mutableCopy;
    // 移除第一个view（window）
    [allViews removeObjectAtIndex:0];
    
    if (shouldRecoverBackColor) {
        // 回复原貌
        for (UIView *subview in allViews) {
            if (!subview.debug_hasStoreDebugColor) { return; }
            subview.backgroundColor = subview.debug_storeOrginalColor ?: [UIColor clearColor];
            subview.debug_hasStoreDebugColor = NO;
            subview.layer.borderWidth = CGFLOAT_MIN;
            if (subview.debug_colorSublayer.superlayer) {
                [subview.debug_colorSublayer removeFromSuperlayer];
            }
        }
    } else {
        // 追加debug
        for (UIView *subview in allViews) {
            
            if (subview.debug_hasStoreDebugColor || subview==_assistiveWindow.statusBarButton) {
                return;
            }
            subview.debug_storeOrginalColor = subview.backgroundColor;
            subview.debug_hasStoreDebugColor = YES;
            if (!CGRectEqualToRect(subview.bounds, [UIScreen mainScreen].bounds)) {
                subview.backgroundColor = [UIColor debug_randomLightColorWithAlpha:0.6];
            }
            
            // 添加view的frame边框
            if (!subview.debug_colorSublayer.superlayer) {
                [subview.layer addSublayer:subview.debug_colorSublayer];
            }
        }
    }
}

@end
