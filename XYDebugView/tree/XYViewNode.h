//
//  XYViewNode.h
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, XYViewNodePosition) {
    XYViewNodePositionHead = 0,
    XYViewNodePositionMiddle = 1,
    XYViewNodePositionTail = 2
};

NS_ASSUME_NONNULL_BEGIN

@interface XYViewNode : NSObject

@property (nonatomic, weak) XYViewNode *parentNode;

@property (nonatomic, strong) NSArray <XYViewNode *> *childNodes;

@property (nonatomic, assign) int deep;

@property (nonatomic, assign) int maxDeep;

@property (nonatomic, readonly, weak) UIView *resourceView;

- (nullable instancetype)initWithView:(__kindof UIView *)view parent:(nullable XYViewNode *)parent NS_DESIGNATED_INITIALIZER;
- (instancetype)init NS_UNAVAILABLE;

@end




@interface XYViewNode (XYDebug)

@property (nonatomic, readonly) NSArray <XYViewNode *> *recurrenceAllChildNodes;

@property (nonatomic, readonly) XYViewNodePosition position;
@property (nonatomic, readonly) BOOL hasChild;
@property (nonatomic, readonly) BOOL hasNext;

@end

NS_ASSUME_NONNULL_END
