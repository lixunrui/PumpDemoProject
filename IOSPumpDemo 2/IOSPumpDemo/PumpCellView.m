//
//  PumpCellView.m
//  IOSPumpDemo
//
//  Created by ITL on 27/05/15.
//  Copyright (c) 2015 ITL. All rights reserved.
//

#import "PumpCellView.h"
#import "ImageNames.h"

#define ANIMATION_CALLING @"calling"

/**
 *  Overwrite a table cell, use to store image and some titles
 */
@implementation PumpCellView
{
    UILabel* _pumpNumber;

    UIView* _pumpView;
    UIImageView* _pumpImage;

    UILabel* _pumpRunningTotalValue;
    UILabel* _pumpRunningTotalQuantity;

    UIImageView* _pumpStatus;

    ENBPump* _currentPump;

    float _widthUnit;
    float _heighUnit;

    UIColor* runningColor;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        _pumpView = [[UIView alloc]init];
        [self addSubview:_pumpView];

        _pumpImage = [[UIImageView alloc]initWithImage:[UIImage imageNamed:PUMPCELL_PUMPIMAGE]];
        [_pumpImage setContentMode:UIViewContentModeScaleAspectFit];

        [_pumpView addSubview:_pumpImage];
        _pumpStatus = [[UIImageView alloc]init];

        runningColor = [UIColor colorWithRed:0 green:125/255.0 blue:177/255.0 alpha:1];

    }
    return self;
}

#pragma mark - Setup Pump and init all components
- (void)setupPump:(ENBPump*)pump
{
    _currentPump = pump;
    [_currentPump addDelegate:self];

    _pumpNumber = [[UILabel alloc]init];
    [_pumpNumber setText:[NSString stringWithFormat:@"%d", _currentPump.number]];

    [self addSubview:_pumpNumber];

    [_pumpStatus setImage:nil];
    [self addSubview:_pumpStatus];

    _pumpRunningTotalQuantity = [[UILabel alloc]init];
    _pumpRunningTotalValue = [[UILabel alloc]init];
    _pumpRunningTotalQuantity.hidden = YES;
    _pumpRunningTotalValue.hidden = YES;
    [self addSubview:_pumpRunningTotalQuantity];
    [self addSubview:_pumpRunningTotalValue];

    _widthUnit = self.frame.size.width/6;
    _heighUnit = self.frame.size.height/6;

    [_pumpNumber setFrame:CGRectMake(0, _heighUnit, _widthUnit, _heighUnit*4)];
    [_pumpNumber setFont:[UIFont systemFontOfSize:28]];
    [_pumpNumber setTextAlignment:NSTextAlignmentCenter];

    // update the pump image
    [self updatePumpImage];
    [self updatePumpTrans];
}

/**
 *  Update Pump Widget based on the auto layout view size
 */
- (void)layoutSubviews
{
    float _minUnit = MIN(_widthUnit, _heighUnit*5);

    if (_widthUnit>(_heighUnit*5))
        [_pumpView setFrame:CGRectMake((_widthUnit - _heighUnit*5)/2+_widthUnit, _heighUnit/2, _minUnit, _minUnit)];
    else
        [_pumpView setFrame:CGRectMake(_widthUnit, (_heighUnit*6 - _widthUnit)/2, _minUnit, _minUnit)];

    [_pumpImage setFrame:CGRectMake(0, 0, _pumpView.frame.size.width, _pumpView.frame.size.height)];
    _pumpView.layer.borderWidth = 0;
    _pumpView.layer.borderColor = [UIColor colorWithRed:39/255.0 green:170/255.0 blue:255/255.0 alpha:1].CGColor;

    [_pumpRunningTotalValue setFrame:CGRectMake(_widthUnit*2.1, _heighUnit*0.8, _widthUnit*2.9, _heighUnit*1.8)];
    [_pumpRunningTotalValue setTextAlignment:NSTextAlignmentLeft];

    [_pumpRunningTotalQuantity setFrame:CGRectMake(_widthUnit*2.1, _heighUnit*3.5, _widthUnit*2.9, _heighUnit*1.8)];
    [_pumpRunningTotalQuantity setTextAlignment:NSTextAlignmentLeft];

    [_pumpStatus setFrame:CGRectMake(_widthUnit*5, 0, _widthUnit, _heighUnit*6)];
}

#pragma mark - pump events
- (void)OnFuellingProgress:(ENBPump *)pump Value:(NSDecimalNumber *)value Quantity:(NSDecimalNumber *)quantity Quantity2:(NSDecimalNumber *)quantity2
{
    dispatch_block_t block = ^{
        _pumpRunningTotalQuantity.hidden = NO;
        _pumpRunningTotalValue.hidden = NO;
        [_pumpRunningTotalQuantity setTextColor:runningColor];
        [_pumpRunningTotalValue setTextColor:runningColor];

        _pumpRunningTotalValue.text = [NSString stringWithFormat:@"$ %@", value];
        _pumpRunningTotalQuantity.text = [NSString stringWithFormat:@"L %@",quantity];
    };

    [self updateCell:block];
}

