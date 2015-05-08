//
//  IAPManager.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameManager.h"
#import "IAPManager.h"
#import "Shop.h"
#import "Mixpanel.h"
#import <StoreKit/StoreKit.h>

@implementation IAPManager {
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
    
    UIActivityIndicatorView *_spinner;
}

@synthesize isShopping;
@synthesize shop;

/* init functions */

- (id)init {
    if (self = [super init]) {
        CCLOG(@"IAP Manager Init.");
    }
    
    // Your application should add an observer to the payment queue during application initialization.
    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    
    // spinner init.
    _spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    _spinner.hidesWhenStopped = YES;
    [[CCDirector sharedDirector].view addSubview:_spinner]; // spinner is not visible until started
    
    return self;
}

+ (id)getIAPManager {
    static IAPManager *iapManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        iapManager = [[self alloc] init];
    });
    return iapManager;
}


- (void)startInAppPurchaseInShop: (Shop *)shopObject {
    if (isShopping) {
        return;
    }
    
    isShopping = true;
    shop = shopObject;
    [_spinner setCenter:CGPointMake(_gameManager.screenWidth/2.0, _gameManager.screenHeight/2.0)];
     [_spinner startAnimating];
    
    // check if the user allow in-app-purchase.
    if ([SKPaymentQueue canMakePayments]) {
        // get product information with product name.
        NSSet * set = [NSSet setWithArray:@[shop.productName]];
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
                CCLOG(@"Failed....");
                [self failedTransaction:transaction];
                break;
            case SKPaymentTransactionStateRestored: //This product is already bought.
                CCLOG(@"Restoring....");
                [self restoreTransaction:transaction];
                break;
            case SKPaymentTransactionStatePurchasing: //Add this product into list.
                CCLOG(@"Purchasing....");
                break;
            default:
                CCLOG(@"Default....");
                break;
        }
    }
}

- (void) completeTransaction: (SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    // add bubble in game.
    [_gameManager addBubble:shop.bubbleToBeAdded];
    [self updateBubbleNumText];
    [_gameManager updateBubbleNumInGamePlay:_gameManager.bubbleNum];
    
    // track in mixpanel.
    [_mixpanel track:@"Transaction Finish" properties:@{@"ItemName": @"Bubble", @"Number": [NSNumber numberWithInt:shop.bubbleToBeAdded], @"Price": [NSNumber numberWithFloat:[self getItemPrice:shop.bubbleToBeAdded]] }];
    
    CCLOG(@"IAP Transaction Completed");
    [self finishInAppPurchase];
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
    if(transaction.error.code != SKErrorPaymentCancelled) {
        CCLOG(@"Purchase failed, error message: %@", transaction.error.description);
    } else {
        CCLOG(@"User cancelled purchase.");
    }
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    
    CCLOG(@"failedTransaction");
    [self finishInAppPurchase];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction {
    [[SKPaymentQueue defaultQueue] finishTransaction: transaction];
    CCLOG(@"Transaction Restored");
    [self finishInAppPurchase];
}

- (void)finishInAppPurchase {
    [_spinner stopAnimating];
    shop.bubbleToBeAdded = 0;
    isShopping = false;
}

/* utilities */

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
    shop.youHaveBubbleNumLabel.string = [@"You have " stringByAppendingString:[NSString stringWithFormat:@"%d", _gameManager.bubbleNum]];
}

@end
