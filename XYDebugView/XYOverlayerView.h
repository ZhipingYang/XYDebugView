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

@property (weak, nonatomic) IBOutlet UISlider *distanceSlider;
@property (weak, nonatomic) IBOutlet UISlider *rangeSlider;
@property (weak, nonatomic) IBOutlet UISlider *m34Slider;

/// top trigger button
@property (weak, nonatomic) IBOutlet UIButton *statusBarButton;
/// bottom config view
@property (weak, nonatomic) IBOutlet UIVisualEffectView *bottomView;
/// reset to default button
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
/// show config button
@property (weak, nonatomic) IBOutlet UIButton *filterButton;

@end
