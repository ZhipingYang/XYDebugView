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
        [self refreshFromView:srcView];
        self.backgroundColor = [UIColor debug_randomLightColorWithAlpha:1];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)refreshFromView:(UIView *)view
{
    self.srcView = view;
    self.bounds = (CGRect){CGPointZero, view.bounds.size};
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (!self.srcView) {
        return;
    }

    NSArray<CALayer *> *sourceSublayers = self.srcView.layer.sublayers ?: @[];
    NSSet<CALayer *> *subviewLayers = [NSSet setWithArray:[self.srcView.subviews valueForKey:@"layer"]];
		
    CALayer *newLayer = [CALayer layer];
    newLayer.contents = self.srcView.layer.contents;
    newLayer.frame = self.bounds;
	newLayer.contentsScale = self.srcView.layer.contentsScale;
	newLayer.contentsGravity = self.srcView.layer.contentsGravity;
    
    for (CALayer *sublayer in sourceSublayers) {
        if ([subviewLayers containsObject:sublayer]) {
            continue;
        }
        CALayer *newSub = [[CALayer alloc] initWithLayer:sublayer];
        newSub.frame = sublayer.frame;
        [newLayer addSublayer:newSub];
    }
    [newLayer renderInContext:UIGraphicsGetCurrentContext()];
}
@end
