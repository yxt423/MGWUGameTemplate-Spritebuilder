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

@implementation Cloud {
    float _timeSinceUpdate;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"cloud";
    _gameManager = [GameManager getGameManager];
}

- (void)removeAndPlayAnimation {
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"Effects/CloudVanish"];
    explosion.autoRemoveOnFinish = TRUE;
    explosion.position = self.position;
    [self.parent addChild:explosion];
    
    // show earned score for a short time
    ScoreAdd *scoreAdd = (ScoreAdd *) [CCBReader load:@"Effects/ScoreAdd"];
    scoreAdd.position = self.position;
    [scoreAdd setScore:(_gameManager.cloudHit * 10)]; // new score added: _cloudHit * 10
    [self.parent addChild:scoreAdd];
    
    // remove scoreAdd when finish.
    CCAnimationManager* animationManager = scoreAdd.userObject;
    [animationManager runAnimationsForSequenceNamed:@"Default Timeline"];
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [scoreAdd removeFromParentAndCleanup:YES];
    }];
    
    // remove a cloud from the scene
    [self removeFromParent];
    
    // play sound effect
    [_gameManager.audio playEffect:@"sound_cloud.wav"];
}


@end
