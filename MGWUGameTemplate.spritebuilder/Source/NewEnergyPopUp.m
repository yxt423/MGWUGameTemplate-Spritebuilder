//
//  NewEnergyPopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewEnergyPopUp.h"
#import "GameManager.h"
#import "MainScene.h"
#import "Energy.h"

@implementation NewEnergyPopUp {
    CCNode *_newLifePopUp;
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    
    return self;
}

- (void)ok {
    [(MainScene*)self.parent updateEnergyLabel:10];
    
    CCNode *energyAdd10 = [GameManager addCCNodeFromFile:@"Effects/EnergyAdd10" WithPosition:ccp(80, 20) Type:_gameManager.getPTUnitTopLeft To:self.parent];
    CCAnimationManager* animationManager = energyAdd10.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [energyAdd10 removeFromParentAndCleanup:YES];
        [_gameManager startNewGame];
    }];
}

@end
