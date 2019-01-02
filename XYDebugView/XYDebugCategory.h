//
//  UIView+XYDebug.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugCloneView.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIView (XYDebug)

/**
 red edge in 2d style
 */
@property (nonatomic, readonly) CALayer *debug_colorSublayer;

/**
 random backcolor in 3d style
 */
@property (nonatomic, readonly) XYDebugCloneView *debug_cloneView;

/**
 get all views drawed in current view
 */
@property (nonatomic, readonly) NSArray <UIView *> *debug_recurrenceAllSubviews;

/**
 release debugView reference
 */
- (void)debug_resetView;

@end



@interface CALayer (XYDebug)

/**
 The distance between the two layers
 */
@property (nonatomic) CGFloat debug_zPostion;

/**
 easy animation way
 */
- (void)debug_zPositionAnimationFrom:(float)from to:(float)to duration:(NSTimeInterval)duration;

@end




@interface UIColor (XYDebug)

/**
 random ligt color
 */
+ (UIColor *)debug_randomLightColorWithAlpha:(CGFloat)alpha;

/**
 random dark color
 */
+ (UIColor *)debug_randomDrakColorWithAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END


@interface UIDevice (XYDebug)

+ (BOOL)isNotchScreen;

@end
