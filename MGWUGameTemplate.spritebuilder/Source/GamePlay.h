//
//  GamePlay.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicScene.h"

@interface GamePlay : BasicScene <CCPhysicsCollisionDelegate> {
    int score;
    
    CCLabelTTF *_scoreLabel;

    int _bubbleLimit;
    int _bubbleToUse;
    CCSprite *_bubbleLife1;
    CCSprite *_bubbleLife2;
    CCSprite *_bubbleLife3;
}

@property (nonatomic, assign) int score;
@property (nonatomic, assign) int highScore;

@property (nonatomic, retain) CCLabelTTF *_scoreLabel;

@property (nonatomic, assign) int _bubbleLimit;
@property (nonatomic, assign) int _bubbleToUse;
@property (nonatomic, retain) CCSprite *_bubbleLife1;
@property (nonatomic, retain) CCSprite *_bubbleLife2;
@property (nonatomic, retain) CCSprite *_bubbleLife3;

@end
