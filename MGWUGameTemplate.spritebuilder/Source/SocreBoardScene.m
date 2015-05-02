//
//  SocreBoardScene.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/30/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "SocreBoardScene.h"
#import "GameManager.h"

@implementation SocreBoardScene {
    CCNode *_scores;
    CCLabelTTF *_score1;
    
    GameManager *_gameManager;
    NSMutableArray *_scoreBoard;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _scoreBoard = _gameManager.scoreBoard;
    
    int yPosition = 0;
    for (int i = 0; i < [_scoreBoard count]; i++) {
        NSString * scoreWithComma = [GameManager scoreWithComma:[[_scoreBoard objectAtIndex:i] intValue]];
        NSString * string = [[[@(i+1) stringValue] stringByAppendingString:@".  "] stringByAppendingString:scoreWithComma];
        CCLabelTTF * textLabel = [CCLabelTTF labelWithString:string fontName:@"Chalkduster" fontSize:18.0f];
        textLabel.anchorPoint = ccp(0.5, 0.5); // align center.
        textLabel.position = ccp(0, yPosition);
        textLabel.positionType = _gameManager.getPTUnitTopLeft;
        textLabel.adjustsFontSizeToFit = true;
        [_scores addChild:textLabel];
        yPosition += textLabel.boundingBox.size.height + 10;
    }
}

- (void)backToMainScene {
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

@end
