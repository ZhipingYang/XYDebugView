//
//  XYDebugWindow.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugWindow.h"
#import "XYDebugCategory.h"
#import "XYOverlayerView.h"

@interface XYDebugWindow ()<UIGestureRecognizerDelegate, XYOverlayerViewDelegate>
{
	CGPoint _panPoint;
	CATransform3D _sublayerTransform;
}
@property (nonatomic, strong) XYOverlayerView *overlayerView;

@property (nonatomic, strong) UIView *layerSourceView;

@property (nonatomic, strong) NSHashTable <CALayer *> *debugLayers;

@property (nonatomic, strong) NSMutableSet<UIGestureRecognizer *> *multiTouchGestures;
@end

@implementation XYDebugWindow

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
        [self xy_commonInit];
	}
	return self;
}

- (instancetype)initWithWindowScene:(UIWindowScene *)windowScene API_AVAILABLE(ios(13.0))
{
    self = [super initWithWindowScene:windowScene];
    if (self) {
        [self xy_commonInit];
    }
    return self;
}

- (void)xy_commonInit
{
    if (_overlayerView != nil) {
        return;
    }

    _multiTouchGestures = [NSMutableSet set];
    self.backgroundColor = [UIColor clearColor];
    self.debugLayers = [NSHashTable weakObjectsHashTable];
    self.layer.masksToBounds = YES;

    _layerSourceView = [[UIView alloc] initWithFrame:CGRectZero];
    _layerSourceView.layer.zPosition = -MAXFLOAT;
    _layerSourceView.backgroundColor = [UIColor darkGrayColor];
    _layerSourceView.hidden = YES;
    _layerSourceView.multipleTouchEnabled = YES;
    [self addSubview:_layerSourceView];

    _overlayerView = [[XYOverlayerView alloc] initWithFrame:self.bounds];
    _overlayerView.delegate = self;
    [self addSubview:_overlayerView];

    UIPanGestureRecognizer *singlePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(singlePan:)];

    UIPanGestureRecognizer *doublePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(doublePan:)];
    doublePan.minimumNumberOfTouches = 2;
    doublePan.delegate = self;
    doublePan.cancelsTouchesInView = NO;

    UIRotationGestureRecognizer *rotate = [[UIRotationGestureRecognizer alloc] initWithTarget:self action:@selector(rotateGes:)];
    rotate.delegate = self;
    rotate.cancelsTouchesInView = NO;

    UIPinchGestureRecognizer *pinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchGes:)];
    pinch.delegate = self;
    pinch.cancelsTouchesInView = NO;

    [self.layerSourceView addGestureRecognizer:singlePan];
    [self.layerSourceView addGestureRecognizer:doublePan];
    [self.layerSourceView addGestureRecognizer:rotate];
    [self.layerSourceView addGestureRecognizer:pinch];

    [_multiTouchGestures addObjectsFromArray:@[doublePan, rotate, pinch]];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	if (self.userInteractionEnabled==NO || self.hidden==YES || self.alpha<=0.01) {
		return nil;
	} else if (![self pointInside:point withEvent:event]) {
		return nil;
	}
	UIView *hitTest = [_overlayerView hitTest:point withEvent:event];
	if (hitTest == nil && _targetView != nil) {
		hitTest = _layerSourceView;
	}
	return hitTest;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	CGFloat width = CGRectGetWidth(self.frame);
	CGFloat height = CGRectGetHeight(self.frame);
	CGFloat length = MAX(width, height);
	_layerSourceView.frame = CGRectMake((width-length)/2.0, (height-length)/2.0, length, length);
	
	_overlayerView.frame = self.bounds;
}

- (void)setDebugStyle:(XYDebugStyle)debugStyle
{
	_debugStyle = debugStyle;
    if (debugStyle == XYDebugStyle2D) {
        [self.overlayerView.quitButton setTitle:@"Close 2D" forState:UIControlStateNormal];
        self.overlayerView.resetButton.hidden = YES;
        self.overlayerView.filterButton.hidden = YES;
        [self.overlayerView setControlsVisible:NO animated:NO];
    } else {
        [self.overlayerView.quitButton setTitle:(self.targetView ? @"Hide 3D" : @"Show 3D") forState:UIControlStateNormal];
        self.overlayerView.resetButton.hidden = (self.targetView == nil);
        self.overlayerView.filterButton.hidden = (self.targetView == nil);
        if (self.targetView == nil) {
            [self.overlayerView setControlsVisible:NO animated:NO];
        }
    }
}

