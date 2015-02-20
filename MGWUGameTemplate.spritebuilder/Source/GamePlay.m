//
//  GamePlay.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"
#import "Character.h"
#import "Cloud.h"

@implementation GamePlay {
    Character *_character;
}

- (void)didLoadFromCCB {
    // tell this scene to accept touches
    self.userInteractionEnabled = TRUE;
}

- (void)touchBegan:(CCTouch *)touch withEvent:(CCTouchEvent *)event {
    [_character jump];
}




- (void)restart {
    // reload this level
    [[CCDirector sharedDirector] replaceScene: [CCBReader loadAsScene:@"GamePlay"]];
}

@end
