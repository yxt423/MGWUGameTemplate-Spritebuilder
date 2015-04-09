//
//  GameManager.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/8/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameManager.h"


@implementation GameManager

@synthesize gamePlayState;
@synthesize muted;

- (id)init {
    if (self = [super init]) {
        // gamePlayState: 0, on going, 1 paused, 2 to be resumed, 3 to be restarted, 4 soumd setting to be reversed
        gamePlayState = 0;
        
        muted = [[NSUserDefaults standardUserDefaults] boolForKey:@"muted"];
        if (!muted) {
            muted = false;
        }
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



@end
