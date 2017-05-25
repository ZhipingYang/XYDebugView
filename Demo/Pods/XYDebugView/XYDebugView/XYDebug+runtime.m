//
//  UIView+XYDebug.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebug+runtime.h"
#import <objc/runtime.h>

const static char * DebugStoreUIViewBackColor = "DebugStoreUIViewBackColor";
const static char * DebugHasStoreUIViewBackColor = "DebugHasStoreUIViewBackColor";
const static char * DebugCloneView = "DebugCloneView";
const static char * DebugColorSublayer = "DebugColorSublayer";

@implementation UIView (XYDebug)

- (void)setDebugStoreOrginalColor:(UIColor *)debugStoreOrginalColor
{
    if ([debugStoreOrginalColor isKindOfClass:[UIColor class]] && debugStoreOrginalColor) {
        objc_setAssociatedObject(self, DebugStoreUIViewBackColor, debugStoreOrginalColor, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIColor *)debugStoreOrginalColor
{
    id obj = objc_getAssociatedObject(self, DebugStoreUIViewBackColor);
    if ([obj isKindOfClass:[UIColor class]]) {
        return (UIColor *)obj;
    }
    return nil;
}

- (CALayer *)debugColorSublayer
{
    CALayer *obj = objc_getAssociatedObject(self, DebugColorSublayer);
    if ([obj isKindOfClass:[CALayer class]] && obj) {
        obj.frame = self.bounds;
        return obj;
    }
    obj = [[CALayer alloc] init];
    obj.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
    obj.borderWidth = 1/[UIScreen mainScreen].scale;
    objc_setAssociatedObject(self, DebugColorSublayer, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debugColorSublayer];
}

- (XYDebugCloneView *)cloneView
{
    XYDebugCloneView *obj = objc_getAssociatedObject(self, DebugCloneView);
    if ([obj isKindOfClass:[XYDebugCloneView class]] && obj) {
        return obj;
    }
    obj = [XYDebugCloneView cloneWith:self];
    obj.debugColorSublayer.frame = obj.bounds;
    [obj.layer addSublayer:obj.debugColorSublayer];
    objc_setAssociatedObject(self, DebugCloneView, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self cloneView];
}

- (void)setHasStoreDebugColor:(BOOL)hasStoreDebugColor
{
    objc_setAssociatedObject(self, DebugHasStoreUIViewBackColor, @(hasStoreDebugColor), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasStoreDebugColor
{
    id obj = objc_getAssociatedObject(self, DebugHasStoreUIViewBackColor);
    return [obj boolValue];
}

- (NSArray<UIView *> *)debuRecurrenceAllSubviews
{
    NSMutableArray <UIView *> *all = @[].mutableCopy;
    void (^getSubViewsBlock)(UIView *current) = ^(UIView *current){
        [all addObject:current];
        for (UIView *sub in current.subviews) {
            [all addObjectsFromArray:[sub debuRecurrenceAllSubviews]];
        }
    };
    getSubViewsBlock(self);
    return [NSArray arrayWithArray:all];
}

@end


const static char * DebugStoreZPosition = "DebugStoreZPosition";


@implementation CALayer (XYDebug)

- (CGFloat)debug_zPostion
{
    id obj = objc_getAssociatedObject(self, DebugStoreZPosition);
    return [obj floatValue];
}

- (void)setDebug_zPostion:(CGFloat)debug_zPostion
{
    objc_setAssociatedObject(self, DebugStoreZPosition, @(debug_zPostion), OBJC_ASSOCIATION_ASSIGN);
}

@end
