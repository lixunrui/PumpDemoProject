//
//  TestClick.m
//  PumpUIDemo2
//
//  Created by Raymond Li on 30/03/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "PumpWidgetUIView.h"
#import "ImageNames.h"
@import EnablerApi;

#define ANIMATION_CALLING @"calling"
#define ANIMATION_DELIVERING @"delivering"
#define ANIMATION_LOCKED @"locked"

#define PUMP_ACTIVITY @"pump activity";

@implementation PumpWidgetUIView
{
    // Image Set
    UIImage* _pumpImage;
    UIImage* _authoriseImage;
    UIImage* _stopImage;
    UIImage* _pauseImage;
    UIImage* _priceChangeImage;
    UIImage* _disconnectImage;
    UIImage* _stackTransImage;
    UIImage* _blockImage;
    
    // Image View set
    UIImageView* _pumpImageView;
    UIImageView* _authImageView;
    UIImageView* _stopImageView;
    UIImageView* _pauseImageView;
    UIImageView* _priceChangeImageView;
    UIImageView* _disconnectImageView;
    UIImageView* _stackedTransImageView;
    UIImageView* _blockImageView;

    UILabel* _valueLabel; // Value: 11
    UILabel* _volumeLabel; // Volume: 12.6
    UILabel* _transLable;
    
    UILabel* _pumpInfo; // display Pump ID and current grade if has
    
    ENBPump* _currentPump;

    // Split a cell unit into several small units, in order to locate emelemts as we need
    float widthUnit; // 1/5 of the viewWidth
    float heighUnit; // 1/6 of the viewHeigh

    BOOL reloadRequired;
}

#pragma mark - Init functions
- (instancetype)init
{
    self = [super init];
    if (self) {
        reloadRequired = YES;
        [self initialization];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        reloadRequired = YES;
        [self initialization];
    }
    return self;
}

- (void)reloadLayout
{
    reloadRequired = YES;
}

/**
 *  Initialize all images, imageviews and labels here
 */
- (void)initialization
{
    if (reloadRequired) {

        heighUnit = self.frame.size.height/6;
        widthUnit = self.frame.size.width/5;

        [self initAllImages];
        [self initAllImageViews];
        [self initAllLabels];

        CALayer * roundCorner = [self layer];

        [roundCorner setMasksToBounds:YES];

        [roundCorner setBorderColor:[UIColor colorWithRed:39/255.0 green:170/255.0 blue:225/255.0 alpha:1].CGColor];
        [roundCorner setBorderWidth:1];

        reloadRequired = NO;
    }
}

#pragma mark - init images, views and labels functions
- (void)initAllImages
{
    _pumpImage = [UIImage imageNamed:PUMPWIDGET_PUMPIMAGE];
    _authoriseImage = [UIImage imageNamed:PUMPWIDGET_AUTHORISED];
    
    _stopImage = [UIImage imageNamed:PUMPWIDGET_STOPPED];
    _disconnectImage= [UIImage imageNamed:PUMPWIDGET_DISCONNECT];

    _stackTransImage = [UIImage imageNamed:PUMPWIDGET_STACK];
    _blockImage = [UIImage imageNamed:PUMPWIDGET_BLOCKED];
}

