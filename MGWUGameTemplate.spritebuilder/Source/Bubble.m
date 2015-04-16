//
//  Bubble.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Bubble.h"
#import "GameManager.h"

static GameManager * _gameManager;

@implementation Bubble

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
}

+ (void)addBubble: (int)num {
    _gameManager.bubbleNum += num;
    [[NSUserDefaults standardUserDefaults] setInteger:_gameManager.bubbleNum forKey:@"bubbleNum"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
