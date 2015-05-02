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
    CCTextField *_yourName;
    
    // game state flags.
    float _timeSinceLastAnimation;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
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
        CCLOG(@"game over new high score");
        [GameManager addCCNodeFromFile:@"Effects/NewHighScore" WithPosition:ccp(0.5, 0.3) Type:_gameManager.getPTNormalizedTopLeft To:self];
        [_normalScore removeFromParent];
        
        // add a text field in code, to get access it's parameter name.
//        CCTextField *yourName = [CCTextField textFieldWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Assets/editYourName.png"]];
//        [yourName.textField setDelegate:self];
//        
//        yourName.string = @"Yxt";
//        yourName.position = ccp(0.52, 1);
//        yourName.positionType = _gameManager.getPTNormalizedTopLeft;
//        yourName.preferredSize = CGSizeMake(92.2, 48);
//        yourName.anchorPoint = ccp(0, 0.5);
//        
//        yourName.textField.textColor = [UIColor whiteColor];
//        yourName.color = [CCColor whiteColor];
////        yourName.textField.t
//        [yourName setFontSize:16.f];
//        [yourName setColor:[CCColor whiteColor]];
//        [newHighScore addChild:yourName];
        
        
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
            
//            CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/StarVanish"];
//            explosion.autoRemoveOnFinish = TRUE; // make the particle effect clean itself up, once it is completed
//            explosion.position = ccp(drand48() / 2 + 0.25, drand48() / 5 + 0.1);
//            explosion.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
//            [self addChild:explosion];
        }
    }
}

- (void)playAgain {
    [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
}

- (void)backToMainScene {
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

- (void)scoreBoard {
    [GameManager replaceSceneWithFadeTransition:@"SocreBoardScene"];
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
