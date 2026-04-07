#import "DemoViewController.h"
#import <XYDebugView/XYDebugViewManager.h>

@interface DemoViewController ()

@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *contentStackView;
@property (nonatomic, strong) UIView *previewCardView;
@property (nonatomic, assign) BOOL launchScenarioHandled;

@end

@implementation DemoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = @"XYDebugView";
    self.view.backgroundColor = [UIColor colorWithRed:0.95 green:0.96 blue:0.98 alpha:1.0];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                               style:UIBarButtonItemStylePlain
                                                                              target:self
                                                                              action:@selector(closeDebug)];

    [self buildInterface];
}

- (void)dealloc
{
    [[XYDebugViewManager sharedInstance] closeDebug];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self runLaunchScenarioIfNeeded];
}

#pragma mark - UI

- (void)buildInterface
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];

    self.contentStackView = [[UIStackView alloc] init];
    self.contentStackView.translatesAutoresizingMaskIntoConstraints = NO;
    self.contentStackView.axis = UILayoutConstraintAxisVertical;
    self.contentStackView.spacing = 20;
    self.contentStackView.layoutMargins = UIEdgeInsetsMake(24, 20, 32, 20);
    self.contentStackView.layoutMarginsRelativeArrangement = YES;
    [self.scrollView addSubview:self.contentStackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],

        [self.contentStackView.topAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.topAnchor],
        [self.contentStackView.leadingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.leadingAnchor],
        [self.contentStackView.trailingAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.trailingAnchor],
        [self.contentStackView.bottomAnchor constraintEqualToAnchor:self.scrollView.contentLayoutGuide.bottomAnchor],
        [self.contentStackView.widthAnchor constraintEqualToAnchor:self.scrollView.frameLayoutGuide.widthAnchor],
    ]];

    [self.contentStackView addArrangedSubview:[self makeHeroSection]];
    [self.contentStackView addArrangedSubview:[self makeActionSectionWithTitle:@"Debug Current Window"
                                                                        lines:@[
                                                                            @[
                                                                                [self actionButtonWithTitle:@"Window 2D" color:[UIColor colorWithRed:0.95 green:0.47 blue:0.38 alpha:1.0] selector:@selector(showWindow2D)],
                                                                                [self actionButtonWithTitle:@"Window 3D" color:[UIColor colorWithRed:0.17 green:0.59 blue:0.93 alpha:1.0] selector:@selector(showWindow3D)],
                                                                            ],
                                                                            @[
                                                                                [self actionButtonWithTitle:@"Window Index" color:[UIColor colorWithRed:0.17 green:0.69 blue:0.56 alpha:1.0] selector:@selector(showWindowIndex)],
                                                                                [self actionButtonWithTitle:@"Close Debug" color:[UIColor colorWithRed:0.29 green:0.32 blue:0.39 alpha:1.0] selector:@selector(closeDebug)],
                                                                            ],
                                                                        ]]];

    self.previewCardView = [self makePreviewCard];
    [self.contentStackView addArrangedSubview:[self makePreviewSection]];

    [self.contentStackView addArrangedSubview:[self makeActionSectionWithTitle:@"Extra Layers To Inspect"
                                                                        lines:@[
                                                                            @[
                                                                                [self actionButtonWithTitle:@"Show Alert" color:[UIColor colorWithRed:0.66 green:0.42 blue:0.91 alpha:1.0] selector:@selector(showAlert)],
                                                                                [self actionButtonWithTitle:@"Show Sheet" color:[UIColor colorWithRed:0.97 green:0.67 blue:0.25 alpha:1.0] selector:@selector(showActionSheet)],
                                                                            ],
                                                                        ]]];
}

- (UIView *)makeHeroSection
{
    UIView *container = [self roundedCardWithBackgroundColor:[UIColor whiteColor]];

    UILabel *titleLabel = [self titleLabelWithText:@"A pure-code demo focused on the pod API"];
    titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightBold];

    UILabel *bodyLabel = [self bodyLabelWithText:@"Use the buttons below to inspect the full window, this preview card, or the live view tree. The sample hierarchy is intentionally layered so 2D and 3D modes are easy to compare."];

    UIView *badge = [self pillLabelWithText:@"Development pod via Podfile"];
    UIView *badgeTwo = [self pillLabelWithText:@"Generated from project.yml"];

    UIStackView *badgeStack = [[UIStackView alloc] initWithArrangedSubviews:@[badge, badgeTwo]];
    badgeStack.axis = UILayoutConstraintAxisHorizontal;
    badgeStack.spacing = 10;
    badgeStack.alignment = UIStackViewAlignmentLeading;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, bodyLabel, badgeStack]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    [container addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:container.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-20],
    ]];

    return container;
}

