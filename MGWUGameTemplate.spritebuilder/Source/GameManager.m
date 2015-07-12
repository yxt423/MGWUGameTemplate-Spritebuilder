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
#import "GameOver.h"

@implementation GameManager {
    Mixpanel *_mixpanel;
    NSUserDefaults *_defaults;
}

@synthesize screenHeight, screenWidth, screenLeft, screenRight;
@synthesize screenHeightInPoints, screenWidthInPoints;
@synthesize tapUIScaleDifference;

@synthesize gamePlayState, mainSceneState, tutorialProgress, currentSceneNo;

@synthesize muted, cloudHit;
@synthesize characterHighest;  //the highest position the character ever been to

@synthesize currentScore, highestScore, newHighScore, scoreBoard;

@synthesize gamePlayTimes, audio;
@synthesize sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.

@synthesize bubbleStartNum, energyNum;

@synthesize TIMETO_SHOW_TUTORIAL1, TIMETO_SHOW_TUTORIAL2, TIMETO_START_ENERGY, FREE_ENERGY_EVERYDAY, FREE_STARTING_BUBBLE;
@synthesize MAINSCENE_NO, GAMEPLAYSCENE_NO, GAMEOVERSCENE_NO;

/* init functions */

- (id)init {
    if (self = [super init]) {
        CCLOG(@"Game Manager Init.");
        
        // constants init.
        TIMETO_SHOW_TUTORIAL1 = 0;
        TIMETO_SHOW_TUTORIAL2 = 3;
        TIMETO_START_ENERGY = 5;
        FREE_ENERGY_EVERYDAY = 3;
        FREE_STARTING_BUBBLE = 1;
        // currentSceneNo: 0, no init, 1, mainscene. 2, gameplay scene, 3, game over scene.
        MAINSCENE_NO = 1, GAMEPLAYSCENE_NO = 2, GAMEOVERSCENE_NO = 3;
        _defaults = [NSUserDefaults standardUserDefaults];
        
        currentSceneNo = 0;
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        // mainSceneState: 0, on going, 1 paused. 
        mainSceneState = 0;
        characterHighest = 0;
        
        // veriables from local storage.
        
        // TO change to two sections.
        if (gamePlayTimes == 0) {
            [_defaults setObject:[NSDate date] forKey:@"lastGiftTime"];
        }
        
        /* tutorialProgress: 0, not started, 1, tutorial1 finished,
           2, swipeUp gesture enabled in game. 3, tutorial 2 (bubble) finished.  */
        tutorialProgress = (int)[_defaults integerForKey:@"tutorialProgress"];
        if (!tutorialProgress) {
            // only outside this class, setter will be automaticlly called when assigning value
            [self setTutorialProgress:0];
        }
        
        highestScore = (int)[_defaults integerForKey:@"highscore"];  // long to int, loss
        gamePlayTimes = (int)[_defaults integerForKey:@"gamePlayTimes"];
        if (!gamePlayTimes) {
            [self setGamePlayTimes:0];
        }
        
        muted = [_defaults boolForKey:@"muted"];
        if (!muted) {
            muted = false;
        }
        bubbleStartNum = (int)[_defaults integerForKey:@"bubbleStartNum"];
        if (!bubbleStartNum) {
            [self setBubbleStartNum:0];
        }
        
        energyNum = (int)[_defaults integerForKey:@"energyNum"];
        if (!energyNum) {
            [self setEnergyNum:FREE_ENERGY_EVERYDAY];
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

/* func about starting a new game */

- (void)playButton: (BasicScene *)scene {
    // new players got to play several times for free.
    if (gamePlayTimes < TIMETO_START_ENERGY) {
        [self startNewGame];
        return;
    }
    
    if (gamePlayTimes == TIMETO_START_ENERGY) {
        [GameManager addCCNodeFromFile:@"PopUp/EnergyStartPopUp" WithPosition:ccp(0.5, 0.5) Type:[self getPTNormalizedTopLeft] To:scene];
        return;
    }
    
    if ([self isNewGiftAvailable]) {
        CCLOG(@"new 10 bubbles!");
        [GameManager addCCNodeFromFile:@"PopUp/NewEnergyPopUp" WithPosition:ccp(0.5, 0.5) Type:[self getPTNormalizedTopLeft] To:scene];
        [self setEnergyNum:energyNum + FREE_ENERGY_EVERYDAY];
        [_defaults setObject:[NSDate date] forKey:@"lastGiftTime"];
        return;
    }
    
    [self energyMinusOneAndStartGame:scene];
}

- (void)energyMinusOneAndStartGame: (BasicScene *)scene {
    if (energyNum > 0) { // energyMinusOneAndStartGame
        [self setEnergyNum:energyNum - 1];
        if (currentSceneNo == MAINSCENE_NO) {
            [(MainScene *)scene updateEnergyLabel];
        } else if (currentSceneNo == GAMEOVERSCENE_NO) {
            [(GameOver *)scene updateEnergyLabel];
        }
        
        CCNode *energyMinus1 = [GameManager addCCNodeFromFile:@"Effects/EnergyMinus1" WithPosition:ccp(80, 20) Type:[self getPTUnitTopLeft] To:scene];
        CCAnimationManager* animationManager = energyMinus1.userObject;
        [animationManager runAnimationsForSequenceNamed:@"In"];
        [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
            [energyMinus1 removeFromParentAndCleanup:YES];
            [self startNewGame];
        }];
    } else { // show EnergyUsedUpPopUp
        [GameManager addCCNodeFromFile:@"PopUp/EnergyUsedUpPopUp" WithPosition:ccp(0.5, 0.5) Type:[self getPTNormalizedTopLeft] To:scene];
    }
}

- (void)startNewGame {
    if (gamePlayTimes == TIMETO_SHOW_TUTORIAL1) {
        [GameManager replaceSceneWithFadeTransition:@"Scenes/Tutorial"];
    } else if (gamePlayTimes == TIMETO_SHOW_TUTORIAL2) {
        [GameManager replaceSceneWithFadeTransition:@"Scenes/Tutorial_bubble"];
    } else {
        [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
    }
    CCLOG(@"start new game!");
}

- (bool)isNewGiftAvailable {
    NSDate *newTime = [NSDate date];
    NSDate *oldTime = [[NSUserDefaults standardUserDefaults] objectForKey:@"lastGiftTime"];
    CCLOG(@"newTime %@", newTime);
    CCLOG(@"oldTime %@", oldTime);
    if ([[oldTime dateByAddingTimeInterval:60*60*24*1] compare: newTime] == NSOrderedAscending) {
        return true;
    } else {
        return false;
    }
}

/* setters. store the value to local storage. 
 only outside this class, setter will be automaticlly called when assigning value. */

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

+ (CCParticleSystem *)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode {
    CCParticleSystem *node = (CCParticleSystem *)[CCBReader load:fileName];
    node.autoRemoveOnFinish = TRUE;
    node.position = position;
    node.positionType = positionType;
    [parentNode addChild:node];
    return node;
}

+ (CCParticleSystem *)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position To: (CCNode *)parentNode {
    CCParticleSystem *node = (CCParticleSystem *)[CCBReader load:fileName];
    node.autoRemoveOnFinish = TRUE;
    node.position = position;
    [parentNode addChild:node];
    return node;
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

@end
