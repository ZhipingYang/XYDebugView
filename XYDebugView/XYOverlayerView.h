//
//  XYOverlayerView.h
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import <UIKit/UIKit.h>

@class XYOverlayerView;
@protocol XYOverlayerViewDelegate<NSObject>

/**
 修改layer之间的距离
 */
- (void)overlayView:(XYOverlayerView *)view distanceChanged:(CGFloat)percent;

/**
 查看layer特定的层级
 */
- (void)overlayView:(XYOverlayerView *)view showingLayerChanged:(CGFloat)percent;

/**
 修改layer在3d下的透视效果
 */
- (void)overlayView:(XYOverlayerView *)view m34Changed:(CGFloat)percent;

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
@property (nonatomic, strong, readonly) UISlider *rangeSlider;
@property (nonatomic, strong, readonly) UISlider *m34Slider;

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

@end
