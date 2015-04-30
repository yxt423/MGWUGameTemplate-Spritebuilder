//
//  Shop.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Shop.h"
#import "GameManager.h"
#import <StoreKit/StoreKit.h>

@implementation Shop {
    CCNode *_shop;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
}

- (void)cancel {
    CCLOG(@"Shop - cancel");
    [GameManager playThenCleanUpAnimationOf:_shop Named:@"Disappear"];
    _gameManager.gamePlayState = 2;
}

- (void)bubble1 {
    NSString * productName = @"skyjumper.bubble.10";
    [self startInAppPurchaseWithProductName:productName];
}

- (void)bubble2 {
    NSString * productName = @"skyjumper.bubble.35";
    [self startInAppPurchaseWithProductName:productName];
}

- (void)bubble3 {
    NSString * productName = @"skyjumper.bubble.60";
    [self startInAppPurchaseWithProductName:productName];
}

- (void)bubble4 {
    NSString * productName = @"skyjumper.bubble.130";
    [self startInAppPurchaseWithProductName:productName];
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
    // You can create a method to record the transaction.
    // [self recordTransaction: transaction];
    
    // You should make the update to your app based on what was purchased and inform user.
    // [self provideContent: transaction.payment.productIdentifier];
    // Finally, remove the transaction from the payment queue.
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
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

@end
