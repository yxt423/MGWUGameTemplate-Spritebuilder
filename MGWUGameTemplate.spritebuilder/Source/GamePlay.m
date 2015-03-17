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
#import "Star.h"
#import "Groud.h"

#import "ScoreAdd.h"
#import "ScoreDouble.h"

#import "CCPhysics+ObjectiveChipmunk.h"

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
    
    
    int _cloudHit;
    
    int _contentHeight;
    CGRect _contentBoundingBox;
    
    bool _tempFlag;
}

- (void)didLoadFromCCB {
    // init game play related varibles
    _score = 0;
    _cloudHit = 0;
    _contentHeight = 0;
    
    _physicsNode.collisionDelegate = self;
    
    // init varibles
    // define the listener for swipes to the left
    _swipeLeft = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeLeft)];
    _swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    // define the listener for swipes to the right
    _swipeRight = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeRight)];
    _swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    // load the first content
    [self loadNewContent];
    [self startUserInteraction];
    //[self followChatacter];
    
    _tempFlag = false;
}

- (void)loadNewContent {
    CCNode *newContent = (CCNode *)[CCBReader load:@"Screen1"];
    newContent.position = ccp(0, _contentHeight);
    newContent.zOrder = -1;
    [_objectsGroup addChild:newContent];
    
    CCLOG(@"load new content! at y: %d", _contentHeight);
    
    // update varibles for CCActionFollow
    _contentHeight += newContent.boundingBox.size.height;
}


- (void)followChatacter {
    CCLOG(@"follow character with height %d", _contentHeight);
    _contentBoundingBox = CGRectMake(self.boundingBox.origin.x, self.boundingBox.origin.y, self.boundingBox.size.width, _contentHeight);
    _followCharacter = [CCActionFollow actionWithTarget:_character worldBoundary:_contentBoundingBox];
    [_contentNode runAction:_followCharacter];
}

- (void)update:(CCTime)delta {
    //TODO: optimize
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
    
    // if character reach top of the scene, load new content.
    if(!_tempFlag) {
        int yMax = _character.boundingBox.origin.y + _character.boundingBox.size.height;
        //int screenTop = self.boundingBox.origin.y + self.boundingBox.size.height;
        int halfVerticalSize = [[UIScreen mainScreen] bounds].size.height / 2;
        
        if (yMax + halfVerticalSize > _contentHeight) {
            [self stopUserInteraction];
            [self loadNewContent];
            [self startUserInteraction];
            [_contentNode stopAllActions];
            [self followChatacter];
            
            _tempFlag = true;
        }
    }
}

- (void)startUserInteraction {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;

    [[[CCDirector sharedDirector] view] addGestureRecognizer:_swipeLeft];
    [[[CCDirector sharedDirector] view] addGestureRecognizer:_swipeRight];
}

- (void)stopUserInteraction {
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeLeft];
    [[[CCDirector sharedDirector] view] removeGestureRecognizer:_swipeRight];
    
    // stop accept touches.
    self.userInteractionEnabled = false;
}


-(BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA cloud:(CCNode *)nodeB {
    //CCLOG(@"character collided with cloud!");
    
    _cloudHit += 1;
    _score += _cloudHit * 10;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_score];
    
    // after hit one cloud, start to follow the character
    // if start following in didLoadFromCCB, the GamePlay scene won't show up correctly. (why?)
    if (_cloudHit == 1) {
        [self followChatacter];
    }
    
    [_character jump];
    [self cloudRemoved:nodeB];
    
    return YES;
}

- (BOOL)ccPhysicsCollisionBegin:(CCPhysicsCollisionPair *)pair character:(CCNode *)nodeA star:(CCNode *)nodeB {
    //CCLOG(@"character collided with star!");
    _score *= 2;
    _scoreLabel.string = [NSString stringWithFormat:@"%ld", (long)_score];
    
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
    ScoreAdd *scoreAdd = (ScoreAdd *) [CCBReader load:@"ScoreAdd"];
    scoreAdd.position = cloud.position;
    [scoreAdd setScore:(_cloudHit * 10)];
    [cloud.parent addChild:scoreAdd];
    
    // remove a cloud from the scene
    [cloud removeFromParent];
}

- (void)starRemoved:(CCNode *)star {
    // show "score double" for a short time
    // use star.parent as the whole object!
    ScoreDouble *scoreDouble = (ScoreDouble *) [CCBReader load:@"ScoreDouble"];
    scoreDouble.position = star.parent.position;
    [star.parent.parent addChild:scoreDouble];
    
    // remove the entire starSpinging object from parent, not just the star.
    [star.parent removeFromParent];
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
    [self followChatacter];
}

@end
