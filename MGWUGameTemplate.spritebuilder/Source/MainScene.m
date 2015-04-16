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
#import "Bubble.h"

@implementation MainScene {
    CCButton *_buttonSetting;
    GameManager *_gameManager;
    Mixpanel *_mixpanel;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
}

- (void)onEnter {
    [super onEnter];
    // init devide parameters.
    [_gameManager initDeviceParam:self];
    
    // get 10 bubbles everyday. Is there a better place to do this?
    NSDate *newDate = [NSDate date];
    NSDate *oldDate = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastOpenDate"];
    [[NSUserDefaults standardUserDefaults] setObject:newDate forKey:@"lastOpenDate"];
    CCLOG(@"newDate %@", newDate);
    CCLOG(@"oldDate %@", oldDate);
    if ( !oldDate || [[oldDate dateByAddingTimeInterval:60*60*24*1] compare: newDate] == NSOrderedAscending) {
        CCLOG(@"new 10 bubbles!");
        CCNode *_newBubblePopUp = [CCBReader load:@"PopUp/NewBubblePopUp"];
        _newBubblePopUp.position = ccp(_gameManager.screenWidth / 2, _gameManager.screenHeight / 2);
        [self addChild:_newBubblePopUp];
        [Bubble addBubble:10];
    }
}

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
}

- (void)setting {
    CCLOG(@"Main - setting");
    CCNode *_popUp = [CCBReader load:@"PopUp/SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    _popUp.positionType = CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerBottomRight);

    [self addChild:_popUp];
}

@end
