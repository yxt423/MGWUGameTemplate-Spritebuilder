//
//  BasicScene.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#include <stdlib.h>
#import "GameManager.h"
#import "Mixpanel.h"
#import "BasicScene.h"

@implementation BasicScene

@synthesize _mixpanel;
@synthesize _physicsNode;
@synthesize _gameManager;

@synthesize pauseCover;

- (id)init {
    self = [super init];
    if (!self) return(nil);
    
    _gameManager = [GameManager getGameManager];
    _mixpanel = [Mixpanel sharedInstance];
    
    return self;
}

/* pause function pair: used in mainScene and gamePlay */
- (void)pauseAndCover {
    _physicsNode.paused = YES;
    pauseCover = [GameManager addCCNodeFromFile:@"Gadgets/PauseCover" WithPosition:ccp(0.5, 0.5) Type:_gameManager.getPTNormalizedTopLeft To:self];
}

- (void)resumeAndUncover {
    _physicsNode.paused = NO;
    [pauseCover removeFromParent];
}

@end
