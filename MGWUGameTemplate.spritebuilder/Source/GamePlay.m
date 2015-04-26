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
#import "GameOver.h"
#import "PausePopUp.h"
#import "Character.h"
#import "Cloud.h"
#import "Star.h"
#import "Groud.h"
#import "Bubble.h"
#import "ScoreAdd.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GameManager.h"
#import "Mixpanel.h"

@implementation GamePlay {
    Character *_character;
    CCNode *_gamePlay;
    CCNode *_contentNode;
    CCNode *_objectsGroup;
    CCNode *_popUp;
    CCNode *_walls;
    CCButton *_buttonPause;
    CCButton *_buttonBubble;
    CCPhysicsNode *_physicsNode;
    CCAction *_followCharacter;
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_bubbleNumLabel;
    CCNode *_bubble;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
    
    // user interaction var
    UITapGestureRecognizer *_tapGesture;
    
    // stats
    int _starHit;
    int _contentHeight;
    int _cloudInterval;
    float _cloudScale;
    
    // game state flags.
    float _timeSinceNewContent;
    bool _canLoadNewContent;
    float _timeInBubble;
    bool _inBubble;
    int _bubbleUsed;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    return self;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    
    _score = 0;
    _starHit = 0;
    _contentHeight = 100;
    _canLoadNewContent = false;
    _timeSinceNewContent = 0.0f;
    _inBubble = false;
    _timeInBubble = 0.0f;
    _bubbleUsed = 0;
    
    _gameManager.characterHighest = 0;
    _gameManager.sharedObjectsGroup = _objectsGroup;
    _gameManager.newHighScore = false;
    _gameManager.cloudHit = 0;
    
    _physicsNode.collisionDelegate = self;
    _bubbleNumLabel.string = [NSString stringWithFormat:@"%d", _gameManager.bubbleNum];

    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_tapGesture setCancelsTouchesInView:NO]; // !! do not cancel the other call back functions of touches.
    
    // load game content
    [self loadNewContent];
    [_mixpanel track:@"Game Start"];
    
    CCLOG(@"Game Start.");
}

- (void)update:(CCTime)delta {
    if (_gameManager.gamePlayState == 0) { // game on going.
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
                CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/BubbleVanish"];
                explosion.autoRemoveOnFinish = TRUE;
                explosion.position = ccp(0.5, 0.2);
                explosion.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
                [_character addChild:explosion];
            }
        }
    }
    
    else if (_gameManager.gamePlayState == 2) { // to be resumed
        _physicsNode.paused = NO;
        [self startUserInteraction];
        [self followCharacter];
        _gameManager.gamePlayState = 0;
    }
    
    else if (_gameManager.gamePlayState == 3) { // to be restarted.
        CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
        [[CCDirector sharedDirector] replaceScene:gameplayScene];
        _gameManager.gamePlayState = 0;
        CCLOG(@"restarted!");
    }
    
    else if (_gameManager.gamePlayState == 4) { // sound setting to be reversed
        _gameManager.audio.muted = _gameManager.muted;
        _gameManager.gamePlayState = 1;
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

// loadNewContent by ramdomly generate game content.
- (void)loadNewContent {
    _cloudInterval = [GameManager getCloudIntervalAt:_contentHeight];
    _cloudScale = [GameManager getCloudScaleAt:_contentHeight];
    
    for (int i = 0; i < 20; i++) {
        CCNode *cloud = [CCBReader load:@"Objects/Cloud"];
        _contentHeight += _cloudInterval;
        cloud.position = ccp(arc4random_uniform(_gameManager.screenWidth - 40) + 20, _contentHeight);
        cloud.zOrder = -1;
        cloud.scale = _cloudScale;
        [_objectsGroup addChild:cloud];
    }
    
    CCNode *star;
    if (_starHit < 2) {
        star = [CCBReader load:@"Objects/StarStatic"];
    } else if (_starHit < 5) {
        star = [CCBReader load:@"Objects/StarSpining40"];
    } else {
        star = [CCBReader load:@"Objects/StarSpining80"];
    }
    _contentHeight += _cloudInterval;
    star.position = ccp(arc4random_uniform(_gameManager.screenWidth - 80) + 40, _contentHeight);
    star.zOrder = -1;
    [_objectsGroup addChild:star];
    CCLOG(@"_cloudInterval %d, _cloudScale %f", _cloudInterval, _cloudScale);
}

- (void)followCharacter {
    // do not set a bound for cintent height. 
    CGRect contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, NSIntegerMax);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:contentBoundingBox];
    [_contentNode runAction:_followCharacter];
    
    CCLOG(@"followCharacter ");
}

