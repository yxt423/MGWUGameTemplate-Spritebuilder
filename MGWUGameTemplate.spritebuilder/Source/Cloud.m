//
//  Cloud.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
/*
 Remove the cloud when it's position is one screen lower than _characterHighest
 */


#import "Cloud.h"
#import "GamePlay.h"
#import "GameManager.h"

@implementation Cloud {
    float _timeSinceUpdate;
    GameManager *_gameManager;
}


- (void)didLoadFromCCB {
    _gameManager = [GameManager getGameManager];
    _timeSinceUpdate = 0;
    
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"cloud";
}

- (void)update:(CCTime)delta {
    
    _timeSinceUpdate += delta;
    
    // excute this block less frenquently. 
    if (_timeSinceUpdate > 1.0f) {
        _timeSinceUpdate = 0;
        
        // Remove the cloud when it's position is one screen lower than _characterHighest
        CGPoint cloudPosition = [self.parent convertToWorldSpace:self.position];
        cloudPosition = [_gameManager.objectsGroup convertToNodeSpace:cloudPosition];
        
        if ((cloudPosition.y + _gameManager.screenHeight) < _gameManager.characterHighest) {
            //CCLOG(@"cloudPosition %f, self.position.y %f, _screenHeight %d, CharacterHighest %d", cloudPosition.y, self.position.y, _screenHeight, [GamePlay getCharacterHighest]);
            [self removeFromParent];
        }
    }

}

@end
