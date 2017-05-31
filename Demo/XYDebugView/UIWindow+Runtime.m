//
//  UIWindow+Runtime.m
//  XYDebugView
//
//  Created by Daniel on 01/06/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "UIWindow+Runtime.h"
#import "FORGestureTrack.h"
#import <objc/runtime.h>

@implementation UIWindow (Runtime)

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(makeKeyAndVisible);
        SEL swizzledSelector = @selector(xy_makeKeyAndVisible);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)xy_makeKeyAndVisible
{
    [self xy_makeKeyAndVisible];
    
    FORGestureTrack* track = [[FORGestureTrack alloc] initWithFrame:self.window.bounds];
    track.dotWidth = 40;
    track.layer.zPosition = CGFLOAT_MAX;
    [self addSubview:track];
}

@end
