//
//  GamePlay.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
/*
 
 == Load game content mechanism == 
 Start with an empty gameplay scene, load new content into _objectsGroup.
 
 
 == End game mechanism  ==
 1. Remove the cloud when it's position is one screen lower than _characterHighest.
    (A cloud can get it's relative position by calling the class method getPositionInObjectsGroup, which uses a static verible _sharedObjectsGroup, which equals to _objectsGroup. // Strategies for Accessing Other Nodes: http://www.learn-cocos2d.com/files/cocos2d-essential-reference-sample/Strategies_for_Accessing_Other_Nodes.html )
 2. End the game when the character is two screens lower than _characterHighest.
 
 */

#include <stdlib.h>

#import "GamePlay.h"
#import "GameOver.h"

#import "Character.h"
#import "Cloud.h"
#import "Star.h"
#import "Groud.h"

#import "ScoreAdd.h"
#import "ScoreDouble.h"

#import "CCPhysics+ObjectiveChipmunk.h"

static int _characterHighest; //the highest position the character ever been to
static CCNode *_sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.

@implementation GamePlay {
    Character *_character;
    CCNode *_contentNode;
    CCNode *_objectsGroup;
    CCPhysicsNode *_physicsNode;
    CCLabelTTF *_scoreLabel;
    CCAction *_followCharacter;
    
    // user interaction var
    UISwipeGestureRecognizer * _swipeLeft;
    UISwipeGestureRecognizer * _swipeRight;
    UILongPressGestureRecognizer *_longPress;
    UITapGestureRecognizer *_tapGesture;
    
    int _cloudHit;
    int _starHit;
    int _contentHeight;
    
    float _timeSinceNewContent;
    bool _canLoadNewContent;
}

- (void)didLoadFromCCB {
    // init game play related varibles
    _score = 0;
    _cloudHit = 0;
    _starHit = 0;
    _contentHeight = 100;
    _characterHighest = 0;
    _timeSinceNewContent = 0.0f;
    _canLoadNewContent = false;
    
    _physicsNode.collisionDelegate = self;

    _sharedObjectsGroup = _objectsGroup;

    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    
    // load game content
    [self loadNewContent];
    [self startUserInteraction];
    
    // play background music
    //[self playBackGroundMusic];
}

- (void)update:(CCTime)delta {
    //TODO: optimize
    int xMin = _character.boundingBox.origin.x;
    int xMax = xMin + _character.boundingBox.size.width;
    int screenLeft = self.boundingBox.origin.x;
    int screenRight = self.boundingBox.origin.x + self.boundingBox.size.width;
    int screenHeight = [[UIScreen mainScreen] bounds].size.height;
    
    // character jump out of the screen from left or right, launch a new character and remove the old one.
    if (xMax < screenLeft) {
        [self lunchCharacterAtPosition:screenRight];
    } else if (xMin > screenRight) {
        [self lunchCharacterAtPosition:screenLeft];
    }
    
    // if character reach top of the scene, load new content.
    if(_canLoadNewContent) {
        int yMax = _character.boundingBox.origin.y + _character.boundingBox.size.height;
        
        // determine when to load new content. (is there any built-in function for this?)
        if (yMax + screenHeight / 2 + 200 > _contentHeight) {
            //[self stopUserInteraction];  // is this line necessary??
            [self loadNewContent];
            [self startUserInteraction];
            //[_contentNode stopAllActions];
            [self followCharacter];
            
            _canLoadNewContent = false;
            _timeSinceNewContent = 0.0f;
        }
    }
    
    _timeSinceNewContent += delta;  // delta is approximately 1/60th of a second
    if (_timeSinceNewContent > 2.0f) {
        _canLoadNewContent = true;
    }
    
    // if the character starts to drop, end the game.
    if (_character.position.y > _characterHighest) {
        _characterHighest = _character.position.y;
    }
    if (_character.position.y + screenHeight * 2 < _characterHighest) {
        [self endGame];
    }
    
    //CCLOG(@"velocity %f", _character.physicsBody.velocity.y);
}

