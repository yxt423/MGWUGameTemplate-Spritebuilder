//
//  Tutorial_bubble.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 6/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial_bubble.h"
#import "GamePlay.h"
#import "GamePlay+UIUtils.h"
#import "GameManager.h"
#import "Character.h"
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
    
    // 1, the bubble you have. 2, swipe up to use a bubble. 3, good job.
    _gameManager.bubbleStartNum = 1;
    [self updateBubbleNum];
    
    // about loading new content.
    _objectsGroup.opacity = 0;
    
    return self;
}

- (void)update:(CCTime)delta {
    if (_tutorialState == 0) {
        [self tutorialStep1];
    }
    
    switch (_gameManager.gamePlayState) {
        case 0:
            if (_tutorialState > 1) {
                [self updateAboutLoadNewContent:delta];
                [self updateAboutBubble:delta];
            }
            break;
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

- (void)tapGesture:(UIGestureRecognizer *)gestureRecognizer  {
    CGPoint point = [gestureRecognizer locationInView:nil];
    point.x = point.x / _gameManager.tapUIScaleDifference;
    point.y = point.y / _gameManager.tapUIScaleDifference;
    if (CGRectContainsPoint(_buttonPause.boundingBox, point) || CGRectContainsPoint(_buttonBubble.boundingBox, point)) {
        return;
    }
    
    if (_tutorialState == 1) {
        [self tutorialStep2];
    } else {
        [_character tapGestureCharacterMove:point];
    }
}

-(void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer {
    [super swipeUpGesture:recognizer];
    if (_tutorialState == 2) {
        [self tutorialStep3];
    }
}

- (void)tutorialStep1 { // show cover and text
    _tutorialState = 1;
    
    pauseCover = [CCBReader load:@"Gadgets/PauseCoverWithHole"];
    pauseCover.anchorPoint = CGPointMake(1, 1);
    pauseCover.positionType = _gameManager.getPTNormalizedTopLeft;
    pauseCover.position = ccp(1, 0);
    [self addChild:pauseCover];
    [pauseCover runAction:[GameManager getFadeIn]];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTextBubble1" WithPosition:ccp(120, 80) Type:_gameManager.getPTUnitTopRight To:self];
}

- (void)tutorialStep2 { // swipe up to use bubble.
    _contentHeight = 300;
    _tutorialState = 2;
    _gameManager.tutorialProgress = 2;
    
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTextBubble2" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.4) To:self];
}

- (void)tutorialStep3 {
    _tutorialState = 3;
    _gameManager.tutorialProgress = 3;
    
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText4" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"In"];
}

@end
