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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

@implementation GameOver {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highScoreLabel;
    CCNode * _normalScore;
    GameManager *_gameManager;
    
    // game state flags.
    float _timeSinceLastAnimation;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _timeSinceLastAnimation = 0;
    
    if (!_gameManager.newHighScore) {
        // show scores
        int score = _gameManager.currentScore;
        int highScore = _gameManager.highestScore;
        
        _scoreLabel.string = [GameManager scoreWithComma:score];
        _highScoreLabel.string = [GameManager scoreWithComma:highScore];
    } else {
        CCLOG(@"game over new high score");
        NewHighScore *newHighScore = (NewHighScore *) [CCBReader load:@"Effects/NewHighScore"];
        newHighScore.position = ccp(0.5, 0.4);
        newHighScore.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
        
        [_normalScore removeFromParent];
        [self addChild:newHighScore];
        
        // random Seed (only once)
        srand48(arc4random());
    }
    
    
}

- (void)update:(CCTime)delta {
    if (_gameManager.newHighScore) {
        // new high score animation.
        _timeSinceLastAnimation += delta;
        if (_timeSinceLastAnimation > 0.3f) {
            _timeSinceLastAnimation = 0;
        
            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/StarVanish"];
            explosion.autoRemoveOnFinish = TRUE; // make the particle effect clean itself up, once it is completed
            explosion.position = ccp(drand48() / 2 + 0.25, drand48() / 5 + 0.1);
            explosion.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
            [self addChild:explosion];
        }
    }
}

- (void)playAgain {
    // resload gameplay scene
    [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
}

- (void)backToMainScene {
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
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