// loadNewContent by ramdomly generate game content.
- (void)loadNewContent {
    int interval;
    float scale;
    
    if (_contentHeight < 3000) {
        interval = 40;
    } else {
        interval = 50;
    }
    
    if (_contentHeight < 10000) {
        scale = 1.f;
    } else if (_contentHeight < 15000) {
        scale = 0.9f;
    } else if (_contentHeight < 20000) {
        scale = 0.8f;
    } else if (_contentHeight < 25000) {
        scale = 0.7f;
    } else {
        scale = 0.6f;
    }
    
    for (int i = 0; i < 20; i++) {
        CCNode *cloud = [CCBReader load:@"Cloud"];
        _contentHeight += interval;
        cloud.position = ccp(arc4random_uniform(280) + 20, _contentHeight);
        cloud.zOrder = -1;
        cloud.scale = scale;
        [_objectsGroup addChild:cloud];
    }
    
    CCNode *star;
    if (_starHit < 3) {
        star = [CCBReader load:@"StarStatic"];
    } else if (_starHit < 8) {
        star = [CCBReader load:@"StarSpining40"];
    } else {
        star = [CCBReader load:@"StarSpining80"];
    }
    _contentHeight += interval;
    star.position = ccp(arc4random_uniform(240) + 40, _contentHeight);
    star.zOrder = -1;
    [_objectsGroup addChild:star];
}

- (void)followCharacter {
    // the height of boundingbox changes when new content is loaded.
    CGRect contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, _contentHeight);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:contentBoundingBox];
    [_contentNode runAction:_followCharacter];
}

- (void)startUserInteraction {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_tapGesture];
}

- (void)stopUserInteraction {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_tapGesture];
    self.userInteractionEnabled = false;  // stop accept touches.
}

- (void)tapGesture:(UIGestureRecognizer *)gestureRecognizer  {
    int xScreenMid = [[UIScreen mainScreen] bounds].size.width / 2;
    float xTap = [gestureRecognizer locationInView:nil].x;
    if (xTap < xScreenMid) {
        [_character moveLeft];
    } else {
        [_character moveRight];
    }
}

-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    //CCLOG(@"character collided with cloud!");
    
    _cloudHit += 1;
    _score += _cloudHit * 10;
    [self updateScore];
    
    // after hit one cloud, start to follow the character
    // if start following in didLoadFromCCB, the GamePlay scene won't show up correctly. (why?)
    if (_cloudHit == 1) {
        [self followCharacter];
    }
    
    [_character jump];
    [self cloudRemoved:nodeB];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    //CCLOG(@"character collided with star!");
    _starHit += 1;
    _score *= 2;
    [self updateScore];
    
    [_character jump];
    CGPoint collisionPoint = pair.contacts.points[0].pointA;
    [self starRemoved:nodeB at:collisionPoint];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA groud:(CCNode *)nodeB {
    //CCLOG(@"character collided with groud!");
    
    if (_cloudHit > 0) {
        [self endGame];
    } else {
        [_character jump];
    }
    
    return YES;
}

// store current score and highest score for later acess, stop user interaction on GamePlay, load GameOver scene.
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
    
    [self stopUserInteraction];
    
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GameOver"]];
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
    [self followCharacter];
}

- (void)updateScore {
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_score];
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
    ScoreAdd *scoreAdd = (ScoreAdd *) [CCBReader load:@"ScoreAdd"];
    scoreAdd.position = cloud.position;
    [scoreAdd setScore:(_cloudHit * 10)];
    [cloud.parent addChild:scoreAdd];
    
    // remove a cloud from the scene
    [cloud removeFromParent];
}

- (void)starRemoved:(CCNode *)star at:(CGPoint)collisionPoint {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarVanish"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the collision's position
    explosion.position = collisionPoint;
    // add the particle effect to the same node the cloud is on
    [star.parent.parent addChild:explosion];
    
    // show "score double" for a short time (use star.parent as the whole object!)
    ScoreDouble *scoreDouble = (ScoreDouble *) [CCBReader load:@"ScoreDouble"];
    scoreDouble.position = collisionPoint;
    [star.parent.parent addChild:scoreDouble];
    
    // remove the entire starSpinging object from parent, not just the star.
    [star.parent removeFromParent];
}

- (void)playBackGroundMusic {
    OALSimpleAudio *bgMusic = [OALSimpleAudio sharedInstance];
    bgMusic.bgVolume = 1;
    [bgMusic playBg:@"High Mario.mp3" loop:YES];
}

+ (int)getCharacterHighest {
    return _characterHighest;
}

+ (CGPoint)getPositionInObjectsGroup: (CGPoint)point {
    return [_sharedObjectsGroup convertToNodeSpace:point];
}

@end
