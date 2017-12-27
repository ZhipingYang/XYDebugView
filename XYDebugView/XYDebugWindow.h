//
//  XYDebugWindow.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugView.h"
#import "XYOverlayerView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM (NSUInteger, DebugViewState) {
	DebugViewStateNone  = 0,
	DebugViewState2D    = 1 << 0,
	DebugViewState3D    = 1 << 1
};

@class XYDebugViewManager;
@class XYDebugWindow;
@protocol XYDebugWindowDelegate

- (void)xy_window:(XYDebugWindow *)window changeState:(DebugViewState)state;

@end

@interface XYDebugWindow : UIWindow

@property (nonatomic, weak) id<XYDebugWindowDelegate> delegate;
@property (nonatomic, weak) UIView *souceView;
@property (nonatomic, strong) XYOverlayerView *overlayerView;

@end


NS_ASSUME_NONNULL_END
