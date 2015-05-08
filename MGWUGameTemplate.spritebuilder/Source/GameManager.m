//
//  GameManager.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//
/*
 Singleton. 
 - Maintain the state of game, socres, game settings, etc. 
 - Utility functions.
 */

#import "GameManager.h"
#import "Mixpanel.h"
#import "MainScene.h"

@implementation GameManager {
    Mixpanel *_mixpanel;
    NSUserDefaults *_defaults;
}

@synthesize screenHeight, screenWidth;
@synthesize screenLeft, screenRight;
@synthesize screenHeightInPoints, screenWidthInPoints;
@synthesize tapUIScaleDifference;

@synthesize currentScore, highestScore;
@synthesize newHighScore;
@synthesize scoreBoard;
@synthesize userName;

@synthesize gamePlayState;
@synthesize muted;
@synthesize characterHighest;  //the highest position the character ever been to
@synthesize sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.
@synthesize bubbleNumLabel;
@synthesize gamePlayTimes;
@synthesize bubbleNum;
@synthesize cloudHit;
@synthesize audio;

/* init functions */

- (id)init {
    if (self = [super init]) {
        CCLOG(@"Game Maneger Init.");
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        characterHighest = 0;
        _defaults = [NSUserDefaults standardUserDefaults];
        
        // init veriables from local
        highestScore = (int)[_defaults integerForKey:@"highscore"];  // long to int, loss
        gamePlayTimes = (int)[_defaults integerForKey:@"gamePlayTimes"];
        if (!gamePlayTimes) {
            gamePlayTimes = 0;
        }
        muted = [_defaults boolForKey:@"muted"];
        if (!muted) {
            muted = false;
        }
        bubbleNum = (int)[_defaults integerForKey:@"bubbleNum"];
        if (!bubbleNum) {
            bubbleNum = 0;
        }
        
        audio = [OALSimpleAudio sharedInstance];
        audio.effectsVolume = 1;
        audio.muted = muted;
        
        scoreBoard = [NSMutableArray arrayWithArray:[_defaults arrayForKey:@"scoreBoard"]];
        userName = [_defaults stringForKey:@"userName"];
        CCLOG(@"userName %@", userName);
        
        _mixpanel = [Mixpanel sharedInstance];
        [_mixpanel track:@"Game Open"];
    }
    return self;
}

+ (id)getGameManager {
    static GameManager *gameManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        gameManager = [[self alloc] init];
    });
    return gameManager;
}

- (void)initDeviceParam: (MainScene *)mainScene {
    // init devide screen related parameters.
    screenHeight = mainScene.boundingBox.size.height;
    screenWidth = mainScene.boundingBox.size.width;
    screenLeft = mainScene.boundingBox.origin.x;
    screenRight = screenLeft + screenWidth;
    screenHeightInPoints = [[UIScreen mainScreen] bounds].size.height;
    screenWidthInPoints = [[UIScreen mainScreen] bounds].size.width;
    tapUIScaleDifference = screenWidthInPoints / screenWidth;
    CCLOG(@"screenHeight %d", screenHeight);
    CCLOG(@"screenWidth %d", screenWidth);
    CCLOG(@"screenHeightInPoints %d", screenHeightInPoints);
    CCLOG(@"screenWidthInPoints %d", screenWidthInPoints);
    CCLOG(@"tapUIScaleDifference %d", tapUIScaleDifference);
}

/* parameters related */

- (void)updateScoreBoard: (int)score {
    if ([scoreBoard count] == 0) {
        [scoreBoard insertObject:[NSNumber numberWithInt:score] atIndex:0];
        [_defaults setObject:scoreBoard forKey:@"scoreBoard"];
        [_defaults synchronize];
        return;
    }
    
    for (int i = 0; i < [scoreBoard count]; i++) {
        if (score >= [[scoreBoard objectAtIndex:i] intValue]) {
            [scoreBoard insertObject:[NSNumber numberWithInt:score] atIndex:i];
            if ([scoreBoard count] > 5) {
                [scoreBoard removeLastObject];
            }
            
            [_defaults setObject:scoreBoard forKey:@"scoreBoard"];
            [_defaults synchronize];
            return;
        }
    }
    
    if ([scoreBoard count] < 5) {
        [scoreBoard insertObject:[NSNumber numberWithInt:score] atIndex:[scoreBoard count]];
        [_defaults setObject:scoreBoard forKey:@"scoreBoard"];
        [_defaults synchronize];
    }
}

