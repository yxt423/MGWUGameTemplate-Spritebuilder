//
//  GameManager.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MainScene.h"

@interface GameManager : NSObject {
    // device params.
    int screenHeight, screenWidth;
    int screenLeft, screenRight;
    int screenHeightInPoints, screenWidthInPoints;
    int tapUIScaleDifference;
    
    // for game play scene.
    int gamePlayState;
    bool muted;
    int characterHighest;
    int cloudHit;
    CCNode *sharedObjectsGroup;
    OALSimpleAudio *audio;
    
    // for game over scene.
    int currentScore;
    int highestScore;
    bool newHighScore;
    
    // stats, objects count.
    int gamePlayTimes;
    int bubbleNum;
}

@property (nonatomic, assign) int screenHeight, screenWidth; // for drawing objects on screen.
@property (nonatomic, assign) int screenHeightInPoints, screenWidthInPoints; // for comparing tap position and chatacter position. 
@property (nonatomic, assign) int screenLeft, screenRight;
@property (nonatomic, assign) int tapUIScaleDifference;
// screenHeight, screenWidth: iPhone4 480 320. iPad 512 384,
// screenHeightInPoints, screenWidthInPoints, iPad 1024 768
// tapUIPositionDifference = screenWidthInPoints / screenWidth;

@property (nonatomic, assign) int gamePlayState;
@property (nonatomic, assign) bool muted;
@property (nonatomic, assign) int cloudHit;
@property (nonatomic, assign) int characterHighest;
@property (nonatomic, retain) CCNode *sharedObjectsGroup;
@property (nonatomic, retain) OALSimpleAudio *audio;

@property (nonatomic, assign) int currentScore;
@property (nonatomic, assign) int highestScore;
@property (nonatomic, assign) bool newHighScore;

@property (nonatomic, assign) int gamePlayTimes;
@property (nonatomic, assign) int bubbleNum;

/* init functions */

+ (id)getGameManager;
- (void)initDeviceParam: (MainScene *)mainScene;

/* parameters related */

- (void)addBubble: (int)num;
- (float)getRandomXAtSameLineWith: (float)x;

/** Class methods */

/* get game parameters */

+ (int)getCloudIntervalAt: (int)height;
+ (float)getCloudScaleAt: (int)height;

/* UI effect methods. */

+ (NSString *)scoreWithComma: (int)s;

+ (void)replaceSceneWithFadeTransition: (NSString*)newSceneName;
+ (void)pushSceneWithFadeTransition: (NSString*)newSceneName;
+ (void)playThenCleanUpAnimationOf: (CCNode *)node Named: (NSString *)name;

@end
