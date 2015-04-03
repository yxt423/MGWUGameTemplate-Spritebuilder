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
    [self.physicsBody applyImpulse:ccp(0.f, -5.f)];
}

- (void)jump {
    //CCLOG(@"jump");
    
    self.physicsBody.velocity = ccp(0.f, 0.f);
    [self.physicsBody applyImpulse:ccp(0.f, 300.f)];
    //self.physicsBody.velocity = ccp(0.f, 300.f);
}

- (void)moveLeft {
//    if (self.physicsBody.velocity.x > 0.f) {
//        self.physicsBody.velocity = ccp(0.f, self.physicsBody.velocity.y);
//    }
    [self.physicsBody applyImpulse:ccp(-150.f, 0.f)];
}

- (void)moveRight {
//    if (self.physicsBody.velocity.x < 0.f) {
//        self.physicsBody.velocity = ccp(0.f, self.physicsBody.velocity.y);
//    }
    [self.physicsBody applyImpulse:ccp(150.f, 0.f)];
}

- (void)longMoveLeft {
    self.physicsBody.velocity = ccp(-200.f, self.physicsBody.velocity.y);
}

- (void)longMoveRight {
    self.physicsBody.velocity = ccp(200.f, self.physicsBody.velocity.y);
}

- (void)cancelHoricentalSpeed {
    self.physicsBody.velocity = ccp(0.f, self.physicsBody.velocity.y);
}

@end