- (UIView *)makePreviewSection
{
    UIView *section = [self roundedCardWithBackgroundColor:[UIColor colorWithRed:0.98 green:0.99 blue:1.0 alpha:1.0]];

    UILabel *titleLabel = [self titleLabelWithText:@"Preview Card"];
    UILabel *bodyLabel = [self bodyLabelWithText:@"Debug the card only when you want to isolate a custom view instead of the whole window."];

    UIStackView *buttonRow = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self actionButtonWithTitle:@"Card 2D" color:[UIColor colorWithRed:0.95 green:0.47 blue:0.38 alpha:1.0] selector:@selector(showCard2D)],
        [self actionButtonWithTitle:@"Card 3D" color:[UIColor colorWithRed:0.17 green:0.59 blue:0.93 alpha:1.0] selector:@selector(showCard3D)],
        [self actionButtonWithTitle:@"Card Index" color:[UIColor colorWithRed:0.17 green:0.69 blue:0.56 alpha:1.0] selector:@selector(showCardIndex)],
    ]];
    buttonRow.axis = UILayoutConstraintAxisHorizontal;
    buttonRow.alignment = UIStackViewAlignmentFill;
    buttonRow.distribution = UIStackViewDistributionFillEqually;
    buttonRow.spacing = 10;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, bodyLabel, self.previewCardView, buttonRow]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 16;
    [section addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:section.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:section.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:section.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:section.bottomAnchor constant:-20],
    ]];

    return section;
}

- (UIView *)makeActionSectionWithTitle:(NSString *)title lines:(NSArray<NSArray<UIButton *> *> *)lines
{
    UIView *section = [self roundedCardWithBackgroundColor:[UIColor whiteColor]];

    NSMutableArray<UIView *> *arrangedSubviews = [NSMutableArray arrayWithObject:[self titleLabelWithText:title]];
    for (NSArray<UIButton *> *buttons in lines) {
        UIStackView *row = [[UIStackView alloc] initWithArrangedSubviews:buttons];
        row.axis = UILayoutConstraintAxisHorizontal;
        row.spacing = 10;
        row.distribution = UIStackViewDistributionFillEqually;
        [arrangedSubviews addObject:row];
    }

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:arrangedSubviews];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 12;
    [section addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:section.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:section.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:section.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:section.bottomAnchor constant:-20],
    ]];

    return section;
}

