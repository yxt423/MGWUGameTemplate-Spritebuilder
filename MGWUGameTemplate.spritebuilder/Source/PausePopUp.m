//
//  PausePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PausePopUp.h"
#import "GameManager.h"

@implementation PausePopUp {
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
}

- (void)buttonContinue {
    CCLOG(@"PausePopUp - buttonContinue");
    _gameManager.gamePlayState = 2;
    [self removeFromParent];
}

@end
