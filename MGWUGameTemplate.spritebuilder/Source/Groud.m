//
//  Groud.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Groud.h"

@implementation Groud

- (void)didLoadFromCCB {
    self.physicsBody.collisionType = @"groud";
}

@end
