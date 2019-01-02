//
//  XYdebugConst.h
//  XYDebugView
//
//  Created by XcodeYang on 27/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_OPTIONS(NSUInteger, XYDebugStyle) {
    XYDebugStyleNone = 0,
	XYDebugStyle2D = 1 << 0,    // inner red lines
	XYDebugStyle3D = 1 << 1     // random backcolor
};

