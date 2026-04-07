//
//  XYDebugCloneView.h
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XYDebugCloneTintMode) {
    XYDebugCloneTintModeOff = 0,
    XYDebugCloneTintModeOutline,
    XYDebugCloneTintModeFilled,
};

@interface XYDebugCloneView : UIView

@property (nonatomic, assign) XYDebugCloneTintMode debugTintMode;

+ (XYDebugCloneView *)cloneWith:(UIView *)view;
- (void)refreshFromView:(UIView *)view;

@end
