//  GamePlay.m
//  MGWUGameTemplate
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
/*
 == Load game content mechanism == 
 Start with an empty gameplay scene, load new content into _objectsGroup.
 
 == End game mechanism  ==
 1. Remove the cloud when it's position is one screen lower than _characterHighest.
    (A cloud can get it's relative position by calling the class method getPositionInObjectsGroup, which uses a static verible _sharedObjectsGroup, which equals to _objectsGroup. // Strategies for Accessing Other Nodes: http://www.learn-cocos2d.com/files/cocos2d-essential-reference-sample/Strategies_for_Accessing_Other_Nodes.html )
 2. End the game when the character is two screens lower than _characterHighest.
 
 */

#include <stdlib.h>
#import "GamePlay.h"
#import "GameOver.h"
#import "PausePopUp.h"
#import "Character.h"
#import "Cloud.h"
#import "Star.h"
#import "Groud.h"
#import "ScoreAdd.h"
#import "ScoreDouble.h"
#import "CCPhysics+ObjectiveChipmunk.h"
#import "GameManager.h"
#import "Mixpanel.h"

static int _characterHighest; //the highest position the character ever been to
static CCNode *_sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.
static int _screenHeight;
static int _screenWidth;

@implementation GamePlay {
    Character *_character;
    CCNode *_gamePlay;
    CCNode *_contentNode;
    CCNode *_objectsGroup;
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabel;
    CCControl *_buttonPause;
    CCAction *_followCharacter;
    CCNode *_popUp;
    OALSimpleAudio *_audio;
    
    // user interaction var
    UITapGestureRecognizer *_tapGesture;
    
    // stats
    int _cloudHit;
    int _starHit;
    int _contentHeight;
    
    // flags.
    float _timeSinceNewContent;
    bool _canLoadNewContent;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    return self;
}

- (void)didLoadFromCCB {
    CCLOG(@"didLoadFromCCB");
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    _screenWidth = [[UIScreen mainScreen] bounds].size.width;
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    
    _audio = [OALSimpleAudio sharedInstance];
    _audio.effectsVolume = 1;
    _audio.muted = _gameManager.muted;
    
    
    // init game play related varibles
    _score = 0;
    _cloudHit = 0;
    _starHit = 0;
    _contentHeight = 100;
    _characterHighest = 0;
    _timeSinceNewContent = 0.0f;
    _canLoadNewContent = false;
    
    _physicsNode.collisionDelegate = self;
    _sharedObjectsGroup = _objectsGroup;

    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    [_tapGesture setCancelsTouchesInView:NO]; // !! do not cancel the other call back functions of touches.
    
    // load game content
    [self loadNewContent];
}

- (void)update:(CCTime)delta {
    if (_gameManager.gamePlayState == 0) { // game on going.
        //TODO: optimize
        int xMin = _character.boundingBox.origin.x;
        int xMax = xMin + _character.boundingBox.size.width;
        int screenLeft = self.boundingBox.origin.x;
        int screenRight = self.boundingBox.origin.x + self.boundingBox.size.width;
        int screenHeight = [[UIScreen mainScreen] bounds].size.height;  // ????????? can I replace it? in onEnter?
        
        // character jump out of the screen from left or right, launch a new character and remove the old one.
        if (xMax < screenLeft) {
            [self lunchCharacterAtPosition:screenRight];
        } else if (xMin > screenRight) {
            [self lunchCharacterAtPosition:screenLeft];
        }
        
        // if character reach top of the scene, load new content.
        if(_canLoadNewContent) {
            int yMax = _character.boundingBox.origin.y + _character.boundingBox.size.height;
            
            // determine when to load new content. (is there any built-in function for this?)
            if (yMax + screenHeight / 2 + 200 > _contentHeight) {
                [self stopUserInteraction];  // is this line necessary??
                [self loadNewContent];
                [self startUserInteraction];
                [self followCharacter];
                
                _canLoadNewContent = false;
                _timeSinceNewContent = 0.0f;
            }
        }
        
        _timeSinceNewContent += delta;  // delta is approximately 1/60th of a second
        if (_timeSinceNewContent > 2.0f) {
            _canLoadNewContent = true;
        }
        
        // if the character starts to drop, end the game.
        if (_character.position.y > _characterHighest) {
            _characterHighest = _character.position.y;
        }
        if (_character.position.y + screenHeight * 2 < _characterHighest) {
            [self endGame];
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
    else if (_gameManager.gamePlayState == 4) { // soumd setting to be reversed
        _audio.muted = _gameManager.muted;
        _gameManager.gamePlayState = 1;
    }
}

- (void)onEnter {
    CCLOG(@"onEnter");
    [super onEnter];
    [self startUserInteraction];
}

- (void)onExit {
    CCLOG(@"onExit");
    [super onExit];
    [self stopUserInteraction];
}

// loadNewContent by ramdomly generate game content.
- (void)loadNewContent {
    int interval;
    float scale;
    
    if (_contentHeight < 3000) {
        interval = 40;
    } else {
        interval = 50;
    }
    
    if (_contentHeight < 10000) {
        scale = 1.f;
    } else if (_contentHeight < 15000) {
        scale = 0.9f;
    } else if (_contentHeight < 20000) {
        scale = 0.8f;
    } else if (_contentHeight < 25000) {
        scale = 0.7f;
    } else {
        scale = 0.6f;
    }
    
    for (int i = 0; i < 20; i++) {
        CCNode *cloud = [CCBReader load:@"Objects/Cloud"];
        _contentHeight += interval;
        cloud.position = ccp(arc4random_uniform(280) + 20, _contentHeight);
        cloud.zOrder = -1;
        cloud.scale = scale;
        [_objectsGroup addChild:cloud];
    }
    
    CCNode *star;
    if (_starHit < 3) {
        star = [CCBReader load:@"Objects/StarStatic"];
    } else if (_starHit < 8) {
        star = [CCBReader load:@"Objects/StarSpining40"];
    } else {
        star = [CCBReader load:@"Objects/StarSpining80"];
    }
    _contentHeight += interval;
    star.position = ccp(arc4random_uniform(240) + 40, _contentHeight);
    star.zOrder = -1;
    [_objectsGroup addChild:star];
}

- (void)followCharacter {
    // the height of boundingbox changes when new content is loaded.
    CGRect contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, _contentHeight);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:contentBoundingBox];
    [_contentNode runAction:_followCharacter];
}

