//
//  Cloud.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
/*
 Remove the cloud when it's position is one screen lower than _characterHighest:
 
 
 */


#import "Cloud.h"
#import "GamePlay.h"

@implementation Cloud {
    float _timeSinceUpdate;
    
    int _screenHeight;
}


- (void)didLoadFromCCB {
    _timeSinceUpdate = 0;
    _screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
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
        cloudPosition = [GamePlay getPositionInObjectsGroup:cloudPosition];
        
        if ((cloudPosition.y + _screenHeight) < [GamePlay getCharacterHighest]) {
            //CCLOG(@"cloudPosition %f, self.position.y %f, _screenHeight %d, CharacterHighest %d", cloudPosition.y, self.position.y, _screenHeight, [GamePlay getCharacterHighest]);
            [self removeFromParent];
        }
    }

}

@end
