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

@synthesize gamePlayState, mainSceneState, tutorialProgress;
@synthesize shopSceneNo; // 1, mainscene. 2, gameplay.

@synthesize muted, cloudHit;
@synthesize characterHighest;  //the highest position the character ever been to

@synthesize currentScore, highestScore, newHighScore, scoreBoard;

@synthesize gamePlayTimes, audio;
@synthesize sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.

@synthesize bubbleStartNum, energyNum;

@synthesize TIMETOSHOWTUTORIAL1, TIMETOSHOWTUTORIAL2;

/* init functions */

- (id)init {
    if (self = [super init]) {
        CCLOG(@"Game Manager Init.");
        
        // constants init.
        TIMETOSHOWTUTORIAL1 = 0;
        TIMETOSHOWTUTORIAL2 = 3;
        
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        // mainSceneState: 0, on going, 1 paused. 
        mainSceneState = 0;
        characterHighest = 0;
        _defaults = [NSUserDefaults standardUserDefaults];
        
        // veriables from local storage.
        
        // tutorialProgress: 0, not started, 1, tutorial1 finished, 2, swipeUp enabled. 3, tutorial 2 (bubble finished.)
        tutorialProgress = (int)[_defaults integerForKey:@"tutorialProgress"];
        if (!tutorialProgress) {
            tutorialProgress = 0;
        }
        
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
            bubbleStartNum = 0;
        }
        energyNum = (int)[_defaults integerForKey:@"energyNum"];
        if (!energyNum) {
            energyNum = 0;
        }
        
        audio = [OALSimpleAudio sharedInstance];
        audio.effectsVolume = 1;
        audio.muted = muted;
        
        scoreBoard = [NSMutableArray arrayWithArray:[_defaults arrayForKey:@"scoreBoard"]];
        
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

- (void)startNewGame {
    if (gamePlayTimes == TIMETOSHOWTUTORIAL1) {
        [GameManager replaceSceneWithFadeTransition:@"Scenes/Tutorial"];
    } else if (gamePlayTimes == TIMETOSHOWTUTORIAL2) {
        [GameManager replaceSceneWithFadeTransition:@"Scenes/Tutorial_bubble"];
    } else {
        [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
    }
    CCLOG(@"start new game!");
}

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

/* setters. store the value to local storage. */

- (void)setHighestScore: (int)score {
    CCLOG(@"new high score!");
    highestScore = score;
    [_defaults setInteger:score forKey:@"highscore"];
    [_defaults synchronize];
}

- (void)setGamePlayTimes:(int)times {
    gamePlayTimes = times;
    [_defaults setInteger:gamePlayTimes forKey:@"gamePlayTimes"];
    [_defaults synchronize];
}

- (void)setBubbleStartNum:(int)num {
    bubbleStartNum = num;
    [_defaults setInteger:bubbleStartNum forKey:@"bubbleStartNum"];
    [_defaults synchronize];
}

- (void)setTutorialProgress:(int)num {
    tutorialProgress = num;
    [_defaults setInteger:tutorialProgress forKey:@"tutorialProgress"];
    [_defaults synchronize];
}

- (void)setEnergyNum:(int)num {
    energyNum = num;
    [_defaults setInteger:energyNum forKey:@"energyNum"];
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

- (CCPositionType)getPTUnitTopRight {
    return CCPositionTypeMake(CCPositionUnitPoints, CCPositionUnitPoints, CCPositionReferenceCornerTopRight);
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

+ (CCActionFadeIn*)getFadeIn {
    return [CCActionFadeIn actionWithDuration:0.5];
}

+ (CCActionFadeOut*)getFadeOut {
    return [CCActionFadeOut actionWithDuration:0.5];
}

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