- (void)initAllImageViews
{
    CGFloat maxUnit = MAX(widthUnit, heighUnit);
    _pumpImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthUnit, heighUnit, maxUnit*3, maxUnit*3)];
    [_pumpImageView setImage:_pumpImage];
    [_pumpImageView setContentMode:UIViewContentModeScaleAspectFit];
    
    [self addSubview:_pumpImageView];
    
    _authImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthUnit/3, heighUnit*3, widthUnit*2, heighUnit*2)];
    [_authImageView setImage:_authoriseImage];
    _authImageView.hidden = YES;
    [_authImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_authImageView];
    
    _stopImageView = [[UIImageView alloc]initWithFrame:CGRectMake(widthUnit, heighUnit, widthUnit*3, heighUnit*3)];
    [_stopImageView setImage:_stopImage];
    _stopImageView.hidden = YES;
    [_stopImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_stopImageView];

    _pauseImageView = [[UIImageView alloc]initWithFrame:CGRectMake(widthUnit*3, heighUnit, widthUnit, heighUnit)];
    [_pauseImageView setImage:_pauseImage];
    _pauseImageView.hidden = YES;
    [_pauseImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_pauseImageView];
    
    _priceChangeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthUnit*3, heighUnit, widthUnit, heighUnit)];
    [_priceChangeImageView setImage:_priceChangeImage];
    _priceChangeImageView.hidden=YES;
    [_priceChangeImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_priceChangeImageView];
    
    _disconnectImageView = [[UIImageView alloc] initWithFrame:CGRectMake(widthUnit, heighUnit, widthUnit*3, heighUnit*3)];
    [_disconnectImageView setImage:_disconnectImage];
    _disconnectImageView.hidden=YES;
    [_disconnectImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_disconnectImageView];

    _stackedTransImageView = [[UIImageView alloc]initWithFrame:CGRectMake(widthUnit*4, heighUnit, widthUnit, heighUnit)];
    [_stackedTransImageView setImage:_stackTransImage];
    _stackedTransImageView.hidden = YES;
    [_stackedTransImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_stackedTransImageView];

    _blockImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, heighUnit, widthUnit, heighUnit)];
    [_blockImageView setImage:_blockImage];
    _blockImageView.hidden=YES;
    [_blockImageView setContentMode:UIViewContentModeScaleAspectFit];
    [self addSubview:_blockImageView];
}

- (void)initAllLabels
{
    _valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(widthUnit, heighUnit*4.5, widthUnit*5, heighUnit*0.6)];
    [_valueLabel setFont:[UIFont systemFontOfSize:15]];
    _valueLabel.textAlignment = NSTextAlignmentLeft;
    _valueLabel.textColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:112/255.0 alpha:1];
    _valueLabel.hidden = YES;
    
    _volumeLabel = [[UILabel alloc] initWithFrame:CGRectMake(widthUnit, heighUnit*5.2, widthUnit*5,  heighUnit*0.6)];
    [_volumeLabel setFont:[UIFont systemFontOfSize:15]];
    _volumeLabel.textColor = [UIColor colorWithRed:0/255.0 green:84/255.0 blue:112/255.0 alpha:1];
    _volumeLabel.textAlignment = NSTextAlignmentLeft;
    _volumeLabel.hidden=YES;

    _transLable = [[UILabel alloc]initWithFrame:CGRectMake(0, heighUnit*4, widthUnit*5, heighUnit*2)];
    [_transLable setFont:[UIFont systemFontOfSize:15]];
    _transLable.textColor = [UIColor blackColor];
    _transLable.textAlignment = NSTextAlignmentCenter;
    _transLable.hidden=YES;

    _pumpInfo = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, widthUnit*5, heighUnit)];
    [_pumpInfo setFont:[UIFont systemFontOfSize:12]];
    _pumpInfo.textColor = [UIColor blackColor];
    _pumpInfo.textAlignment = NSTextAlignmentCenter;
    _pumpInfo.hidden = NO;
    
    [self addSubview:_valueLabel];
    [self addSubview:_volumeLabel];
    [self addSubview:_pumpInfo];
    [self addSubview:_transLable];
}


#pragma mark - Supported Functions

- (void)setPump:(ENBPump*)pump
{
    _currentPump = pump;
    [_currentPump addDelegate:self];

    dispatch_async(dispatch_get_main_queue(), ^{
        _pumpInfo.text = [NSString stringWithFormat:@"Pump %li", (long)_currentPump.number];
    });

    [self setupPumpState];
    [self updateStackTrans];

    if ([_currentPump state] == ENBPumpStateNotResponding ||
        [_currentPump state] == ENBPumpStateNotInstalled) {
        return;
    }
    
    if (_currentPump.isCurrentTransaction) {
        [self updateDisplay:[_currentPump currentTransaction]];
    }
}

