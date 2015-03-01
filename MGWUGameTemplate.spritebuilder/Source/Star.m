//
//  Star.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 3/1/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "Star.h"

@implementation Star


- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"star";
}

@end
