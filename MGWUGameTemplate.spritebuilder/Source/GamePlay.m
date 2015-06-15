//  GamePlay.m
//  MGWUGameTemplate
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
/*
 == Load game content mechanism == 
 Start with an empty gameplay scene, load new content into _objectsGroup.
 
 == End game mechanism  ==
 1. Remove the cloud when it's position is one screen lower than characterHighest.
 2. End the game when the character is two screens lower than characterHighest.
 
 */

#include <stdlib.h>
#import "GamePlay.h"
#import "GamePlay+UIUtils.h"
#import "GameOver.h"
#import "PausePopUp.h"
#import "Character.h"
#import "Cloud.h"
#import "CloudBlack.h"
#import "Star.h"
#import "Groud.h"
#import "BubbleObject.h"
#import "ScoreAdd.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GameManager.h"
#import "Mixpanel.h"

@implementation GamePlay {
    CCNode *_contentNode;
    CCNode *_popUp;
    CCAction *_followCharacter;
    CCNode *_bubble;
    
    // user interaction var
    UITapGestureRecognizer *_tapGesture;
    UISwipeGestureRecognizer *_swipeUpGesture;
    
    // game state flags.
    float _timeSinceNewContent;
    bool _canLoadNewContent;
    float _timeInBubble;
    bool _inBubble;
}

@synthesize score;

@synthesize _starHit;
@synthesize _contentHeight;
@synthesize _objectInterval;
@synthesize _cloudScale;

@synthesize _scoreLabel;
@synthesize _objectsGroup;

@synthesize _bubbleLimit;
@synthesize _bubbleToUse;
@synthesize _bubbleLife1;
@synthesize _bubbleLife2;
@synthesize _bubbleLife3;

@synthesize _character;
@synthesize _buttonPause, _buttonBubble;
@synthesize _walls;

- (void)didLoadFromCCB {
    score = 0;
    _starHit = 0;
    _contentHeight = 100;
    _canLoadNewContent = true;
    _timeSinceNewContent = 0.0f;
    _inBubble = false;
    _timeInBubble = 0.0f;
    
    // constants
    _bubbleLimit = 3;
    
    _gameManager.gamePlayState = 0;
    _gameManager.characterHighest = 0;
    _gameManager.sharedObjectsGroup = _objectsGroup;
    _gameManager.newHighScore = false;
    _gameManager.cloudHit = 0;
    _bubbleToUse = _gameManager.bubbleStartNum;
    [self updateBubbleNum];
    
    _physicsNode.collisionDelegate = self;
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_tapGesture setCancelsTouchesInView:NO]; // !! do not cancel the other call back functions of touches.
    
    _swipeUpGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeUpGesture:)];
    [_swipeUpGesture setDirection:(UISwipeGestureRecognizerDirectionUp)];
    [_swipeUpGesture setCancelsTouchesInView:NO];
    
    // load game content
    CCLOG(@"gamePlayTimes: %d", _gameManager.gamePlayTimes);
    
    if (_gameManager.gamePlayTimes != 0) {
        [self loadNewContent];
        [_mixpanel track:@"Game Start"];
    } else {
        [_mixpanel track:@"Tutorial Start"];
    }
    
    CCLOG(@"GamePlay didLoadFromCCB.");
}

- (void)update:(CCTime)delta {
    switch (_gameManager.gamePlayState) {
        case 0:   // game on going.
            // if character reach top of the current content, load new content.
            if(_canLoadNewContent) {
                int yMax = _character.boundingBox.origin.y + _character.boundingBox.size.height;
                if (yMax + _gameManager.screenHeight / 2 + 1000 > _contentHeight) { // determine when to load new content.
                    [self loadNewContent];
                    _canLoadNewContent = false;
                    _timeSinceNewContent = 0.0f;
                }
            }
            
            _timeSinceNewContent += delta;  // delta is approximately 1/60th of a second
            if (_timeSinceNewContent > 2.0f) {
                _canLoadNewContent = true;
            }
            
            if (_character.position.y > _gameManager.characterHighest) {
                _gameManager.characterHighest = _character.position.y;
            }
            
            // if the character starts to drop, end the game.
            if (_character.position.y + _gameManager.screenHeight * 2 < _gameManager.characterHighest) {
                [self endGame];
            }
            
            // the wall goes with the character.
            _walls.position = ccp(0, _character.position.y - _walls.boundingBox.size.height / 2);
            
            if (_inBubble) {
                _timeInBubble += delta;
                if (_timeInBubble > 2.0f) {
                    _inBubble = false;
                    _timeInBubble = 0.0f;
                    [_bubble removeFromParent];
                    
                    // show remove bubble animation.
                    [GameManager addParticleFromFile:@"Effects/BubbleVanish" WithPosition:ccp(0.5, 0.2) Type:_gameManager.getPTNormalizedTopLeft To:_character];
                }
            }
            break;
        case 2:   // to be resumed
            [self resume];
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

- (void)onEnter {
    [super onEnter];
    [self followCharacter];
    [self startUserInteraction];
}

- (void)onExit {
    [super onExit];
    [self stopUserInteraction];
}

- (void)followCharacter {
    // do not set a bound for cintent height.
    CGRect contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, NSIntegerMax);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:contentBoundingBox];
    [_contentNode runAction:_followCharacter];
}

- (void)startUserInteraction {
    self.userInteractionEnabled = TRUE;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_tapGesture];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_swipeUpGesture];
}

- (void)stopUserInteraction {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_tapGesture];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeUpGesture];
    self.userInteractionEnabled = false;  // stop accept touches.
}

