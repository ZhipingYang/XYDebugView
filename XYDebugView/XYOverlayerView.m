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
@property (nonatomic, strong, readwrite) UISlider *m34Slider;
@property (nonatomic, assign, readwrite) XYDebugCloneTintMode tintMode;
@property (nonatomic, assign, readwrite) NSInteger focusIndex;
@property (nonatomic, assign, readwrite) NSInteger focusContextRange;
@property (nonatomic, assign, readwrite) CGFloat focusContextOpacity;
@property (nonatomic, strong, readwrite) UIVisualEffectView *bottomView;
@property (nonatomic, strong, readwrite) UIButton *quitButton;
@property (nonatomic, strong, readwrite) UIButton *resetButton;
@property (nonatomic, strong, readwrite) UIButton *filterButton;

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UILabel *tintTitleLabel;
@property (nonatomic, strong) UILabel *focusRangeTitleLabel;
@property (nonatomic, strong) UILabel *focusFadeTitleLabel;
@property (nonatomic, strong) UILabel *distanceTitleLabel;
@property (nonatomic, strong) UILabel *m34TitleLabel;
@property (nonatomic, strong) UILabel *focusRangeValueLabel;
@property (nonatomic, strong) UILabel *focusFadeValueLabel;
@property (nonatomic, strong) UILabel *distanceValueLabel;
@property (nonatomic, strong) UILabel *m34ValueLabel;
@property (nonatomic, strong) UISegmentedControl *tintModeControl;
@property (nonatomic, strong) UISlider *focusRangeSlider;
@property (nonatomic, strong) UISlider *focusFadeSlider;
@property (nonatomic, strong) UIView *headerDividerView;
@property (nonatomic, strong) UIView *slidersDividerView;

@property (nonatomic, strong) UIVisualEffectView *focusWheelView;
@property (nonatomic, strong) UILabel *focusWheelTitleLabel;
@property (nonatomic, strong) UILabel *focusDetailLabel;
@property (nonatomic, strong) UIView *focusSpineView;
@property (nonatomic, strong) UIView *focusSelectionView;
@property (nonatomic, strong) NSArray<UIView *> *focusTickViews;
@property (nonatomic, copy) NSArray<NSString *> *focusItems;
@property (nonatomic) BOOL focusWheelHidden;
@property (nonatomic) NSInteger focusPanStartIndex;
@property (nonatomic) CGFloat focusTouchStartY;
@property (nonatomic) BOOL focusExpanded;
@property (nonatomic, copy) dispatch_block_t pendingFocusResetBlock;

@property (nonatomic, getter=isControlsVisible) BOOL controlsVisible;

@end

@implementation XYOverlayerView

- (UIColor *)xy_accentColor
{
    return [UIColor colorWithRed:0.44 green:0.76 blue:1.0 alpha:1.0];
}

- (UIColor *)xy_primaryTextColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.94];
}

- (UIColor *)xy_secondaryTextColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.62];
}

- (UIColor *)xy_surfaceColor
{
    return [[UIColor colorWithWhite:0.04 alpha:1.0] colorWithAlphaComponent:0.68];
}

- (UIColor *)xy_surfaceBorderColor
{
    return [[UIColor whiteColor] colorWithAlphaComponent:0.10];
}

- (CGFloat)xy_focusTickSpacing
{
    return self.focusExpanded ? 16.0 : 10.0;
}

- (CGRect)xy_focusInteractionFrame
{
    if (self.focusWheelView.hidden) {
        return CGRectNull;
    }

    CGFloat extraLeftInset = self.focusExpanded ? 20.0 : 26.0;
    CGFloat extraVerticalInset = self.focusExpanded ? 12.0 : 16.0;
    return CGRectInset(CGRectMake(CGRectGetMinX(self.focusWheelView.frame) - extraLeftInset,
                                  CGRectGetMinY(self.focusWheelView.frame),
                                  CGRectGetWidth(self.focusWheelView.frame) + extraLeftInset,
                                  CGRectGetHeight(self.focusWheelView.frame)),
                       0,
                       -extraVerticalInset);
}

