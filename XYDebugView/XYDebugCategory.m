//
//  UIView+XYDebug.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugCategory.h"
#import <objc/runtime.h>

const static char * DebugCloneView = "DebugCloneView";
const static char * debug_colorSublayer = "debug_colorSublayer";

@implementation UIView (XYDebug)

- (CALayer *)debug_colorSublayer
{
    CALayer *obj = objc_getAssociatedObject(self, debug_colorSublayer);
    if ([obj isKindOfClass:[CALayer class]] && obj) {
        obj.frame = self.bounds;
        return obj;
    }
    obj = [[CALayer alloc] init];
    obj.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.6].CGColor;
    CGFloat scale = self.traitCollection.displayScale > 0 ? self.traitCollection.displayScale : 1.0;
    obj.borderWidth = 1 / scale;
    objc_setAssociatedObject(self, debug_colorSublayer, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debug_colorSublayer];
}

- (XYDebugCloneView *)debug_cloneView
{
    XYDebugCloneView *obj = objc_getAssociatedObject(self, DebugCloneView);
    if ([obj isKindOfClass:[XYDebugCloneView class]] && obj) {
        [obj refreshFromView:self];
        return obj;
    }
    obj = [XYDebugCloneView cloneWith:self];
    objc_setAssociatedObject(self, DebugCloneView, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debug_cloneView];
}

- (NSArray<UIView *> *)debug_recurrenceAllSubviews
{
    NSMutableArray<UIView *> *all = [NSMutableArray array];
    NSMutableArray<UIView *> *stack = [NSMutableArray arrayWithObject:self];
    while (stack.count > 0) {
        UIView *current = stack.lastObject;
        [stack removeLastObject];
        [all addObject:current];
        NSEnumerator<UIView *> *reverseEnumerator = current.subviews.reverseObjectEnumerator;
        for (UIView *subview in reverseEnumerator) {
            [stack addObject:subview];
        }
    }
    return all.copy;
}

- (void)debug_resetView
{
	CALayer *debug_associatedLayer = objc_getAssociatedObject(self, debug_colorSublayer);
	[debug_associatedLayer removeFromSuperlayer];
	objc_setAssociatedObject(self, debug_colorSublayer, nil, OBJC_ASSOCIATION_ASSIGN);
	XYDebugCloneView *debug_associatedView = objc_getAssociatedObject(self, DebugCloneView);
	[debug_associatedView.layer removeFromSuperlayer];
	objc_setAssociatedObject(self, DebugCloneView, nil, OBJC_ASSOCIATION_ASSIGN);
}

@end


const static char * DebugStoreZPosition = "DebugStoreZPosition";
const static char * DebugStoreOrderIndex = "DebugStoreOrderIndex";

@implementation CALayer (XYDebug)

- (CGFloat)debug_zPostion
{
    id obj = objc_getAssociatedObject(self, DebugStoreZPosition);
    return [obj floatValue];
}

- (void)setDebug_zPostion:(CGFloat)debug_zPostion
{
    objc_setAssociatedObject(self, DebugStoreZPosition, @(debug_zPostion), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSInteger)debug_orderIndex
{
    id obj = objc_getAssociatedObject(self, DebugStoreOrderIndex);
    return [obj integerValue];
}

- (void)setDebug_orderIndex:(NSInteger)debug_orderIndex
{
    objc_setAssociatedObject(self, DebugStoreOrderIndex, @(debug_orderIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)debug_zPositionAnimationFrom:(float)from to:(float)to duration:(NSTimeInterval)duration
{
    if ([self animationForKey:@"zPosition"]) {
        [self removeAnimationForKey:@"zPosition"];
    }
    CABasicAnimation *theAnimation;
    theAnimation = [CABasicAnimation animationWithKeyPath:@"zPosition"];
	theAnimation.fromValue = [NSNumber numberWithFloat:from];
	theAnimation.toValue = [NSNumber numberWithFloat:to];
    theAnimation.duration = duration;
    theAnimation.fillMode = kCAFillModeForwards;
    theAnimation.removedOnCompletion = NO;
    [self addAnimation:theAnimation forKey:@"zPosition"];
	self.zPosition = to;
}

@end

@implementation UIColor (XYDebug)

+ (UIColor *)debug_randomLightColorWithAlpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:(arc4random()%100+155)/255.0
						   green:(arc4random()%100+155)/255.0
							blue:(arc4random()%100+155)/255.0
						   alpha:alpha];
}

+ (UIColor *)debug_randomDrakColorWithAlpha:(CGFloat)alpha
{
	return [UIColor colorWithRed:(arc4random()%150)/255.0
						   green:(arc4random()%150)/255.0
							blue:(arc4random()%150)/255.0
						   alpha:alpha];
}
@end

@implementation UIApplication (XYDebug)

- (NSArray<UIWindow *> *)debug_activeWindows
{
    NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in self.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            if (scene.activationState != UISceneActivationStateForegroundActive &&
                scene.activationState != UISceneActivationStateForegroundInactive) {
                continue;
            }
            [windows addObjectsFromArray:((UIWindowScene *)scene).windows];
        }
    }
    if (windows.count == 0) {
        if ([self.delegate respondsToSelector:@selector(window)] && self.delegate.window) {
            [windows addObject:self.delegate.window];
        }
    }
    return windows.copy;
}

- (UIWindow *)debug_keyWindow
{
    NSArray<UIWindow *> *windows = self.debug_activeWindows;
    for (UIWindow *window in windows.reverseObjectEnumerator) {
        if (window.isKeyWindow) {
            return window;
        }
    }
    for (UIWindow *window in windows.reverseObjectEnumerator) {
        if (!window.hidden && window.alpha > 0.01) {
            return window;
        }
    }
    return nil;
}

@end

@implementation UIDevice (XYDebug)

+ (BOOL)isNotchScreen
{
    if (@available(iOS 11.0, *)) {
        UIWindow *window = UIApplication.sharedApplication.debug_keyWindow;
        UIEdgeInsets windowInsets = window.safeAreaInsets;
        return !UIEdgeInsetsEqualToEdgeInsets(windowInsets, UIEdgeInsetsZero);
    }
    return NO;
}

@end
