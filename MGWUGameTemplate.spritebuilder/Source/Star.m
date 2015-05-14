//
//  Star.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Star.h"
#import "GamePlay.h"
#import "GameManager.h"

@implementation Star

- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"star";
}

- (void)removeAndPlayAnimationAt: (CGPoint)collisionPoint {
    [GameManager addParticleFromFile:@"Effects/StarVanish" WithPosition:collisionPoint To:self.parent.parent];
//    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/StarVanish"];
//    explosion.autoRemoveOnFinish = TRUE; // make the particle effect clean itself up, once it is completed
//    explosion.position = collisionPoint;
//    [self.parent.parent addChild:explosion];
    
    // show "score double" for a short time (use star.parent as the whole object!)
    CCNode *scoreDouble = [GameManager addCCNodeFromFile:@"Effects/ScoreDouble" WithPosition:collisionPoint To:self.parent.parent];
//    CCNode *scoreDouble = [CCBReader load:@"Effects/ScoreDouble"];
//    scoreDouble.position = collisionPoint;
//    [self.parent.parent addChild:scoreDouble];
    
    // remove when finish.
    [GameManager playThenCleanUpAnimationOf:scoreDouble Named:@"Default Timeline"];
//    CCAnimationManager* animationManager = scoreDouble.userObject;
//    [animationManager runAnimationsForSequenceNamed:@"Default Timeline"];
//    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
//        [scoreDouble removeFromParentAndCleanup:YES];
//    }];
    
    // remove the entire starSpinging object from parent, not just the star.
    [self.parent removeFromParent];
    
    // play sound effect
    [_gameManager.audio playEffect:@"star_sound.wav"];
}

@end