- (void)startUserInteraction {
    self.userInteractionEnabled = TRUE;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_tapGesture];
}

- (void)stopUserInteraction {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_tapGesture];
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
        // point 是大坐标。 does this work?
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

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    if (!_inBubble) {
        _gameManager.cloudHit += 1;
        _score += _gameManager.cloudHit * 10;
        [self updateScore];
        [_character jump];
        [(Cloud *)nodeB removeAndPlayAnimation];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    if (!_inBubble) {
        _starHit += 1;
        _score *= 2;
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

// update current score and highest score, stop user interaction on GamePlay, load GameOver scene.
- (void)endGame {
    _gameManager.gamePlayTimes += 1;
    _gameManager.currentScore = _score;
    if (_score > _gameManager.highestScore) {
        _gameManager.highestScore = _score;
        _gameManager.newHighScore = true;
    }
    
    [self stopUserInteraction];
    [self trackGameEnd];
    
    [GameManager replaceSceneWithFadeTransition:@"GameOver"];
}

- (void)trackGameEnd {
    [_mixpanel track:@"Game End" properties:@{@"Score": [NSNumber numberWithInt:_score],
                                              @"Height": [NSNumber numberWithInt:_gameManager.characterHighest],
                                              @"StarHit": [NSNumber numberWithInt:_starHit],
                                              @"gamePlayTimes": [NSNumber numberWithInt:_gameManager.gamePlayTimes],
                                              @"CloudInterval": [NSNumber numberWithInt:_cloudInterval],
                                              @"CloudScale": [NSNumber numberWithFloat:_cloudScale],
                                              @"Bubble Used": [NSNumber numberWithInt:_bubbleUsed]
                                              }];
}

- (void)pause {
    if (_gameManager.gamePlayState == 0) {
        _popUp = [CCBReader load:@"PopUp/PausePopUp"];
        _popUp.position = _buttonPause.position;
        _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
        [_gamePlay addChild:_popUp];
        
        _physicsNode.paused = YES;
        [self stopUserInteraction];
        _gameManager.gamePlayState = 1;
    }
}

- (void)buttonBubble {
    // the button works when the character is not in bubble.
    if (!_inBubble) {
        if (_gameManager.bubbleNum > 0) {
            if (_bubbleUsed >= 3) {
                // show: you can use at most 3 bubbles in one game.
                CCNode * _bubbleLimitPopUp = [CCBReader load:@"PopUp/BubbleLimitPopUp"];
                _bubbleLimitPopUp.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
                _bubbleLimitPopUp.position = ccp(0.5, 0.3);
                [self addChild:_bubbleLimitPopUp];
                
                CCAnimationManager* animationManager = _bubbleLimitPopUp.userObject;
                [animationManager runAnimationsForSequenceNamed:@"Show"];
                // remove the popUp from mainScene after finish.
                [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
                    [_bubbleLimitPopUp removeFromParentAndCleanup:YES];
                }];
                
            } else { // put character in bubble.
                _inBubble = true;
                _bubbleUsed += 1;
                _bubble = [CCBReader load:@"Objects/Bubble"];
                _bubble.position = ccp(_character.boundingBox.size.width / 2, _character.boundingBox.size.height / 2);
                [_character addChild:_bubble];
                [_character bubbleUp];
                
                [_gameManager addBubble:-1];
                _bubbleNumLabel.string = [NSString stringWithFormat:@"%d", _gameManager.bubbleNum];
            }
            
        } else { // pop up shop window.
            _physicsNode.paused = YES;
            [self stopUserInteraction];
            _gameManager.gamePlayState = 1;
            
            CCNode * _shopPopUp = [CCBReader load:@"PopUp/Shop"];
            _shopPopUp.positionType = CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
            _shopPopUp.position = ccp(0.5, 0.5);
            [self addChild:_shopPopUp];
        }
    }
}

- (void)updateScore {
    _scoreLabel.string = [GameManager scoreWithComma:_score];
}

@end
