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

- (void)resume {
    CCLOG(@"PausePopUp - resume");
    _gameManager.gamePlayState = 2;
    [self removeFromParent];
}

- (void)restart {
    CCLOG(@"PausePopUp - restart");
    _gameManager.gamePlayState = 3;
    [self removeFromParent];
}

- (void)mute {
    CCLOG(@"PausePopUp - mute");
    
}

@end
