//
//  Shop.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"
#import <StoreKit/StoreKit.h>

@interface Shop : CCNode <SKProductsRequestDelegate,SKPaymentTransactionObserver>

@end