- (void)OnTransactionEvent:(ENBPump *)pump EventType:(ENBTransactionEventType)eventType TransactionID:(NSInteger)transactionId Transaction:(ENBTransaction *)trans
{
    _currentPump = pump;

    if (eventType == ENBTransactionEventTypeCleared) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _pumpRunningTotalQuantity.hidden = YES;
            _pumpRunningTotalValue.hidden = YES;
            [_pumpView setBackgroundColor:[UIColor clearColor]];
        });
    }
    [self updatePumpTrans];
}

- (void)OnStatusDidChangeEvent:(ENBPump *)pump EventType:(ENBPumpStatusEventType)eventType
{
    _currentPump = pump;
    [self updatePumpImage];
}

#pragma mark Support functions
- (void)updatePumpImage
{
    dispatch_block_t block = ^{
        [_pumpImage.layer removeAllAnimations];
        [_pumpImage setImage:[UIImage imageNamed:PUMPCELL_PUMPIMAGE]];
        _pumpStatus.hidden = YES;

        if (_currentPump.isBlocked) {
            [_pumpStatus setImage:[UIImage imageNamed:PUMPCELL_BLOCKED]];
            _pumpStatus.hidden = NO;
        }

        switch (_currentPump.state) {
            case ENBPumpStateNotResponding:
                [_pumpImage setImage:[UIImage imageNamed:PUMPWIDGET_DISCONNECT]];
                break;
            case ENBPumpStateDeliveryPaused:
            case ENBPumpStateDelivering:
                _pumpImage.transform = CGAffineTransformMakeRotation(M_PI_2);
                break;
            case ENBPumpStateCalling:
            {
                CAKeyframeAnimation * animation = [CAKeyframeAnimation animation];
                animation.keyPath = @"transform.rotation.z";
                animation.values=@[@0, @((30.0f* M_PI)/180.0f), @0];
                animation.keyTimes = @[@0, @(1/2.0f), @1];
                animation.duration = 1;
                animation.repeatCount = INFINITY;
                animation.additive = YES;
                [_pumpImage.layer addAnimation:animation forKey:ANIMATION_CALLING];
            }
                break;

            case ENBPumpStateDeliveryStopped:
                [_pumpStatus setImage:[UIImage imageNamed:PUMPCELL_STOPPED]];
                break;
                
            case ENBPumpStateLocked:
            case ENBPumpStateDeliveryFinished:
                _pumpImage.transform = CGAffineTransformMakeRotation(0);
                break;
            default:
                break;
        }
    };

    [self updateCell:block];
}

// If there is a transaction, then we update the UI to display the transaction
- (void)updatePumpTrans
{
    dispatch_block_t block = ^{
        _pumpRunningTotalQuantity.hidden = YES;
        _pumpRunningTotalValue.hidden = YES;

    if ([_currentPump isCurrentTransaction]) {
        if (![_currentPump isBlocked]) {
            _pumpStatus.hidden = YES;
        }

        switch ([_currentPump currentTransaction].state) {
            case ENBTransactionStateAuthorised:
                [_pumpStatus setImage:[UIImage imageNamed:PUMPCELL_AUTHRISED]];
                _pumpStatus.hidden = NO;
                break;
            case ENBTransactionStateFuelling:
                _pumpRunningTotalValue.hidden = NO;
                _pumpRunningTotalQuantity.hidden = NO;
                break;
            case ENBTransactionStateCompleted:
                _pumpRunningTotalValue.hidden = NO;
                _pumpRunningTotalQuantity.hidden = NO;
                [self transCompleted:[_currentPump currentTransaction]];
                break;
            case ENBTransactionStateCleared:

                break;
            case ENBTransactionStateCancelled:

                break;
            default:
                break;
        }
        }
    };
        [self updateCell:block];
}

- (void)transCompleted:(ENBTransaction*)trans
{
    [_pumpView setBackgroundColor:[UIColor colorWithRed:212/255.0 green:238/255.0 blue:249/255.0 alpha:1]];

    [_pumpRunningTotalQuantity setTextColor:[UIColor blackColor]];
    [_pumpRunningTotalValue setTextColor:[UIColor blackColor]];

    [_pumpRunningTotalValue setText:[NSString stringWithFormat:@"$ %@",trans.deliveryData.money]];
    [_pumpRunningTotalQuantity setText:[NSString stringWithFormat:@"L %@",trans.deliveryData.quantity]];
}


#pragma mark - UI Update
- (void)updateCell:(dispatch_block_t) block
{
    dispatch_async(dispatch_get_main_queue(), block);
}

#pragma mark - default methods
- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}
@end
