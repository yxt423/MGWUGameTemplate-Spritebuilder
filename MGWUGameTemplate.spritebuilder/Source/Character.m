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


- (void) jump {
    CCLOG(@"jump");
    [self.physicsBody applyImpulse:ccp(0.f, 3500.f)];
}

@end
