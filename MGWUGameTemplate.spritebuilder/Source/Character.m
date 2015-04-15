//
//  Character.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Character.h"

@implementation Character

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"character";
}

- (void)update:(CCTime)delta {
    
}

- (void)jump {
    self.physicsBody.velocity = ccp(0.f, 0.f);
    [self.physicsBody applyImpulse:ccp(0.f, 300.f)];
}

- (void)moveLeft {
    [self.physicsBody applyImpulse:ccp(-150.f, 0.f)];
}

- (void)moveRight {
    [self.physicsBody applyImpulse:ccp(150.f, 0.f)];
}

- (void)bubbleUp {
    self.physicsBody.velocity = ccp(0.f, 0.f);
    [self.physicsBody applyImpulse:ccp(0.f, 1000.f)];
}

@end
