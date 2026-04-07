//
//  XYOverlayerView.h
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYDebugCloneView.h"

@class XYOverlayerView;
@protocol XYOverlayerViewDelegate<NSObject>

/**
 修改layer之间的距离
 */
- (void)overlayView:(XYOverlayerView *)view distanceChanged:(CGFloat)percent;

/**
 修改layer在3d下的透视效果
 */
- (void)overlayView:(XYOverlayerView *)view m34Changed:(CGFloat)percent;

/**
 修改 focus 时保留的上下文层数
 */
- (void)overlayView:(XYOverlayerView *)view focusContextRangeChanged:(NSInteger)range;

/**
 修改 focus 时远处层级的最小透明度
 */
- (void)overlayView:(XYOverlayerView *)view focusContextOpacityChanged:(CGFloat)opacity;

/**
 控制3d层是否显示调试颜色
 */
- (void)overlayView:(XYOverlayerView *)view tintModeChanged:(XYDebugCloneTintMode)mode;

/**
 专注于指定layer层级
 */
- (void)overlayView:(XYOverlayerView *)view focusIndexChanged:(NSInteger)focusIndex;

/**
 修改bug显示的阶段
 */
- (void)overlayViewDebugChanged:(XYOverlayerView *)view;

/**
 修改layer之间的距离
 */
- (void)overlayViewReseted:(XYOverlayerView *)view;

@end

@interface XYOverlayerView : UIView

@property (nonatomic, weak) id<XYOverlayerViewDelegate> delegate;

@property (nonatomic, strong, readonly) UISlider *distanceSlider;
@property (nonatomic, strong, readonly) UISlider *m34Slider;
@property (nonatomic, assign, readonly) XYDebugCloneTintMode tintMode;
@property (nonatomic, assign, readonly) NSInteger focusIndex;
@property (nonatomic, assign, readonly) NSInteger focusContextRange;
@property (nonatomic, assign, readonly) CGFloat focusContextOpacity;

/// bottom config view
@property (nonatomic, strong, readonly) UIVisualEffectView *bottomView;
/// quit trigger button
@property (nonatomic, strong, readonly) UIButton *quitButton;
/// reset to default button
@property (nonatomic, strong, readonly) UIButton *resetButton;
/// show config button
@property (nonatomic, strong, readonly) UIButton *filterButton;

- (void)setControlsVisible:(BOOL)visible animated:(BOOL)animated;
- (void)refreshDisplayedValues;
- (void)setTintMode:(XYDebugCloneTintMode)tintMode;
- (void)setFocusContextRange:(NSInteger)focusContextRange;
- (void)setFocusContextOpacity:(CGFloat)focusContextOpacity;
- (void)setFocusItems:(NSArray<NSString *> *)focusItems selectedIndex:(NSInteger)selectedIndex;
- (void)setFocusWheelHidden:(BOOL)hidden;

@end
