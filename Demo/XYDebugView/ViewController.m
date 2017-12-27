//
//  ViewController.m
//  XYDebugView
//
//  Created by XcodeYang on 24/05/2017.
//  Copyright © 2017 XcodeYang. All rights reserved.
//

#import "ViewController.h"
#import "XYDebugViewManager.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UISwitch *debugSwitch;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
	_debugSwitch.on = [XYDebugViewManager isDebugging];
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0: [self showAlert]; break;
            case 1: [self showSheet]; break;
            case 2: [self showActivity]; break;
            default: break;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

#pragma mark - action
- (void)showAlert {
    [[[UIAlertView alloc] initWithTitle:@"Alert Title" message:@"ready to debug alert view's layout" delegate:nil cancelButtonTitle:@"Cancel" otherButtonTitles:@"Sure", nil] show];
}

- (void)showSheet {
    [[[UIActionSheet alloc] initWithTitle:@"Sheet Title" delegate:nil cancelButtonTitle:@"Cancel" destructiveButtonTitle:@"Destructive" otherButtonTitles:@"Others", nil] showInView:self.view];
}

- (void)showActivity {
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:@[@"Activity Title",[NSURL URLWithString:@"https://www.baidu.com"]] applicationActivities:nil];
    [self presentViewController:activityVC animated:YES completion:nil];
}

- (IBAction)switchChanged:(UISwitch *)sender {
	if (sender.on) {
		[XYDebugViewManager showDebugInView:nil withDebugStyle:XYDebugStyle2D];
//		[XYDebugViewManager showDebugInView:[self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] withDebugStyle:XYDebugStyle2D];
	} else {
		[XYDebugViewManager dismissDebugView];
	}
}

@end
