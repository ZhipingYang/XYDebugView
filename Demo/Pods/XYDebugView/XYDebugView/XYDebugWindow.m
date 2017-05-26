//
//  XYDebugWindow.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugWindow.h"
#import "XYDebugViewManager.h"
#import "XYDebug+runtime.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#endif

@interface XYDebugWindow ()

@property (nonatomic, strong) DebugSlider *layerSlider;

@property (nonatomic, strong) DebugSlider *distanceSlider;

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray <CALayer *>* debugLayers;

@end

@implementation XYDebugWindow

#pragma mark - life cycle

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
        
        _layerSlider = [[DebugSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 40, 30, SCREEN_HEIGHT-40*2)];
        _layerSlider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _layerSlider.hidden = YES;
        
        _distanceSlider = [[DebugSlider alloc] initWithFrame:CGRectMake(0, 40, 30, SCREEN_HEIGHT-40*2)];
        _distanceSlider.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
        _distanceSlider.hidden = YES;
        _distanceSlider.defalutPercent = 0.5;
        typeof(self) weakSelf = self;
        _layerSlider.touchMoveBlock = ^(float percent) {
            [weakSelf showDifferentLayers:percent];
        };
        _layerSlider.touchEndBlock = ^{
            [weakSelf showAllLayer];
        };
        _distanceSlider.touchMoveBlock = ^(float percent) {
            [weakSelf changeDistance:percent];
        };
        _distanceSlider.touchEndBlock = ^{
            [weakSelf recoverLayersDistance];
        };
        
        [self addSubview:_scrollView];
        [self addSubview:_button];
        [self addSubview:_layerSlider];
        [self addSubview:_distanceSlider];
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
        } else if (CGRectContainsPoint(_layerSlider.frame,point) && _souceView) {
            return _layerSlider;
        } else if (CGRectContainsPoint(_distanceSlider.frame,point) && _souceView) {
            return _distanceSlider;
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
        [[_debugLayers copy] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        _scrollView.hidden = YES;
        _layerSlider.hidden = YES;
        _distanceSlider.hidden = YES;
        
    } else {
        [self scrollViewAddLayersInView:_souceView layerLevel:0 index:0];
        _scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        _scrollView.hidden = NO;
        _layerSlider.hidden = NO;
        _distanceSlider.hidden = NO;
        [self recoverLayersDistance];
    }
}

#pragma mark - private

- (void)scrollViewAddLayersInView:(UIView *)view layerLevel:(CGFloat)layerLevel index:(NSUInteger)index
{
    if ([view isKindOfClass:[UIView class]] && view) {
        if (view.superview) {
            UIView *cloneView = view.cloneView;
            cloneView.layer.zPosition = 0;
            cloneView.layer.debug_zPostion = (layerLevel*80 + index*8) - 600;
            cloneView.layer.masksToBounds = YES;
            
            CGRect frame = [view.superview convertRect:view.frame toView:_souceView];
            frame.origin = CGPointMake(CGRectGetMinX(frame)+SCREEN_WIDTH/2.f, CGRectGetMinY(frame)+SCREEN_HEIGHT/2.f);
            cloneView.layer.frame = frame;
            cloneView.layer.opacity = 0.8;
            [self.debugLayers addObject:cloneView.layer];
            [self.scrollView.layer addSublayer:cloneView.layer];
        }
        [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self scrollViewAddLayersInView:obj layerLevel:layerLevel+1 index:idx];
        }];
    }
}

#pragma mark - actions

- (void)showDifferentLayers:(float)percent
{
    CGFloat positionMax = self.debugLayers.firstObject.debug_zPostion;
    CGFloat positionMin = positionMax;
    for (CALayer *layer in self.debugLayers) {
        if (layer.debug_zPostion >= positionMax) {
            positionMax = layer.debug_zPostion;
        }
        if (layer.debug_zPostion <= positionMin) {
            positionMin = layer.debug_zPostion;
        }
    }
    // 分成20节,每节为5
    CGFloat gap = (positionMax - positionMin)/20.f;
    
    // 每节为5，计算当前处于那一节的layer层显示
    float num = ceil((percent * 100)/5.f);
    
    CGFloat upRange = positionMin + gap*num;
    CGFloat dowmRange = positionMin + gap*(num-1);
    
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = (layer.debug_zPostion>upRange || layer.debug_zPostion<dowmRange) ? 0.1:1;
    }
}

- (void)showAllLayer
{
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = 0.8;
    }
}

- (void)changeDistance:(float)percent
{
    for (CALayer *layer in self.debugLayers) {
        [layer removeAnimationForKey:@"zPosition"];
        CGFloat newZPostion = 2 * layer.debug_zPostion * percent;
        layer.zPosition = newZPostion;
    }
}

- (void)recoverLayersDistance
{
    _distanceSlider.defalutPercent = 0.5;
    
    for (CALayer *layer in self.debugLayers) {
        [layer zPositionAnimationFrom:layer.zPosition to:layer.debug_zPostion duration:0.6];
    }
}

@end