- (void)setHighestScore: (int)score {
    CCLOG(@"new high score!");
    highestScore = score;
    [_defaults setInteger:score forKey:@"highscore"];
    [_defaults synchronize];
}

- (void)addBubble: (int)num {
    // add bubbleNum and save to local.
    bubbleNum += num;
    [_defaults setInteger:bubbleNum forKey:@"bubbleNum"];
    [_defaults synchronize];
}

- (void)setBubbleNum:(int)num {
    CCLOG(@"set bubble num to %d", num);
    
    bubbleNum = num;
    [_defaults setInteger:num forKey:@"bubbleNum"];
    [_defaults synchronize];
}

- (void)updateBubbleNumInGamePlay:(int)num {
    bubbleNumLabel.string = [NSString stringWithFormat:@"%d", bubbleNum];
}

- (float)getRandomXAtSameLineWith: (float)x {
    if (x < screenWidth / 2) {
        return arc4random_uniform(screenWidth / 2 - 40) + screenWidth / 2 + 20;
    } else {
        return arc4random_uniform(screenWidth / 2 - 40) + 20;
    }
}

/* Class methods */

/* get game parameters */

+ (int)getCloudIntervalAt: (int)height {
    int _cloudInterval;
    
    if (height > 8000) {
        _cloudInterval = 42;
    } else if (height > 5000) {
        _cloudInterval = 39;
    } else if (height > 3000) {
        _cloudInterval = 36;
    } else if (height > 1000) {
        _cloudInterval = 33;
    } else {
        _cloudInterval = 30;
    }
    
    return _cloudInterval;
}

+ (float)getCloudScaleAt: (int)height {
    float _cloudScale;
    
    if (height < 5000) {
        _cloudScale = 1.f;
    } else if (height < 10000) {
        _cloudScale = 0.9f;
    } else if (height < 18000) {
        _cloudScale = 0.8f;
    } else if (height < 26000) {
        _cloudScale = 0.7f;
    } else {
        _cloudScale = 0.6f;
    }
    
    return _cloudScale;
}

- (CCPositionType)getPTNormalizedTopLeft {
    return CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
}

- (CCPositionType)getPTUnitTopLeft {
    return CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
}

/* UI effect methods. */

+ (void)replaceSceneWithFadeTransition: (NSString*)newSceneName {
    CCScene *newScene = [CCBReader loadAsScene:newSceneName];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.4f];
    [[CCDirector sharedDirector] replaceScene:newScene withTransition:transition];
}

+ (void)pushSceneWithFadeTransition: (NSString*)newSceneName {
    CCScene *newScene = [CCBReader loadAsScene:newSceneName];
    CCTransition *transition = [CCTransition transitionFadeWithDuration:0.4f];
    [[CCDirector sharedDirector] pushScene:newScene withTransition:transition];
}

+ (CCNode *)addCCNodeFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode {
    CCNode * node = [CCBReader load:fileName];
    node.positionType =positionType;
    node.position = position;
    [parentNode addChild:node];
    return node;
}

+ (void)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode {
    CCParticleSystem *node = (CCParticleSystem *)[CCBReader load:fileName];
    node.autoRemoveOnFinish = TRUE;
    node.position = position;
    node.positionType = positionType;
    [parentNode addChild:node];
}

+ (void)playThenCleanUpAnimationOf: (CCNode *)node Named: (NSString *)name {
    CCAnimationManager* animationManager = node.userObject;
    [animationManager runAnimationsForSequenceNamed:name];
    
    // remove the node from scene after finish.
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [node removeFromParentAndCleanup:YES];
    }];
}

+ (NSString *)scoreWithComma: (int)s{
    NSString * result = @"";
    
    while (true) {
        int last3Digits = s % 1000;
        s /= 1000;
        NSString * newStr = [NSString stringWithFormat:@"%d", last3Digits];
        result = [newStr stringByAppendingString:result];
        if (s == 0) {
            return result;
        }
        if (newStr.length == 2) {
            result = [@"0" stringByAppendingString:result];
        } else if (newStr.length == 1) {
            result = [@"00" stringByAppendingString:result];
        }
        result = [@"," stringByAppendingString:result];
    }
    
    return result;
}

@end
