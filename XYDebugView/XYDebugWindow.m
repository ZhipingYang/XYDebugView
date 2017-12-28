//
//  XYDebugWindow.m
//  Pods
//
//  Created by XcodeYang on 25/05/2017.
//
//

#import "XYDebugWindow.h"
#import "XYDebugViewManager.h"
#import "XYDebugCategory.h"
#import "XYOverlayerView.h"

#ifndef SCREEN_WIDTH
#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#endif

#ifndef SCREEN_HEIGHT
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height
#endif

@interface XYDebugWindow ()<UIGestureRecognizerDelegate, XYOverlayerViewDelegate>
{
	CGPoint _panPoint;
	CGPoint _doublePoint;
	CATransform3D _sublayerTransform;
}
@property (nonatomic, strong) XYOverlayerView *overlayerView;

@property (nonatomic, strong) UIView *layerSourceView;

@property (nonatomic, strong) NSHashTable <CALayer *> *debugLayers;

@property (nonatomic, strong) NSMutableSet *doubleTouchsGestures;
@end

@implementation XYDebugWindow

#pragma mark - life cycle

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_doubleTouchsGestures = [NSMutableSet set];
		self.backgroundColor = [UIColor clearColor];
		self.debugLayers = [NSHashTable weakObjectsHashTable];
		self.layer.masksToBounds = YES;

		CGFloat width = CGRectGetWidth(self.frame);
		CGFloat height = CGRectGetHeight(self.frame);
		CGFloat length = MAX(width, height);
		_layerSourceView = [[UIView alloc] initWithFrame:CGRectMake((width-length)/2.0, (height-length)/2.0, length, length)];
		_layerSourceView.layer.zPosition = -MAXFLOAT;
		_layerSourceView.backgroundColor = [UIColor darkGrayColor];
		_layerSourceView.hidden = YES;
		_layerSourceView.multipleTouchEnabled = YES;
		[self addSubview:_layerSourceView];
		
		_overlayerView = [[NSBundle bundleForClass:[XYOverlayerView class]] loadNibNamed:NSStringFromClass([XYOverlayerView class]) owner:nil options:nil].firstObject;
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
		
		self.layerSourceView.multipleTouchEnabled = YES;
		[_doubleTouchsGestures addObjectsFromArray:@[doublePan,rotate,pinch]];
	}
	return self;
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
	_overlayerView.resetButton.hidden = debugStyle == XYDebugStyle2D;
	_overlayerView.filterButton.hidden = debugStyle == XYDebugStyle2D;
	_overlayerView.bottomView.hidden = debugStyle == XYDebugStyle2D;
}