- (UIBlurEffect *)xy_panelBlurEffect
{
    if (@available(iOS 13.0, *)) {
        return [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemChromeMaterialDark];
    }
    return [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
}

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

    _quitButton = [self xy_makePillButtonWithTitle:@"Close 3D"];
    [self xy_applyButtonAppearance:_quitButton emphasized:YES];
    [_quitButton addTarget:self action:@selector(quitDebug:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_quitButton];

    _resetButton = [self xy_makePillButtonWithTitle:@"Reset View"];
    [self xy_applyButtonAppearance:_resetButton emphasized:NO];
    [_resetButton addTarget:self action:@selector(resetAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_resetButton];

    _filterButton = [self xy_makePillButtonWithTitle:@"Controls"];
    [self xy_applyButtonAppearance:_filterButton emphasized:NO];
    [_filterButton addTarget:self action:@selector(filterAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_filterButton];

    _bottomView = [self xy_makeFloatingPanelWithCornerRadius:24];
    _bottomView.hidden = YES;
    _bottomView.alpha = 0;
    [self addSubview:_bottomView];

    UIView *contentView = _bottomView.contentView;

    _titleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:17 weight:UIFontWeightSemibold]
                                       color:[self xy_primaryTextColor]
                                        text:@"3D Inspector"];
    [contentView addSubview:_titleLabel];

    _hintLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:11 weight:UIFontWeightRegular]
                                      color:[self xy_secondaryTextColor]
                                       text:@"Rotate   Pan   Zoom"];
    [contentView addSubview:_hintLabel];

    _headerDividerView = [self xy_makeDivider];
    [contentView addSubview:_headerDividerView];

    _tintTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                           color:[self xy_secondaryTextColor]
                                            text:@"Layer Coloring"];
    [contentView addSubview:_tintTitleLabel];

    _focusRangeTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                                 color:[self xy_secondaryTextColor]
                                                  text:@"Focus Range"];
    [contentView addSubview:_focusRangeTitleLabel];

    _focusFadeTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                                color:[self xy_secondaryTextColor]
                                                 text:@"Context Fade"];
    [contentView addSubview:_focusFadeTitleLabel];

    _distanceTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                               color:[self xy_secondaryTextColor]
                                                text:@"Depth Spread"];
    [contentView addSubview:_distanceTitleLabel];

    _m34TitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium]
                                          color:[self xy_secondaryTextColor]
                                           text:@"Camera"];
    [contentView addSubview:_m34TitleLabel];

    _distanceValueLabel = [self xy_makeLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold]
                                               color:[self xy_primaryTextColor]
                                                text:nil];
    _distanceValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_distanceValueLabel];

    _focusRangeValueLabel = [self xy_makeLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold]
                                                 color:[self xy_primaryTextColor]
                                                  text:nil];
    _focusRangeValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_focusRangeValueLabel];

    _focusFadeValueLabel = [self xy_makeLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold]
                                                color:[self xy_primaryTextColor]
                                                 text:nil];
    _focusFadeValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_focusFadeValueLabel];

    _m34ValueLabel = [self xy_makeLabelWithFont:[UIFont monospacedDigitSystemFontOfSize:12 weight:UIFontWeightSemibold]
                                          color:[self xy_primaryTextColor]
                                           text:nil];
    _m34ValueLabel.textAlignment = NSTextAlignmentRight;
    [contentView addSubview:_m34ValueLabel];

    _focusRangeSlider = [self xy_makeSliderWithMinimumValue:0 maximumValue:4 value:2 action:@selector(focusRangeChanged:)];
    [contentView addSubview:_focusRangeSlider];

    _focusFadeSlider = [self xy_makeSliderWithMinimumValue:0 maximumValue:0.24 value:0.05 action:@selector(focusFadeChanged:)];
    [contentView addSubview:_focusFadeSlider];

    _distanceSlider = [self xy_makeSliderWithValue:0.5 action:@selector(distanceChanged:)];
    [contentView addSubview:_distanceSlider];

    _m34Slider = [self xy_makeSliderWithValue:1 action:@selector(m34Changed:)];
    [contentView addSubview:_m34Slider];

    _tintModeControl = [[UISegmentedControl alloc] initWithItems:@[@"Off", @"Outline", @"Filled"]];
    _tintModeControl.selectedSegmentIndex = XYDebugCloneTintModeOff;
    _tintModeControl.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.07];
    _tintModeControl.tintColor = [self xy_accentColor];
    [_tintModeControl setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [[UIColor whiteColor] colorWithAlphaComponent:0.78],
        NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
    } forState:UIControlStateNormal];
    if (@available(iOS 13.0, *)) {
        _tintModeControl.selectedSegmentTintColor = [self xy_accentColor];
        [_tintModeControl setTitleTextAttributes:@{
            NSForegroundColorAttributeName: [UIColor colorWithWhite:0.07 alpha:1.0],
            NSFontAttributeName: [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold]
        } forState:UIControlStateSelected];
    }
    [_tintModeControl addTarget:self action:@selector(tintModeChanged:) forControlEvents:UIControlEventValueChanged];
    [contentView addSubview:_tintModeControl];

    _slidersDividerView = [self xy_makeDivider];
    [contentView addSubview:_slidersDividerView];

    _focusWheelView = [self xy_makeFloatingPanelWithCornerRadius:22];
    _focusWheelView.effect = nil;
    _focusWheelView.contentView.backgroundColor = [UIColor colorWithWhite:0.03 alpha:0.88];
    _focusWheelView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.12].CGColor;
    _focusWheelView.hidden = YES;
    [self addSubview:_focusWheelView];

    UIView *focusContentView = _focusWheelView.contentView;
    _focusWheelTitleLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:10 weight:UIFontWeightSemibold]
                                                 color:[[UIColor whiteColor] colorWithAlphaComponent:0.22]
                                                  text:@"Layer Focus"];
    _focusWheelTitleLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:_focusWheelTitleLabel];

    _focusDetailLabel = [self xy_makeLabelWithFont:[UIFont systemFontOfSize:11 weight:UIFontWeightSemibold]
                                             color:[[UIColor whiteColor] colorWithAlphaComponent:0.36]
                                              text:@"All Layers"];
    _focusDetailLabel.numberOfLines = 2;
    _focusDetailLabel.textAlignment = NSTextAlignmentRight;
    _focusDetailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:_focusDetailLabel];

    _focusSpineView = [[UIView alloc] init];
    _focusSpineView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.10];
    _focusSpineView.layer.cornerRadius = 1;
    [focusContentView addSubview:_focusSpineView];

    _focusSelectionView = [[UIView alloc] init];
    _focusSelectionView.backgroundColor = [self xy_accentColor];
    _focusSelectionView.layer.cornerRadius = 1.5;
    _focusSelectionView.layer.shadowColor = [self xy_accentColor].CGColor;
    _focusSelectionView.layer.shadowOpacity = 0.28;
    _focusSelectionView.layer.shadowRadius = 8;
    _focusSelectionView.layer.shadowOffset = CGSizeZero;
    [focusContentView addSubview:_focusSelectionView];

    NSMutableArray<UIView *> *ticks = [NSMutableArray array];
    for (NSInteger index = 0; index < 15; index++) {
        UIView *tickView = [[UIView alloc] init];
        tickView.backgroundColor = [UIColor whiteColor];
        tickView.layer.cornerRadius = 1;
        [focusContentView addSubview:tickView];
        [ticks addObject:tickView];
    }
    self.focusTickViews = ticks.copy;

    UILongPressGestureRecognizer *focusPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(focusPress:)];
    focusPress.minimumPressDuration = 0;
    focusPress.allowableMovement = CGFLOAT_MAX;
    [_focusWheelView addGestureRecognizer:focusPress];

    self.focusItems = @[];
    [self xy_refreshButtonTitles];
    [self setTintMode:XYDebugCloneTintModeOff];
    [self setFocusContextRange:2];
    [self setFocusContextOpacity:0.05];
    [self xy_updateSliderValueLabels];
    [self setFocusItems:@[] selectedIndex:0];
    [self setFocusWheelHidden:YES];
}

