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

@implementation Tutorial_bubble {
    int _tutorialState;
    float _coverBoundary;
    CCNode *_tutorialText;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    /* 1, the bubble you have. 2, swipe up to use a bubble. 3, good job. 
     4, tip of using bubble. 5, resume and continue the game */
    _tutorialState = 0;
    _gameManager.tutorialProgress = 0;
    _gameManager.bubbleStartNum = _gameManager.FREE_STARTING_BUBBLE;
    
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
            [_gameManager startNewGame];
            break;
        case 4:  // sound setting to be reversed
            _gameManager.audio.muted = _gameManager.muted;
            _gameManager.gamePlayState = 1;
            break;
    }
}

- (void)updateAboutBubble:(CCTime)delta {
    if (_inBubble) {
        _timeInBubble += delta;
        if (_timeInBubble > 2.0f) {
            _inBubble = false;
            _timeInBubble = 0.0f;
            [_bubble removeFromParent];
            
            // show remove bubble animation.
            [GameManager addParticleFromFile:@"Effects/BubbleVanish" WithPosition:ccp(0.5, 0.2) Type:_gameManager.getPTNormalizedTopLeft To:_character];
            
            if(_tutorialState == 3) {
                [self tutorialStep4];
            }
        }
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
    } else if (_tutorialState == 4) {
        [self tutorialStep5];
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
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTextBubble1" WithPosition:ccp(30, 80) Type:_gameManager.getPTUnitTopRight To:self];
}

- (void)tutorialStep2 { // swipe up to use bubble.
    _tutorialState = 2;
    _gameManager.tutorialProgress = 2;
    _contentHeight = 300;
    
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTextBubble2" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.4) To:self];
}

- (void)tutorialStep3 { // show "Good job!" after receiving swipe.
    _tutorialState = 3;
    
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText4" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"In"];
}

- (void)tutorialStep4 { // pause, show tip of using bubble.
    _tutorialState = 4;
    
    [self pauseAndCover];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTextBubble3" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
}

- (void)tutorialStep5 { // resume from pause.
    _tutorialState = 5;
    _gameManager.tutorialProgress = 3;
    
    [self resume];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    CCLOG(@"tutorialStep5");
}

@end