- (void)setTargetView:(UIView *)targetView
{
	_targetView = targetView;
	
	_overlayerView.filterButton.hidden = !targetView;
	_overlayerView.resetButton.hidden = !targetView;
	_overlayerView.bottomView.hidden = !targetView;
	
	if (targetView == nil) {
		_layerSourceView.hidden = YES;
	} else {
		[[self.debugLayers allObjects] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
		[self.debugLayers removeAllObjects];
		[self scrollViewAddLayersInView:targetView layerLevel:0 index:0];
		_layerSourceView.hidden = NO;
		[self reCalculateZPostion];
		
		_layerSourceView.layer.sublayerTransform = CATransform3DIdentity;
		[self recoverLayersTransform];
	}
}

#pragma mark - private

- (void)scrollViewAddLayersInView:(UIView *)view layerLevel:(CGFloat)layerLevel index:(NSUInteger)index
{
	if ([view isKindOfClass:[UIView class]] && view) {
		
//		if (view.superview) {
//			UIView *cloneView = view.debug_cloneView;
//			cloneView.layer.zPosition = 0;
//			cloneView.layer.debug_zPostion = layerLevel*20+index;
//			cloneView.layer.frame = [view.superview convertRect:view.frame toView:_targetView];
//			cloneView.layer.opacity = 1;
//			[self.debugLayers addObject:cloneView.layer];
//			[self.layerSourceView.layer addSublayer:cloneView.layer];
//		}
//		[view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//			[self scrollViewAddLayersInView:obj layerLevel:layerLevel+1 index:idx];
//		}];
		
		__block CGPoint offset = CGPointZero;
		[view.debug_recurrenceAllSubviews enumerateObjectsUsingBlock:^(UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
			if (idx==0) {
				CGSize layerSize = obj.debug_cloneView.layer.frame.size;
				CGSize containSize = _layerSourceView.frame.size;
				offset = CGPointMake((containSize.width-layerSize.width)/2.0, (containSize.height-layerSize.height)/2.0);
			}
			if (obj.superview) {
				UIView *cloneView = obj.debug_cloneView;
				cloneView.layer.zPosition = 0;
				cloneView.layer.debug_zPostion = idx;
				CGRect rect = [obj.superview convertRect:obj.frame toView:_targetView];
				cloneView.layer.frame = CGRectOffset(rect, offset.x, offset.y);
				cloneView.layer.opacity = 1;
				[self.debugLayers addObject:cloneView.layer];
				[self.layerSourceView.layer addSublayer:cloneView.layer];
			}
		}];
	}
}

- (void)reCalculateZPostion
{
	if (_debugLayers.count<=1) { return; }
	
	CGFloat positionMax = self.debugLayers.anyObject.debug_zPostion;
	CGFloat positionMin = positionMax;
	for (CALayer *layer in self.debugLayers) {
		if (layer.debug_zPostion >= positionMax) {
			positionMax = layer.debug_zPostion;
		}
		if (layer.debug_zPostion <= positionMin) {
			positionMin = layer.debug_zPostion;
		}
	}
	
	CGFloat defalutMin = -300;
	CGFloat defalutMax = 200;
	if (_debugLayers.count<50) {
		defalutMin = -100;
		defalutMax = 100;
	}
	CGFloat scale = (defalutMax-defalutMin)/(positionMax-positionMin);
	for (CALayer *layer in self.debugLayers) {
		layer.debug_zPostion = defalutMin + (layer.debug_zPostion - positionMin)*scale;
	}
}

#pragma mark - actions

- (void)showDifferentLayers:(float)percent
{
	CGFloat positionMax = self.debugLayers.anyObject.debug_zPostion;
	CGFloat positionMin = positionMax;
	for (CALayer *layer in self.debugLayers) {
		if (layer.debug_zPostion >= positionMax) {
			positionMax = layer.debug_zPostion;
		}
		if (layer.debug_zPostion <= positionMin) {
			positionMin = layer.debug_zPostion;
		}
	}
	// 分成_debugLayers.count节或20节
	float divisor = (float)(_debugLayers.count>0 ? _debugLayers.count:20);
	CGFloat gap = (positionMax - positionMin)/divisor;
	
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
		CGFloat newZPostion = 2 * layer.debug_zPostion * percent;
		layer.zPosition = newZPostion;
	}
}

// 恢复默认
- (void)recoverLayersTransform
{
	_overlayerView.distanceSlider.value = 0.5;
	_overlayerView.m34Slider.value = 1;
	
	CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.6, 0.6, 0.6);
	transform.m34 = -1.0 / SCREEN_HEIGHT;
	
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
			CGFloat angleX = (current.x - _panPoint.x) * M_PI / SCREEN_WIDTH;
			CGFloat angleY = (current.y - _panPoint.y) * M_PI / SCREEN_HEIGHT;
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
	return [_doubleTouchsGestures containsObject:gestureRecognizer] && [_doubleTouchsGestures containsObject:otherGestureRecognizer];
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
	CATransform3D transform = CATransform3DScale(CATransform3DIdentity, 0.6, 0.6, 0.6);
	transform.m34 = -1.0 / (SCREEN_HEIGHT/MAX(CGFLOAT_MIN, percent));
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
	[self recoverLayersTransform];
}

@end

