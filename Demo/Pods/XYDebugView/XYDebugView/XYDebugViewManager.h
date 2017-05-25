//
//  XYDebugViewManager.h
//  QueryViolations
//
//  Created by XcodeYang on 02/05/2017.
//  Copyright © 2017 eclicks. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYDebugViewManager : NSObject

@property (nonatomic, assign) BOOL isDebugging;

+ (XYDebugViewManager *)sharedInstance;

@end