- (void)setTargetView:(UIView *)targetView
{
	_targetView = targetView;

    [self setNeedsLayout];
    [self layoutIfNeeded];
	
    BOOL is3DDebugging = (targetView != nil);
    [self.overlayerView.quitButton setTitle:(is3DDebugging ? @"Hide 3D" : @"Show 3D") forState:UIControlStateNormal];
	_overlayerView.filterButton.hidden = !is3DDebugging;
	_overlayerView.resetButton.hidden = !is3DDebugging;
	
	if (targetView == nil) {
        [[self.debugLayers allObjects] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.debugLayers removeAllObjects];
        [self.overlayerView setControlsVisible:NO animated:NO];
		_layerSourceView.hidden = YES;
	} else {
		[[self.debugLayers allObjects] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
		[self.debugLayers removeAllObjects];
		[self scrollViewAddLayersInView:targetView];
		_layerSourceView.hidden = NO;
		[self recalculateLayerDepths];
		
		_layerSourceView.layer.sublayerTransform = CATransform3DIdentity;
		[self resetLayerTransforms];
	}
}

#pragma mark - private

- (void)scrollViewAddLayersInView:(UIView *)view
{
	if ([view isKindOfClass:[UIView class]] && view) {
        NSArray<UIView *> *allSubviews = view.debug_recurrenceAllSubviews;
        UIView *rootView = allSubviews.firstObject;
        CGSize containSize = self.layerSourceView.frame.size;
        CGPoint offset = CGPointMake((containSize.width - rootView.bounds.size.width) / 2.0,
                                     (containSize.height - rootView.bounds.size.height) / 2.0);
        [allSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.superview) {
                return;
            }
            XYDebugCloneView *cloneView = obj.debug_cloneView;
            cloneView.layer.zPosition = 0;
            cloneView.layer.debug_zPostion = idx;
            CGRect rect = [obj.superview convertRect:obj.frame toView:self.targetView];
            cloneView.layer.frame = CGRectOffset(rect, offset.x, offset.y);
            cloneView.layer.opacity = 1;
            [self.debugLayers addObject:cloneView.layer];
            [self.layerSourceView.layer addSublayer:cloneView.layer];
        }];
	}
}

- (BOOL)layerDepthBoundsMin:(CGFloat *)minPosition max:(CGFloat *)maxPosition
{
    if (self.debugLayers.count == 0) {
        return NO;
    }

    CGFloat positionMax = self.debugLayers.anyObject.debug_zPostion;
    CGFloat positionMin = positionMax;
    for (CALayer *layer in self.debugLayers) {
        positionMax = MAX(positionMax, layer.debug_zPostion);
        positionMin = MIN(positionMin, layer.debug_zPostion);
    }

    if (minPosition != NULL) {
        *minPosition = positionMin;
    }
    if (maxPosition != NULL) {
        *maxPosition = positionMax;
    }
    return YES;
}

- (void)recalculateLayerDepths
{
    CGFloat positionMin = 0;
    CGFloat positionMax = 0;
    if (![self layerDepthBoundsMin:&positionMin max:&positionMax] || positionMax <= positionMin) {
        return;
    }

    CGFloat minimumDepth = self.debugLayers.count < 50 ? -100 : -300;
    CGFloat maximumDepth = self.debugLayers.count < 50 ? 100 : 200;
    CGFloat scale = (maximumDepth - minimumDepth) / (positionMax - positionMin);
    for (CALayer *layer in self.debugLayers) {
        layer.debug_zPostion = minimumDepth + (layer.debug_zPostion - positionMin) * scale;
    }
}

#pragma mark - actions

- (void)showDifferentLayers:(float)percent
{
    CGFloat positionMin = 0;
    CGFloat positionMax = 0;
    if (![self layerDepthBoundsMin:&positionMin max:&positionMax]) {
        return;
    }

	float divisor = (float)(self.debugLayers.count > 0 ? self.debugLayers.count : 20);
	CGFloat gap = divisor > 0 ? (positionMax - positionMin) / divisor : 0;
	
	// 计算当前处于那一节的layer层显示
	float num = ceil(percent * divisor);
	
	CGFloat upRange = positionMin + gap*num;
	CGFloat dowmRange = positionMin + gap*(num-1);
	
	for (CALayer *layer in self.debugLayers) {
		layer.opacity = (layer.debug_zPostion>upRange || layer.debug_zPostion<dowmRange) ? 0.1:1;
	}
}

- (void)showAllLayer
{
	for (CALayer *layer in self.debugLayers) {
		layer.opacity = 1;
	}
}

- (void)changeDistance:(float)percent
{
	for (CALayer *layer in self.debugLayers) {
		[layer removeAnimationForKey:@"zPosition"];
		layer.zPosition = 2 * layer.debug_zPostion * percent;
	}
}

