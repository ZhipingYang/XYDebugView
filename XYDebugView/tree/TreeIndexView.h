//
//  TreeIndexView.h
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface TreeIndexView : UIView

@property (nonatomic, strong) XYViewNode *node;
@property (nonatomic, readonly) CGFloat graphRight;

- (instancetype)initWithNode:(XYViewNode *)node;

@end

NS_ASSUME_NONNULL_END
