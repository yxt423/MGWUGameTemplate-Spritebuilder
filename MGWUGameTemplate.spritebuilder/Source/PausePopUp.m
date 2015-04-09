//
//  PausePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.

/*
 The class for PausePopUp.ccb and SettingPopUp.ccb
 */

#import "PausePopUp.h"
#import "GameManager.h"

static NSString * const buttonMusic = @"Assets/Button/Button_music_240.png";
static NSString * const buttonMuted = @"Assets/Button/Button_muted_240.png";

@implementation PausePopUp {
    GameManager *_gameManager;
    CCButton *_buttonMuted; // refers to 2 different buttons in 2 ccb files.
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    [self updateMuteButton];
}

- (void)resume {
    CCLOG(@"PausePopUp - resume");
    _gameManager.gamePlayState = 2;
    [self removeFromParent];
}

- (void)restart {
    CCLOG(@"PausePopUp - restart");
    _gameManager.gamePlayState = 3;
    [self removeFromParent];
}

- (void)backToMainScene {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
    _gameManager.gamePlayState = 0;
}

- (void)muteGamePlay {
    CCLOG(@"PausePopUp - muteGamePlay");
    [self mute];
    _gameManager.gamePlayState = 4;
}

- (void)muteMainMenu {
    CCLOG(@"PausePopUp - muteMainMenu");
    [self mute];
}

- (void)mute {
    _gameManager.muted = !_gameManager.muted;
    [[NSUserDefaults standardUserDefaults] setBool:_gameManager.muted forKey:@"muted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [self updateMuteButton];
}

- (void)updateMuteButton {
    CCSpriteFrame *mutedImage;
    if (!_gameManager.muted) {
        mutedImage = [CCSpriteFrame frameWithImageNamed:buttonMusic];
    } else {
        mutedImage = [CCSpriteFrame frameWithImageNamed:buttonMuted];
    }
    // _buttonMuted refers to 2 different buttons in 2 ccb files: PausePopUp & SettingPopUp
    [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateNormal];
    [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateHighlighted];
}

- (void)setting {
    [self removeFromParent];
}

- (void)info {
    CCScene *infoScene = [CCBReader loadAsScene:@"InfoScene"];
    [[CCDirector sharedDirector] pushScene:infoScene];
}

@end
