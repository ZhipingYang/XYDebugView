//
//  XYDebugWindow.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugWindow.h"
#import "XYDebugViewManager.h"
#import "UIView+XYDebug.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#endif

@implementation XYDebugWindow

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _button = [UIButton buttonWithType:UIButtonTypeCustom];
        [_button setTitle:@"tap statusbar to refresh debugging..." forState:UIControlStateNormal];
        _button.backgroundColor = [UIColor redColor];
        _button.frame = CGRectMake(0, 0, SCREEN_WIDTH, 20);
        _button.titleLabel.font = [UIFont systemFontOfSize:11];
        _button.layer.zPosition = MAXFLOAT;
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.layer.zPosition = -MAXFLOAT;
        _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH*2,SCREEN_HEIGHT*2);
        _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.hidden = YES;
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        _scrollView.layer.sublayerTransform = transform;
        
        _slider = [[DebugSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 40, 40, SCREEN_HEIGHT-40*2)];
        _slider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _slider.hidden = YES;
        
        typeof(self) weakSelf = self;
        _slider.touchMoveBlock = ^(float percent) {
            [weakSelf showDifferentLayers:percent];
        };
        _slider.touchEndBlock = ^{
            [weakSelf showAllLayer];
        };
        
        [self addSubview:_scrollView];
        [self addSubview:_button];
        [self addSubview:_slider];
        self.backgroundColor = [UIColor clearColor];
        self.debugLayers = @[].mutableCopy;
        self.layer.masksToBounds = YES;
    }
    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled==NO || self.hidden==YES || self.alpha<=0.01) {
        return nil;
    } else if (![self pointInside:point withEvent:event]) {
        return nil;
    } else if (_frameManager.isDebugging) {
        if (CGRectContainsPoint(_button.frame,point)) {
            return _button;
        } else if (CGRectContainsPoint(_slider.frame,point) && _souceView) {
            return _slider;
        } else if (CGRectContainsPoint(_scrollView.frame,point) && _souceView) {
            return _scrollView;
        }
        return nil;
    }
    return nil;
}

- (void)setSouceView:(UIView *)souceView
{
    _souceView = souceView;
    if (_souceView == nil) {
        [[self.debugLayers copy] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        self.scrollView.hidden = YES;
        self.slider.hidden = YES;
    } else {
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        [self scrollViewAddLayersInView:_souceView layerLevel:0 index:0];
        self.scrollView.hidden = NO;
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        self.slider.hidden = NO;
    }
}

- (void)scrollViewAddLayersInView:(UIView *)view layerLevel:(CGFloat)layerLevel index:(NSUInteger)index
{
    if ([view isKindOfClass:[UIView class]] && view) {
        if (view.superview) {
            UIView *cloneView = view.cloneView;
            cloneView.layer.zPosition = -600 + (layerLevel*80+index*8);
            cloneView.layer.masksToBounds = YES;
            
            CGRect frame = [view.superview convertRect:view.frame toView:_souceView];
            frame.origin = CGPointMake(CGRectGetMinX(frame)+SCREEN_WIDTH/2.f, CGRectGetMinY(frame)+SCREEN_HEIGHT/2.f);
            cloneView.layer.frame = frame;
            cloneView.layer.opacity = 0.8;
            [self.debugLayers addObject:cloneView.layer];
            [self.scrollView.layer addSublayer:cloneView.layer];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self scrollViewAddLayersInView:obj layerLevel:layerLevel+1 index:idx];
            }];
        });
    }
}

- (void)showDifferentLayers:(float)percent
{
    CGFloat positionMax = self.debugLayers.firstObject.zPosition;
    CGFloat positionMin = positionMax;
    for (CALayer *layer in self.debugLayers) {
        if (layer.zPosition >= positionMax) {
            positionMax = layer.zPosition;
        }
        if (layer.zPosition <= positionMin) {
            positionMin = layer.zPosition;
        }
    }
    // 分成20节,每节为5
    CGFloat gap = (positionMax - positionMin)/20.f;
    
    // 每节为5，计算当前处于那一节的layer层显示
    float num = ceil((percent * 100)/5.f);
    
    CGFloat upRange = positionMin + gap*num;
    CGFloat dowmRange = positionMin + gap*(num-1);
    
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = (layer.zPosition>upRange || layer.zPosition<dowmRange) ? 0.1:1;
    }
}

- (void)showAllLayer
{
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = 0.8;
    }
}


@end
