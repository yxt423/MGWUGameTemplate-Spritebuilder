//
//  Energy.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/4/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Energy.h"
#import "GameManager.h"

@implementation Energy {
    GameManager *_gameManager;
    CCLabelTTF *_energyLabel;
}

- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    [self updateEnergyNum];
}

- (void)updateEnergyNum {
    _energyLabel.string = [NSString stringWithFormat:@"%d", _gameManager.energyNum];
}

@end
