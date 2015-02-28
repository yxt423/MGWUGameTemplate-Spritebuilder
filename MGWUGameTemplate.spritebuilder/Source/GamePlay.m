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
    Character *_character_new;
    CCNode *_contentNode;
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabel;
    CCAction *_followCharacter;
    
    int _cloudHit;
    
//    int _screenLeft;
//    int _screenRight;
}

- (void)didLoadFromCCB {
    // init game play related varibles
    
//    _screenLeft = self.boundingBox.origin.x;
//    _screenRight = self.boundingBox.origin.x + self.boundingBox.size.width;
    
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
    int xMin = _character.boundingBox.origin.x;
    int xMax = xMin + _character.boundingBox.size.width;
    int screenLeft = self.boundingBox.origin.x;
    int screenRight = self.boundingBox.origin.x + self.boundingBox.size.width;
    
    // character jump out of the screen from left or right, launch a new character and remove the old one.
    if (xMax < screenLeft) {
        [self lunchCharacterAtPosition:screenRight];
    } else if (xMin > screenRight) {
        [self lunchCharacterAtPosition:screenLeft];
    }
}

- (void)lunchCharacterAtPosition: (int)x {
    // launch a new chatacter
    CCNode *character = [CCBReader load:@"Character"];
    character.position = ccp(x, _character.position.y);
    character.physicsBody.velocity = _character.physicsBody.velocity;
    
    // replace the old one with the new one.
    [_character removeFromParent];
    _character = (Character *)character;
    [_physicsNode addChild:_character];
    [self followChatacter];
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    //CCLOG(@"character collided with cloud!");
    
    [_character jump];
    [self cloudRemoved:nodeB];
    
    _cloudHit += 1;
    _score += _cloudHit * 10;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_score];
    
    // after hit one cloud, start to follow the character
    // if start following in didLoadFromCCB, the GamePlay scene won't show up correctly. (why?)
    if (_cloudHit == 1) {
        [self followChatacter];
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
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"CloudVanish"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the cloud's position
    explosion.position = cloud.position;
    // add the particle effect to the same node the cloud is on
    [cloud.parent addChild:explosion];
    
    // show earned score for a short time
//    CCLabelTTF * scoreAdded = [CCLabelTTF labelWithString:@"10" fontName:@"Marker Felt" fontSize:10];
//    scoreAdded.position = cloud.position;
//    [cloud.parent addChild:scoreAdded];
    
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

- (void)followChatacter {
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:self.boundingBox];
    [_contentNode runAction:_followCharacter];
}

@end
