//
//  PumpViewController.m
//  IOSPumpDemo
//
//  Created by ITL on 27/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "PumpViewController.h"
#import "PumpWidgetUIView.h"
#import "UIButton+ButtomLayout.h"
#import "ImageNames.h"

#define PUMPVIEWMARGINLEFTRIGHT 25
#define BUTTON_AUTH @"Authorise"
#define BUTTON_STOP @"Stop"
#define BUTTON_BLOCK @"Block"
#define BUTTON_UNBLOCK @"Unblock"

extern ENBForecourt* _forecourt;
@interface PumpViewController ()

@end

@implementation PumpViewController
{
    IBOutlet ScrollView *pumpWidgetView;
    __weak IBOutlet UIButton *btnAuthorise;
    __weak IBOutlet UIButton *btnStop;
    __weak IBOutlet UIButton *btnBlock;
    __weak IBOutlet UITableView *transTable;

    BOOL pumpStopped;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [btnAuthorise centerImageAndTitle];
    [btnBlock centerImageAndTitle];
    [btnStop centerImageAndTitle];
    
    transTable.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    [transTable reloadData];
    [_currentPump addDelegate:self];
    [self loadButtons];
    // Do any additional setup after loading the view.
    pumpWidgetView.delegate = self;
    pumpWidgetView.dataSource = self;
    pumpWidgetView.orientation = ScrollViewOrientationHorizontal;

    // preload the specific pump
    [pumpWidgetView initializeWithItemNumber:_currentPump.number-1];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)loadButtons
{
    pumpStopped = _currentPump.isBlocked;
    if (pumpStopped) {
        [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK] forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:170/255.0 green:226/255.0 blue:60/255.0 alpha:1]];
    }
    else
    {
        [btnBlock setTitle:BUTTON_BLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_BLOCK] forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:134/255.0 green:134/255.0 blue:134/255.0 alpha:1]];
    }
}

#pragma mark - Scroll delegate
- (CGSize)itemSizeInScrollView:(ScrollView *)scrollView
{
    return CGSizeMake(pumpWidgetView.bounds.size.width, pumpWidgetView.bounds.size.height);
}

- (UIView *)scrollView:(ScrollView *)scrollView cellForItemAtIndex:(NSInteger)index
{
    PumpWidgetUIView* pumpWidgetUI = (PumpWidgetUIView*)[pumpWidgetView dequeueReuseableCellFromIndex:index];

    if ((NSObject*)pumpWidgetUI == [NSNull null]) {
        pumpWidgetUI = [[PumpWidgetUIView alloc]initWithFrame:CGRectMake(0,0, pumpWidgetView.bounds.size.width, pumpWidgetView.bounds.size.height)];
        [pumpWidgetUI setPump:[_forecourt.pumps getByIndex:(int)index]];
    }

    return pumpWidgetUI;
}

- (NSInteger)numberOfItemsInScrollView:(ScrollView *)scrollView
{
    return _forecourt.pumps.count;
}

- (void)didScrollToItem:(NSInteger)itemNumber inScrollView:(ScrollView *)scrollView
{
    _currentPump = [_forecourt.pumps getByIndex:(int)(itemNumber)];
    [self loadButtons];
    [_currentPump addDelegate:self];
    [transTable reloadData];
}


