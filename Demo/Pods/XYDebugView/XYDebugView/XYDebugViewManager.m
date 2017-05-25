//
//  XYDebugViewManager.m
//  QueryViolations
//
//  Created by XcodeYang on 02/05/2017.
//  Copyright © 2017 eclicks. All rights reserved.
//

#import "XYDebugViewManager.h"
#import <objc/runtime.h>

#define SCREEN_WIDTH    [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT   [UIScreen mainScreen].bounds.size.height

#pragma mark - UIColor random

@interface UIColor (Random)
+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha;
@end

@implementation UIColor (Random)
+ (UIColor *)randomColorWithAlpha:(CGFloat)alpha
{
    
    return [UIColor colorWithRed:(arc4random()%155+100)/255.0
                           green:(arc4random()%155+100)/255.0
                            blue:(arc4random()%155+100)/255.0
                           alpha:alpha];
}
@end

#pragma mark - CloneView
@interface CloneView : UIView
@property(nonatomic, weak) UIView *srcView;
+ (CloneView *)cloneWith:(UIView *)view;
@end

@implementation CloneView
+ (CloneView *)cloneWith:(UIView *)view{
    return [[CloneView alloc] initWithCopyView:view];
}
- (instancetype)initWithCopyView:(UIView *)srcView{
    self = [super initWithFrame:srcView.frame];
    if (self) {
        self.srcView = srcView;
        self.backgroundColor = [UIColor randomColorWithAlpha:0.6];
    }
    return self;
}
- (void)drawRect:(CGRect)rect{
    NSMutableArray *mArr = self.srcView.layer.sublayers.mutableCopy;
    for (UIView *subview in self.srcView.subviews) {
        if ([mArr containsObject:subview.layer]) {
            [mArr removeObject:subview.layer];
        }
    }
    CALayer *newLayer = [CALayer layer];
    newLayer.contents = self.srcView.layer.contents;
    newLayer.frame = self.srcView.layer.frame;
    
    for (CALayer *sublayer in mArr) {
        CALayer *newSub = [[CALayer alloc] initWithLayer:sublayer];
        newSub.frame = sublayer.frame;
        [newLayer addSublayer:newSub];
    }
    [newLayer renderInContext:UIGraphicsGetCurrentContext()];
}
@end

#pragma mark - UIView runtime 添加属性

const static char * DebugStoreUIViewBackColor = "DebugStoreUIViewBackColor";
const static char * DebugHasStoreUIViewBackColor = "DebugHasStoreUIViewBackColor";
const static char * DebugCloneView = "DebugCloneView";
const static char * DebugCloneLayer = "DebugCloneLayer";
const static char * DebugColorSublayer = "DebugColorSublayer";


@interface UIView (DebugStoreUIViewBackColor)

@property (nonatomic, strong) UIColor *debugStoreOrginalColor;
@property (nonatomic, assign) BOOL hasStoreDebugColor;
@property (nonatomic, strong, readonly) CALayer *debugColorSublayer;
@property (nonatomic, strong, readonly) CloneView *cloneView;
@property (nonatomic, strong, readonly) CALayer *cloneLayer;
@property (nonatomic, copy, readonly) NSArray <UIView *> *debuRecurrenceAllSubviews;

@end

@implementation UIView (DebugStoreUIViewBackColor)

- (void)setDebugStoreOrginalColor:(UIColor *)debugStoreOrginalColor
{
    if ([debugStoreOrginalColor isKindOfClass:[UIColor class]] && debugStoreOrginalColor) {
        objc_setAssociatedObject(self, DebugStoreUIViewBackColor, debugStoreOrginalColor, OBJC_ASSOCIATION_RETAIN);
    }
}

- (UIColor *)debugStoreOrginalColor
{
    id obj = objc_getAssociatedObject(self, DebugStoreUIViewBackColor);
    if ([obj isKindOfClass:[UIColor class]]) {
        return (UIColor *)obj;
    }
    return nil;
}

- (CALayer *)debugColorSublayer
{
    CALayer *obj = objc_getAssociatedObject(self, DebugColorSublayer);
    if ([obj isKindOfClass:[CALayer class]] && obj) {
        obj.frame = self.bounds;
        return obj;
    }
    obj = [[CALayer alloc] init];
    obj.borderColor = [[UIColor redColor] colorWithAlphaComponent:0.2].CGColor;
    obj.borderWidth = 1/[UIScreen mainScreen].scale;
    objc_setAssociatedObject(self, DebugColorSublayer, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self debugColorSublayer];
}

- (CloneView *)cloneView
{
    CloneView *obj = objc_getAssociatedObject(self, DebugCloneView);
    if ([obj isKindOfClass:[CloneView class]] && obj) {
        return obj;
    }
    obj = [CloneView cloneWith:self];
    objc_setAssociatedObject(self, DebugCloneView, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self cloneView];
}

