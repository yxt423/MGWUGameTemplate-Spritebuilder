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

@property (nonatomic, assign) int screenHeight, screenWidth;
@property (nonatomic, assign) int screenLeft, screenRight;

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

+ (id)getGameManager;

+ (NSString *)scoreWithComma: (int)s;

- (void)initDeviceParam: (MainScene *)mainScene;

- (void)addBubble: (int)num;

@end
