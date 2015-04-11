//
//  GameOver.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOver.h"
#import "GamePlay.h"
#import "GameManager.h"

@implementation GameOver {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highScoreLabel;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    // show scores
    int score = _gameManager.currentScore;
    int highScore = _gameManager.highestScore;
    
    _scoreLabel.string = [GameManager scoreWithComma:score];
    _highScoreLabel.string = [GameManager scoreWithComma:highScore];
}

- (void)playAgain {
    // resload gameplay scene
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GamePlay"]];
}

- (void)backToMainScene {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