- (UIView *)makePreviewCard
{
    UIView *card = [self roundedCardWithBackgroundColor:[UIColor colorWithRed:0.11 green:0.14 blue:0.22 alpha:1.0]];
    card.layer.cornerRadius = 28;

    UIView *avatar = [[UIView alloc] init];
    avatar.translatesAutoresizingMaskIntoConstraints = NO;
    avatar.backgroundColor = [UIColor colorWithRed:0.98 green:0.78 blue:0.30 alpha:1.0];
    avatar.layer.cornerRadius = 26;
    [NSLayoutConstraint activateConstraints:@[
        [avatar.widthAnchor constraintEqualToConstant:52],
        [avatar.heightAnchor constraintEqualToConstant:52],
    ]];

    UILabel *nameLabel = [self labelWithText:@"Debug Overlay" font:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold] color:[UIColor whiteColor]];
    UILabel *subtitleLabel = [self labelWithText:@"Programmatic nested views for 2D / 3D inspection" font:[UIFont systemFontOfSize:13 weight:UIFontWeightRegular] color:[[UIColor whiteColor] colorWithAlphaComponent:0.7]];

    UIStackView *nameStack = [[UIStackView alloc] initWithArrangedSubviews:@[nameLabel, subtitleLabel]];
    nameStack.axis = UILayoutConstraintAxisVertical;
    nameStack.spacing = 4;

    UIView *statusBadge = [self pillLabelWithText:@"READY"];
    statusBadge.backgroundColor = [UIColor colorWithRed:0.16 green:0.69 blue:0.56 alpha:1.0];

    UIStackView *header = [[UIStackView alloc] initWithArrangedSubviews:@[avatar, nameStack, statusBadge]];
    header.axis = UILayoutConstraintAxisHorizontal;
    header.alignment = UIStackViewAlignmentCenter;
    header.spacing = 14;

    UIStackView *statRow = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self metricCardWithTitle:@"Layers" value:@"42"],
        [self metricCardWithTitle:@"Depth" value:@"3D"],
        [self metricCardWithTitle:@"Tree" value:@"Index"],
    ]];
    statRow.axis = UILayoutConstraintAxisHorizontal;
    statRow.spacing = 10;
    statRow.distribution = UIStackViewDistributionFillEqually;

    UIView *leftPanel = [self roundedCardWithBackgroundColor:[UIColor colorWithRed:0.16 green:0.19 blue:0.28 alpha:1.0]];
    UIView *rightPanel = [self roundedCardWithBackgroundColor:[UIColor colorWithRed:0.14 green:0.17 blue:0.25 alpha:1.0]];

    UIStackView *leftStack = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self metricCardWithTitle:@"Header" value:@"Pinned"],
        [self metricCardWithTitle:@"Modal" value:@"Alert"],
    ]];
    leftStack.translatesAutoresizingMaskIntoConstraints = NO;
    leftStack.axis = UILayoutConstraintAxisVertical;
    leftStack.spacing = 10;
    [leftPanel addSubview:leftStack];

    UIView *barOne = [self chartBarWithHeight:54 color:[UIColor colorWithRed:0.95 green:0.47 blue:0.38 alpha:1.0]];
    UIView *barTwo = [self chartBarWithHeight:82 color:[UIColor colorWithRed:0.17 green:0.59 blue:0.93 alpha:1.0]];
    UIView *barThree = [self chartBarWithHeight:38 color:[UIColor colorWithRed:0.16 green:0.69 blue:0.56 alpha:1.0]];

    UIStackView *chart = [[UIStackView alloc] initWithArrangedSubviews:@[barOne, barTwo, barThree]];
    chart.translatesAutoresizingMaskIntoConstraints = NO;
    chart.axis = UILayoutConstraintAxisHorizontal;
    chart.alignment = UIStackViewAlignmentBottom;
    chart.distribution = UIStackViewDistributionFillEqually;
    chart.spacing = 12;
    [rightPanel addSubview:chart];

    [NSLayoutConstraint activateConstraints:@[
        [leftStack.topAnchor constraintEqualToAnchor:leftPanel.topAnchor constant:14],
        [leftStack.leadingAnchor constraintEqualToAnchor:leftPanel.leadingAnchor constant:14],
        [leftStack.trailingAnchor constraintEqualToAnchor:leftPanel.trailingAnchor constant:-14],
        [leftStack.bottomAnchor constraintEqualToAnchor:leftPanel.bottomAnchor constant:-14],

        [chart.topAnchor constraintEqualToAnchor:rightPanel.topAnchor constant:20],
        [chart.leadingAnchor constraintEqualToAnchor:rightPanel.leadingAnchor constant:16],
        [chart.trailingAnchor constraintEqualToAnchor:rightPanel.trailingAnchor constant:-16],
        [chart.bottomAnchor constraintEqualToAnchor:rightPanel.bottomAnchor constant:-16],
    ]];

    UIStackView *panels = [[UIStackView alloc] initWithArrangedSubviews:@[leftPanel, rightPanel]];
    panels.axis = UILayoutConstraintAxisHorizontal;
    panels.spacing = 10;
    panels.distribution = UIStackViewDistributionFillEqually;

    UIStackView *footerTopRow = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self pillLabelWithText:@"tap buttons above"],
        [self pillLabelWithText:@"open alert / sheet"],
    ]];
    footerTopRow.axis = UILayoutConstraintAxisHorizontal;
    footerTopRow.spacing = 10;
    footerTopRow.distribution = UIStackViewDistributionFillProportionally;

    UIStackView *footerBottomRow = [[UIStackView alloc] initWithArrangedSubviews:@[
        [self pillLabelWithText:@"inspect hierarchy"],
    ]];
    footerBottomRow.axis = UILayoutConstraintAxisHorizontal;

    UIStackView *footer = [[UIStackView alloc] initWithArrangedSubviews:@[footerTopRow, footerBottomRow]];
    footer.axis = UILayoutConstraintAxisVertical;
    footer.spacing = 10;

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[header, statRow, panels, footer]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 14;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:20],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:20],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-20],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-20],
    ]];

    return card;
}

