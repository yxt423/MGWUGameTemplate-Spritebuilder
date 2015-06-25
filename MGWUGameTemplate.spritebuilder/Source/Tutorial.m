//
//  Tutorial.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
// Totorial about mo

#import "Tutorial.h"
#import "GamePlay+UIUtils.h"
#import "GameManager.h"
#import "Character.h"
#import "Star.h"
#import "Cloud.h"

@implementation Tutorial {
    int _tutorialState;
    float _coverBoundary;
    CCNode *_tutorialText;
    
    CCNode *_cloud1;
    CCNode *_cloud2;
    CCNode *_star;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _tutorialState = 0;
    /* 0: to load left cover.  1, left cover loaded.  2, right cover loaded. 3, clouds and star loaded. */
    
    return self;
}

// GamePlay update function won't be excuted.
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

/* collision functions */

// switching states when the character hit the groud.
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    [_character jump];
    
    if (_tutorialState == 1 && _character.position.x > _coverBoundary + 50) {
        [self tutorialStep2];
    } else if (_tutorialState == 2 && _character.position.x + 50 < _coverBoundary) {
        [self tutorialStep3];
    } else if (_tutorialState == 3 && _gameManager.cloudHit > 0 && _starHit == 0) {
        [self restartStep3];
    }
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    _starHit += 1;
    _score *= 2;
    [super updateScore];
    
    [_character jump];
    CGPoint collisionPoint = pair.contacts.points[0].pointA;
    [(Star *)nodeB removeAndPlayAnimationAt:(CGPoint)collisionPoint];
    
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText4" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
    CCAnimationManager* animationManager = _tutorialText.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [self endTutorial];
    }];
    
    return YES;
}

/* tutorial steps */

- (void)tutorialStep1 {
    _tutorialState = 1;
    
    pauseCover = [CCBReader load:@"Gadgets/PauseCover"];
    pauseCover.anchorPoint = CGPointMake(1, 0);
    pauseCover.position = CGPointMake(_character.position.x, 0);
    [self addChild:pauseCover];
    _coverBoundary = _character.position.x;
    
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
    _coverBoundary = _character.position.x;
    
    [self loadTabAt:ccp(_character.position.x / 2, 80)];
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText2" WithPosition:ccp(_character.position.x / 2, 200) To:self];
}

- (void)tutorialStep3 {
    // clean up previous step; load text, load cloud and star.
    _tutorialState = 3;
    [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
    [GameManager playThenCleanUpAnimationOf:_tutorialText Named:@"Out"];
    
    _tutorialText = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText3" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7) To:self];
    [self loadCloudAndStar];
}

- (void)restartStep3 {
    _gameManager.cloudHit = 0;
    
    CCNode *tryAgain = [GameManager addCCNodeFromFile:@"Gadgets/TutorialText5" WithPosition:ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight * 0.7 - 60) To:self];
    [GameManager playThenCleanUpAnimationOf:tryAgain Named:@"In"];
    
    CCAnimationManager* animationManager = tryAgain.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [tryAgain removeFromParentAndCleanup:YES];
        [self removeCloudAndStar];
        [self loadCloudAndStar];
    }];
}

- (void)endTutorial {
    if (_gameManager.gamePlayState == -1) {
        return; // endGame is already called once.
    }
    _gameManager.gamePlayState = -1;
    _gameManager.gamePlayTimes += 1;
    _gameManager.tutorialProgress = 1;
    
    [GameManager startNewGame];
}

/* others */

- (void)loadTabAt: (CGPoint)position {
    CCNode *T_tab = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTab" WithPosition:position To:self];
    [GameManager playThenCleanUpAnimationOf:T_tab Named:@"In"];
}

- (void)loadCloudAndStar {
    _cloud1 = [GameManager addCCNodeFromFile:@"Objects/Cloud" WithPosition:ccp(_gameManager.screenWidth - 130, 120) To:_objectsGroup];
    _cloud2 = [GameManager addCCNodeFromFile:@"Objects/Cloud" WithPosition:ccp(_cloud1.position.x - 70, 180) To:_objectsGroup];
    _star = [GameManager addCCNodeFromFile:@"Objects/StarStatic" WithPosition:ccp(_cloud1.position.x, 240) To:_objectsGroup];
}

- (void)removeCloudAndStar {
    if (_cloud1) {[_cloud1 removeFromParent];}
    if (_cloud2) {[_cloud2 removeFromParent];}
    if (_star) {[_star removeFromParent];}
}

-(void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer{
    return; // override super. do not activate bubble function.
}


@end
