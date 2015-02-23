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


- (void)jump {
    CCLOG(@"jump");
    //[self.physicsBody applyImpulse:ccp(0.f, 3500.f)];
    self.physicsBody.velocity = ccp(0.f, 150.f);
}

- (void)moveLeft {
    // to be modified
    self.physicsBody.velocity = ccp(-80.f, 0.f);
}

- (void)moveRight {
    self.physicsBody.velocity = ccp(80.f, 0.f);
}

@end
