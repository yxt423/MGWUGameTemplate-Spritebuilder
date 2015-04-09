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
    
    _scoreLabel.string = [self scoreWithComma:score];
    _highScoreLabel.string = [self scoreWithComma:highScore];
}

- (void)playAgain {
    // resload gameplay scene
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GamePlay"]];
}

- (NSString *)scoreWithComma: (NSNumber *)score{
    NSString * result = @"";
    int s = [score intValue]; // use int s = score will cause problem!
    int counter = 0;
    
    while (true) {
        int lastDigit = s % 10;
        s /= 10;
        result = [[NSString stringWithFormat:@"%d", lastDigit] stringByAppendingString:result];
        if (s == 0) {
            return result;
        }
        counter++;
        if (counter == 3) {
            result = [@"," stringByAppendingString:result];
            counter = 0;
        }
    }
    
    return result;
}

- (void)backToMainScene {
    CCScene *mainScene = [CCBReader loadAsScene:@"MainScene"];
    [[CCDirector sharedDirector] replaceScene:mainScene];
}

@end