- (UIVisualEffectView *)xy_makeFloatingPanelWithCornerRadius:(CGFloat)cornerRadius
{
    UIVisualEffectView *panel = [[UIVisualEffectView alloc] initWithEffect:[self xy_panelBlurEffect]];
    panel.clipsToBounds = YES;
    panel.layer.cornerRadius = cornerRadius;
    panel.layer.borderWidth = 0.8;
    panel.layer.borderColor = [self xy_surfaceBorderColor].CGColor;
    panel.contentView.backgroundColor = [[UIColor colorWithWhite:0.03 alpha:1.0] colorWithAlphaComponent:0.18];
    return panel;
}

- (UIView *)xy_makeDivider
{
    UIView *divider = [[UIView alloc] init];
    divider.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
    divider.layer.cornerRadius = 0.5;
    return divider;
}

- (UIButton *)xy_makePillButtonWithTitle:(NSString *)title
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [self xy_surfaceColor];
    button.layer.cornerRadius = 21;
    button.layer.borderWidth = 0.8;
    button.layer.borderColor = [self xy_surfaceBorderColor].CGColor;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.22;
    button.layer.shadowRadius = 12;
    button.layer.shadowOffset = CGSizeMake(0, 6);
    button.titleLabel.font = [UIFont systemFontOfSize:13.5 weight:UIFontWeightSemibold];
    [button setTitleColor:[self xy_primaryTextColor] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 16, 0, 16);
    [button setTitle:title forState:UIControlStateNormal];
    return button;
}

