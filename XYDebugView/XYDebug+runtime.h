//
//  UIView+XYDebug.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugView.h"

@interface UIView (XYDebug)

@property (nonatomic, strong) UIColor *debugStoreOrginalColor;
@property (nonatomic, assign) BOOL hasStoreDebugColor;
@property (nonatomic, strong, readonly) CALayer *debugColorSublayer;
@property (nonatomic, strong, readonly) XYDebugCloneView *cloneView;
@property (nonatomic, copy, readonly) NSArray <UIView *> *debuRecurrenceAllSubviews;

@end

@interface CALayer (XYDebug)

@property (nonatomic, assign) CGFloat debug_zPostion;

@property (nonatomic, assign) CGPoint debugPoint;

- (void)zPositionAnimationFrom:(float)from to:(float)to duration:(NSTimeInterval)duration;

@end

