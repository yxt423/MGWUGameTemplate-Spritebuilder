//
//  EnergyStartPopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "EnergyStartPopUp.h"
#import "GameManager.h"
#import "MainScene.h"
#import "GameOver.h"

@implementation EnergyStartPopUp {
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    
    return self;
}

- (void)ok {
    _gameManager.energyNum -= 1;
    if (_gameManager.currentSceneNo == _gameManager.MAINSCENE_NO) {
        [(MainScene *)self.parent updateEnergyLabel];
    } else if (_gameManager.currentSceneNo == _gameManager.GAMEOVERSCENE_NO) {
        [(GameOver *)self.parent updateEnergyLabel];
    }

    CCNode *energyMinus1 = [GameManager addCCNodeFromFile:@"Effects/EnergyMinus1" WithPosition:ccp(80, 20) Type:_gameManager.getPTUnitTopLeft To:self.parent];
    
    CCAnimationManager* animationManager = energyMinus1.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [energyMinus1 removeFromParentAndCleanup:YES];
        [_gameManager startNewGame];
    }];
}

@end
