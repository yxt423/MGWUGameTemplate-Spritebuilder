//
//  EnergyStartPopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/6/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "EnergyStartPopUp.h"
#import "GameManager.h"
#import "MainScene.h"
#import "BasicScene.h"
#import "GameOver.h"

@implementation EnergyStartPopUp {
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    
    return self;
}

- (void)ok {
    [_gameManager energyMinusOneAndStartGame:(BasicScene*)self.parent];
}

@end
