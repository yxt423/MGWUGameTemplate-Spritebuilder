//
//  BubbleObject.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BubbleObject.h"
#import "GameManager.h"

@implementation BubbleObject


- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"bubbleObject";
}

- (void)removeAndPlayBubbleAddOne {
    [GameManager addParticleFromFile:@"Effects/BubbleVanish" WithPosition:self.position To:self.parent];
    
    // show bubble plus 1 for a short time, remove when finish.
    CCNode *bubbleAddOne = [GameManager addCCNodeFromFile:@"Effects/BubbleAddOne" WithPosition:self.position To:self.parent];
    [GameManager playThenCleanUpAnimationOf:bubbleAddOne Named:@"Default Timeline"];
    
    [self removeFromParent];
}

- (void)removeAndPlayVanish {
    [GameManager addParticleFromFile:@"Effects/BubbleVanish" WithPosition:self.position To:self.parent];
    [self removeFromParent];
}

@end
