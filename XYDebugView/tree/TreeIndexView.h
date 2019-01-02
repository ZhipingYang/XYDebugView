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

@property (nonatomic, readonly, assign) NSInteger deep;

- (instancetype)initWithTreeDeep:(NSInteger)deep NS_DESIGNATED_INITIALIZER;
- (instancetype)initWithFrame:(CGRect)frame NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)aDecoder NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
