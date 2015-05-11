//
//  BasicScene.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/11/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

@class Mixpanel;
@class CCNode;
@class GameManager;

@interface BasicScene : CCNode {
    CCPhysicsNode *_physicsNode;
    Mixpanel *_mixpanel;
    GameManager *_gameManager;
    
    // ui gadgets.
    CCNode * pauseCover;
}

@property (nonatomic, retain) CCPhysicsNode *_physicsNode;
@property (nonatomic, retain) Mixpanel *_mixpanel;
@property (nonatomic, retain) GameManager *_gameManager;

// ui gadgets.
@property (nonatomic, retain) CCNode * pauseCover;

- (void)pauseAndCover;
- (void)resumeAndUncover;

@end
