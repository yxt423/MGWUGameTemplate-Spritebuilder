//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#include <stdlib.h>
#import "MainScene.h"
#import "GamePlay.h"
#import "GameManager.h"
#import "IAPManager.h"
#import "Character.h"
#import "Groud.h"
#import "Energy.h"
#import "InfoScene.h"
#import "Mixpanel.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation MainScene {
    CCButton *_buttonSetting;
    CCButton *_buttonFB;
    IAPManager *_iapManager;
    CCNode *_mainScene;
    Character *_character;
    CCNode *_bubble;
    Energy *_energy;
    
    bool _inBubble;
    float _timeSinceUpdate;
    bool _canUpdate;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _inBubble = true;
    
    return self;
}

- (void)didLoadFromCCB {
    _gameManager.currentSceneNo = _gameManager.MAINSCENE_NO;
    _iapManager = [IAPManager getIAPManager];
    _physicsNode.collisionDelegate = self;
    _timeSinceUpdate = 0.f;
    _canUpdate = true;
    
    // prevent the ground from being removed.
    _gameManager.characterHighest = 0;
    
    CCAnimationManager* animationManager = _energy.userObject;
    [animationManager runAnimationsForSequenceNamed:@"In"];
}

- (void)onEnter {
    [super onEnter];
    // init devide parameters.
    [_gameManager initDeviceParam:self];
}

- (void)update:(CCTime)delta {
    _timeSinceUpdate += delta;
    if (_timeSinceUpdate > 0.1f) {
        _canUpdate = true;
    }
    
    if (!_inBubble) { // no updates if the character is not in bubble.
        return;
    }
    
    // limit the character in a certain area of the screen.
    if (_canUpdate) {
        if (_character.position.x < 50) {
            [_character.physicsBody applyImpulse:ccp(50.f, 0.f)];
        } else if (_character.position.x > 150) {
            [_character.physicsBody applyImpulse:ccp(-50.f, 0.f)];
        }
        
        _canUpdate = false;
        _timeSinceUpdate = 0;
    }
    
    // let the bubble move with character.
    _bubble.position = _character.position;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    if (_inBubble) {
        // remove bubble and play vanish animation
        [_bubble removeFromParent];
        _inBubble = false;
        [GameManager addParticleFromFile:@"Effects/BubbleVanish" WithPosition:ccp(0.5, 0.2) Type:_gameManager.getPTNormalizedTopLeft To:_character];
        
        [_character stop];
        
        CCAnimationManager* animationManager = _mainScene.userObject;
        [animationManager runAnimationsForSequenceNamed:@"Repeat"];
    }
    
    return YES;
}

- (void)play {
    [_gameManager playButton:self];
//    // get 10 energy everyday.
//    NSDate *newTime = [NSDate date];
//    NSDate *oldTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGiftTime"];
//    CCLOG(@"newTime %@", newTime);
//    CCLOG(@"oldTime %@", oldTime);
//    
////    [GameManager addCCNodeFromFile:@"PopUp/NewEnergyPopUp" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
//    
//    // new players got to play several times for free.
//    if (_gameManager.gamePlayTimes < _gameManager.TIMETO_START_ENERGY) {
//        [_gameManager startNewGame];
//        return;
//    }
//    if (_gameManager.gamePlayTimes == _gameManager.TIMETO_START_ENERGY) {
//        [GameManager addCCNodeFromFile:@"PopUp/EnergyStartPopUp" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
//        _gameManager.energyNum -= 1;
//        return;
//    }
//    
//    if (!oldTime || [[oldTime dateByAddingTimeInterval:60*60*24*1] compare: newTime] == NSOrderedAscending) {
//        CCLOG(@"new 10 bubbles!");
//        [GameManager addCCNodeFromFile:@"PopUp/NewEnergyPopUp" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
//        _gameManager.energyNum += _gameManager.FREE_ENERGY_EVERYDAY;
//        [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"lastGiftTime"];
//    } else {
//        [_gameManager startNewGame];
//    }
}

- (void)updateEnergyLabel{
    [_energy updateEnergyNum];
}

- (void)setting {
    if (_gameManager.mainSceneState == 1) {
        return;
    }
    
    CCNode *_popUp = [CCBReader load:@"PopUp/SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);

    [self addChild:_popUp];
}

- (void)shop {
    if (_gameManager.mainSceneState == 1) {
        return;
    }
    
    [self pauseAndCover];
    [GameManager addCCNodeFromFile:@"PopUp/Shop" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
    _gameManager.shopSceneNo = 1;
    _gameManager.mainSceneState = 1;
}

- (void)scoreBoard {
    if (_gameManager.mainSceneState == 1) {
        return;
    }
    
    [GameManager pushSceneWithFadeTransition:@"SocreBoardScene"];
}

// invisible button
- (void)reset {
    CCLOG(@".....just reset game.");
    _gameManager.highestScore = 0;
    _gameManager.gamePlayTimes = 0;
    _gameManager.bubbleStartNum = 0;
    _gameManager.energyNum = _gameManager.FREE_ENERGY_EVERYDAY;
    _gameManager.tutorialProgress = 0;
    
    _gameManager.scoreBoard = nil;
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"scoreBoard"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _gameManager.scoreBoard = [[NSMutableArray alloc] init];
}

// invisible button
- (void)addEnergy {
    _gameManager.energyNum += 10;
}

@end