- (void)xy_applyButtonAppearance:(UIButton *)button emphasized:(BOOL)emphasized
{
    button.backgroundColor = emphasized
    ? [[UIColor colorWithRed:0.08 green:0.11 blue:0.15 alpha:1.0] colorWithAlphaComponent:0.88]
    : [self xy_surfaceColor];
    button.layer.borderColor = (emphasized
                                ? [[self xy_accentColor] colorWithAlphaComponent:0.22]
                                : [self xy_surfaceBorderColor]).CGColor;
    button.layer.shadowOpacity = emphasized ? 0.30 : 0.22;
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
    return [self xy_makeSliderWithMinimumValue:0 maximumValue:1 value:value action:action];
}

- (UISlider *)xy_makeSliderWithMinimumValue:(float)minimumValue
                               maximumValue:(float)maximumValue
                                      value:(float)value
                                     action:(SEL)action
{
    UISlider *slider = [[UISlider alloc] init];
    slider.minimumValue = minimumValue;
    slider.maximumValue = maximumValue;
    slider.value = value;
    slider.minimumTrackTintColor = [self xy_accentColor];
    slider.maximumTrackTintColor = [[UIColor whiteColor] colorWithAlphaComponent:0.14];
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

    CGFloat buttonHeight = 42;
    CGFloat sideInset = 18;
    CGFloat bottomInset = safeBottom + 18;
    CGFloat availableWidth = CGRectGetWidth(self.bounds) - sideInset * 2;
    CGFloat panelWidth = MIN(availableWidth, 500);
    CGFloat panelX = (CGRectGetWidth(self.bounds) - panelWidth) / 2.0;
    CGFloat panelHeight = 304;
    CGFloat buttonY = CGRectGetHeight(self.bounds) - bottomInset - buttonHeight;

    CGSize quitSize = [self.quitButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat quitWidth = MAX(112, quitSize.width + 24);
    self.quitButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - sideInset - quitWidth, safeTop, quitWidth, buttonHeight);

    CGSize filterSize = [self.filterButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat filterWidth = MAX(104, filterSize.width + 24);
    self.filterButton.frame = CGRectMake(sideInset, buttonY, filterWidth, buttonHeight);

    CGSize resetSize = [self.resetButton sizeThatFits:CGSizeMake(CGFLOAT_MAX, buttonHeight)];
    CGFloat resetWidth = MAX(118, resetSize.width + 24);
    self.resetButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - sideInset - resetWidth, buttonY, resetWidth, buttonHeight);

    CGRect visiblePanelFrame = CGRectMake(panelX, buttonY - 14 - panelHeight, panelWidth, panelHeight);
    CGRect hiddenPanelFrame = visiblePanelFrame;
    hiddenPanelFrame.origin.y = CGRectGetHeight(self.bounds) + 16;
    self.bottomView.frame = self.isControlsVisible ? visiblePanelFrame : hiddenPanelFrame;
    self.bottomView.alpha = self.isControlsVisible ? 1 : 0;

    CGFloat contentInset = 18;
    CGFloat contentWidth = panelWidth - contentInset * 2;
    self.titleLabel.frame = CGRectMake(contentInset, 16, contentWidth, 24);
    self.hintLabel.frame = CGRectMake(contentInset, CGRectGetMaxY(self.titleLabel.frame) + 2, contentWidth, 16);
    self.headerDividerView.frame = CGRectMake(contentInset,
                                              CGRectGetMaxY(self.hintLabel.frame) + 12,
                                              contentWidth,
                                              1);
    self.tintTitleLabel.frame = CGRectMake(contentInset, CGRectGetMaxY(self.headerDividerView.frame) + 12, contentWidth, 16);
    self.tintModeControl.frame = CGRectMake(contentInset, CGRectGetMaxY(self.tintTitleLabel.frame) + 8, contentWidth, 32);
    self.slidersDividerView.frame = CGRectMake(contentInset,
                                               CGRectGetMaxY(self.tintModeControl.frame) + 14,
                                               contentWidth,
                                               1);

    [self xy_layoutRowWithTitleLabel:self.focusRangeTitleLabel
                          valueLabel:self.focusRangeValueLabel
                              slider:self.focusRangeSlider
                                   y:CGRectGetMaxY(self.slidersDividerView.frame) + 14
                        contentWidth:contentWidth];

    [self xy_layoutRowWithTitleLabel:self.focusFadeTitleLabel
                          valueLabel:self.focusFadeValueLabel
                              slider:self.focusFadeSlider
                                   y:CGRectGetMaxY(self.focusRangeSlider.frame) + 18
                        contentWidth:contentWidth];

    [self xy_layoutRowWithTitleLabel:self.distanceTitleLabel
                          valueLabel:self.distanceValueLabel
                              slider:self.distanceSlider
                                   y:CGRectGetMaxY(self.focusFadeSlider.frame) + 18
                        contentWidth:contentWidth];

    [self xy_layoutRowWithTitleLabel:self.m34TitleLabel
                          valueLabel:self.m34ValueLabel
                              slider:self.m34Slider
                                   y:CGRectGetMaxY(self.distanceSlider.frame) + 18
                        contentWidth:contentWidth];

    CGFloat rightInset = 0;
    CGFloat labelSpacing = 10;
    CGFloat labelWidth = MIN(124, availableWidth * 0.34);
    CGFloat collapsedWheelWidth = 12;
    CGFloat expandedWheelWidth = MIN(30, availableWidth * 0.12);
    CGFloat wheelWidth = self.focusExpanded ? expandedWheelWidth : collapsedWheelWidth;
    CGFloat collapsedWheelHeight = 96;
    CGFloat expandedWheelHeight = MIN(MAX(CGRectGetHeight(self.bounds) - safeTop - safeBottom - 232, 220), 276);
    CGFloat wheelHeight = self.focusExpanded ? expandedWheelHeight : collapsedWheelHeight;
    CGFloat wheelX = CGRectGetWidth(self.bounds) - rightInset - wheelWidth;
    CGFloat wheelY = (CGRectGetHeight(self.bounds) - wheelHeight) / 2.0;
    self.focusWheelView.frame = CGRectMake(wheelX, wheelY, wheelWidth, wheelHeight);
    self.focusWheelView.layer.cornerRadius = wheelWidth / 2.0;

    CGFloat labelX = CGRectGetMinX(self.focusWheelView.frame) - labelSpacing - labelWidth;
    self.focusWheelTitleLabel.frame = CGRectMake(labelX,
                                                 CGRectGetMidY(self.focusWheelView.frame) - 16,
                                                 labelWidth,
                                                 16);
    self.focusDetailLabel.frame = CGRectMake(labelX,
                                             CGRectGetMaxY(self.focusWheelTitleLabel.frame) + 4,
                                             labelWidth,
                                             30);

    CGFloat centerX = floor(CGRectGetWidth(self.focusWheelView.bounds) / 2.0);
    self.focusSpineView.frame = CGRectMake(centerX,
                                           10,
                                           1.5,
                                           CGRectGetHeight(self.focusWheelView.bounds) - 20);

    CGFloat rowHeight = [self xy_focusTickSpacing];
    CGFloat ticksTop = (CGRectGetHeight(self.focusWheelView.bounds) - rowHeight * self.focusTickViews.count) / 2.0;
    NSInteger centerSlot = self.focusTickViews.count / 2;
    CGFloat indicatorWidth = self.focusExpanded ? MAX(9, wheelWidth - 7) : MAX(5, wheelWidth - 4);
    CGFloat indicatorHeight = self.focusExpanded ? 3 : 18;
    self.focusSelectionView.frame = CGRectMake(CGRectGetWidth(self.focusWheelView.bounds) - indicatorWidth - 2.5,
                                               ticksTop + centerSlot * rowHeight + (rowHeight - indicatorHeight) / 2.0,
                                               indicatorWidth,
                                               indicatorHeight);
    self.focusSelectionView.layer.cornerRadius = indicatorHeight / 2.0;
    [self.focusTickViews enumerateObjectsUsingBlock:^(UIView * _Nonnull tickView, NSUInteger idx, BOOL * _Nonnull stop) {
        tickView.frame = CGRectMake(CGRectGetWidth(self.focusWheelView.bounds) - 6.5,
                                    ticksTop + rowHeight * idx + (rowHeight - 2) / 2.0,
                                    2,
                                    2);
    }];

    [self xy_refreshFocusLabels];
}

