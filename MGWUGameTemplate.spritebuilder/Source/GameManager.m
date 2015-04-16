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
}

@synthesize screenHeight, screenWidth;
@synthesize screenLeft, screenRight;
@synthesize currentScore, highestScore;
@synthesize gamePlayState;
@synthesize muted;
@synthesize characterHighest;  //the highest position the character ever been to
@synthesize sharedObjectsGroup; // equals to _objectsGroup. used by the clouds in class method getPositionInObjectsGroup.
@synthesize gamePlayTimes;
@synthesize bubbleNum;

- (id)init {
    if (self = [super init]) {
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        characterHighest = 0;
        
        // init veriables from local
        highestScore = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"highscore"];  // long to int, loss
        gamePlayTimes = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"gamePlayTimes"];
        if (!gamePlayTimes) {
            gamePlayTimes = 0;
        }
        muted = [[NSUserDefaults standardUserDefaults] boolForKey:@"muted"];
        if (!muted) {
            muted = false;
        }
        bubbleNum = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"bubbleNum"];
        if (!bubbleNum) {
            bubbleNum = 0;
        }
        // for testing.
        bubbleNum += 5;
        [[NSUserDefaults standardUserDefaults] setInteger:bubbleNum forKey:@"bubbleNum"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
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
    CCLOG(@"screenHeight %d", screenHeight);
    CCLOG(@"screenWidth %d", screenWidth);
}

/* scoring functions */

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

/*
- (void)playBackGroundMusic {
    OALSimpleAudio *bgMusic = [OALSimpleAudio sharedInstance];
    bgMusic.bgVolume = 1;
    [bgMusic playBg:@"High Mario.mp3" loop:YES];
}
 */

@end