- (CALayer *)cloneLayer
{
    CALayer *obj = objc_getAssociatedObject(self, DebugCloneLayer);
    if ([obj isKindOfClass:[CALayer class]] && obj) {
        return obj;
    }
    obj = [CALayer layer];
    obj.contents = self.layer.contents;
    objc_setAssociatedObject(self, DebugCloneLayer, obj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return [self cloneLayer];
}

- (void)setHasStoreDebugColor:(BOOL)hasStoreDebugColor
{
    objc_setAssociatedObject(self, DebugHasStoreUIViewBackColor, @(hasStoreDebugColor), OBJC_ASSOCIATION_ASSIGN);
}

- (BOOL)hasStoreDebugColor
{
    id obj = objc_getAssociatedObject(self, DebugHasStoreUIViewBackColor);
    return [obj boolValue];
}

- (NSArray<UIView *> *)debuRecurrenceAllSubviews
{
    NSMutableArray <UIView *> *all = @[].mutableCopy;
    void (^getSubViewsBlock)(UIView *current) = ^(UIView *current){
        [all addObject:current];
        for (UIView *sub in current.subviews) {
            [all addObjectsFromArray:[sub debuRecurrenceAllSubviews]];
        }
    };
    getSubViewsBlock(self);
    return [NSArray arrayWithArray:all];
}

@end

#pragma mark - DebugSlider

@interface DebugSlider : UIView
@property void (^touchMoveBlock)(float percent);
@property void (^touchEndBlock)();
@end

@implementation DebugSlider

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    float percent = point.y / self.frame.size.height;
    percent = percent<0 ? percent : (percent>1 ? 1:percent);
    !_touchMoveBlock ?: _touchMoveBlock(percent);
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    !_touchEndBlock ?: _touchEndBlock();
}

@end

#pragma mark - DebugWindow

@interface DebugWindow : UIWindow

@property (nonatomic, weak) XYDebugViewManager *frameManager;

@property (nonatomic, weak) UIView *souceView;

@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) DebugSlider *slider;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray <CALayer *>* debugLayers;
@end

@implementation DebugWindow

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
        _scrollView.hidden = YES;
        CATransform3D transform = CATransform3DIdentity;
        transform.m34 = -1.0 / 500;
        _scrollView.layer.sublayerTransform = transform;
        
        _slider = [[DebugSlider alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-30, 40, 20, SCREEN_HEIGHT-40*2)];
        _slider.backgroundColor = [[UIColor greenColor] colorWithAlphaComponent:0.3];
        _slider.hidden = YES;
        
        typeof(self) weakSelf = self;
        _slider.touchMoveBlock = ^(float percent) {
            [weakSelf showDifferentLayers:percent];
        };
        _slider.touchEndBlock = ^{
            [weakSelf showAllLayer];
        };
        
        [self addSubview:_scrollView];
        [self addSubview:_button];
        [self addSubview:_slider];
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
        } else if (CGRectContainsPoint(_slider.frame,point) && _souceView) {
            return _slider;
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
        [[self.debugLayers copy] makeObjectsPerformSelector:@selector(removeFromSuperlayer)];
        self.scrollView.hidden = YES;
        self.slider.hidden = YES;
    } else {
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        [self scrollViewAddLayersInView:_souceView layerLevel:0 index:0];
        self.scrollView.hidden = NO;
        self.scrollView.contentOffset = CGPointMake(SCREEN_WIDTH/2.0, SCREEN_HEIGHT/2.0);
        self.slider.hidden = NO;
    }
}

- (void)scrollViewAddLayersInView:(UIView *)view layerLevel:(CGFloat)layerLevel index:(NSUInteger)index
{
    if ([view isKindOfClass:[UIView class]] && view) {
        if (view.superview) {
            UIView *cloneView = view.cloneView;
            cloneView.layer.zPosition = -500 + (layerLevel*60+index*5);
            cloneView.layer.masksToBounds = YES;
            
            CGRect frame = [view.superview convertRect:view.frame toView:_souceView];
            frame.origin = CGPointMake(CGRectGetMinX(frame)+SCREEN_WIDTH/2.f, CGRectGetMinY(frame)+SCREEN_HEIGHT/2.f);
            cloneView.layer.frame = frame;
            cloneView.layer.opacity = 0.8;
            [self.debugLayers addObject:cloneView.layer];
            [self.scrollView.layer addSublayer:cloneView.layer];
        }
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [view.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self scrollViewAddLayersInView:obj layerLevel:layerLevel+1 index:idx];
            }];
        });
    }
}

- (void)showDifferentLayers:(float)percent
{
    CGFloat positionMax = self.debugLayers.firstObject.zPosition;
    CGFloat positionMin = positionMax;
    for (CALayer *layer in self.debugLayers) {
        if (layer.zPosition >= positionMax) {
            positionMax = layer.zPosition;
        }
        if (layer.zPosition <= positionMin) {
            positionMin = layer.zPosition;
        }
    }
    // 分成20节,每节为5
    CGFloat gap = (positionMax - positionMin)/20.f;
    
    // 每节为5，计算当前处于那一节的layer层显示
    float num = ceil((percent * 100)/5.f);
    
    CGFloat upRange = positionMin + gap*num;
    CGFloat dowmRange = positionMin + gap*(num-1);
    
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = (layer.zPosition>upRange || layer.zPosition<dowmRange) ? 0.1:1;
    }
}