- (void)startUserInteraction {
    self.userInteractionEnabled = TRUE;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_tapGesture];
    CCLOG(@"addGestureRecognizer");
}

- (void)stopUserInteraction {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_tapGesture];
    self.userInteractionEnabled = false;  // stop accept touches.
    CCLOG(@"removeGestureRecognizer");
}

- (void)tapGesture:(UIGestureRecognizer *)gestureRecognizer  {
    CGPoint point = [gestureRecognizer locationInView:gestureRecognizer.view];
    CGPoint convertedPoint = [self convertToNodeSpace:[self convertToWorldSpace:point]];
    convertedPoint.y = _screenHeight - convertedPoint.y; // the convertedPoint has different reference corner.
    if (CGRectContainsPoint(_buttonPause.boundingBox, convertedPoint)) {
        return;
    }
    
    int xScreenMid = _screenWidth / 2;
    float xTap = point.x;
    if (xTap < xScreenMid) {
        [_character moveLeft];
    } else {
        [_character moveRight];
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    //CCLOG(@"character collided with cloud!");
    
    _cloudHit += 1;
    _score += _cloudHit * 10;
    [self updateScore];
    
    // after hit one cloud, start to follow the character
    // if start following in didLoadFromCCB, the GamePlay scene won't show up correctly. (why?)
    if (_cloudHit == 1) {
        [self followCharacter];
    }
    
    [_character jump];
    [self cloudRemoved:nodeB];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    //CCLOG(@"character collided with star!");
    _starHit += 1;
    _score *= 2;
    [self updateScore];
    
    [_character jump];
    CGPoint collisionPoint = pair.contacts.points[0].pointA;
    [self starRemoved:nodeB at:collisionPoint];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    //CCLOG(@"character collided with groud!");
    
    if (_cloudHit > 0) {
        [self endGame];
    } else {
        [_character jump];
    }
    
    return YES;
}

// update current score and highest score, stop user interaction on GamePlay, load GameOver scene.
- (void)endGame {
    _gameManager.currentScore = _score;
    if (_score > _gameManager.highestScore) {
        _gameManager.highestScore = _score;
    }
    
    [self stopUserInteraction];
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GameOver"]];
}

- (void)lunchCharacterAtPosition: (int)x {
    // launch a new chatacter
    CCNode *character = [CCBReader load:@"Character"];
    character.position = ccp(x, _character.position.y);
    character.physicsBody.velocity = _character.physicsBody.velocity;
    
    // replace the old one with the new one.
    [_character removeFromParent];
    _character = (Character *)character;
    [_physicsNode addChild:_character];
    [self followCharacter];
}

- (void)updateScore {
    _scoreLabel.string = [GameManager scoreWithComma:_score];
}

- (void)cloudRemoved:(CCNode *)cloud {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/CloudVanish"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = cloud.position;
    [cloud.parent addChild:explosion];
    
    // show earned score for a short time
    ScoreAdd *scoreAdd = (ScoreAdd *) [CCBReader load:@"Effects/ScoreAdd"];
    scoreAdd.position = cloud.position;
    [scoreAdd setScore:(_cloudHit * 10)];
    [cloud.parent addChild:scoreAdd];
    
    // remove a cloud from the scene
    [cloud removeFromParent];
    
    // play sound effect
    [_audio playEffect:@"sound_cloud.wav"];
}

- (void)starRemoved:(CCNode *)star at:(CGPoint)collisionPoint {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/StarVanish"];
    explosion.autoRemoveOnFinish = TRUE; // make the particle effect clean itself up, once it is completed
    explosion.position = collisionPoint;
    [star.parent.parent addChild:explosion];
    
    // show "score double" for a short time (use star.parent as the whole object!)
    ScoreDouble *scoreDouble = (ScoreDouble *) [CCBReader load:@"Effects/ScoreDouble"];
    scoreDouble.position = collisionPoint;
    [star.parent.parent addChild:scoreDouble];
    
    // remove the entire starSpinging object from parent, not just the star.
    [star.parent removeFromParent];
    
    // play sound effect
    [_audio playEffect:@"star_sound.wav"];
}

- (void)pause {
    CCLOG(@"pause");
    if (_gameManager.gamePlayState == 0) {
        _popUp = [CCBReader load:@"PausePopUp"];
        // ButtonPause and _popUp has difference reference corner, use _screenHeight - y
        _popUp.position = ccp(_buttonPause.position.x, _screenHeight - _buttonPause.position.y);
        [_gamePlay addChild:_popUp];
        
        _physicsNode.paused = YES;
        [self stopUserInteraction];
        _gameManager.gamePlayState = 1;
    }
}

- (void)playBackGroundMusic {
    OALSimpleAudio *bgMusic = [OALSimpleAudio sharedInstance];
    bgMusic.bgVolume = 1;
    [bgMusic playBg:@"High Mario.mp3" loop:YES];
}

+ (int)getCharacterHighest {
    return _characterHighest;
}

+ (CGPoint)getPositionInObjectsGroup: (CGPoint)point {
    return [_sharedObjectsGroup convertToNodeSpace:point];
}

@end
