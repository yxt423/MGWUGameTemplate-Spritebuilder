//
//  GameManager.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import <Foundation/Foundation.h>
@class MainScene;
@class BasicScene;

@interface GameManager : NSObject {
    // device params.
    int screenHeight, screenWidth;
    int screenLeft, screenRight;
    int screenHeightInPoints, screenWidthInPoints;
    int tapUIScaleDifference;
    
    // scene states.
    int gamePlayState;
    int mainSceneState;
    int tutorialProgress;
    int currentSceneNo;
    
    // for game play scene.
    bool muted;
    int characterHighest;
    int cloudHit;
    
    // for game over scene.
    int currentScore;
    int highestScore;
    bool newHighScore;
    NSMutableArray *scoreBoard;
    
    // shared var.
    int gamePlayTimes;
    CCNode *sharedObjectsGroup;
    OALSimpleAudio *audio;
    
    // IAP items
    int bubbleStartNum;
    int energyNum;
    
    // constants
    int TIMETO_SHOW_TUTORIAL1, TIMETO_SHOW_TUTORIAL2;
    int TIMETO_START_ENERGY;
    int FREE_ENERGY_EVERYDAY;
    int FREE_STARTING_BUBBLE;
    int MAINSCENE_NO, GAMEPLAYSCENE_NO, GAMEOVERSCENE_NO;
    
}

// device params.
@property (nonatomic, assign) int screenHeight, screenWidth; // for drawing objects on screen.
@property (nonatomic, assign) int screenHeightInPoints, screenWidthInPoints; // for comparing tap position and chatacter position. 
@property (nonatomic, assign) int screenLeft, screenRight;
@property (nonatomic, assign) int tapUIScaleDifference;
// screenHeight, screenWidth: iPhone4 480 320. iPad 512 384,
// screenHeightInPoints, screenWidthInPoints, iPad 1024 768
// tapUIPositionDifference = screenWidthInPoints / screenWidth;

// scene states.
@property (nonatomic, assign) int gamePlayState;
@property (nonatomic, assign) int mainSceneState;
@property (nonatomic, assign) int tutorialProgress;
@property (nonatomic, assign) int currentSceneNo;

// for game play scene.
@property (nonatomic, assign) bool muted;
@property (nonatomic, assign) int cloudHit;
@property (nonatomic, assign) int characterHighest;

// for game over scene.
@property (nonatomic, assign) int currentScore;
@property (nonatomic, assign) int highestScore;
@property (nonatomic, assign) bool newHighScore;
@property (nonatomic, retain) NSMutableArray *scoreBoard;

// shared var.
@property (nonatomic, assign) int gamePlayTimes;
@property (nonatomic, retain) CCNode *sharedObjectsGroup;
@property (nonatomic, retain) OALSimpleAudio *audio;

// IAP items
@property (nonatomic, assign) int bubbleStartNum;
@property (nonatomic, assign) int energyNum;

// constants
@property (nonatomic, assign) int TIMETO_SHOW_TUTORIAL1, TIMETO_SHOW_TUTORIAL2;
@property (nonatomic, assign) int TIMETO_START_ENERGY;
@property (nonatomic, assign) int FREE_ENERGY_EVERYDAY;
@property (nonatomic, assign) int FREE_STARTING_BUBBLE;
@property (nonatomic, assign) int MAINSCENE_NO, GAMEPLAYSCENE_NO, GAMEOVERSCENE_NO;

/* init functions */

+ (id)getGameManager;
- (void)initDeviceParam: (MainScene *)mainScene;

/* func about starting new game */
- (void)playButton: (BasicScene *)scene;
- (void)energyMinusOneAndStartGame: (BasicScene *)scene;
- (void)startNewGame;
- (bool)isNewGiftAvailable;

/* parameters related */


// get CCPositionType.
- (CCPositionType)getPTNormalizedTopLeft;
- (CCPositionType)getPTUnitTopLeft;
- (CCPositionType)getPTUnitTopRight;

/** Class methods */

/* UI effect methods. */
+ (CCActionFadeIn*)getFadeIn;
+ (CCActionFadeIn*)getFadeOut;
+ (CCNode *)addCCNodeFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode;
+ (CCNode *)addCCNodeFromFile: (NSString *)fileName WithPosition: (CGPoint)position To: (CCNode *)parentNode;
+ (CCParticleSystem *)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position Type: (CCPositionType)positionType To: (CCNode *)parentNode;
+ (CCParticleSystem *)addParticleFromFile: (NSString *)fileName WithPosition: (CGPoint)position To: (CCNode *)parentNode;
+ (void)playThenCleanUpAnimationOf: (CCNode *)node Named: (NSString *)name;

/* scene loading methods */
+ (void)replaceSceneWithFadeTransition: (NSString*)newSceneName;
+ (void)pushSceneWithFadeTransition: (NSString*)newSceneName;
+ (void)popSceneWithFadeTransition;


/* UI utilities. */
+ (NSString *)scoreWithComma: (int)s;
- (void)updateScoreBoard: (int)score;

@end
