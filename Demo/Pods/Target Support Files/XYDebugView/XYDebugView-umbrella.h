#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "UIColor+XYRandom.h"
#import "XYDebug+runtime.h"
#import "XYDebugView.h"
#import "XYDebugViewManager.h"
#import "XYDebugWindow.h"

FOUNDATION_EXPORT double XYDebugViewVersionNumber;
FOUNDATION_EXPORT const unsigned char XYDebugViewVersionString[];

