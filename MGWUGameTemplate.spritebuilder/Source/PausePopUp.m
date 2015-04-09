//
//  PausePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "PausePopUp.h"
#import "GameManager.h"

@implementation PausePopUp {
    GameManager *_gameManager;
    CCButton *_buttonMuted;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    
    if (_gameManager.muted) {
        CCSpriteFrame *mutedImage = [CCSpriteFrame frameWithImageNamed:@"Button_muted_120.png"];
        [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateNormal];
        [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateHighlighted];
    }
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

- (void)mute {
    CCLOG(@"PausePopUp - mute");
    _gameManager.muted = !_gameManager.muted;
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:_gameManager.muted] forKey:@"muted"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    CCSpriteFrame *mutedImage;
    if (!_gameManager.muted) {
        mutedImage = [CCSpriteFrame frameWithImageNamed:@"Button_music_120.png"];
    } else {
        mutedImage = [CCSpriteFrame frameWithImageNamed:@"Button_muted_120.png"];
    }
    [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateNormal];
    [_buttonMuted setBackgroundSpriteFrame:mutedImage forState:CCControlStateHighlighted];
    
    _gameManager.gamePlayState = 4;
}

@end
