//
//  PumpPublic.h
//  EnablerApi
//
//  Created by ITL on 8/05/15.
//  Copyright (c) 2015 Itl. All rights reserved.
//


#import "PumpStates.h"
#import "PumpAuthorise.h"
#import "HosePublic.h"

@class ENBPump;
@class ENBTransaction;
@class TransactionCollection;
@class HoseCollection;


/*!
 *  Protocol used to fire events from a pump or pump collection.
 */
@protocol PumpEventDelegates
@optional
/*!
 *  This event is fired when the PumpStatus changes.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of PumpStatus that triggered this event.
 */
-(void)OnStatusDidChangeEvent:(ENBPump*)pump
                    EventType:(ENBPumpStatusEventType)eventType;
/*!
 *  <#Description#>
 *
 *  @param pump      The pump firing the event.
 *  @param value     The current money value of fuel delivered for the current fuel transaction.
 *  @param quantity  The current quantity/volume of fuel delivered for the current fuel transaction.
 *                   For blended products this indicates the total gross volume delivered (primary + secondary product).
 *  @param quantity2 The current quantity/volume of the secondary grade delivered for the current fuel transaction for blended products. 
 *                   Always zero (0) for non-blended transactions.
 */
-(void)OnFuellingProgress:(ENBPump*)pump
                    Value:(NSDecimalNumber *)value
                 Quantity:(NSDecimalNumber *)quantity
                Quantity2:(NSDecimalNumber *)quantity2;
/*!
 *  This event is fired when a hose event occurs.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of hose event that caused the event.
 */
-(void)OnHoseEvent: (ENBPump *)pump
               EventType:(ENBhoseEventType)eventType;
/*!
 *  This event is fired when a TransactionEvent occurs.
 *
 *  @param pump      The pump firing the event.
 *  @param eventType The type of TransactionEvent that triggered this event.
 *  @param transactionId     The associatted transaction Id.
 *  @param trans     The associatted transaction.
 */
-(void)OnTransactionEvent:(ENBPump *)pump
                 EventType:(ENBTransactionEventType)eventType
            TransactionID:(NSInteger)transactionId
               Transaction:(ENBTransaction*)trans;

// FIXME: OnTransactionEvents should also have transaction ID
@end

/*!
 *  Pump object
 */
@interface ENBPump

/*!
 *  Pumps decription
 */
@property (readonly) NSString *    description;

/*!
 *  Unique ID of the pump
 */
@property (readonly) int           ID;

/*!
 *  Number of Pump.
 */
@property (readonly) int number;

/*!
 *  State of the fuel flow for the current delivery. If true the fuel is flowing.
 */
@property (readonly) BOOL          fuelFlow;

/*!
 *  Returns true if pump is blocked
 */
@property (readonly) BOOL          isBlocked;

/*!
 *  Returns the current state of the pumps lights
 */
@property (readonly) BOOL            pumpLights;

/*!
 *  Returns a bitmap of the reasons the Pump is blocked.
 */
@property (readonly) ENBPumpBlockedReason blockedReason;

/*!
 *  Returns the current state of the pump
 */
@property (readonly) int           state;

/*!
 *  Gets a reference to the hose object currently lifted from the pump if it is calling or delivering.
 */
@property (readonly) ENBHose*     currentHose;

/*!
 *  Collection of Hoses on pump
 */
@property (readonly) HoseCollection* hoses;

/*!
 *  Returns true if there is a Current Transaction.
 */
@property (readonly) BOOL isCurrentTransaction;

/*!
 *  Returns the current transaction on the pump.  A transaction begins as soon as the pump is reserved or authorised. Once it is completed, the transaction remains on the pump until it is cleared or stacked.
 */
@property (readonly) ENBTransaction* currentTransaction;

/*!
 *  The transaction stack stores a list of Transaction objects for the pump that have been completed and stacked by calling Pump.StackCurrentTransaction but have not yet been cleared (sold).
 *  Returns the Transaction stack collection.
 */
@property (readonly) TransactionCollection* transactionStack;

//******************
// Pump commands
//******************

