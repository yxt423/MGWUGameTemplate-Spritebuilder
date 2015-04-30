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
    CCNode *_popUp;
    CCButton *_buttonMuted; // refers to 2 different buttons in 2 ccb files.
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    [self updateMuteButton];
}

- (void)resume {
    _gameManager.gamePlayState = 2;
    [self removeFromParent];
}

- (void)restart {
    _gameManager.gamePlayState = 3;
    [self removeFromParent];
}

- (void)backToMainScene {
    _gameManager.gamePlayState = 0;
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

- (void)muteGamePlay {
    [self mute];
    _gameManager.gamePlayState = 4;
}

- (void)muteMainMenu {
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
    [GameManager playThenCleanUpAnimationOf:_popUp Named:@"Collapse"];
}

- (void)info {
    [GameManager replaceSceneWithFadeTransition:@"InfoScene"];
}

@end
