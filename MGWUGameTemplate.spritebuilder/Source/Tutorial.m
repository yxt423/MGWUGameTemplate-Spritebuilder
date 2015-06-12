//
//  Tutorial.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Tutorial.h"
#import "GameManager.h"
#import "Character.h"

@implementation Tutorial {
    int _tutorialState;
    float _flagPosition;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _tutorialState = 0;
    // 0: to load left cover.  1, left cover loaded.  2, right cover loaded.  3,
    
    
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
            [self loadCoverOnLeft];
            _tutorialState = 1;
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

- (void)loadCoverOnLeft {
    pauseCover = [CCBReader load:@"Gadgets/PauseCover"];
    pauseCover.anchorPoint = CGPointMake(1, 0);
    pauseCover.position = CGPointMake(_character.position.x, 0);
    [self addChild:pauseCover];
    _flagPosition = _character.position.x;
    
    [self loadTabAt: ccp((_gameManager.screenWidth - _character.position.x) / 2 + _character.position.x, 80)];
}

- (void)loadCoverOnRight {
    pauseCover = [CCBReader load:@"Gadgets/PauseCover"];
    pauseCover.anchorPoint = CGPointMake(0, 0);
    pauseCover.position = CGPointMake(_character.position.x, 0);
    [self addChild:pauseCover];
    _flagPosition = _character.position.x;
    
    [self loadTabAt:ccp(_character.position.x / 2, 80)];
}

- (void)loadTabAt: (CGPoint)position {
    CCNode *T_tab = [GameManager addCCNodeFromFile:@"Gadgets/TutorialTab" WithPosition:position To:self];
    [GameManager playThenCleanUpAnimationOf:T_tab Named:@"In"];
}

// switching states when the character hit the groud. 
- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    [_character jump];
    if (_tutorialState == 1 && _character.position.x > _flagPosition + 70) {
        [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
        [self loadCoverOnRight];
        _tutorialState = 2;
    } else if (_tutorialState == 2 && _character.position.x + 70 < _flagPosition) {
        [GameManager playThenCleanUpAnimationOf:pauseCover Named:@"Out"];
        _tutorialState = 3;
    }
    return YES;
}

-(void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer{
    return; // override super. do not activate bubble function.
}


@end
