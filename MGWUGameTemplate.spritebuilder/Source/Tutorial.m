//
//  Tutorial.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "GamePlay+UIUtils.h"
#import "GameManager.h"
#import "Character.h"
#import "Star.h"
#import "Cloud.h"

@implementation Tutorial {
    int _tutorialState;
    float _flagPosition;
    CCNode *_tutorialText;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _tutorialState = 0;
    /* 0: to load left cover.  1, left cover loaded.  2, right cover loaded.  
     3, clouds and star loaded. 4, finish!
    */
    
    return self;
}

- (void)onEnter {
    [super onEnter];
    CCLOG(@"Tutorial started....");
}

// GamePlay update function won't be excuted.
- (void)update:(CCTime)delta {
    switch (_tutorialState) {
        case 0:
            [self tutorialStep1];
            break;
        case 1:
            break;
        default:
            break;
    }
    
    switch (_gameManager.gamePlayState) {
        case 0:  // game going on.
            // the wall goes with the character.
            _walls.position = ccp(0, _character.position.y - _walls.boundingBox.size.height / 2);
            break;
        case 2:   // to be resumed
            [super resume];
            break;
        case 3:  // to be restarted.
            [GameManager replaceSceneWithFadeTransition:@"Tutorial"];
            _gameManager.gamePlayState = 0;
            break;
        case 4:  // sound setting to be reversed
            _gameManager.audio.muted = _gameManager.muted;
            _gameManager.gamePlayState = 1;
            break;
        default:
            break;
    }
}

/* collision functions */

// switching states when the character hit the groud.
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    [_character jump];
    
    if (_tutorialState == 1 && _character.position.x > _flagPosition + 70) {
        [self tutorialStep2];
    } else if (_tutorialState == 2 && _character.position.x + 70 < _flagPosition) {
        [self tutorialStep3];
    }
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    
    _starHit += 1;
    score *= 2;
    [super updateScore];
    
    [_character jump];
    CGPoint collisionPoint = pair.contacts.points[0].pointA;
    [(Star *)nodeB removeAndPlayAnimationAt:(CGPoint)collisionPoint];
    
    return YES;
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    _gameManager.cloudHit += 1;
    score += _gameManager.cloudHit * 10;
    [self updateScore];
    [_character jump];
    [(Cloud *)nodeB removeAndPlayAnimation];
    return YES;
}

/* tutorial steps */

- (void)tutorialStep1 {
    _tutorialState = 1;
    
    pauseCover = [CCBReader load:@"Gadgets/PauseCover"];
    pauseCover.anchorPoint = CGPointMake(1, 0);
    pauseCover.position = CGPointMake(_character.position.x, 0);
    [self addChild:pauseCover];
    _flagPosition = _character.position.x;
    
    float positionX = (_gameManager.screenWidth - _character.position.x) / 2 + _character.position.x;
    [self loadTabAt: ccp(positionX, 80)];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText1" WithPosition:ccp(positionX, 200) To:self];
}

- (void)tutorialStep2 {
    // clean up previous step; load cover, load tabPosition, load text.
    _tutorialState = 2;
    [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    
    pauseCover = [CCBReader load:@"Gadgets/PauseCover"];
    pauseCover.anchorPoint = CGPointMake(0, 0);
    pauseCover.position = CGPointMake(_character.position.x, 0);
    [self addChild:pauseCover];
    _flagPosition = _character.position.x;
    
    [self loadTabAt:ccp(_character.position.x / 2, 80)];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText2" WithPosition:ccp(_character.position.x / 2, 200) To:self];
}

- (void)tutorialStep3 {
    // clean up previous step; load text, load cloud and star.
    _tutorialState = 3;
    [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText3" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
    
    CCNode *cloud = [GameManager addCCNodeFromFile:@"Objects/Cloud" WithPosition:ccp(_gameManager.screenWidth - 130, 120) To:_objectsGroup];
    [GameManager addCCNodeFromFile:@"Objects/Cloud" WithPosition:ccp(cloud.position.x - 50, 180) To:_objectsGroup];
    [GameManager addCCNodeFromFile:@"Objects/StarStatic" WithPosition:ccp(cloud.position.x, 240) To:_objectsGroup];
}

- (void)loadTabAt: (CGPoint)position {
    CCNode *T_tab = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTab" WithPosition:position To:self];
    [GameManager playThenCleanUpAnimationOf:T_tab Named:@"In"];
}

-(void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer{
    return; // override super. do not activate bubble function.
}


@end
