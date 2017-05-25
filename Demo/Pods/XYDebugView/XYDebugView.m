//
//  XYDebugCloneView.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugView.h"
#import "UIColor+XYRandom.h"

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
        self.backgroundColor = [UIColor randomLightColorWithAlpha:1];
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
    
    for (CALayer *sublayer in mArr) {
        CALayer *newSub = [[CALayer alloc] initWithLayer:sublayer];
        newSub.frame = sublayer.frame;
        [newLayer addSublayer:newSub];
    }
    [newLayer renderInContext:UIGraphicsGetCurrentContext()];
}
@end


@implementation DebugSlider
{
    CALayer *_colorLayer;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _colorLayer = [CALayer layer];
        _colorLayer.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.4].CGColor;
        [self.layer addSublayer:_colorLayer];
    }
    return self;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    _colorLayer.frame = CGRectMake(0, 0, self.bounds.size.width, point.y);
    float percent = point.y / self.frame.size.height;
    percent = percent<0 ? percent : (percent>1 ? 1:percent);
    !_touchMoveBlock ?: _touchMoveBlock(percent);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    _colorLayer.frame = CGRectZero;
    !_touchEndBlock ?: _touchEndBlock();
}

@end
