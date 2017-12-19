//
//  XYDebugCloneView.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import <UIKit/UIKit.h>

@interface XYDebugCloneView : UIView

+ (XYDebugCloneView *)cloneWith:(UIView *)view;

@end


@interface DebugSlider : UIView

@property (nonatomic) float defalutPercent;

@property void (^touchMoveBlock)(float percent);

@property void (^touchEndBlock)(void);

@end
