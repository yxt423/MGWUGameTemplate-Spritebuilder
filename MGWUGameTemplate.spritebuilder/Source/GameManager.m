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

@synthesize screenHeight, screenWidth, screenLeft, screenRight;
@synthesize screenHeightInPoints, screenWidthInPoints;
@synthesize tapUIScaleDifference;

@synthesize currentScore, highestScore;
@synthesize newHighScore;
@synthesize scoreBoard;
@synthesize userName;

@synthesize gamePlayState, mainSceneState;
@synthesize shopSceneNo; // 1, mainscene. 2, gameplay.

@synthesize muted;
@synthesize characterHighest;  //the highest position the character ever been to
@synthesize sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.
@synthesize bubbleStartNum;

@synthesize gamePlayTimes;
@synthesize cloudHit;
@synthesize audio;

/* init functions */

- (id)init {
    if (self = [super init]) {
        CCLOG(@"Game Maneger Init.");
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        // mainSceneState: 0, on going, 1 paused. 
        mainSceneState = 0;
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
        bubbleStartNum = (int)[_defaults integerForKey:@"bubbleStartNum"];
        if (!bubbleStartNum) {
            bubbleStartNum = 3;
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

/* Class methods */

/* get PositionType */

- (CCPositionType)getPTNormalizedTopLeft {
    return CCPositionTypeMake(CCPositionUnitNormalized, CCPositionUnitNormalized, CCPositionReferenceCornerTopLeft);
}

- (CCPositionType)getPTUnitTopLeft {
    return CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopLeft);
}

/* scene loading methods */

+ (CCTransition *)getFadeTransition {
    return [CCTransition transitionFadeWithDuration:0.4f];
}

+ (void)replaceSceneWithFadeTransition: (NSString*)newSceneName {
    CCScene *newScene = [CCBReader loadAsScene:newSceneName];
    [[CCDirector sharedDirector] replaceScene:newScene withTransition:[self getFadeTransition]];
}

+ (void)pushSceneWithFadeTransition: (NSString*)newSceneName {
    CCScene *newScene = [CCBReader loadAsScene:newSceneName];
    [[CCDirector sharedDirector] pushScene:newScene withTransition:[self getFadeTransition]];
}

+ (void)popSceneWithFadeTransition {
    [[CCDirector sharedDirector] popSceneWithTransition:[self getFadeTransition]];
}

/* noces / objects loading methods. */

+ (CCNode *)addCCNodeFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode {
    CCNode * node = [CCBReader load:fileName];
    node.positionType = positionType;
    node.position = position;
    [parentNode addChild:node];
    return node;
}

+ (CCNode *)addCCNodeFromFile: (NSString *)fileName WithPosition: (CGPoint)position To: (CCNode *)parentNode {
    CCNode * node = [CCBReader load:fileName];
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

+ (void)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position To: (CCNode *)parentNode {
    CCParticleSystem *node = (CCParticleSystem *)[CCBReader load:fileName];
    node.autoRemoveOnFinish = TRUE;
    node.position = position;
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

/* UI utilities. */

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
