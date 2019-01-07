//
//  XYDebugViewManager.h
//  QueryViolations
//
//  Created by XcodeYang on 02/05/2017.
//  Copyright © 2017 eclicks. All rights reserved.
//

#import "XYdebugConst.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYDebugViewManager : NSObject

@property (nonatomic, readonly) XYDebugStyle debugStyle;

@property (nonatomic, weak, readonly) UIView *debugView;

+ (XYDebugViewManager *)sharedInstance;

/**
 开启debug功能，默认使用XYDebugStyleIndex对keyWindow进行debug
 */
- (void)showDebug;

/**
 关闭debug功能
 */
- (void)closeDebug;

/**
 默认debug对象是keyWindow

 @param debugStyle debug类型
 */
- (void)showDebugStyle:(XYDebugStyle)debugStyle;

/**
 对指定view，采用指定的debug方式

 @param view 指定视图debug
 @param debugStyle debug类型
 */
- (void)showDebugView:(nullable UIView *)view withDebugStyle:(XYDebugStyle)debugStyle;

@end

NS_ASSUME_NONNULL_END
