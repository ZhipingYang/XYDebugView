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

@end
