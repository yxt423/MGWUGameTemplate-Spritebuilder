//
//  IAPManager.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Shop.h"
#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface IAPManager : NSObject <SKProductsRequestDelegate,SKPaymentTransactionObserver> {
    bool isShopping;
    Shop *shop;
}

@property (nonatomic, assign) bool isShopping;
@property (nonatomic, retain) Shop *shop;

+ (id)getIAPManager;

- (void)startInAppPurchaseInShop: (Shop *)shop;

@end




