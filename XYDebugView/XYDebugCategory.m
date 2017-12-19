//
//  UIView+XYDebug.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugCategory.h"
#import <objc/runtime.h>

const static char * DebugStoreUIViewBackColor = "DebugStoreUIViewBackColor";
const static char * DebugHasStoreUIViewBackColor = "DebugHasStoreUIViewBackColor";
const static char * DebugCloneView = "DebugCloneView";
const static char * debug_colorSublayer = "debug_colorSublayer";

@implementation UIView (XYDebug)

- (void)setDebug_storeOrginalColor:(UIColor *)debug_storeOrginalColor
{
    if ([debug_storeOrginalColor isKindOfClass:[UIColor class]] && debug_storeOrginalColor) {
        objc_setAssociatedObject(self, DebugStoreUIViewBackColor, debug_storeOrginalColor, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIColor *)debug_storeOrginalColor
{
    id obj = objc_getAssociatedObject(self, DebugStoreUIViewBackColor);
    if ([obj isKindOfClass:[UIColor class]]) {
        return (UIColor *)obj;
    }
    return nil;
}

- (CALayer *)debug_colorSublayer
{
    CALayer *obj = objc_getAssociatedObject(self, debug_colorSublayer);
    if ([obj isKindOfClass:[CALayer class]] && obj) {
        obj.frame = self.bounds;
        return obj;
    }
    obj = [[CALayer alloc] init];
    obj.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.3].CGColor;
    obj.borderWidth = 1/[UIScreen mainScreen].scale;
    objc_setAssociatedObject(self, debug_colorSublayer, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debug_colorSublayer];
}

- (XYDebugCloneView *)debug_cloneView
{
    XYDebugCloneView *obj = objc_getAssociatedObject(self, DebugCloneView);
    if ([obj isKindOfClass:[XYDebugCloneView class]] && obj) {
        return obj;
    }
    obj = [XYDebugCloneView cloneWith:self];
    obj.debug_colorSublayer.frame = obj.bounds;
    [obj.layer addSublayer:obj.debug_colorSublayer];
    objc_setAssociatedObject(self, DebugCloneView, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debug_cloneView];
}

- (void)setDebug_hasStoreDebugColor:(BOOL)debug_hasStoreDebugColor
{
    objc_setAssociatedObject(self, DebugHasStoreUIViewBackColor, @(debug_hasStoreDebugColor), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)debug_hasStoreDebugColor
{
    id obj = objc_getAssociatedObject(self, DebugHasStoreUIViewBackColor);
    return [obj boolValue];
}

- (NSArray<UIView *> *)debug_recurrenceAllSubviews
{
    NSMutableArray <UIView *> *all = @[].mutableCopy;
    void (^getSubViewsBlock)(UIView *current) = ^(UIView *current){
        [all addObject:current];
        for (UIView *sub in current.subviews) {
            [all addObjectsFromArray:[sub debug_recurrenceAllSubviews]];
        }
    };
    getSubViewsBlock(self);
    return [NSArray arrayWithArray:all];
}

- (void)debug_resetView
{
	UIColor * debug_associatedColor = objc_getAssociatedObject(self, DebugStoreUIViewBackColor);
	objc_removeAssociatedObjects(debug_associatedColor);
	CALayer *debug_associatedLayer = objc_getAssociatedObject(self, debug_colorSublayer);
	objc_removeAssociatedObjects(debug_associatedLayer);
	XYDebugCloneView *debug_associatedView = objc_getAssociatedObject(self, DebugCloneView);
	objc_removeAssociatedObjects(debug_associatedView);
	NSNumber *debug_associatedBool = objc_getAssociatedObject(self, DebugHasStoreUIViewBackColor);
	objc_removeAssociatedObjects(debug_associatedBool);
}

@end


const static char * DebugStoreZPosition = "DebugStoreZPosition";
const static char * DebugStoreOrigin = "DebugStoreOrigin";

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

- (CGPoint)debug_oriPoint
{
    NSValue *obj = objc_getAssociatedObject(self, DebugStoreOrigin);
    if ([obj isKindOfClass:[NSValue class]]) {
        return [obj CGPointValue];
    }
    return CGPointZero;
}

- (void)setDebug_oriPoint:(CGPoint)debug_oriPoint
{
    objc_setAssociatedObject(self, DebugStoreOrigin, [NSValue valueWithCGPoint:debug_oriPoint], OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
