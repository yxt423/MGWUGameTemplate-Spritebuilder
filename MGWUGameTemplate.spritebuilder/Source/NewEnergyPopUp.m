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
#import "GameOver.h"
#import "Energy.h"

@implementation NewEnergyPopUp {
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    
    return self;
}

- (void)ok {
    if (_gameManager.currentSceneNo == _gameManager.MAINSCENE_NO) {
        [(MainScene *)self.parent updateEnergyLabel];
    } else if (_gameManager.currentSceneNo == _gameManager.GAMEOVERSCENE_NO) {
        [(GameOver *)self.parent updateEnergyLabel];
    }
    
    CCNode *energyAdd10 = [GameManager addCCNodeFromFile:@"Effects/EnergyAdd10" WithPosition:ccp(80, 20) Type:_gameManager.getPTUnitTopLeft To:self.parent];
    CCAnimationManager* animationManager = energyAdd10.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [energyAdd10 removeFromParentAndCleanup:YES];
        [_gameManager startNewGame];
    }];
}

@end
