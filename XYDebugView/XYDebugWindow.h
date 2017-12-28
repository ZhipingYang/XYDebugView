//
//  XYDebugWindow.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugCloneView.h"
#import "XYdebugConst.h"

NS_ASSUME_NONNULL_BEGIN

@class XYDebugWindow;
@protocol XYDebugWindowDelegate

- (void)debugWindowTopButtonClick:(XYDebugWindow *)window is3DDebugging:(BOOL)is3DDebugging;

@end

@interface XYDebugWindow : UIWindow

@property (nonatomic, weak) NSObject<XYDebugWindowDelegate> *delegate;
@property (nonatomic, weak) UIView *targetView;
@property (nonatomic) XYDebugStyle debugStyle;

@end


NS_ASSUME_NONNULL_END
