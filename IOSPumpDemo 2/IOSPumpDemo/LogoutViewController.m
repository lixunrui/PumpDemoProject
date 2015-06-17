//
//  LogoutViewController.m
//  IOSPumpDemo
//
//  Created by ITL on 4/06/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "LogoutViewController.h"
#import "LoginViewController.h"
@import EnablerApi;

extern ENBForecourt* _forecourt;
@interface LogoutViewController ()

@end

@implementation LogoutViewController

- (void)viewWillAppear:(BOOL)animated
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Logout?" message:nil delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"YES", nil];
    [alertView show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex > 0) {
        AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
        [app setIsConnected:NO];
        int result;

        if ([_forecourt isConnected]) {
            result = [_forecourt disconnectWithMessage:@"Disconnected"];
            if (result == 0) {
                app.tabbarController.selectedIndex = 0;
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }
    else
    {
        self.tabBarController.selectedIndex = 0;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
