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

static int _screenHeight;

@implementation MainScene {
    CCButton *_buttonSetting;
}

- (void)didLoadFromCCB {
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
}

- (void)play {
    CCScene *gameplayScene = [CCBReader loadAsScene:@"GamePlay"];
    [[CCDirector sharedDirector] replaceScene:gameplayScene];
    
    
    Mixpanel *mixpanel = [Mixpanel sharedInstance];
    [mixpanel track:@"Plan Selected" properties:@{
                                                  @"Gender": @"Female",
                                                  @"Plan": @"Premium"
                                                  }];
}

- (void)setting {
    CCLOG(@"Main - setting");
    CCNode *_popUp = [CCBReader load:@"SettingPopUp"];
    _popUp.position = _buttonSetting.position;
    [self addChild:_popUp];
}

@end