- (UIView *)metricCardWithTitle:(NSString *)title value:(NSString *)value
{
    UIView *card = [self roundedCardWithBackgroundColor:[UIColor colorWithRed:0.20 green:0.24 blue:0.33 alpha:1.0]];

    UILabel *titleLabel = [self labelWithText:title font:[UIFont systemFontOfSize:12 weight:UIFontWeightMedium] color:[[UIColor whiteColor] colorWithAlphaComponent:0.65]];
    UILabel *valueLabel = [self labelWithText:value font:[UIFont systemFontOfSize:18 weight:UIFontWeightBold] color:[UIColor whiteColor]];

    UIStackView *stack = [[UIStackView alloc] initWithArrangedSubviews:@[titleLabel, valueLabel]];
    stack.translatesAutoresizingMaskIntoConstraints = NO;
    stack.axis = UILayoutConstraintAxisVertical;
    stack.spacing = 6;
    [card addSubview:stack];

    [NSLayoutConstraint activateConstraints:@[
        [stack.topAnchor constraintEqualToAnchor:card.topAnchor constant:14],
        [stack.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:14],
        [stack.trailingAnchor constraintEqualToAnchor:card.trailingAnchor constant:-14],
        [stack.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-14],
    ]];

    return card;
}

- (UIView *)chartBarWithHeight:(CGFloat)height color:(UIColor *)color
{
    UIView *bar = [[UIView alloc] init];
    bar.translatesAutoresizingMaskIntoConstraints = NO;
    bar.backgroundColor = color;
    bar.layer.cornerRadius = 12;
    [NSLayoutConstraint activateConstraints:@[
        [bar.heightAnchor constraintEqualToConstant:height],
    ]];
    return bar;
}

- (UIView *)roundedCardWithBackgroundColor:(UIColor *)backgroundColor
{
    UIView *view = [[UIView alloc] init];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    view.backgroundColor = backgroundColor;
    view.layer.cornerRadius = 24;
    return view;
}

- (UILabel *)titleLabelWithText:(NSString *)text
{
    return [self labelWithText:text font:[UIFont systemFontOfSize:20 weight:UIFontWeightSemibold] color:[UIColor colorWithRed:0.11 green:0.14 blue:0.22 alpha:1.0]];
}

- (UILabel *)bodyLabelWithText:(NSString *)text
{
    UILabel *label = [self labelWithText:text font:[UIFont systemFontOfSize:15 weight:UIFontWeightRegular] color:[UIColor colorWithRed:0.35 green:0.39 blue:0.47 alpha:1.0]];
    label.numberOfLines = 0;
    return label;
}

- (UILabel *)labelWithText:(NSString *)text font:(UIFont *)font color:(UIColor *)color
{
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = font;
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

- (UIView *)pillLabelWithText:(NSString *)text
{
    UILabel *label = [self labelWithText:text font:[UIFont systemFontOfSize:12 weight:UIFontWeightSemibold] color:[UIColor whiteColor]];
    label.textAlignment = NSTextAlignmentCenter;

    UIView *container = [[UIView alloc] init];
    container.translatesAutoresizingMaskIntoConstraints = NO;
    container.backgroundColor = [UIColor colorWithRed:0.24 green:0.29 blue:0.39 alpha:1.0];
    container.layer.cornerRadius = 15;
    [container addSubview:label];
    label.translatesAutoresizingMaskIntoConstraints = NO;

    [NSLayoutConstraint activateConstraints:@[
        [label.topAnchor constraintEqualToAnchor:container.topAnchor constant:7],
        [label.leadingAnchor constraintEqualToAnchor:container.leadingAnchor constant:12],
        [label.trailingAnchor constraintEqualToAnchor:container.trailingAnchor constant:-12],
        [label.bottomAnchor constraintEqualToAnchor:container.bottomAnchor constant:-7],
    ]];

    return container;
}

- (UIButton *)actionButtonWithTitle:(NSString *)title color:(UIColor *)color selector:(SEL)selector
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = color;
    button.layer.cornerRadius = 16;
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.contentEdgeInsets = UIEdgeInsetsMake(14, 12, 14, 12);
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [button.heightAnchor constraintEqualToConstant:52].active = YES;
    return button;
}

