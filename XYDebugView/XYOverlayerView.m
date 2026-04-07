//
//  XYOverlayerView.m
//  XYDebugView
//
//  Created by XcodeYang on 22/12/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "XYOverlayerView.h"

@interface XYOverlayerView ()

@property (nonatomic, strong, readwrite) UISlider *distanceSlider;
@property (nonatomic, strong, readwrite) UISlider *rangeSlider;
@property (nonatomic, strong, readwrite) UISlider *m34Slider;
@property (nonatomic, strong, readwrite) UIVisualEffectView *bottomView;
@property (nonatomic, strong, readwrite) UIButton *quitButton;
@property (nonatomic, strong, readwrite) UIButton *resetButton;
@property (nonatomic, strong, readwrite) UIButton *filterButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *distanceTitleLabel;
@property (nonatomic, strong) UILabel *rangeTitleLabel;
@property (nonatomic, strong) UILabel *m34TitleLabel;
@property (nonatomic, strong) UILabel *distanceValueLabel;
@property (nonatomic, strong) UILabel *rangeValueLabel;
@property (nonatomic, strong) UILabel *m34ValueLabel;

@property (nonatomic, getter=isControlsVisible) BOOL controlsVisible;

@end

@implementation XYOverlayerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self xy_commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self xy_commonInit];
    }
    return self;
}

- (void)xy_commonInit
{
    self.backgroundColor = [UIColor clearColor];

    _quitButton = [self xy_makePillButtonWithTitle:@"Hide 3D"];
    [_quitButton addTarget:self action:@selector(quitDebug:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_quitButton];

    _resetButton = [self xy_makePillButtonWithTitle:@"Reset View"];
    [_resetButton addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resetButton];

    _filterButton = [self xy_makePillButtonWithTitle:@"Controls"];
    [_filterButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterButton];

    _bottomView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
    _bottomView.hidden = YES;
    _bottomView.alpha = 0;
    _bottomView.clipsToBounds = YES;
    _bottomView.layer.cornerRadius = 24;
    _bottomView.layer.borderWidth = 1;
    _bottomView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12].CGColor;
    [self addSubview:_bottomView];

    UIView *contentView = _bottomView.contentView;
    contentView.backgroundColor = [[UIColor colorWithWhite:0.08 alpha:1.0] colorWithAlphaComponent:0.22];

    _titleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]
                                       color:[UIColor whiteColor]
                                        text:@"3D Inspector"];
    [contentView addSubview:_titleLabel];

    _hintLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightRegular]
                                      color:[[UIColor whiteColor] colorWithAlphaComponent:0.72]
                                       text:@"1-finger rotate   2-finger move   pinch zoom"];
    [contentView addSubview:_hintLabel];

    _distanceTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                               color:[[UIColor whiteColor] colorWithAlphaComponent:0.72]
                                                text:@"Depth"];
    [contentView addSubview:_distanceTitleLabel];

    _rangeTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                            color:[[UIColor whiteColor] colorWithAlphaComponent:0.72]
                                             text:@"Layer Focus"];
    [contentView addSubview:_rangeTitleLabel];

    _m34TitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                          color:[[UIColor whiteColor] colorWithAlphaComponent:0.72]
                                           text:@"Perspective"];
    [contentView addSubview:_m34TitleLabel];

    _distanceValueLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
                                               color:[UIColor whiteColor]
                                                text:nil];
    _distanceValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_distanceValueLabel];

    _rangeValueLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
                                            color:[UIColor whiteColor]
                                             text:nil];
    _rangeValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_rangeValueLabel];

    _m34ValueLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
                                          color:[UIColor whiteColor]
                                           text:nil];
    _m34ValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_m34ValueLabel];

    _distanceSlider = [self xy_makeSliderWithValue:0.5 action:@selector(distanceChanged:)];
    [contentView addSubview:_distanceSlider];

    _rangeSlider = [self xy_makeSliderWithValue:0.5 action:@selector(showingLayerChanged:)];
    [contentView addSubview:_rangeSlider];

    _m34Slider = [self xy_makeSliderWithValue:1 action:@selector(m34Changed:)];
    [contentView addSubview:_m34Slider];

    [self xy_refreshButtonTitles];
    [self xy_updateSliderValueLabels];
}

