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

static const CGFloat XYDebugDefaultDistancePercent = 0.5f;
static const CGFloat XYDebugDefaultPerspectivePercent = 1.0f;
static const NSInteger XYDebugDefaultFocusContextRange = 2;
static const CGFloat XYDebugDefaultFocusContextOpacity = 0.05f;

@interface XYDebugWindow ()<UIGestureRecognizerDelegate, XYOverlayerViewDelegate>
{
	CGPoint _panPoint;
	CATransform3D _sublayerTransform;
}
@property (nonatomic, strong) XYOverlayerView *overlayerView;

@property (nonatomic, strong) UIView *layerSourceView;

@property (nonatomic, strong) NSHashTable <CALayer *> *debugLayers;
@property (nonatomic, strong) NSHashTable <XYDebugCloneView *> *debugCloneViews;
@property (nonatomic, copy) NSArray<NSString *> *focusItems;
@property (nonatomic, assign) NSInteger focusedLayerIndex;

@property (nonatomic, strong) NSMutableSet<UIGestureRecognizer *> *multiTouchGestures;
@property (nonatomic, assign) XYDebugCloneTintMode layerTintMode;
@property (nonatomic, assign) NSInteger focusContextRange;
@property (nonatomic, assign) CGFloat focusContextOpacity;
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
    _layerTintMode = XYDebugCloneTintModeOff;
    _focusItems = @[];
    _focusedLayerIndex = 0;
    _focusContextRange = XYDebugDefaultFocusContextRange;
    _focusContextOpacity = XYDebugDefaultFocusContextOpacity;
    self.backgroundColor = [UIColor clearColor];
    self.debugLayers = [NSHashTable weakObjectsHashTable];
    self.debugCloneViews = [NSHashTable weakObjectsHashTable];
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

- (void)refreshOverlayState
{
    if (self.debugStyle == XYDebugStyle2D) {
        [self.overlayerView.quitButton setTitle:@"Clear 2D" forState:UIControlStateNormal];
        self.overlayerView.resetButton.hidden = YES;
        self.overlayerView.filterButton.hidden = YES;
        [self.overlayerView setControlsVisible:NO animated:NO];
        [self.overlayerView setFocusWheelHidden:YES];
        return;
    }

    BOOL is3DDebugging = (self.targetView != nil);
    [self.overlayerView.quitButton setTitle:@"Close 3D" forState:UIControlStateNormal];
    [self.overlayerView setTintMode:self.layerTintMode];
    [self.overlayerView setFocusContextRange:self.focusContextRange];
    [self.overlayerView setFocusContextOpacity:self.focusContextOpacity];
    [self.overlayerView setFocusItems:self.focusItems selectedIndex:self.focusedLayerIndex];
    [self.overlayerView setFocusWheelHidden:!is3DDebugging];
    self.overlayerView.resetButton.hidden = !is3DDebugging;
    self.overlayerView.filterButton.hidden = !is3DDebugging;

    if (!is3DDebugging) {
        [self.overlayerView setControlsVisible:NO animated:NO];
    }
}

- (void)setDebugStyle:(XYDebugStyle)debugStyle
{
	_debugStyle = debugStyle;
    [self refreshOverlayState];
}

