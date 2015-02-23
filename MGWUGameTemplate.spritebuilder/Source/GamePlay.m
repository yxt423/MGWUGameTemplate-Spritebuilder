//
//  GamePlay.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "Character.h"
#import "Cloud.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation GamePlay {
    Character *_character;
    CCNode *_contentNode;
    CCPhysicsNode *_physicsNode;
    
    BOOL gameStarted;
}

- (void)didLoadFromCCB {
    // init game play related varibles
    gameStarted = false;
    
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    _physicsNode.collisionDelegate = self;
    
    // listen for swipes to the left
    UISwipeGestureRecognizer * swipeLeft= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeLeft];
    
    // listen for swipes to the right
    UISwipeGestureRecognizer * swipeRight= [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:swipeRight];
}

//- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
//    [_character jump];
//}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    CCLOG(@"character collided with cloud!");
    
    [_character jump];
    
    return YES;
}

- (void)swipeLeft {
    [_character moveLeft];
}

- (void)swipeRight {
    [_character moveRight];
}

- (void)restart {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GamePlay"]];
    gameStarted = false;
}

- (void)start {
    if (!gameStarted) {
        gameStarted = true;
        [_character jump];
    }
}

@end