- (UIButton *)xy_makePillButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [[UIColor colorWithWhite:0.08 alpha:1.0] colorWithAlphaComponent:0.78];
    button.layer.cornerRadius = 20;
    button.layer.borderWidth = 1;
    button.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.16].CGColor;
    button.titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (UILabel *)xy_makeLabelWithFont:(UIFont *)font color:(UIColor *)color text:(NSString *)text
{
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = color;
    label.text = text;
    label.numberOfLines = 1;
    return label;
}

- (UISlider *)xy_makeSliderWithValue:(float)value action:(SEL)action
{
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = 0;
    slider.maximumValue = 1;
    slider.value = value;
    slider.minimumTrackTintColor = [UIColor colorWithRed:0.40 green:0.71 blue:1.0 alpha:1.0];
    slider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.18];
    [slider addTarget:self action:action forControlEvents:UIControlEventValueChanged];
    return slider;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGFloat safeTop = 12;
    CGFloat safeBottom = 0;
    if (@available(iOS 11.0, *)) {
        safeTop += self.safeAreaInsets.top;
        safeBottom = self.safeAreaInsets.bottom;
    }

    CGFloat buttonHeight = 40;
    CGFloat sideInset = 16;
    CGFloat bottomInset = safeBottom + 16;
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - sideInset * 2;
    CGFloat panelWidth = MIN(availableWidth, 560);
    CGFloat panelX = (CGRectGetWidth(self.bounds) - panelWidth) / 2.0;
    CGFloat panelHeight = 188;
    CGFloat buttonY = CGRectGetHeight(self.bounds) - bottomInset - buttonHeight;

    CGSize quitSize = [self.quitButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat quitWidth = MAX(104, quitSize.width + 24);
    self.quitButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - sideInset - quitWidth, safeTop, quitWidth, buttonHeight);

    CGSize filterSize = [self.filterButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat filterWidth = MAX(104, filterSize.width + 24);
    self.filterButton.frame = CGRectMake(sideInset, buttonY, filterWidth, buttonHeight);

    CGSize resetSize = [self.resetButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat resetWidth = MAX(118, resetSize.width + 24);
    self.resetButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - sideInset - resetWidth, buttonY, resetWidth, buttonHeight);

    CGRect visiblePanelFrame = CGRectMake(panelX, buttonY - 12 - panelHeight, panelWidth, panelHeight);
    CGRect hiddenPanelFrame = visiblePanelFrame;
    hiddenPanelFrame.origin.y = CGRectGetHeight(self.bounds) + 16;
    self.bottomView.frame = self.isControlsVisible ? visiblePanelFrame : hiddenPanelFrame;
    self.bottomView.alpha = self.isControlsVisible ? 1 : 0;

    CGFloat contentInset = 18;
    CGFloat contentWidth = panelWidth - contentInset * 2;
    self.titleLabel.frame = CGRectMake(contentInset, 14, contentWidth, 24);
    self.hintLabel.frame = CGRectMake(contentInset, CGRectGetMaxY(self.titleLabel.frame) + 2, contentWidth, 18);

    [self xy_layoutRowWithTitleLabel:self.distanceTitleLabel
                          valueLabel:self.distanceValueLabel
                              slider:self.distanceSlider
                                   y:CGRectGetMaxY(self.hintLabel.frame) + 16
                          contentWidth:contentWidth];

    [self xy_layoutRowWithTitleLabel:self.rangeTitleLabel
                          valueLabel:self.rangeValueLabel
                              slider:self.rangeSlider
                                   y:CGRectGetMaxY(self.distanceSlider.frame) + 16
                          contentWidth:contentWidth];

    [self xy_layoutRowWithTitleLabel:self.m34TitleLabel
                          valueLabel:self.m34ValueLabel
                              slider:self.m34Slider
                                   y:CGRectGetMaxY(self.rangeSlider.frame) + 16
                          contentWidth:contentWidth];
}

