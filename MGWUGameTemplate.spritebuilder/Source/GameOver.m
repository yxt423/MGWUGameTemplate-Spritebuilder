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
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <FBSDKShareKit/FBSDKShareKit.h>

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

- (void)facebookShare {
    // TODO: change the sharing content!!!!
    // Bug: game freeze after FB finish !!!
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentTitle = @"I've got a 1,000 score in Sky Jumper, come play with me!";
    [FBSDKShareDialog showFromViewController:[CCDirector sharedDirector]
                                 withContent:content
                                    delegate:nil];
}

@end
