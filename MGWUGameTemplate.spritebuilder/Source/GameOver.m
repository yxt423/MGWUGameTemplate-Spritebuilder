//
//  GameOver.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/23/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GameOver.h"
#import "GamePlay.h"

@implementation GameOver {
    CCLabelTTF *_scoreLabel;
    CCLabelTTF *_highScoreLabel;
}


- (void)didLoadFromCCB {
    // show scores
    NSNumber *score = [[NSUserDefaults standardUserDefaults] objectForKey:@"score"];
    NSNumber *highScore = [[NSUserDefaults standardUserDefaults] objectForKey:@"highscore"];
    _scoreLabel.string = [NSString stringWithFormat:@"%d", [score intValue]];
    _highScoreLabel.string = [NSString stringWithFormat:@"%d", [highScore intValue]];
}

- (void)playAgain {
    // resload gameplay scene
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GamePlay"]];
}

@end