- (void)showAllLayer
{
    for (CALayer *layer in self.debugLayers) {
        layer.opacity = 0.8;
    }
}

@end

#pragma mark - XYDebugViewManager

typedef NS_ENUM (NSUInteger, DebugViewState) {
    DebugViewStateNone  = 0,
    DebugViewState2D    = 1 << 0,
    DebugViewState3D    = 1 << 1
};

@interface XYDebugViewManager ()

@property (nonatomic, strong) DebugWindow *assistiveWindow;
@property (nonatomic, weak) UIWindow *keyWindow;
@property (nonatomic, assign) DebugViewState debugState;

@end

@implementation XYDebugViewManager

+ (XYDebugViewManager *)sharedInstance
{
    static XYDebugViewManager *instance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.isDebugging = NO;
        instance.debugState = DebugViewStateNone;
        instance.keyWindow = [UIApplication sharedApplication].keyWindow;
    });
    return instance;
}

- (void)setIsDebugging:(BOOL)isDebugging
{
    if (!_assistiveWindow) {
        _assistiveWindow = [[DebugWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _assistiveWindow.frameManager = self;
        [_assistiveWindow.button addTarget:self action:@selector(debugViewBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    
    _assistiveWindow.windowLevel = isDebugging ? CGFLOAT_MAX:UIWindowLevelNormal;
    _assistiveWindow.button.hidden = !isDebugging;
    _assistiveWindow.souceView = nil;

    if (isDebugging) {
        [_assistiveWindow makeKeyAndVisible];
        if (_keyWindow) {
            [_keyWindow makeKeyWindow];
        }
    } else {
        [_assistiveWindow resignKeyWindow];
        _assistiveWindow = nil;
        [_keyWindow makeKeyAndVisible];
    }
    
    [self currentWindowsShowDebugView:NO];
    _debugState = DebugViewStateNone;
    _isDebugging = isDebugging;
}

- (void)debugViewBtnClick
{
    switch (self.debugState) {
        case DebugViewStateNone: {
            [self currentWindowsShowDebugView:YES];
            self.debugState = DebugViewState2D;
        }
            break;
        case DebugViewState2D:{
            _assistiveWindow.souceView = [UIApplication sharedApplication].keyWindow;
            self.debugState = DebugViewState3D;
        }
            break;
        case DebugViewState3D:{
            [self currentWindowsShowDebugView:NO];
            self.assistiveWindow.souceView = nil;
            self.debugState = DebugViewStateNone;
        }
            break;
            
        default:
            break;
    }
}

- (void)currentWindowsShowDebugView:(BOOL)showDebugView
{
    for (UIWindow *w in [UIApplication sharedApplication].windows) {
        if (w != _assistiveWindow && w != [UIApplication sharedApplication].keyWindow) {
            [self traverseSubviewIn:w shouldRecoverBackColor:!showDebugView];
        }
    }
    [self traverseSubviewIn:[UIApplication sharedApplication].keyWindow shouldRecoverBackColor:!showDebugView];
}

- (void)traverseSubviewIn:(UIView *)parentView shouldRecoverBackColor:(BOOL)shouldRecoverBackColor
{
    NSMutableArray <UIView *>* allViews = parentView.debuRecurrenceAllSubviews.mutableCopy;
    // 移除第一个view（window）
    [allViews removeObjectAtIndex:0];
    
    if (shouldRecoverBackColor) {
        // 回复原貌
        for (UIView *subview in allViews) {
            if (!subview.hasStoreDebugColor) { return; }
            subview.backgroundColor = subview.debugStoreOrginalColor ?: [UIColor clearColor];
            subview.hasStoreDebugColor = NO;
            subview.layer.borderWidth = CGFLOAT_MIN;
            if (subview.debugColorSublayer.superlayer) {
                [subview.debugColorSublayer removeFromSuperlayer];
            }
        }
    } else {
        // 追加debug
        for (UIView *subview in allViews) {
            
            if (subview.hasStoreDebugColor || subview==_assistiveWindow.button) {
                return;
            }
            subview.debugStoreOrginalColor = subview.backgroundColor;
            subview.hasStoreDebugColor = YES;
            if (!CGRectEqualToRect(subview.bounds, [UIScreen mainScreen].bounds)) {
                subview.backgroundColor = [UIColor randomColorWithAlpha:0.3];
            }
            
            // 添加view的frame边框
            if (!subview.debugColorSublayer.superlayer) {
                [subview.layer addSublayer:subview.debugColorSublayer];
            }
        }
    }
}

@end