/*!
 *  Authorise the pump with no limits.
 *
 *  @param clientActivity  Client activity is an optional string to indicate activity or what ever the client application wants to store against transaction.
 *  @param clientReference Client reference string(optional). This must match any previous Reserve. The Client reference will be recorded against the transaction. The Transaction can then be looked up using the Client reference.
 *  @param attendantID     Id of attendant for an Attendant authorise or -1 when no attendant.
 *
 *  @return Api result code
 */
-(int)authoriseNoLimitsWithClientActivtity:(NSString *)clientActivity ClientReference:(NSString *)clientReference AttendantID:(int)attendantID;

/*!
 *  Authorise the pump with limits.
 *
 *  @param clientActivity  Client activity is an optional string to indicate activity or what ever the client application wants to store against transaction.
 *  @param clientReference Client reference string(optional). This must match any previous Reserve. The Client reference will be recorded against the transaction. The Transaction can then be looked up using the Client reference.
 *  @param attendantID     Id of attendant for an Attendant authorise or -1 when no attendant.
 *  @param limits           ENBPumpAuthoriseLimits class containing the limits to be applied to Authorise
 *
 *  @return Api result code
 */
-(int)authoriseWithClientActivtity:(NSString *)clientActivity
                    ClientReferece:(NSString *)clientReference
                       attendantID:(int)attendantID
               PumpAuthoriseLimits:(ENBPumpAuthoriseLimits *) limits;

/*!
 *  Cancel the Authorisation from a pump.
 *
 *  @return Api result code
 */
-(int)cancelAuthorise;

/*!
 *  Cancel a previous reserve against pump
 *
 *  @return Api result code
 */
-(int)cancelReserve;

/*!
 *  Permanently stop an in progress delivery.
 *
 *  @return Api result code
 */
-(int)stop;

/*!
 *  Pause an in progress delivery on the pump.
 *
 *  @return Api result code
 */
-(int)pause;

/*!
 *  Resume an in progress delivery on the pump.
 *
 *  @return Api result code
 */
-(int)resume;

/*!
 *  Move the current Transaction out of the CurrentTransaction to allow a new Transaction to begin and into the Pump.TransactionStack.
 *
 *  @return Api result code
 */
-(int)stackCurrentTransaction;

/*!
 *  Blocks all operations on this pump and prevents it from starting a new transaction.
 *
 *  @param blockState Set to true to block pump, false to unblock.
 *  @param message    An optional message to assign a reason for blocking this pump. This message will be logged in the system journal if present.
 *
 *  @return Api result code
 */
-(int)setBlock:(bool)blockState
 ReasonMessage:(NSString*)message;


/**
 *  Returns the culture specific string resource from framework for the pump state
 *
 *  @param pumpState Pump state to get
 *
 *  @return String containing the requested pump state string
 */
+ (NSString*)getPumpStateString:(ENBPumpState) pumpState;


// Add - Remove client delegates

/*!
 *  Adds a delegate to list of delegates called on pump events.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<PumpEventDelegates>)delegate;

/*!
 *  Removes the passed delgate from the list of delegates called on pump events.
 *
 *  @param delegate The delegate to remove.
 */
-(void) removeDelegate:(id<PumpEventDelegates>)delegate;

@end



/*!
 *  Pump collection object
 */
@interface PumpCollection : NSObject <PumpEventDelegates, NSFastEnumeration>

/*!
 *  Number of pumps in the pump collection.
 */
@property (readonly) int count;

/*!
 *  Get a pump by its id.
 *
 *  @param ID Id of pump to get.
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getById:(int) ID;

/*!
 *  Get a pump by its number.
 *
 *  @param number Number of pump to get.
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getByNumber:(int) number;

/*!
 *  Get a pump by its index in the pump collection.
 *
 *  @param index    index of pump
 *
 *  @return Returns the pump or nil if not found.
 */
- (ENBPump *)getByIndex:(int) index;

/*!
 *  Adds a delegate to list of delegates called on any pump events. Adding a delegate to the Pump collection will monitor events for all pump.
 *  Each pump event will return a refernce to the pump firing the event.
 *
 *  @param delegate The delegate to add
 */
-(void) addDelegate:(id<PumpEventDelegates>)delegate;

/*!
 *  Removes the passed delgate from the list of delegates called on any pump events.
 *
 *  @param delegate The delegate to remove
 */
-(void) removeDelegate:(id<PumpEventDelegates>)delegate;

@end