#pragma mark - Click operations
- (IBAction)ClickAuth:(id)sender {
    int result = [_currentPump authoriseNoLimitsWithClientActivtity:@"IOS" ClientReference:@"IOS Client" AttendantID:-1];
    if (result != 0) {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

- (IBAction)ClickStop:(id)sender {
    int result = [_currentPump stop];
    if (result == 0) {
        pumpStopped = YES;
        [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
        [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK] forState:UIControlStateNormal];
        [btnBlock setBackgroundColor:[UIColor colorWithRed:170/255.0 green:226/255.0 blue:60/255.0 alpha:1]];
    }
    else
    {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

- (IBAction)ClickBlock:(id)sender {

    int result;
    if (pumpStopped) {
        result = [_currentPump setBlock:NO ReasonMessage:@"IOS UnBlock"];
        if (result == 0) {
            [btnBlock setTitle:BUTTON_BLOCK forState:UIControlStateNormal];
            [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_BLOCK] forState:UIControlStateNormal];
            [btnBlock setBackgroundColor:[UIColor colorWithRed:134/255.0 green:134/255.0 blue:134/255.0 alpha:1]];
            pumpStopped = NO;
        }
    }
    else
    {
        result = [_currentPump setBlock:YES ReasonMessage:@"IOS Block"];
        if (result == 0) {
            [btnBlock setTitle:BUTTON_UNBLOCK forState:UIControlStateNormal];
            [btnBlock setImage:[UIImage imageNamed:PUMPDETAILSBUTTON_UNBLOCK] forState:UIControlStateNormal];
            [btnBlock setBackgroundColor:[UIColor colorWithRed:170/255.0 green:226/255.0 blue:60/255.0 alpha:1]];
            pumpStopped = YES;
        }
    }

    if (result != 0 ) {
        [self showAlertWithMessage:[ENBForecourt getResultString:result]];
    }
}

- (IBAction)buttonTouchEffect:(UIButton *)sender {
    [sender setAlpha:0.8];
}

- (IBAction)buttonTouchFinish:(UIButton *)sender
{
    [sender setAlpha:1];
}

#pragma mark - Pump Events
- (void)OnTransactionEvent:(ENBPump *)pump EventType:(ENBTransactionEventType)eventType TransactionID:(NSInteger)transactionId Transaction:(ENBTransaction *)trans
{
    if (pump) {
        if (pump.ID == _currentPump.ID) {
            _currentPump = pump;
            switch (eventType) {
                case ENBTransactionEventTypeStacked:
                case ENBTransactionEventTypeCleared:
                {
                    dispatch_async(dispatch_get_main_queue(), ^{[transTable reloadData];});
                    break;
                }
                default:
                    break;
            }
        }
    }
}

- (void)OnStatusDidChangeEvent:(ENBPump *)pump EventType:(ENBPumpStatusEventType)eventType
{
    if (pump) {
        if (pump.ID == _currentPump.ID) {
            _currentPump = pump;
            if (eventType == ENBPumpStatusEventTypeBlocked) {
                dispatch_async(dispatch_get_main_queue(), ^{ [self loadButtons];});
            }
        }
    }

}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - table view
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[ UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"];

    ENBTransaction* trans =[_currentPump.transactionStack getByIndex:(int)indexPath.row];

    cell.textLabel.text = [NSString stringWithFormat:@"%@: $ %@,L %@", trans.deliveryData.grade.name, trans.deliveryData.money, trans.deliveryData.quantity];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Hose:%d, Unit Price:%@", trans.hose.number, trans.deliveryData.unitPrice];
    [cell.textLabel setFont:[UIFont systemFontOfSize:15]];
    [cell.detailTextLabel setFont:[UIFont systemFontOfSize:12]];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return _currentPump.transactionStack.count;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Stacked Deliveries";
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return  33;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.contentView.backgroundColor = [UIColor clearColor];
    UIView* clearRoundedCornerView = [[UIView alloc] initWithFrame:CGRectMake(0, 3, cell.frame.size.width, cell.frame.size.height-6)];
    clearRoundedCornerView.backgroundColor = [UIColor whiteColor];
    clearRoundedCornerView.layer.masksToBounds = NO;
    clearRoundedCornerView.layer.cornerRadius = 3.0;
    //clearRoundedCornerView.layer.shadowOffset = CGSizeMake(-1, 1);
    //clearRoundedCornerView.layer.shadowOpacity = 0.5;

    [cell.contentView addSubview:clearRoundedCornerView];
    [cell.contentView sendSubviewToBack:clearRoundedCornerView];
}

#pragma mark - Support
- (void)showAlertWithMessage:(NSString*)message
{
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:@"Results" message:message delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
    [alertView show];
}
@end
