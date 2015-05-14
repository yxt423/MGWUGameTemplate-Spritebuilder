//
//  CloudBlack.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/26/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CloudBlack.h"
#import "GameManager.h"

@implementation CloudBlack

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"cloudBlack";
}

@end
