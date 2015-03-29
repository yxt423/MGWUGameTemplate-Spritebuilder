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

//static const int NUM_OF_CONTENT_FILE = 3;
static const int USER_CONTROL = 3; // 1. swipe 2. long press 3. tap.

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
    
    //
    _sharedObjectsGroup = _objectsGroup;
    
    // init varibles
    
    // define the listener for swipes to the left
    _swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    // define the listener for swipes to the right
    _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    // define the listener for long press
    _longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    _longPress.numberOfTapsRequired = 0;      // The default number of taps is 0.
    _longPress.minimumPressDuration = 0.1f;    // The default duration is is 0.5 seconds.
    _longPress.numberOfTouchesRequired = 1;   // The default number of fingers is 1.
    _longPress.allowableMovement = 10;        // The default distance is 10 pixels.
    
    _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGesture:)];
    
    // load game content
    [self loadNewContent];
    [self startUserInteraction];
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
}

/*  // loadNewContent from pre-designed file.
- (void)loadNewContent {
    // load new content from file.
    CCNode *newContent = (CCNode *)[CCBReader load:[self getNameOfContentFile]];
    newContent.position = ccp(0, _contentHeight);
    newContent.zOrder = -1;
    [_objectsGroup addChild:newContent];
    
    CCLOG(@"load new content! at y: %d", _contentHeight);
    
    // update varibles for CCActionFollow
    _contentHeight += newContent.boundingBox.size.height;
}
*/

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
    
    for (int i = 0; i < 10; i++) {
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
    
    CCLOG(@"load new content at y: %d, interval %d, scale %f", _contentHeight, interval, scale);
}

/*  // select a game content file: randomly.
- (NSString*) getNameOfContentFile {
    int fileNumber = arc4random_uniform(NUM_OF_CONTENT_FILE);
    NSString *fileName = [@"Screen" stringByAppendingString:[NSString stringWithFormat:@"%d", fileNumber]];
    CCLOG(@"%@", fileName);
    return fileName;
}
 */

- (void)followCharacter {
    // the height of boundingbox changes when new content is loaded.
    CGRect contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, _contentHeight);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:contentBoundingBox];
    [_contentNode runAction:_followCharacter];
}

- (void)startUserInteraction {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
    
    switch (USER_CONTROL) {
        case 1:
            [[[CCDirector sharedDirector] view] addGestureRecognizer:_swipeLeft];
            [[[CCDirector sharedDirector] view] addGestureRecognizer:_swipeRight];
            break;
        case 2:
            [[[CCDirector sharedDirector] view] addGestureRecognizer:_longPress];
            break;
        case 3:
            [[[CCDirector sharedDirector] view] addGestureRecognizer:_tapGesture];
            break;
    }
}

- (void)stopUserInteraction {
    switch (USER_CONTROL) {
        case 1:
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeft];
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRight];
            break;
        case 2:
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:_longPress];
            break;
        case 3:
            [[[CCDirector sharedDirector] view] removeGestureRecognizer:_tapGesture];
            break;
    }
    
    // stop accept touches.
    self.userInteractionEnabled = false;
}

- (void)swipeLeft {
    [_character moveLeft];
}

- (void)swipeRight {
    [_character moveRight];
}

- (void)longPress:(UIGestureRecognizer *)gestureRecognizer  {
    int xScreenMid;
    switch (gestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            xScreenMid = [[UIScreen mainScreen] bounds].size.width / 2;
            
            float xTap = [gestureRecognizer locationInView:nil].x;
            if (xTap < xScreenMid) {
                [_character longMoveLeft];
            } else {
                [_character longMoveRight];
            }
            break;
        case UIGestureRecognizerStateEnded:
            [_character cancelHoricentalSpeed];
            break;
    }
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
    [self starRemoved:nodeB];
    
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

- (void)starRemoved:(CCNode *)star {
    // load particle effect
    CCParticleSystem *explosion = (CCParticleSystem *)[CCBReader load:@"StarVanish"];
    // make the particle effect clean itself up, once it is completed
    explosion.autoRemoveOnFinish = TRUE;
    // place the particle effect on the cloud's position
//    CGPoint starPosition = [star.parent convertToWorldSpace:star.position];
//    explosion.position = [_physicsNode convertToNodeSpace:starPosition];
    explosion.position = star.parent.position; // ????   CHANGE TO: Collision positio.
    // add the particle effect to the same node the cloud is on
    [star.parent.parent addChild:explosion];
    
    // show "score double" for a short time
    // use star.parent as the whole object!
    ScoreDouble *scoreDouble = (ScoreDouble *) [CCBReader load:@"ScoreDouble"];
    scoreDouble.position = star.parent.position;
    [star.parent.parent addChild:scoreDouble];
    
    // remove the entire starSpinging object from parent, not just the star.
    [star.parent removeFromParent];
}

+ (int)getCharacterHighest {
    return _characterHighest;
}

+ (CGPoint)getPositionInObjectsGroup: (CGPoint)point {
    return [_sharedObjectsGroup convertToNodeSpace:point];
}

@end
