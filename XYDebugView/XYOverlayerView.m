//
//  XYOverlayerView.m
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYOverlayerView.h"
#import "XYDebugCategory.h"

@interface XYOverlayerView()<UIGestureRecognizerDelegate>

@property (nonatomic, getter=isShowing) BOOL showing;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topBarHeight;

@property (weak, nonatomic) IBOutlet UIView *line;

@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@end

@implementation XYOverlayerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_showing = NO;
		_panGesture.delegate = self;
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_topBarHeight.constant = [UIDevice isIPhoneX] ? 45:20;
	_line.layer.cornerRadius = CGRectGetHeight(_line.frame)/2.0;
	_line.clipsToBounds = YES;
	
	_filterButton.layer.cornerRadius = 22;
	_filterButton.clipsToBounds = YES;
	
	_resetButton.layer.cornerRadius = 22;
	_resetButton.clipsToBounds = YES;
}

- (void)setShowing:(BOOL)showing
{
	_showing = showing;
	[UIView animateWithDuration:0.2 animations:^{
		CGFloat height = [UIDevice isIPhoneX] ? 200	: 150;
		_bottomHeight.constant = _showing ? height:0;
		[self layoutIfNeeded];
	}];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
	UIView *hitView = [super hitTest:point withEvent:event];
	return hitView == self ? nil : hitView;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
	[super touchesEnded:touches withEvent:event];
	if (self.isShowing) {
		self.showing = NO;
	}
}

#pragma mark - actions


static CGPoint panBeginPoint;

- (IBAction)panGestureAction:(UIPanGestureRecognizer *)sender {
	CGPoint bottomPoint = [_panGesture locationInView:_bottomView];
	CGPoint point = [_panGesture locationInView:self];
	CGFloat height = [UIDevice isIPhoneX] ? 200	: 150;
	if (CGRectContainsPoint(_bottomView.bounds, bottomPoint) && _showing) {
		switch (sender.state) {
			case UIGestureRecognizerStateBegan: {
				panBeginPoint = point;
			}
				break;
			case UIGestureRecognizerStateChanged: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = MIN(MAX(height-y, 0), height);
			}
				break;
			case UIGestureRecognizerStateEnded: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = height-y;
				CGFloat speedY = [sender velocityInView:self].y;
				self.showing = speedY<=0 && y<=50;
			}
				break;
			case UIGestureRecognizerStateCancelled: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = height-y;
				CGFloat speedY = [sender velocityInView:self].y;
				self.showing = speedY<=0 && y<=50;
			}
				break;

			default:
				break;
		}
	}
}

// state
- (IBAction)debugStyleChanged:(UIButton *)sender {
	if ([self.delegate respondsToSelector:@selector(overlayViewDebugChanged:)]) {
		[self.delegate overlayViewDebugChanged:self];
	}
}

// buttons
- (IBAction)resetAction:(UIButton *)sender {
	if ([self.delegate respondsToSelector:@selector(overlayViewReseted:)]) {
		[self.delegate overlayViewReseted:self];
	}
}

- (IBAction)filterAction:(UIButton *)sender {
	if (!_showing) {
		self.showing = YES;
	}
}

// sliders
- (IBAction)distanceChanged:(UISlider *)sender {
	if ([self.delegate respondsToSelector:@selector(overlayView:distanceChanged:)]) {
		[self.delegate overlayView:self distanceChanged:sender.value];
	}
}
- (IBAction)showingLayerChanged:(UISlider *)sender {
	if ([self.delegate respondsToSelector:@selector(overlayView:showingLayerChanged:)]) {
		[self.delegate overlayView:self showingLayerChanged:sender.value];
	}
}
- (IBAction)m34Changed:(UISlider *)sender {
	if ([self.delegate respondsToSelector:@selector(overlayView:m34Changed:)]) {
		[self.delegate overlayView:self m34Changed:sender.value];
	}
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
	if (gestureRecognizer == _panGesture) {
		CGPoint v = [_panGesture velocityInView:self];
		return ABS(v.y) >= ABS(v.x);
	}
	return YES;
}

@end
