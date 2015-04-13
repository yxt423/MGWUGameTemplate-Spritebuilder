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
    
    int screenHeight, screenWidth;
    int screenLeft, screenRight;
    
    int gamePlayState;
    bool muted;
    
    int currentScore;
    int highestScore;
    
    int characterHighest;
    CCNode *sharedObjectsGroup;
    
    int gamePlayTimes;
}

@property (nonatomic, assign) int screenHeight, screenWidth;
@property (nonatomic, assign) int screenLeft, screenRight;

@property (nonatomic, assign) int gamePlayState;
@property (nonatomic, assign) bool muted;

@property (nonatomic, assign) int currentScore;
@property (nonatomic, assign) int highestScore;

@property (nonatomic, assign) int characterHighest;
@property (nonatomic, retain) CCNode *sharedObjectsGroup;

@property (nonatomic, assign) int gamePlayTimes;

+ (id)getGameManager;

+ (NSString *)scoreWithComma: (int)s;

- (void)initDeviceParam: (MainScene *)mainScene;

@end
