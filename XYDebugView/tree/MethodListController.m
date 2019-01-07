//
//  MethodListController.m
//  XYDebugView
//
//  Created by Daniel Yang on 2019/1/14.
//  Copyright © 2019 XcodeYang. All rights reserved.
//

#import "MethodListController.h"

@interface MethodListController ()
@property (nonatomic, strong) UITextView *textView;
@end

@implementation MethodListController

- (void)viewDidLoad {
    [super viewDidLoad];
    _textView = [[UITextView alloc] init];
    _textView.editable = NO;
    _textView.text = _string;
    [self.view addSubview:_textView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    _textView.frame = self.view.bounds;
}

@end
