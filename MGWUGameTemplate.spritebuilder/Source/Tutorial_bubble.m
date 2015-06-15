//
//  Tutorial_bubble.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 6/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial_bubble.h"
#import "GamePlay+UIUtils.h"
#import "GameManager.h"
//#import "Character.h"
//#import "Star.h"
//#import "Cloud.h"

@implementation Tutorial_bubble {
    int _tutorialState;
    float _coverBoundary;
    CCNode *_tutorialText;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _tutorialState = 0;
    _gameManager.bubbleStartNum = 1;
    [self updateBubbleNum];
    
    return self;
}

- (void)update:(CCTime)delta {
    if (_tutorialState == 0) {
        [self tutorialStep1];
    }
    
    switch (_gameManager.gamePlayState) {
        case 2:   // to be resumed
            [super resume];
            break;
        case 3:  // to be restarted.
            [GameManager startNewGame];
            break;
        case 4:  // sound setting to be reversed
            _gameManager.audio.muted = _gameManager.muted;
            _gameManager.gamePlayState = 1;
            break;
    }
}

- (void)tutorialStep1 {
    _tutorialState = 1;
    
//    pauseCover = [GameManager addCCNodeFromFile:@"Gadgets/PauseCoverWithHole" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
    pauseCover = [CCBReader load:@"Gadgets/PauseCoverWithHole"];
    pauseCover.anchorPoint = CGPointMake(1, 1);
    pauseCover.positionType = _gameManager.getPTNormalizedTopLeft;
    pauseCover.position = ccp(1, 0);
    [self addChild:pauseCover];
}


@end
