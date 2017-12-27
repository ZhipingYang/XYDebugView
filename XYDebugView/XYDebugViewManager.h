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

/**
 开启debug功能，默认使用XYDebugStyle2D对keyWindow进行debug
 */
+ (void)showDebug;

/**
 默认debug对象是keyWindow

 @param debugStyle debug类型
 */
+ (void)showDebugWithStyle:(XYDebugStyle)debugStyle;

/**
 对指定view，采用指定的debug方式

 @param View 指定视图debug
 @param debugStyle debug类型
 */
+ (void)showDebugInView:(nullable UIView *)View withDebugStyle:(XYDebugStyle)debugStyle;

/**
 关闭debug功能
 */
+ (void)dismissDebugView;

/**
 是否开启debug功能，UI直观查看顶部红色按钮也是一样的

 @return 是否开启debugView
 */
+ (BOOL)isDebugging;

@end

NS_ASSUME_NONNULL_END
