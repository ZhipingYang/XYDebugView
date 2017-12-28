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

@property (weak, nonatomic) IBOutlet UISwitch *debugCustom2D;
@property (weak, nonatomic) IBOutlet UISwitch *debugCustom3D;
@property (weak, nonatomic) IBOutlet UISwitch *debugWindow2D;
@property (weak, nonatomic) IBOutlet UISwitch *debugWindow3D;

@property (strong, nonatomic) IBOutletCollection(UISwitch) NSArray<UISwitch *> *allSwitch;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
	[XYDebugViewManager dismissDebugView];
}

#pragma mark - delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 2) {
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
	
	[XYDebugViewManager dismissDebugView];

	[_allSwitch enumerateObjectsUsingBlock:^(UISwitch * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
		if (obj != sender && obj.isOn) {
			obj.on = NO;
		}
	}];
	
	if (sender.on) {
		UITableViewCell *customCell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
		if (sender == _debugCustom2D) {
			[XYDebugViewManager showDebugInView:customCell withDebugStyle:XYDebugStyle2D];
		} else if (sender == _debugCustom3D) {
			[XYDebugViewManager showDebugInView:customCell withDebugStyle:XYDebugStyle3D];
		} else if (sender == _debugWindow2D) {
			[XYDebugViewManager showDebugWithStyle:XYDebugStyle2D];
		} else if (sender == _debugWindow3D) {
			[XYDebugViewManager showDebugWithStyle:XYDebugStyle3D];
		}
	}
}

@end