#pragma mark - Actions

- (void)showWindow2D
{
    [[XYDebugViewManager sharedInstance] showDebugStyle:XYDebugStyle2D];
}

- (void)showWindow3D
{
    [[XYDebugViewManager sharedInstance] showDebugStyle:XYDebugStyle3D];
}

- (void)showWindowIndex
{
    [[XYDebugViewManager sharedInstance] showDebugStyle:XYDebugStyleIndex];
}

- (void)showCard2D
{
    [[XYDebugViewManager sharedInstance] showDebugView:self.previewCardView withDebugStyle:XYDebugStyle2D];
}

- (void)showCard3D
{
    [[XYDebugViewManager sharedInstance] showDebugView:self.previewCardView withDebugStyle:XYDebugStyle3D];
}

- (void)showCardIndex
{
    [[XYDebugViewManager sharedInstance] showDebugView:self.previewCardView withDebugStyle:XYDebugStyleIndex];
}

- (void)closeDebug
{
    [[XYDebugViewManager sharedInstance] closeDebug];
}

- (void)showAlert
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Nested Alert"
                                                                        message:@"Use this alert to inspect transient UIKit layers and presentation containers."
                                                                 preferredStyle:UIAlertControllerStyleAlert];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Inspect" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showActionSheet
{
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"Debug More Layers"
                                                                        message:@"Action sheets add another presentation stack that is useful in the hierarchy browser."
                                                                 preferredStyle:UIAlertControllerStyleActionSheet];
    [controller addAction:[UIAlertAction actionWithTitle:@"Open 2D" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [self showWindow2D];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Open 3D" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *action) {
        [self showWindow3D];
    }]];
    [controller addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    controller.popoverPresentationController.sourceView = self.view;
    controller.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMidY(self.view.bounds), 1, 1);
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark - Screenshot Support

- (void)runLaunchScenarioIfNeeded
{
    if (self.launchScenarioHandled) {
        return;
    }
    self.launchScenarioHandled = YES;

    NSArray<NSString *> *arguments = NSProcessInfo.processInfo.arguments;
    BOOL shouldOpenWindow3D = [arguments containsObject:@"-XYDemoAutoShowWindow3D"];
    BOOL shouldOpenCard3D = [arguments containsObject:@"-XYDemoAutoShowCard3D"];
    BOOL shouldOpenControls = [arguments containsObject:@"-XYDemoAutoOpenControls"];

    if (!shouldOpenWindow3D && !shouldOpenCard3D && !shouldOpenControls) {
        return;
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.45 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (shouldOpenWindow3D) {
            [self showWindow3D];
        } else if (shouldOpenCard3D) {
            [self showCard3D];
        }

        if (shouldOpenControls) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self triggerOverlayButtonWithTitle:@"Controls"];
            });
        }
    });
}

- (void)triggerOverlayButtonWithTitle:(NSString *)title
{
    for (UIWindow *window in [self activeWindows].reverseObjectEnumerator) {
        UIButton *button = [self findButtonWithTitle:title inView:window];
        if (button != nil) {
            [button sendActionsForControlEvents:UIControlEventTouchUpInside];
            return;
        }
    }
}

- (UIButton *)findButtonWithTitle:(NSString *)title inView:(UIView *)view
{
    if ([view isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton *)view;
        if ([[button titleForState:UIControlStateNormal] isEqualToString:title]) {
            return button;
        }
    }

    for (UIView *subview in view.subviews.reverseObjectEnumerator) {
        UIButton *button = [self findButtonWithTitle:title inView:subview];
        if (button != nil) {
            return button;
        }
    }

    return nil;
}

- (NSArray<UIWindow *> *)activeWindows
{
    NSMutableArray<UIWindow *> *windows = [NSMutableArray array];
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:[UIWindowScene class]]) {
                continue;
            }
            [windows addObjectsFromArray:((UIWindowScene *)scene).windows];
        }
    }
    return windows.copy;
}

@end