// the tap position and character position has different UI density. Why is that?
- (void)tapGesture:(UIGestureRecognizer *)gestureRecognizer  {
//    CCLOG(@"=========== tapGesture =================");
//    CCLOG(@"_character.position %f, %f", _character.position.x , _character.position.y);
    
    CGPoint point = [gestureRecognizer locationInView:nil];
//    CCLOG(@"point %f, %f", point.x, point.y);
    point.x = point.x / _gameManager.tapUIScaleDifference;
    point.y = point.y / _gameManager.tapUIScaleDifference;
    point.y = _gameManager.screenHeight - point.y; // the convertedPoint has different reference corner.
//    CCLOG(@"point adjusted %f, %f", point.x, point.y);
//    CCLOG(@"_buttonPause.boundingBox %f, %f, %f, %f", _buttonPause.boundingBox.origin.x , _buttonPause.boundingBox.origin.y, _buttonPause.boundingBox.size.width, _buttonPause.boundingBox.size.height);
    
    if (CGRectContainsPoint(_buttonPause.boundingBox, point) || CGRectContainsPoint(_buttonBubble.boundingBox, point)) {
        return;
    }
    
    // if tap on left side of character, or very left of the screen, jump left. 
    if (point.x < 40) {
        [_character moveLeft];
    } else if (_gameManager.screenWidthInPoints - point.x < 40 ) {
        [_character moveRight];
    } else if (point.x < _character.positionInPoints.x) {
        [_character moveLeft];
    } else {
        [_character moveRight];
    }
}

-(void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer{
    if(recognizer.direction != UISwipeGestureRecognizerDirectionUp) {
        return;
    }
    
    [self buttonBubble];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    if (!_inBubble) {
        _gameManager.cloudHit += 1;
        score += _gameManager.cloudHit * 10;
        [self updateScore];
        [_character jump];
        [(Cloud *)nodeB removeAndPlayAnimation];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    if (!_inBubble) {
        _starHit += 1;
        score *= 2;
        [self updateScore];
        
        [_character jump];
        CGPoint collisionPoint = pair.contacts.points[0].pointA;
        [(Star *)nodeB removeAndPlayAnimationAt:(CGPoint)collisionPoint];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    if (_gameManager.cloudHit > 0) {
        [self endGame];
    } else {
        [_character jump];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA bubbleObject:(CCNode *)nodeB {
    if (!_inBubble) {
        [_character jump];
        if (_bubbleToUse < 3) {
            [(BubbleObject *)nodeB removeAndPlayBubbleAddOne];
            _bubbleToUse += 1;
            [self updateBubbleNum];
        } else {
            [(BubbleObject *)nodeB removeAndPlayVanish];
        }
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloudBlack:(CloudBlack *)nodeB {
    if (!_inBubble) {
        [_character jump];
    } else {
        // if character in bubble, make everything sensor so it can keep going up.
        nodeB.physicsBody.sensor = YES;
    }
    
    return YES;
}

// update current score and highest score, stop user interaction on GamePlay, load GameOver scene.
- (void)endGame {
    if (_gameManager.gamePlayState == -1) {
        return; // endGame is already called once.
    }
    
    _gameManager.gamePlayState = -1;
    _gameManager.gamePlayTimes += 1;
    
    _gameManager.currentScore = score;
    if (score > _gameManager.highestScore) {
        _gameManager.highestScore = score;
        _gameManager.newHighScore = true;
    }
    [_gameManager updateScoreBoard:score];
    
    [self stopUserInteraction];
    [self trackGameEnd];
    
    [GameManager replaceSceneWithFadeTransition:@"GameOver"];
}

- (void)trackGameEnd {
    [_mixpanel track:@"Game End" properties:@{@"Score": [NSNumber numberWithInt:score],
                                              @"Height": [NSNumber numberWithInt:_gameManager.characterHighest],
                                              @"StarHit": [NSNumber numberWithInt:_starHit],
                                              @"gamePlayTimes": [NSNumber numberWithInt:_gameManager.gamePlayTimes],
                                              @"CloudInterval": [NSNumber numberWithInt:_objectInterval],
                                              @"CloudScale": [NSNumber numberWithFloat:_cloudScale]
                                              }];
}

- (void)pause {
    if (_gameManager.gamePlayState == 0) {
        [self pauseAndCover];
        [GameManager addCCNodeFromFile:@"PopUp/PausePopUp" WithPosition:_buttonPause.position Type:_gameManager.getPTUnitTopLeft To:self];
        
        [self stopUserInteraction];
        _gameManager.gamePlayState = 1;
    }
}

- (void)resume {
    [self resumeAndUncover];
    [self startUserInteraction];
    [self followCharacter];
    _gameManager.gamePlayState = 0;
}

- (void)buttonBubble {
    // the button works when the character is not in bubble.
    if (_inBubble || _gameManager.gamePlayState != 0) {
        return;
    }
    
    if (_bubbleToUse <= 0) {
        // pop up bubble limit
        CCNode * _bubbleLimitPopUp = [GameManager addCCNodeFromFile:@"Effects/BubbleUsedUp" WithPosition:ccp(0.5, 0.3) Type:_gameManager.getPTNormalizedTopLeft To:self];
        [GameManager playThenCleanUpAnimationOf:_bubbleLimitPopUp Named:@"Show"];
    } else {
        // put character in bubble.
        _inBubble = true;
        _bubbleToUse -= 1;
        [self updateBubbleNum];
        
        _bubble = [GameManager addCCNodeFromFile:@"Objects/Bubble" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:_character];
        [_character bubbleUp];
    }
}

@end