- (void)xy_layoutRowWithTitleLabel:(UILabel *)titleLabel
                        valueLabel:(UILabel *)valueLabel
                            slider:(UISlider *)slider
                                 y:(CGFloat)y
                      contentWidth:(CGFloat)contentWidth
{
    CGFloat contentInset = 18;
    CGFloat titleWidth = 96;
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
    self.focusRangeValueLabel.text = [NSString stringWithFormat:@"±%ld", (long)lroundf(self.focusRangeSlider.value)];
    self.focusFadeValueLabel.text = [NSString stringWithFormat:@"%.0f%%", self.focusFadeSlider.value * 100];
    self.distanceValueLabel.text = [NSString stringWithFormat:@"%.0f%%", self.distanceSlider.value * 200];
    self.m34ValueLabel.text = [NSString stringWithFormat:@"%.2fx", self.m34Slider.value];
}

- (void)refreshDisplayedValues
{
    [self xy_updateSliderValueLabels];
}

- (void)setTintMode:(XYDebugCloneTintMode)tintMode
{
    _tintMode = tintMode;
    self.tintModeControl.selectedSegmentIndex = tintMode;
}

- (void)setFocusContextRange:(NSInteger)focusContextRange
{
    NSInteger clampedRange = MIN(MAX(focusContextRange, 0), 4);
    _focusContextRange = clampedRange;
    self.focusRangeSlider.value = clampedRange;
    [self xy_updateSliderValueLabels];
}