- (void)xy_layoutRowWithTitleLabel:(UILabel *)titleLabel
                        valueLabel:(UILabel *)valueLabel
                            slider:(UISlider *)slider
                                 y:(CGFloat)y
                        contentWidth:(CGFloat)contentWidth
{
    CGFloat contentInset = 18;
    CGFloat titleWidth = 92;
    CGFloat valueWidth = 68;
    CGFloat sliderSpacing = 12;
    CGFloat sliderX = contentInset + titleWidth + sliderSpacing;
    CGFloat sliderWidth = contentWidth - titleWidth - valueWidth - sliderSpacing * 2;

    titleLabel.frame = CGRectMake(contentInset, y, titleWidth, 16);
    valueLabel.frame = CGRectMake(CGRectGetMaxX(titleLabel.frame) + sliderSpacing + sliderWidth + sliderSpacing, y, valueWidth, 16);
    slider.frame = CGRectMake(sliderX, y - 5, sliderWidth, 26);
}

- (void)setControlsVisible:(BOOL)visible animated:(BOOL)animated
{
    _controlsVisible = visible;
    [self xy_refreshButtonTitles];

    if (visible) {
        self.bottomView.hidden = NO;
    }

    void (^animations)(void) = ^{
        [self setNeedsLayout];
        [self layoutIfNeeded];
    };

    void (^completion)(BOOL) = ^(BOOL finished) {
        if (!visible) {
            self.bottomView.hidden = YES;
        }
    };

    if (animated) {
        [UIView animateWithDuration:0.24
                              delay:0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:animations
                         completion:completion];
    } else {
        animations();
        completion(YES);
    }
}

- (void)xy_refreshButtonTitles
{
    NSString *filterTitle = self.isControlsVisible ? @"Hide Controls" : @"Controls";
    [self.filterButton setTitle:filterTitle forState:UIControlStateNormal];
}

- (void)xy_updateSliderValueLabels
{
    self.distanceValueLabel.text = [NSString stringWithFormat:@"%.0f%%", self.distanceSlider.value * 200];
    self.rangeValueLabel.text = self.rangeSlider.value >= 0.99 ? @"All" : [NSString stringWithFormat:@"%.0f%%", self.rangeSlider.value * 100];
    self.m34ValueLabel.text = [NSString stringWithFormat:@"%.2fx", self.m34Slider.value];
}

- (void)refreshDisplayedValues
{
    [self xy_updateSliderValueLabels];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *hitView = [super hitTest:point withEvent:event];
    return hitView == self ? nil : hitView;
}

#pragma mark - Actions

- (void)quitDebug:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayViewDebugChanged:)]) {
        [self.delegate overlayViewDebugChanged:self];
    }
}

- (void)resetAction:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(overlayViewReseted:)]) {
        [self.delegate overlayViewReseted:self];
    }
}

- (void)filterAction:(UIButton *)sender
{
    [self setControlsVisible:!self.isControlsVisible animated:YES];
}

- (void)distanceChanged:(UISlider *)sender
{
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:distanceChanged:)]) {
        [self.delegate overlayView:self distanceChanged:sender.value];
    }
}

- (void)showingLayerChanged:(UISlider *)sender
{
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:showingLayerChanged:)]) {
        [self.delegate overlayView:self showingLayerChanged:sender.value];
    }
}

- (void)m34Changed:(UISlider *)sender
{
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:m34Changed:)]) {
        [self.delegate overlayView:self m34Changed:sender.value];
    }
}

@end
