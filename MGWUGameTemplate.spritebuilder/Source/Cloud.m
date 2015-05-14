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
#import "ScoreAdd.h"
#import "GameManager.h"

@implementation Cloud

- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"cloud";
}

- (void)removeAndPlayAnimation {
    [GameManager addParticleFromFile:@"Effects/CloudVanish" WithPosition:self.position To:self.parent];
    
    // show earned score for a short time
    ScoreAdd *scoreAdd = (ScoreAdd *)[GameManager addCCNodeFromFile:@"Effects/ScoreAdd" WithPosition:self.position To:self.parent];
    [scoreAdd setScore:(_gameManager.cloudHit * 10)]; // new score added: _cloudHit * 10
    [GameManager playThenCleanUpAnimationOf:scoreAdd Named:@"Default Timeline"];
    
    [self removeFromParent];
    [_gameManager.audio playEffect:@"sound_cloud.wav"]; // play sound effect
}


@end
