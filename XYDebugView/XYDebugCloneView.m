//
//  XYDebugCloneView.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugCloneView.h"
#import "XYDebugCategory.h"

@interface XYDebugCloneView ()

@property(nonatomic, weak) UIView *srcView;

@end

@implementation XYDebugCloneView

+ (XYDebugCloneView *)cloneWith:(UIView *)view
{
    return [[XYDebugCloneView alloc] initWithCopyView:view];
}

- (instancetype)initWithCopyView:(UIView *)srcView
{
    self = [super initWithFrame:srcView.frame];
    if (self) {
        self.srcView = srcView;
        self.backgroundColor = [UIColor debug_randomLightColorWithAlpha:1];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    NSMutableArray *mArr = self.srcView.layer.sublayers.mutableCopy;
    for (UIView *subview in self.srcView.subviews) {
        if ([mArr containsObject:subview.layer]) {
            [mArr removeObject:subview.layer];
        }
	}
	
    CALayer *newLayer = [CALayer layer];
    newLayer.contents = self.srcView.layer.contents;
    newLayer.frame = self.srcView.layer.frame;
	newLayer.contentsScale = self.srcView.layer.contentsScale;
	newLayer.contentsGravity = self.srcView.layer.contentsGravity;
    
    for (CALayer *sublayer in mArr) {
        CALayer *newSub = [[CALayer alloc] initWithLayer:sublayer];
        newSub.frame = sublayer.frame;
        [newLayer addSublayer:newSub];
    }
    [newLayer renderInContext:UIGraphicsGetCurrentContext()];
}
@end