- (void)setFocusContextOpacity:(CGFloat)focusContextOpacity
{
    CGFloat clampedOpacity = MIN(MAX(focusContextOpacity, self.focusFadeSlider.minimumValue), self.focusFadeSlider.maximumValue);
    _focusContextOpacity = clampedOpacity;
    self.focusFadeSlider.value = clampedOpacity;
    [self xy_updateSliderValueLabels];
}

- (void)setFocusItems:(NSArray<NSString *> *)focusItems selectedIndex:(NSInteger)selectedIndex
{
    [self xy_cancelPendingFocusReset];
    self.focusItems = focusItems.copy ?: @[];
    NSInteger clampedIndex = [self xy_clampedFocusIndex:selectedIndex];
    _focusIndex = clampedIndex;
    [self xy_refreshFocusLabels];
    [self setFocusWheelHidden:self.focusWheelHidden || self.focusItems.count == 0];
}

- (void)setFocusWheelHidden:(BOOL)hidden
{
    if (hidden) {
        [self xy_cancelPendingFocusReset];
        self.focusExpanded = NO;
    }
    _focusWheelHidden = hidden;
    BOOL shouldHide = hidden || self.focusItems.count == 0;
    self.focusWheelView.hidden = shouldHide;
    self.focusWheelView.userInteractionEnabled = !shouldHide;
    self.focusWheelTitleLabel.hidden = shouldHide;
    self.focusDetailLabel.hidden = shouldHide;
    [self xy_refreshFocusLabels];
    if (!shouldHide) {
        [self setNeedsLayout];
    }
}

