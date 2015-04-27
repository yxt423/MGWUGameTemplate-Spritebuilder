//
//  BubbleObject.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BubbleObject.h"

@implementation BubbleObject


- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"bubbleObject";
}

- (void)removeAndPlayAnimation {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/BubbleVanish"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    // show bubble plus 1 for a short time
    CCNode *bubbleAddOne =  [CCBReader load:@"Effects/BubbleAddOne"];
    bubbleAddOne.position = self.position;
    [self.parent addChild:bubbleAddOne];
    
    // remove when finish.
    CCAnimationManager* animationManager = bubbleAddOne.userObject;
    [animationManager runAnimationsForSequenceNamed:@"Default Timeline"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [bubbleAddOne removeFromParentAndCleanup:YES];
    }];
    
    [self removeFromParent];
}

@end
