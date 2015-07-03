//
//  NewBubblePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewBubblePopUp.h"
#import "GameManager.h"
#import "MainScene.h"

@implementation NewBubblePopUp {
    CCNode *_newBubblePopUp;
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);

    _gameManager = [GameManager getGameManager];
    
    return self;
}

- (void)ok {
    [_gameManager startNewGame];
}

@end
