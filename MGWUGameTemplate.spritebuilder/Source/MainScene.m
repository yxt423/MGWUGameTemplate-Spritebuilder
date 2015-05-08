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
#import "InfoScene.h"
#import "Mixpanel.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation MainScene {
    CCButton *_buttonSetting;
    CCButton *_buttonFB;
    GameManager *_gameManager;
    IAPManager *_iapManager;
    CCPhysicsNode *_physicsNode;
    Mixpanel *_mixpanel;
    CCNode *_mainScene;
    Character *_character;
    CCNode *_bubble;
    
    bool _inBubble;
    float _timeSinceUpdate;
    bool _canUpdate;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _iapManager = [IAPManager getIAPManager];
    _mixpanel = [Mixpanel sharedInstance];
    
    _physicsNode.collisionDelegate = self;
    _timeSinceUpdate = 0.f;
    _inBubble = false;
    _canUpdate = true;
    
    // prevent the ground from being removed.
    _gameManager.characterHighest = 0;
}

- (void)onEnter {
    [super onEnter];
    // init devide parameters.
    [_gameManager initDeviceParam:self];
    
    _bubble = [CCBReader load:@"Objects/Bubble"];
    _bubble.position = ccp(_character.boundingBox.size.width / 2, _character.boundingBox.size.height / 2);
    [_character addChild:_bubble];
    _inBubble = true;
}

- (void)update:(CCTime)delta {
    _timeSinceUpdate += delta;
    if (_timeSinceUpdate > 0.1f) {
        _canUpdate = true;
    }
    
    if(_canUpdate && _inBubble) {
        if (_character.position.x < 50) {
            [_character.physicsBody applyImpulse:ccp(50.f, 0.f)];
        } else if (_character.position.x > 150) {
            [_character.physicsBody applyImpulse:ccp(-50.f, 0.f)];
        }
        
        _canUpdate = false;
        _timeSinceUpdate = 0;
    }
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    if (_inBubble) {
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
    // get 10 bubbles everyday.
    NSDate *newTime = [NSDate date];
    NSDate *oldTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGiftTime"];
    CCLOG(@"newTime %@", newTime);
    CCLOG(@"oldTime %@", oldTime);
    
    if (!oldTime || [[oldTime dateByAddingTimeInterval:60*60*24*1] compare: newTime] == NSOrderedAscending) {
        CCLOG(@"new 10 bubbles!");
        [GameManager addCCNodeFromFile:@"PopUp/NewBubblePopUp" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
        [_gameManager addBubble:10];
        [[NSUserDefaults standardUserDefaults] setObject:newTime forKey:@"lastGiftTime"];
    } else {
        [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
    }
}

- (void)setting {
    CCNode *_popUp = [CCBReader load:@"PopUp/SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);

    [self addChild:_popUp];
}

- (void)shop {
    [GameManager addCCNodeFromFile:@"PopUp/Shop" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
}

- (void)scoreBoard {
    [GameManager replaceSceneWithFadeTransition:@"SocreBoardScene"];
}

- (void)buttonAddBubble {
    CCLOG(@".....just add more bubbles.");
    [_gameManager addBubble:2];
}

- (void)reset {
    CCLOG(@".....just reset game.");
    _gameManager.highestScore = 0;
    _gameManager.bubbleNum = 0;
    
    _gameManager.scoreBoard = nil;
    [[NSUserDefaults standardUserDefaults] setObject:[[NSMutableArray alloc] init] forKey:@"scoreBoard"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    _gameManager.scoreBoard = [[NSMutableArray alloc] init];
    
//    [[NSUserDefaults standardUserDefaults] setObject:0 forKey:@"lastGiftTime"];
}

@end