- (NSInteger)xy_clampedFocusIndex:(NSInteger)focusIndex
{
    if (self.focusItems.count == 0) {
        return 0;
    }
    return MIN(MAX(focusIndex, 0), self.focusItems.count - 1);
}

- (void)xy_setFocusIndex:(NSInteger)focusIndex notifyDelegate:(BOOL)notifyDelegate
{
    NSInteger clampedIndex = [self xy_clampedFocusIndex:focusIndex];
    if (_focusIndex == clampedIndex && !notifyDelegate) {
        [self xy_refreshFocusLabels];
        return;
    }

    _focusIndex = clampedIndex;
    [self xy_refreshFocusLabels];

    if (notifyDelegate && [self.delegate respondsToSelector:@selector(overlayView:focusIndexChanged:)]) {
        [self.delegate overlayView:self focusIndexChanged:clampedIndex];
    }
}

- (void)xy_setFocusExpanded:(BOOL)expanded animated:(BOOL)animated
{
    if (self.focusExpanded == expanded) {
        return;
    }

    self.focusExpanded = expanded;
    void (^changes)(void) = ^{
        [self xy_refreshFocusLabels];
        [self setNeedsLayout];
        [self layoutIfNeeded];
    };

    if (animated) {
        [UIView animateWithDuration:0.28
                              delay:0
             usingSpringWithDamping:0.9
              initialSpringVelocity:0.18
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:changes
                         completion:nil];
    } else {
        changes();
    }
}

- (void)xy_cancelPendingFocusReset
{
    if (self.pendingFocusResetBlock == nil) {
        return;
    }

    dispatch_block_cancel(self.pendingFocusResetBlock);
    self.pendingFocusResetBlock = nil;
}

- (void)xy_scheduleFocusReset
{
    [self xy_cancelPendingFocusReset];

    __weak typeof(self) weakSelf = self;
    dispatch_block_t block = dispatch_block_create(0, ^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (strongSelf == nil) {
            return;
        }
        strongSelf.pendingFocusResetBlock = nil;
        [strongSelf xy_setFocusIndex:0 notifyDelegate:YES];
        [strongSelf xy_setFocusExpanded:NO animated:YES];
    });
    self.pendingFocusResetBlock = block;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(NSEC_PER_SEC)), dispatch_get_main_queue(), block);
}

