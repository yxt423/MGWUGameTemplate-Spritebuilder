//
//  Shop.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Shop.h"
#import "GameManager.h"
#import "IAPManager.h"
#import "Mixpanel.h"
#import "BasicScene.h"

@implementation Shop {
    CCNode *_shop;
    GameManager *_gameManager;
    IAPManager *_iapManager;
    CCLabelTTF *_youHaveBubbleNum;
}

@synthesize bubbleToBeAdded;
@synthesize productName;
@synthesize youHaveBubbleNumLabel;

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _iapManager = [IAPManager getIAPManager];
    bubbleToBeAdded = 0;
    youHaveBubbleNumLabel = _youHaveBubbleNum;
}

- (void)cancel{
    [GameManager playThenCleanUpAnimationOf:_shop Named:@"Disappear"];
    
    if (_gameManager.shopSceneNo == 1) {
        [(BasicScene *)self.parent resumeAndUncover]; // the parent of shop must be a child of BasicScene.
        _gameManager.mainSceneState = 0;
    }
}

- (void)bubble1 {
    CCLOG(@"bubble1 button pressed....");
    productName = @"skyjumper.bubble.10";
    [_iapManager startInAppPurchaseInShop: (Shop *)self];
    bubbleToBeAdded = 10;
}

- (void)bubble2 {
    productName = @"skyjumper.bubble.35";
    [_iapManager startInAppPurchaseInShop: (Shop *)self];
    bubbleToBeAdded = 35;
}

- (void)bubble3 {
    productName = @"skyjumper.bubble.60";
    [_iapManager startInAppPurchaseInShop: (Shop *)self];
    bubbleToBeAdded = 60;
}

- (void)bubble4 {
    productName = @"skyjumper.bubble.130";
    [_iapManager startInAppPurchaseInShop: (Shop *)self];
    bubbleToBeAdded = 130;
}

@end
