//
//  XYDebugTreeController.h
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "XYViewNode.h"

NS_ASSUME_NONNULL_BEGIN

@interface XYDebugTreeController : UITableViewController

@property (nonatomic, strong) XYViewNode *rootNode;

@end

NS_ASSUME_NONNULL_END
