#import "AppDelegate.h"
#import "DemoViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];

    DemoViewController *controller = [[DemoViewController alloc] init];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:controller];

    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end
