//
//  BasicObject.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicObject.h"
#import "GameManager.h"

@implementation BasicObject {
    float _timeSinceUpdate;
    GameManager *_gameManager;
}

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    _timeSinceUpdate = 0;
//    self.physicsBody.sensor = YES;
    
    return self;
}

- (void)update:(CCTime)delta {
    
    _timeSinceUpdate += delta;
    
    // excute this block less frenquently.
    if (_timeSinceUpdate > 1.0f) {
        _timeSinceUpdate = 0;
        
        // Remove the object when it's position is one screen lower than _characterHighest
        CGPoint position = [self.parent convertToWorldSpace:self.position];
        position = [_gameManager.sharedObjectsGroup convertToNodeSpace:position];
        
        if ((position.y + _gameManager.screenHeight) < _gameManager.characterHighest) {
            [self removeFromParent];
        }
    }
    
}

@end
