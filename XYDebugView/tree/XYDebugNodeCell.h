//
//  XYDebugNodeCell.h
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/2.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XYViewNode.h"

NS_ASSUME_NONNULL_BEGIN
extern CGFloat XYDebugNodeCellHeight;

@interface XYDebugNodeCell : UITableViewCell

@property (nonatomic, strong) XYViewNode *node;

@end

NS_ASSUME_NONNULL_END
