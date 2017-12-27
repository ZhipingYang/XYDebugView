//
//  XYOverlayerView.m
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYOverlayerView.h"
#import "XYDebugCategory.h"

@interface XYOverlayerView()

@property (nonatomic, getter=isShowing) BOOL showing;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomHeight;

@property (weak, nonatomic) IBOutlet UIView *line;

@property (weak, nonatomic) IBOutlet UIPanGestureRecognizer *panGesture;

@end

@implementation XYOverlayerView

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self) {
		_showing = NO;
	}
	return self;
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	_line.layer.cornerRadius = CGRectGetHeight(_line.frame)/2.0;
	_line.clipsToBounds = YES;
	
	_filterButton.layer.cornerRadius = 22;
	_filterButton.clipsToBounds = YES;
	
	_resetButton.layer.cornerRadius = 22;
	_resetButton.clipsToBounds = YES;
}

- (void)setShowing:(BOOL)showing
{
	if (showing == _showing) { return; }
	_showing = showing;
	[UIView animateWithDuration:0.2 animations:^{
		_bottomHeight.constant = _showing ? 150:0;
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
	if (CGRectContainsPoint(_bottomView.bounds, bottomPoint) && _showing) {
		switch (sender.state) {
			case UIGestureRecognizerStateBegan: {
				panBeginPoint = point;
			}
				break;
			case UIGestureRecognizerStateChanged: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = MIN(MAX(150-y, 0), 150);
			}
				break;
			case UIGestureRecognizerStateEnded: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = 150-y;
				CGFloat speedY = [sender velocityInView:self].y;
				if (speedY>0 || y>50) {
					self.showing = NO;
				} else {
					[UIView animateWithDuration:0.2 animations:^{
						_bottomHeight.constant = 150;
						[self layoutIfNeeded];
					}];
				}
			}
				break;
			case UIGestureRecognizerStateCancelled: {
				CGFloat y = point.y - panBeginPoint.y;
				_bottomHeight.constant = 150-y;
				CGFloat speedY = [sender velocityInView:self].y;
				if (speedY>0 || y>50) {
					self.showing = NO;
				} else {
					[UIView animateWithDuration:0.2 animations:^{
						_bottomHeight.constant = 150;
						[self layoutIfNeeded];
					}];
				}
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

@end
