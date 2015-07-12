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
#import "NewHighScore.h"
#import "Energy.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation GameOver {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highScoreLabel;
    CCNode * _normalScore;
    Energy *_energy;
    
    // game state flags.
    float _timeSinceLastAnimation;
}

- (void)didLoadFromCCB {
    _gameManager.currentSceneNo = _gameManager.GAMEOVERSCENE_NO;
    _timeSinceLastAnimation = 0;
    
    // prevent the ground from being removed.
    _gameManager.characterHighest = 0;
    
    if (!_gameManager.newHighScore) {
        // show scores
        int score = _gameManager.currentScore;
        int highScore = _gameManager.highestScore;
        
        _scoreLabel.string = [GameManager scoreWithComma:score];
        _highScoreLabel.string = [GameManager scoreWithComma:highScore];
    } else {
        [GameManager addCCNodeFromFile:@"Effects/NewHighScore" WithPosition:ccp(0.5, 0.3) Type:_gameManager.getPTNormalizedTopLeft To:self];
        [_normalScore removeFromParent];
        
        // random Seed (only once)
        srand48(arc4random());
    }
}

- (void)update:(CCTime)delta {
    if (_gameManager.newHighScore) {
        
        _timeSinceLastAnimation += delta;
        if (_timeSinceLastAnimation > 0.3f) {
            _timeSinceLastAnimation = 0;
        
            // new high score animation: random starVanish effect.
            [GameManager addParticleFromFile:@"Effects/StarVanish" WithPosition:ccp(drand48() / 2 + 0.25, drand48() / 5 + 0.1) Type:_gameManager.getPTNormalizedTopLeft To:self];
        }
    }
}

- (void)playAgain {
    [_gameManager playButton:self];
//    [_gameManager startNewGame];
}

- (void)backToMainScene {
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

- (void)scoreBoard {
    [GameManager pushSceneWithFadeTransition:@"SocreBoardScene"];
}

- (void)updateEnergyLabel {
    [_energy updateEnergyNum];
}

- (void)facebookShare {
    // TODO: change the sharing content!!!!
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:@"http://developers.facebook.com"];
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];
}

@end
