//
//  GamePlay.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCNode.h"

@interface GamePlay : CCNode <CCPhysicsCollisionDelegate>

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

@end
