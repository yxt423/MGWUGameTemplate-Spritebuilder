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
#import "GameManager.h"

@implementation Cloud {
    float _timeSinceUpdate;
    GameManager *_gameManager;
}

- (void)didLoadFromCCB {
    self.physicsBody.sensor = YES;
    self.physicsBody.collisionType = @"cloud";
}



@end
