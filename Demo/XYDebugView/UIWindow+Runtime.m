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
#import "NSObject+Runtime.h"

@implementation UIWindow (Runtime)

//+ (void)load {
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        [self swizzleInstanceMethodWithOriginSel:@selector(makeKeyAndVisible) swizzledSel:@selector(xy_makeKeyAndVisible)];
//        [self swizzleInstanceMethodWithOriginSel:@selector(becomeKeyWindow) swizzledSel:@selector(xy_becomeKeyWindow)];
//        [self swizzleInstanceMethodWithOriginSel:@selector(makeKeyWindow) swizzledSel:@selector(xy_makeKeyWindow)];
//    });
//}

- (void)xy_makeKeyAndVisible
{
    [self xy_makeKeyAndVisible];
    [self startTrack];
}

- (void)xy_becomeKeyWindow
{
    [self xy_becomeKeyWindow];
    [self startTrack];
}

- (void)xy_makeKeyWindow
{
    [self xy_makeKeyWindow];
    [self startTrack];
}

- (void)startTrack
{
    FORGestureTrack* track = [[FORGestureTrack alloc] initWithFrame:self.window.bounds];
    track.dotWidth = 40;
    track.layer.zPosition = CGFLOAT_MAX;
    [self addSubview:track];
}

@end
