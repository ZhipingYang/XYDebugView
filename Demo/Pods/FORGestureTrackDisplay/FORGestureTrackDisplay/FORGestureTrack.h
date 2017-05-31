//
//  FORGestureTrack.h
//  FORGestureTrackDisplayDemo
//
//  Created by Daniel on 31/05/2017.
//  Copyright © 2017 Daniel. All rights reserved.
//

#import "FORTrackGesture.h"

//@interface UIWindow (tracking)
//- (void)startTracking;
//@end


@interface FORGestureTrack : UIView <FORGestureDelegate>
@property (nonatomic) UIColor* dotColor;
@property (nonatomic) CGFloat dotWidth;
@end