- (void)setTargetView:(UIView *)targetView
{
	_targetView = targetView;

    [self setNeedsLayout];
    [self layoutIfNeeded];
	
	if (targetView == nil) {
        [[self.debugLayers allObjects] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        [self.debugLayers removeAllObjects];
        [self.debugCloneViews removeAllObjects];
        self.focusItems = @[];
        self.focusedLayerIndex = 0;
        [self.overlayerView setFocusItems:@[] selectedIndex:0];
        [self.overlayerView setControlsVisible:NO animated:NO];
			_layerSourceView.hidden = YES;
	} else {
			[[self.debugLayers allObjects] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
			[self.debugLayers removeAllObjects];
            [self.debugCloneViews removeAllObjects];
			[self scrollViewAddLayersInView:targetView];
			_layerSourceView.hidden = NO;
			[self recalculateLayerDepths];
            [self applyTintModeToCloneViews];
			
			_layerSourceView.layer.sublayerTransform = CATransform3DIdentity;
			[self resetLayerTransforms];
		}

    [self refreshOverlayState];
}

#pragma mark - private

- (void)scrollViewAddLayersInView:(UIView *)view
{
	if ([view isKindOfClass:[UIView class]] && view) {
	        NSArray<UIView *> *allSubviews = view.debug_recurrenceAllSubviews;
        NSMutableArray<NSString *> *focusItems = [NSMutableArray arrayWithObject:@"All Layers"];
	        UIView *rootView = allSubviews.firstObject;
	        CGSize containSize = self.layerSourceView.frame.size;
	        CGPoint offset = CGPointMake((containSize.width - rootView.bounds.size.width) / 2.0,
	                                     (containSize.height - rootView.bounds.size.height) / 2.0);
	        [allSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!obj.superview) {
                return;
	            }
	            XYDebugCloneView *cloneView = obj.debug_cloneView;
	            cloneView.debugTintMode = self.layerTintMode;
	            cloneView.layer.zPosition = 0;
            cloneView.layer.debug_orderIndex = (NSInteger)idx;
	            cloneView.layer.debug_zPostion = idx;
	            CGRect rect = [obj.superview convertRect:obj.frame toView:self.targetView];
	            cloneView.layer.frame = CGRectOffset(rect, offset.x, offset.y);
	            cloneView.layer.opacity = 1;
	            [self.debugLayers addObject:cloneView.layer];
	            [self.debugCloneViews addObject:cloneView];
            [focusItems addObject:[self focusTitleForView:obj atIndex:idx]];
	            [self.layerSourceView.layer addSublayer:cloneView.layer];
	        }];
        self.focusItems = focusItems.copy;
        self.focusedLayerIndex = 0;
        [self.overlayerView setFocusItems:self.focusItems selectedIndex:0];
		}
}

- (NSString *)focusTitleForView:(UIView *)view atIndex:(NSUInteger)index
{
    NSString *className = NSStringFromClass(view.class);
    NSString *detail = nil;

    if ([view isKindOfClass:[UILabel class]]) {
        detail = ((UILabel *)view).text;
    } else if ([view isKindOfClass:[UIButton class]]) {
        detail = [((UIButton *)view) titleForState:UIControlStateNormal];
    } else if ([view isKindOfClass:[UITextField class]]) {
        UITextField *textField = (UITextField *)view;
        detail = textField.text.length > 0 ? textField.text : textField.placeholder;
    } else if ([view isKindOfClass:[UITextView class]]) {
        detail = ((UITextView *)view).text;
    }

    detail = [[detail stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] copy];
    if (detail.length > 18) {
        detail = [[detail substringToIndex:18] stringByAppendingString:@"..."];
    }

    if (detail.length > 0) {
        return [NSString stringWithFormat:@"#%03lu %@  %@", (unsigned long)index, className, detail];
    }
    return [NSString stringWithFormat:@"#%03lu %@", (unsigned long)index, className];
}