// 恢复默认
- (void)resetLayerTransforms
{
	_overlayerView.distanceSlider.value = 0.5;
    _overlayerView.rangeSlider.value = 1;
	_overlayerView.m34Slider.value = 1;
    [_overlayerView refreshDisplayedValues];
    [_overlayerView setControlsVisible:NO animated:NO];
	
	CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.6, 0.6, 0.6);
	transform.m34 = -1.0 / CGRectGetHeight(self.bounds);
	
	[_layerSourceView.layer removeAllAnimations];
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"sublayerTransform"];
	animation.fromValue = [NSValue valueWithCATransform3D:_layerSourceView.layer.sublayerTransform];
	animation.toValue = [NSValue valueWithCATransform3D:transform];
	animation.duration = 0.6;
	[_layerSourceView.layer addAnimation:animation forKey:@"SublayerTransformReset"];
	_layerSourceView.layer.sublayerTransform = transform;
	for (CALayer *layer in self.debugLayers) {
		[layer debug_zPositionAnimationFrom:layer.zPosition to:layer.debug_zPostion duration:0.6];
	}
}

- (void)singlePan:(UIPanGestureRecognizer *)pan
{
	switch (pan.state) {
		case UIGestureRecognizerStateBegan: {
			_panPoint = [pan locationInView:_layerSourceView];
			_sublayerTransform = _layerSourceView.layer.sublayerTransform;
		}
			break;
		case UIGestureRecognizerStateChanged: {
			CGPoint current = [pan locationInView:_layerSourceView];
			CGFloat angleX = (current.x - _panPoint.x) * M_PI / CGRectGetWidth(self.bounds);
			CGFloat angleY = (current.y - _panPoint.y) * M_PI / CGRectGetHeight(self.bounds);
			CATransform3D transform3D = CATransform3DRotate(_sublayerTransform, angleX, 0, 1, 0);
			_layerSourceView.layer.sublayerTransform = CATransform3DRotate(transform3D, -angleY, 1, 0, 0);
		}
			break;
		default:
			break;
	}
}

- (void)doublePan:(UIPanGestureRecognizer *)pan
{
	if (pan.numberOfTouches<=1) {
		return;
	}
	
	if (pan.state == UIGestureRecognizerStateBegan || pan.state == UIGestureRecognizerStateChanged) {
		CGPoint point = [pan translationInView:_layerSourceView];
		_layerSourceView.layer.sublayerTransform = CATransform3DTranslate(_layerSourceView.layer.sublayerTransform, point.x, point.y, 0);
		[pan setTranslation:CGPointZero inView:_layerSourceView];
	}
}

- (void)rotateGes:(UIRotationGestureRecognizer *)rotate
{
	_layerSourceView.layer.sublayerTransform = CATransform3DRotate(_layerSourceView.layer.sublayerTransform, rotate.rotation, 0, 0, 1);
	[rotate setRotation:0];
}

- (void)pinchGes:(UIPinchGestureRecognizer *)pinch
{
	_layerSourceView.layer.sublayerTransform = CATransform3DScale(_layerSourceView.layer.sublayerTransform, pinch.scale, pinch.scale, pinch.scale);
	[pinch setScale:1];
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
	return [self.multiTouchGestures containsObject:gestureRecognizer] && [self.multiTouchGestures containsObject:otherGestureRecognizer];
}


#pragma mark - XYOverlayerViewDelegate
/**
 修改layer之间的距离
 */
- (void)overlayView:(XYOverlayerView *)view distanceChanged:(CGFloat)percent
{
	[self changeDistance:percent];
}

/**
 查看layer特定的层级
 */
- (void)overlayView:(XYOverlayerView *)view showingLayerChanged:(CGFloat)percent
{
	[self showDifferentLayers:percent];
}

/**
 修改layer在3d下的透视效果
 */
- (void)overlayView:(XYOverlayerView *)view m34Changed:(CGFloat)percent
{
    CGFloat clampedPercent = MAX(percent, 0.05);
	CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.6, 0.6, 0.6);
	transform.m34 = -1.0 / (CGRectGetHeight(self.bounds) / clampedPercent);
	_layerSourceView.layer.sublayerTransform = transform;
}

/**
 修改bug显示的阶段
 */
- (void)overlayViewDebugChanged:(XYOverlayerView *)view
{
	if ([self.delegate respondsToSelector:@selector(debugWindowTopButtonClick:is3DDebugging:)]) {
		[self.delegate debugWindowTopButtonClick:self is3DDebugging:_targetView!=nil];
	}
}

/**
 修改layer之间的距离
 */
- (void)overlayViewReseted:(XYOverlayerView *)view
{
	[self showAllLayer];
	[self resetLayerTransforms];
}

@end
