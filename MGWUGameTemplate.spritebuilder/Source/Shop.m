//
//  Shop.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Shop.h"
#import "GameManager.h"
#import "Mixpanel.h"
#import <StoreKit/StoreKit.h>

@implementation Shop {
    CCNode *_shop;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
    CCLabelTTF *_youHaveBubbleNum;
    
    int _bubbleToBeAdded;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    _bubbleToBeAdded = 0;
    [self updateBubbleNumText];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)cancel {
    [GameManager playThenCleanUpAnimationOf:_shop Named:@"Disappear"];
}

- (void)bubble1 {
    NSString * productName = @"skyjumper.bubble.10";
    [self startInAppPurchaseWithProductName:productName];
    _bubbleToBeAdded = 10;
}

- (void)bubble2 {
    NSString * productName = @"skyjumper.bubble.35";
    [self startInAppPurchaseWithProductName:productName];
    _bubbleToBeAdded = 35;
}

- (void)bubble3 {
    NSString * productName = @"skyjumper.bubble.60";
    [self startInAppPurchaseWithProductName:productName];
    _bubbleToBeAdded = 60;
}

- (void)bubble4 {
    NSString * productName = @"skyjumper.bubble.130";
    [self startInAppPurchaseWithProductName:productName];
    _bubbleToBeAdded = 130;
}

- (void)startInAppPurchaseWithProductName: (NSString *)productName {
    // chech if the user allow in-app-purchase.
    if ([SKPaymentQueue canMakePayments]) {
        // get product information with product name.
        NSSet * set = [NSSet setWithArray:@[productName]];
        SKProductsRequest * request = [[SKProductsRequest alloc] initWithProductIdentifiers:set];
        request.delegate = self;
        [request start];
    } else {
        CCLOG(@"Purchase failed. The user forbids in app purchase.");
    }
}

// the call back function for SKProductsRequest
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *myProduct = response.products;
    if (myProduct.count == 0) {
        CCLOG(@"Cannot find info of this product, the purchase failed.");
        return;
    }
    
    SKPayment * payment = [SKPayment paymentWithProduct:myProduct[0]];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions){
        switch (transaction.transactionState){
            case SKPaymentTransactionStatePurchased: //Transaction finished.
                CCLOG(@"transactionIdentifier = %@", transaction.transactionIdentifier);
                [self completeTransaction:transaction];
                break;
            case SKPaymentTransactionStateFailed: //Transaction failed.
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: //This product is already bought.
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing: //Add this product into list.
                CCLOG(@"Purchasing....");
                break;
            default:
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    CCLOG(@"IAP Transaction Completed");
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // add bubble in game.
    [_gameManager addBubble:_bubbleToBeAdded];
    [self updateBubbleNumText];
    [_gameManager updateBubbleNumInGamePlay:_gameManager.bubbleNum];
    _bubbleToBeAdded = 0;
    
    // track in mixpanel.
    [_mixpanel track:@"Transaction Finish" properties:@{@"ItemName": @"Bubble", @"Number": [NSNumber numberWithInt:_bubbleToBeAdded], @"Price": [NSNumber numberWithFloat:[self getItemPrice:_bubbleToBeAdded]] }];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        CCLOG(@"Purchase failed, error message: %@", transaction.error.description);
    } else {
        CCLOG(@"User cancelled purchase.");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    CCLOG(@"Transaction Restored");
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
}

- (float)getItemPrice:(int)bubbleNum {
    switch (bubbleNum) {
        case 10: return 0.99;
        case 35: return 2.99;
        case 60: return 4.99;
        case 130: return 9.99;
        default: return 0;
    }
}

- (void)updateBubbleNumText {
    _youHaveBubbleNum.string = [@"You have " stringByAppendingString:[NSString stringWithFormat:@"%d", _gameManager.bubbleNum]];
}
@end