- (void)xy_refreshFocusLabels
{
    NSInteger centerSlot = self.focusTickViews.count / 2;
    [self.focusTickViews enumerateObjectsUsingBlock:^(UIView * _Nonnull tickView, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger offset = (NSInteger)idx - centerSlot;
        NSInteger itemIndex = self.focusIndex + offset;
        BOOL isValid = (itemIndex >= 0 && itemIndex < self.focusItems.count);
        CGFloat distance = fabs((CGFloat)offset);
        BOOL isMajorTick = (itemIndex == 0 || itemIndex % 5 == 0);
        CGFloat alpha = isValid ? MAX(0.12, 0.95 - distance * 0.14) : 0;
        CGFloat width = 0;

        if (self.focusExpanded) {
            if (offset == 0) {
                width = CGRectGetWidth(self.focusWheelView.bounds) - 8;
            } else if (isMajorTick) {
                width = CGRectGetWidth(self.focusWheelView.bounds) - 14;
            } else {
                width = CGRectGetWidth(self.focusWheelView.bounds) - 20;
            }
        } else {
            width = 2;
            alpha = 0;
        }

        CGRect frame = tickView.frame;
        frame.size.width = MAX(2, width);
        frame.origin.x = CGRectGetWidth(self.focusWheelView.bounds) - frame.size.width - 2;
        tickView.frame = frame;
        tickView.alpha = self.focusExpanded ? alpha : 0;
        tickView.hidden = !isValid && offset != 0;
        tickView.backgroundColor = (offset == 0)
        ? [[UIColor whiteColor] colorWithAlphaComponent:0.95]
        : [[UIColor whiteColor] colorWithAlphaComponent:(isMajorTick ? 0.72 : 0.44)];
        tickView.layer.cornerRadius = frame.size.height / 2.0;
    }];

    NSString *detail = (self.focusIndex >= 0 && self.focusIndex < self.focusItems.count) ? self.focusItems[self.focusIndex] : @"All Layers";
    self.focusDetailLabel.text = detail;
    self.focusDetailLabel.textColor = (self.focusIndex == 0)
    ? [[UIColor whiteColor] colorWithAlphaComponent:0.38]
    : [[self xy_accentColor] colorWithAlphaComponent:0.74];
    self.focusDetailLabel.alpha = self.focusExpanded ? 0.40 : 0.0;
    self.focusWheelTitleLabel.alpha = self.focusExpanded ? 0.24 : 0.0;
    self.focusSelectionView.alpha = self.focusExpanded ? 1.0 : 0.92;
    self.focusSpineView.alpha = self.focusExpanded ? 0.72 : 0.46;
    self.focusWheelView.contentView.backgroundColor = [UIColor colorWithWhite:0.03 alpha:(self.focusExpanded ? 0.92 : 0.84)];
    self.focusWheelView.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:(self.focusExpanded ? 0.16 : 0.10)].CGColor;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.focusWheelView.hidden && CGRectContainsPoint([self xy_focusInteractionFrame], point)) {
        CGPoint wheelPoint = [self convertPoint:point toView:self.focusWheelView];
        UIView *focusHitView = [self.focusWheelView hitTest:wheelPoint withEvent:event];
        return focusHitView ?: self.focusWheelView;
    }

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

- (void)tintModeChanged:(UISegmentedControl *)sender
{
    XYDebugCloneTintMode selectedMode = (XYDebugCloneTintMode)sender.selectedSegmentIndex;
    _tintMode = selectedMode;
    if ([self.delegate respondsToSelector:@selector(overlayView:tintModeChanged:)]) {
        [self.delegate overlayView:self tintModeChanged:selectedMode];
    }
}

- (void)focusPress:(UILongPressGestureRecognizer *)gesture
{
    if (self.focusWheelHidden || self.focusItems.count == 0) {
        return;
    }

    CGFloat rowHeight = [self xy_focusTickSpacing];
    CGPoint location = [gesture locationInView:self.focusWheelView];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self xy_cancelPendingFocusReset];
            self.focusPanStartIndex = self.focusIndex;
            self.focusTouchStartY = location.y;
            [self xy_setFocusExpanded:YES animated:YES];
            break;
        case UIGestureRecognizerStateChanged:
        case UIGestureRecognizerStateEnded: {
            CGFloat deltaY = location.y - self.focusTouchStartY;
            NSInteger delta = (NSInteger)lround(deltaY / rowHeight);
            [self xy_setFocusIndex:self.focusPanStartIndex + delta notifyDelegate:YES];
            if (gesture.state == UIGestureRecognizerStateEnded) {
                [self xy_scheduleFocusReset];
            }
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
            [self xy_scheduleFocusReset];
            break;
        default:
            break;
    }
}

- (void)distanceChanged:(UISlider *)sender
{
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:distanceChanged:)]) {
        [self.delegate overlayView:self distanceChanged:sender.value];
    }
}

- (void)m34Changed:(UISlider *)sender
{
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:m34Changed:)]) {
        [self.delegate overlayView:self m34Changed:sender.value];
    }
}

- (void)focusRangeChanged:(UISlider *)sender
{
    NSInteger steppedRange = (NSInteger)lroundf(sender.value);
    sender.value = steppedRange;
    _focusContextRange = steppedRange;
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:focusContextRangeChanged:)]) {
        [self.delegate overlayView:self focusContextRangeChanged:steppedRange];
    }
}

- (void)focusFadeChanged:(UISlider *)sender
{
    _focusContextOpacity = sender.value;
    [self xy_updateSliderValueLabels];
    if ([self.delegate respondsToSelector:@selector(overlayView:focusContextOpacityChanged:)]) {
        [self.delegate overlayView:self focusContextOpacityChanged:sender.value];
    }
}

@end
