//
//  NewHighScore.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/22/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewHighScore.h"
#import "GameManager.h"

@implementation NewHighScore {
    CCLabelTTF *_scoreLabel;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    
    int score = _gameManager.currentScore;
    _scoreLabel.string = [GameManager scoreWithComma:score];
}

@end
