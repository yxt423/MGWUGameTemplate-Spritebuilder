//
//  GamePlay.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "GameOver.h"
#import "Character.h"
#import "Cloud.h"
#import "Groud.h"
#import "CCPhysics+ObjectiveChipmunk.h"

@implementation GamePlay {
    Character *_character;
    CCNode *_contentNode;
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabel;
    
    CCAction *_followCharacter;
    
    int _cloudHit;
}

- (void)didLoadFromCCB {
    // init game play related varibles
    _score = 0;
    _cloudHit = 0;
    
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

- (void)update:(CCTime)delta {
}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    //CCLOG(@"character collided with cloud!");
    
    [_character jump];
    [self cloudRemoved:nodeB];
    
    _cloudHit += 1;
    _score += _cloudHit * 10;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_score];
    
    // after hit one cloud, start to follow the character
    // if start following in didLoadFromCCB, the GamePlay scene wouldn't show up correctly. ?
    if (_cloudHit == 1) {
        _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:self.boundingBox];
        [_contentNode runAction:_followCharacter];
    }
    
    return YES;
}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    //CCLOG(@"character collided with groud!");
    
    if (_cloudHit > 0) {
        [self endGame];
    } else {
        [_character jump];
    }
    
    return YES;
}

- (void)swipeLeft {
    [_character moveLeft];
}

- (void)swipeRight {
    [_character moveRight];
}

- (void)cloudRemoved:(CCNode *)cloud {
    // remove a cloud from the scene
    [cloud removeFromParent];
}

- (void)endGame {
    // store current score
    [[NSUserDefaults standardUserDefaults] setObject: [NSNumber numberWithInt:_score] forKey:@"score"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // update high score
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
    if (_score > [highScore intValue]) {
        // new highscore!
        highScore = [NSNumber numberWithInt:_score];
        [[NSUserDefaults standardUserDefaults] setObject:highScore forKey:@"highscore"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GameOver"]];
}

@end
