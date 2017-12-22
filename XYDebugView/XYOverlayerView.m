//
//  XYOverlayerView.m
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYOverlayerView.h"
#import "TTRangeSlider.h"

@interface XYOverlayerView()

@property (nonatomic, getter=isShowing) BOOL showing;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) UISlider *distanceSlider;
@property (nonatomic, strong) UISlider *m34Slider;
@property (nonatomic, strong) TTRangeSlider *rangeSlider;

@end

@implementation XYOverlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
	self = [super initWithFrame:frame];
	if (self) {
		_showing = NO;
		
		_bottomView = [UIView new];
		_bottomView.backgroundColor = [UIColor lightGrayColor];
		[self addSubview:_bottomView];
		
		_distanceSlider = [UISlider ]
	}
	return self;
}



@end
