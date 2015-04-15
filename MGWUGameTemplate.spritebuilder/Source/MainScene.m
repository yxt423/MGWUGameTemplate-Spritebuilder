//
//  MainScene.m
//  PROJECTNAME
//
//  Created by Viktor on 10/10/13.
//  Copyright (c) 2013 Apportable. All rights reserved.
//

#import "MainScene.h"
#import "GamePlay.h"
#import "GameManager.h"
#import "InfoScene.h"
#import "Mixpanel.h"

@implementation MainScene {
    CCButton *_buttonSetting;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    [_mixpanel track:@"Game Open"];
}

- (void)play {
    // init devide parameters.
    [_gameManager initDeviceParam:self];
    
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)setting {
    CCLOG(@"Main - setting");
    CCNode *_popUp = [CCBReader load:@"SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);

    [self addChild:_popUp];
}

@end
