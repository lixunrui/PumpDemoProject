//
//  LoginViewController.m
//  IOSPumpDemo
//
//  Created by ITL on 20/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "LoginViewController.h"
#import "MainViewController.h"
#import "ForecourtViewController.h"
#import "SiteViewController.h"
#import "LogoutViewController.h"
#import "ImageNames.h"
#import "UIButton+ButtomLayout.h"

#define TERMINALNAME @"IOS Terminal"
#define TABBAR_ID @"MainBoard"


@interface LoginViewController ()
@property (weak, nonatomic) IBOutlet UITextField *txtServerAddress;
@property (weak, nonatomic) IBOutlet UITextField *txtTerminalID;
@property (weak, nonatomic) IBOutlet UITextField *txtTerminalPassword;

@property (weak, nonatomic) IBOutlet UIButton *btnLogin;

@end

ENBForecourt* _forecourt;

@implementation LoginViewController
{
    dispatch_semaphore_t loading;

    float ratation;
}

/**
 *  Setup background color
 *
 *  @return
 */
- (CAGradientLayer*) backgroundGradient {

    UIColor *colorbottom = [UIColor colorWithRed:(0/255.0) green:(48/255.0) blue:(70/255.0) alpha:1.0];
    UIColor *colorTop = [UIColor colorWithRed:(0/255.0)  green:(84/255.0)  blue:(112/255.0)  alpha:1.0];

    NSArray *colors = [NSArray arrayWithObjects:(id)colorTop.CGColor, colorbottom.CGColor, nil];

    NSNumber *stopOne = [NSNumber numberWithFloat:0.0];
    NSNumber *stopTwo = [NSNumber numberWithFloat:1.0];

    NSArray *locations = [NSArray arrayWithObjects:stopOne, stopTwo, nil];

    CAGradientLayer *backgroundLayer = [CAGradientLayer layer];
    backgroundLayer.colors = colors;
    backgroundLayer.locations = locations;

    return backgroundLayer;
}

- (void)viewDidAppear:(BOOL)animated
{
    CAGradientLayer *bgLayer = [self backgroundGradient];
    bgLayer.frame = self.view.bounds;
    [self.view.layer insertSublayer:bgLayer atIndex:0];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if (_forecourt == nil) {
        _forecourt = [[ENBForecourt alloc]init];
        [_forecourt addDelegate:self];
    }

    NSUserDefaults* connectionData = [NSUserDefaults standardUserDefaults];

    _txtServerAddress.text = [connectionData objectForKey:@"server"];
    _txtTerminalID.text = [connectionData objectForKey:@"id"];
    _txtTerminalPassword.text = [connectionData objectForKey:@"password"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  Anmination of the loading image
 *
 *  @param sender UIImage View
 */
- (void)change:(id)sender
{
    ratation += 0.1;
    UIImageView* view = (UIImageView*)[sender userInfo];

    if (ratation>2) {
        ratation = 0;
    }

    view.transform = CGAffineTransformMakeRotation(M_PI*ratation);
}

#pragma mark - click operations
- (IBAction)clickLogin:(id)sender {

    if (_txtServerAddress.text.length<=0 || _txtTerminalID.text.length<=0 || _txtTerminalPassword.text.length <=0) {
        return;
    }

    [_btnLogin setBackgroundColor:[UIColor colorWithRed:39/255.0 green:170/255.0 blue:225/255.0 alpha:1]];

    __block UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Connecting..." message:nil delegate:self cancelButtonTitle:nil otherButtonTitles: nil];

    UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:LOGON_SPINNER]];

    [imageView setContentMode:UIViewContentModeCenter];

    [alertView setValue:imageView forKey:@"accessoryView"];

    NSTimer* timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(change:) userInfo:imageView repeats:YES];

    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];

    [alertView show];

    [_forecourt connectToServer:_txtServerAddress.text withTerminalID:[_txtTerminalID.text intValue]  withTerminalName:TERMINALNAME withPassword:_txtTerminalPassword.text setToFallback:YES Completion:^(int result){
        [alertView dismissWithClickedButtonIndex:0 animated:YES];
        if (result == 0) {
            NSUserDefaults* connectionData = [NSUserDefaults standardUserDefaults];

            [connectionData setObject:_txtServerAddress.text forKey:@"server"];
            [connectionData setObject:_txtTerminalID.text forKey:@"id"];
            [connectionData setObject:_txtTerminalPassword.text forKey:@"password"];

            [connectionData synchronize];

            [self authorisedLogin];
        }
        else
        {
            alertView = [[UIAlertView alloc]initWithTitle:@"Connection Result" message:@"Error" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alertView show];
        }
    }];
}

#pragma mark complete login
- (void)loadingDataCompleted
{
    dispatch_semaphore_signal(loading);
}

- (void)authorisedLogin
{
    AppDelegate* app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    [app setForecourt:_forecourt ];
    [app setIsConnected:YES];
    
    [self presentViewController:app.tabbarController animated:YES completion:nil];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - UI Text Delegate
/**
 *  Dismiss the keyboard
 */
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtServerAddress) {
        [self.txtTerminalID becomeFirstResponder];
    }

    if (textField == self.txtTerminalID) {
        [self.txtTerminalPassword becomeFirstResponder];
    }

    if (textField == self.txtTerminalPassword) {
        [textField resignFirstResponder];
        [self clickLogin:_btnLogin];
    }

    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    CGRect frame = textField.frame;

    int offset = frame.origin.y - (self.view.frame.size.height - 216.0);

    [UIView beginAnimations:@"ResizeForKeyBoard" context:nil];
    [UIView setAnimationDuration:0.5];

    if (offset > 0) {
        self.view.frame = CGRectMake(self.view.frame.origin.x, - offset, self.view.frame.size.width, self.view.frame.size.height);
    }

    [UIView commitAnimations];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
}

/**
 *  Use a light view of the status bar
 *
 */
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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
