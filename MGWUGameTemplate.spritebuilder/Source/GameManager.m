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


@implementation GameManager

@synthesize screenHeight, screenWidth;
@synthesize screenLeft, screenRight;
@synthesize currentScore, highestScore;
@synthesize gamePlayState;
@synthesize muted;
@synthesize characterHighest;  //the highest position the character ever been to
@synthesize objectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.

- (id)init {
    if (self = [super init]) {
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        
        muted = [[NSUserDefaults standardUserDefaults] boolForKey:@"muted"];
        if (!muted) {
            muted = false;
        }
        
        // init highest score
        highestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];
        
        // init devide parameters.
        screenHeight = [[UIScreen mainScreen] bounds].size.height;
        screenWidth = [[UIScreen mainScreen] bounds].size.width;
        screenLeft = [[UIScreen mainScreen] bounds].origin.x;
        screenRight = screenLeft + screenWidth;
        
        characterHighest = 0;
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

- (void)setHighestScore: (int)score {
    CCLOG(@"new high score!");
    highestScore = score;
    [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"highscore"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (NSString *)scoreWithComma: (int)s{
    NSString * result = @"";
    
    while (true) {
        int last3Digits = s % 1000;
        s /= 1000;
        result = [[NSString stringWithFormat:@"%d", last3Digits] stringByAppendingString:result];
        if (s == 0) {
            return result;
        }
        result = [@"," stringByAppendingString:result];
    }
    
    return result;
}

/*
- (void)playBackGroundMusic {
    OALSimpleAudio *bgMusic = [OALSimpleAudio sharedInstance];
    bgMusic.bgVolume = 1;
    [bgMusic playBg:@"High Mario.mp3" loop:YES];
}
 */

@end
