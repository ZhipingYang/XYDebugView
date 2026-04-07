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
@property (nonatomic, strong) CALayer *highlightLayer;
@property (nonatomic, strong) UIColor *highlightColor;

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
        self.backgroundColor = UIColor.clearColor;
        self.contentMode = UIViewContentModeRedraw;
        self.opaque = NO;
        self.highlightColor = [UIColor debug_randomLightColorWithAlpha:1];
        self.debugTintMode = XYDebugCloneTintModeOff;
        [self xy_updateHighlightAppearance];
    }
    return self;
}

- (void)refreshFromView:(UIView *)view
{
    self.srcView = view;
    self.bounds = (CGRect){CGPointZero, view.bounds.size};
    [self xy_updateHighlightAppearance];
    [self setNeedsDisplay];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self xy_updateHighlightAppearance];
}

- (void)setDebugTintMode:(XYDebugCloneTintMode)debugTintMode
{
    _debugTintMode = debugTintMode;
    [self xy_updateHighlightAppearance];
}

- (CALayer *)highlightLayer
{
    if (_highlightLayer != nil) {
        return _highlightLayer;
    }

    _highlightLayer = [CALayer layer];
    _highlightLayer.cornerRadius = 2;
    _highlightLayer.masksToBounds = YES;
    [self.layer addSublayer:_highlightLayer];
    return _highlightLayer;
}

- (void)xy_updateHighlightAppearance
{
    CALayer *highlightLayer = self.highlightLayer;
    highlightLayer.frame = self.bounds;
    highlightLayer.cornerRadius = self.srcView.layer.cornerRadius;
    highlightLayer.hidden = (self.debugTintMode == XYDebugCloneTintModeOff);

    if (self.debugTintMode == XYDebugCloneTintModeOff) {
        highlightLayer.backgroundColor = nil;
        highlightLayer.borderColor = nil;
        highlightLayer.borderWidth = 0;
        return;
    }

    UIColor *baseColor = self.highlightColor ?: [UIColor debug_randomLightColorWithAlpha:1];
    self.highlightColor = baseColor;

    CGFloat scale = self.traitCollection.displayScale > 0 ? self.traitCollection.displayScale : 1.0;
    highlightLayer.backgroundColor = (self.debugTintMode == XYDebugCloneTintModeFilled)
    ? [baseColor colorWithAlphaComponent:0.20].CGColor
    : nil;
    highlightLayer.borderColor = [baseColor colorWithAlphaComponent:(self.debugTintMode == XYDebugCloneTintModeFilled ? 0.72 : 0.88)].CGColor;
    highlightLayer.borderWidth = 1.0 / scale;
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
    newLayer.backgroundColor = self.srcView.layer.backgroundColor;
    newLayer.cornerRadius = self.srcView.layer.cornerRadius;
    newLayer.masksToBounds = self.srcView.layer.masksToBounds;
    newLayer.borderColor = self.srcView.layer.borderColor;
    newLayer.borderWidth = self.srcView.layer.borderWidth;
    newLayer.opacity = self.srcView.layer.opacity;
    newLayer.shadowColor = self.srcView.layer.shadowColor;
    newLayer.shadowOpacity = self.srcView.layer.shadowOpacity;
    newLayer.shadowOffset = self.srcView.layer.shadowOffset;
    newLayer.shadowRadius = self.srcView.layer.shadowRadius;
    newLayer.contentsCenter = self.srcView.layer.contentsCenter;
	    
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