- (void)applyTintModeToCloneViews
{
    for (XYDebugCloneView *cloneView in self.debugCloneViews) {
        cloneView.debugTintMode = self.layerTintMode;
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
    if (self.debugLayers.count == 0) {
        return;
    }

    NSInteger maximumOrderIndex = 0;
    for (CALayer *layer in self.debugLayers) {
        maximumOrderIndex = MAX(maximumOrderIndex, layer.debug_orderIndex);
    }

    CGFloat frontDepth = MIN(MAX((CGFloat)self.debugLayers.count * 10.0, 280.0), CGRectGetHeight(self.bounds) * 0.82);
    CGFloat rearDepth = -MIN(36.0, frontDepth * 0.08);
    CGFloat spacing = maximumOrderIndex > 0 ? frontDepth / maximumOrderIndex : 0;
    for (CALayer *layer in self.debugLayers) {
        layer.debug_zPostion = rearDepth + layer.debug_orderIndex * spacing;
    }
}

#pragma mark - actions

- (void)applyFocusedLayerIndex:(NSInteger)focusIndex updateOverlay:(BOOL)updateOverlay
{
    NSInteger maximumFocusIndex = MAX((NSInteger)self.focusItems.count - 1, 0);
    NSInteger clampedFocusIndex = MIN(MAX(focusIndex, 0), maximumFocusIndex);
    self.focusedLayerIndex = clampedFocusIndex;

    if (updateOverlay) {
        [self.overlayerView setFocusItems:self.focusItems selectedIndex:clampedFocusIndex];
    }

    if (clampedFocusIndex == 0) {
        [self showAllLayer];
        return;
    }

    NSInteger targetOrderIndex = clampedFocusIndex - 1;
    for (CALayer *layer in self.debugLayers) {
        NSInteger distance = labs(layer.debug_orderIndex - targetOrderIndex);
        CGFloat opacity = self.focusContextOpacity;
        if (distance == 0) {
            opacity = 1.0;
        } else if (distance <= self.focusContextRange) {
            CGFloat nearestOpacity = MAX(self.focusContextOpacity, 0.56);
            CGFloat furthestOpacity = MAX(self.focusContextOpacity, 0.14);
            CGFloat interpolation = self.focusContextRange > 1
            ? (CGFloat)(distance - 1) / (CGFloat)(self.focusContextRange - 1)
            : 0;
            opacity = nearestOpacity + (furthestOpacity - nearestOpacity) * interpolation;
        }
        layer.opacity = opacity;
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

- (CATransform3D)sceneTransformForPerspectivePercent:(CGFloat)percent
{
    CGFloat clampedPercent = MAX(percent, 0.05);
    CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.82, 0.82, 0.82);
    transform.m34 = -1.0 / ((CGRectGetHeight(self.bounds) * 1.35) / clampedPercent);
    return transform;
}

// 恢复默认
- (void)resetLayerTransforms
{
		self.layerTintMode = XYDebugCloneTintModeOff;
    self.focusContextRange = XYDebugDefaultFocusContextRange;
    self.focusContextOpacity = XYDebugDefaultFocusContextOpacity;
    [self.overlayerView setTintMode:self.layerTintMode];
    [self.overlayerView setFocusContextRange:self.focusContextRange];
    [self.overlayerView setFocusContextOpacity:self.focusContextOpacity];
		_overlayerView.distanceSlider.value = XYDebugDefaultDistancePercent;
		_overlayerView.m34Slider.value = XYDebugDefaultPerspectivePercent;
	    [_overlayerView refreshDisplayedValues];
	    [_overlayerView setControlsVisible:NO animated:NO];
    [self applyTintModeToCloneViews];
    [self applyFocusedLayerIndex:0 updateOverlay:YES];
		
		CATransform3D transform = [self sceneTransformForPerspectivePercent:_overlayerView.m34Slider.value];
		
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
 专注于指定的layer层级
 */
- (void)overlayView:(XYOverlayerView *)view focusIndexChanged:(NSInteger)focusIndex
{
    [self applyFocusedLayerIndex:focusIndex updateOverlay:NO];
}

/**
 修改 focus 时保留的上下文层数
 */
- (void)overlayView:(XYOverlayerView *)view focusContextRangeChanged:(NSInteger)range
{
    self.focusContextRange = range;
    [self applyFocusedLayerIndex:self.focusedLayerIndex updateOverlay:NO];
}

/**
 修改 focus 时远处层级的最小透明度
 */
- (void)overlayView:(XYOverlayerView *)view focusContextOpacityChanged:(CGFloat)opacity
{
    self.focusContextOpacity = opacity;
    [self applyFocusedLayerIndex:self.focusedLayerIndex updateOverlay:NO];
}

/**
 修改layer在3d下的透视效果
 */
- (void)overlayView:(XYOverlayerView *)view m34Changed:(CGFloat)percent
{
    _layerSourceView.layer.sublayerTransform = [self sceneTransformForPerspectivePercent:percent];
}

- (void)overlayView:(XYOverlayerView *)view tintModeChanged:(XYDebugCloneTintMode)mode
{
    self.layerTintMode = mode;
    [self applyTintModeToCloneViews];
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
	[self resetLayerTransforms];
}

@end
