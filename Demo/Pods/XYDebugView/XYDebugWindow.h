//
//  XYDebugWindow.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugView.h"

@class XYDebugViewManager;
@interface XYDebugWindow : UIWindow

@property (nonatomic, weak) XYDebugViewManager *frameManager;
@property (nonatomic, weak) UIView *souceView;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) DebugSlider *slider;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray <CALayer *>* debugLayers;

@end