#pragma mark - Pump Animation
- (void)startAnimation
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.duration = 0.5; // half second
    animation.repeatCount = 1; // repeat once
    
    animation.fromValue=[NSNumber numberWithFloat:0.0f];
    animation.toValue=[NSNumber numberWithFloat:((90.0f* M_PI)/180.0f)];
    
    animation.fillMode = kCAFillModeForwards;
    
    animation.removedOnCompletion = NO;
    
    [_pumpImageView.layer addAnimation:animation forKey:ANIMATION_DELIVERING];
}

- (void)dismissAnimation
{
    CABasicAnimation* animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    animation.duration = 0.5; // one second
    animation.repeatCount = 1; // repeat once
    
    animation.fromValue=[NSNumber numberWithFloat:((90.0f* M_PI)/180.0f)];
    animation.toValue=[NSNumber numberWithFloat:0.0f];
    
    animation.fillMode = kCAFillModeForwards;
    
    animation.removedOnCompletion = NO;

    [_pumpImageView.layer addAnimation:animation forKey:ANIMATION_LOCKED];
}

- (void)showCallingAnimation
{
    CAKeyframeAnimation * animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"transform.rotation.z";
    
    animation.values=@[@0, @((15.0f* M_PI)/180.0f), @0];
    
    animation.keyTimes = @[@0, @(1/2.0f), @1];
    
    animation.duration = 0.5;
    
    animation.repeatCount = INFINITY;
    
    animation.additive = YES;
    
    [_pumpImageView.layer addAnimation:animation forKey:ANIMATION_CALLING];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark - internal methods
- (void)hideAllViews
{
    _disconnectImageView.hidden = YES;
    _authImageView.hidden = YES;
    _pauseImageView.hidden = YES;
    _stopImageView.hidden = YES;
    _blockImageView.hidden = YES;
}

- (void)showPumpStop
{
    dispatch_block_t block = ^{
        if ([_currentPump isBlocked]) {
            _blockImageView.hidden = NO;
        }
        else
        {
            _blockImageView.hidden = YES;
        }
    };
    [self updateUI:block];
}

- (void)updateStackTrans
{
    NSString* imageName ;
    dispatch_block_t block ;
    if (_currentPump.transactionStack.count>0) {
        if (_currentPump.transactionStack.count<=5) {
            imageName = [NSString stringWithFormat:@"%@%ld", PUMPWIDGET_STACK,(long)_currentPump.transactionStack.count];
        }
        else
            imageName =[NSString stringWithFormat:@"%@5",PUMPWIDGET_STACK];
        block = ^{
            _stackedTransImageView.hidden = NO;
            [_stackedTransImageView setImage:[UIImage imageNamed:imageName]];
        };
    }
    else
    {
        block = ^{
            _stackedTransImageView.hidden = YES;
        };
    }

    [self updateUI:block];
}

- (void)setupPumpState
{
    dispatch_block_t block = ^{
    [self hideAllViews];

    if (_currentPump.isBlocked) {
            _blockImageView.hidden = NO;
    }

    switch ((ENBPumpState)[_currentPump state]) {
        case ENBPumpStateNotInstalled:
        case ENBPumpStateNotResponding:
            _disconnectImageView.hidden = NO;
            break;
        case ENBPumpStateAuthorising:
            _authImageView.hidden = NO;
            break;
        case ENBPumpStateCalling:
        {
            _pumpInfo.text = [NSString stringWithFormat:@"Pump %li: %@", (long)_currentPump.number, _currentPump.currentHose.grade.name];
            [self showCallingAnimation];
        }
            break;
        case ENBPumpStateDelivering:
        {
            _pumpInfo.text = [NSString stringWithFormat:@"Pump %li: %@", (long)_currentPump.number, _currentPump.currentHose.grade.name];
            _authImageView.hidden = NO;
            [self startAnimation];

        }
            break;
        case ENBPumpStateDeliveryStopped:
            _stopImageView.hidden = NO;
            _blockImageView.hidden=NO;
            break;
        case ENBPumpStateDeliveryPaused:
            _pauseImageView.hidden = NO;
            break;
        case ENBPumpStateLocked:
            _pumpInfo.text = [NSString stringWithFormat:@"Pump %li", (long)_currentPump.number];
            if ([_currentPump isBlocked]) {
                _blockImageView.hidden = NO;
            }
            [_pumpImageView.layer removeAllAnimations];
            break;
        case  ENBPumpStateDeliveryFinished:
        {
            [self dismissAnimation];

        }
            break;
        default:
            break;
    }
    };

    [self updateUI:block];
}

#pragma mark - pump event
- (void)OnFuellingProgress:(ENBPump *)pump Value:(NSDecimalNumber *)value Quantity:(NSDecimalNumber *)quantity Quantity2:(NSDecimalNumber *)quantity2
{
    [self updateRunningTotal:value QuantityOne:quantity QuantityTwo:quantity2];
}

- (void)OnStatusDidChangeEvent:(ENBPump *)pump EventType:(ENBPumpStatusEventType)eventType
{
    if (pump) {
        if (_currentPump.ID != pump.ID) {
            return;
        }
    }
    _currentPump = pump;
    switch (eventType) {
        case ENBPumpStatusEventTypeBlocked:
            [self showPumpStop];
            break;
        case ENBPumpStatusEventTypeState:
        {
            [self setupPumpState];
        }
            break;
        case ENBPumpStatusEventTypeFuelFlow:
            [self updateDisplay:_currentPump.currentTransaction];
            break;
        default:
            break;
    }
}

- (void)OnTransactionEvent:(ENBPump *)pump EventType:(ENBTransactionEventType)eventType TransactionID:(NSInteger)transactionId Transaction:(ENBTransaction *)trans
{
    if (pump) {
        if (_currentPump.ID == pump.ID) {
            _currentPump = pump;
            switch (eventType) {
                case ENBTransactionEventTypeAuthorised:
                case ENBTransactionEventTypeFuelling:
                case ENBTransactionEventTypeCompleted:
                case ENBTransactionEventTypeCleared:
                    [self updateDisplay:trans];
                    break;
                default:
                    break;
            }
            [self updateStackTrans];
        }
    }
}

#pragma mark support functions
- (void)updateRunningTotal:(NSDecimalNumber*)money
               QuantityOne:(NSDecimalNumber*)quantity1
               QuantityTwo:(NSDecimalNumber*)quantity2
{
    dispatch_async(dispatch_get_main_queue(), ^{
        _valueLabel.hidden = NO;
        _volumeLabel.hidden = NO;
        [_valueLabel setText:[NSString stringWithFormat:@"$ %@",money]];
        [_volumeLabel setText:[NSString stringWithFormat:@"L %@", quantity1]];
    });
}

- (void)updateDisplay:(ENBTransaction*)trans
{
    dispatch_block_t block = ^{
        _volumeLabel.hidden = YES;
        _valueLabel.hidden = YES;
        _transLable.hidden = YES;
        _authImageView.hidden = YES;
        switch (trans.state) {
            case ENBTransactionStateAuthorised:
                    _authImageView.hidden = NO;
                    _valueLabel.text = nil;
                    _volumeLabel.text = nil;
                break;

            case ENBTransactionStateFuelling:
            {
               [self updateRunningTotal:trans.deliveryData.money QuantityOne:trans.deliveryData.quantity QuantityTwo:nil];
            }
                break;

            case ENBTransactionStateCompleted:
            {
                _transLable.hidden = NO;
                _transLable.text = [NSString stringWithFormat:@"$ %@ L %@",trans.deliveryData.money, trans.deliveryData.quantity];
            }
                break;

            case ENBTransactionStateCleared:
            {
                if ([_currentPump isCurrentTransaction]) {
                    if ([_currentPump currentTransaction].ID == trans.ID) {
                        _transLable.text = nil;
                    }
                    else
                    {
                        if ([_currentPump currentTransaction].state == ENBTransactionStateCompleted) {
                            _transLable.hidden = NO;
                        }
                    }
                }

            }
                break;

            case ENBTransactionStateCancelled:
                break;

            case ENBTransactionStateReserved:
                break;
            default:
                break;
        }
    };
    [self updateUI:block];
}

#pragma mark Update UI
- (void)updateUI:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), block);
}
@end
