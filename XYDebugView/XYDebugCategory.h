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

@property (nonatomic, readonly) CALayer *debug_colorSublayer;
@property (nonatomic, readonly) XYDebugCloneView *debug_cloneView;
@property (nonatomic, readonly) NSArray <UIView *> *debug_recurrenceAllSubviews;

- (void)debug_resetView;

@end



@interface CALayer (XYDebug)

@property (nonatomic) CGFloat debug_zPostion;

@property (nonatomic) CGPoint debug_oriPoint;

- (void)debug_zPositionAnimationFrom:(float)from to:(float)to duration:(NSTimeInterval)duration;

@end




@interface UIColor (XYDebug)

+ (UIColor *)debug_randomLightColorWithAlpha:(CGFloat)alpha;

+ (UIColor *)debug_randomDrakColorWithAlpha:(CGFloat)alpha;

@end

NS_ASSUME_NONNULL_END


@interface UIDevice (XYDebug)

+ (BOOL)isIPhoneX;

@end
