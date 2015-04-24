//
//  Shop.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/24/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Shop.h"
#import "GameManager.h"

@implementation Shop {
    CCNode *_shop;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
}

- (void)cancel {
    CCLOG(@"Shop - cancel");
    CCAnimationManager* animationManager = _shop.userObject;
    [animationManager runAnimationsForSequenceNamed:@"Disappear"];
    
    // remove the popUp from scene after finish.
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [_shop removeFromParentAndCleanup:YES];
    }];
    
    _gameManager.gamePlayState = 2;
}

- (void)bubble10 {
    
}

- (void)bubble30 {
    
}

- (void)bubble50 {
    
}

@end
