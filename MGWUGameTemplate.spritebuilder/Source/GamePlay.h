//
//  GamePlay.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "BasicScene.h"
@class Character;

@interface GamePlay : BasicScene <CCPhysicsCollisionDelegate> {
    int _score;
    
    // stats
    int _starHit;
    int _contentHeight;
    int _objectInterval;
    float _cloudScale;
    
    CCNode *_objectsGroup;
    CCLabelTTF *_scoreLabel;

    int _bubbleLimit;
    int _bubbleToUse;
    CCSprite *_bubbleLife1, *_bubbleLife2, *_bubbleLife3;
    
    Character *_character;
    CCButton *_buttonPause, *_buttonBubble;
    CCNode *_walls;
}

@property (nonatomic, assign) int _score;

@property (nonatomic, assign) int _starHit;
@property (nonatomic, assign) int _contentHeight;
@property (nonatomic, assign) int _objectInterval;
@property (nonatomic, assign) float _cloudScale;

@property (nonatomic, retain) CCNode *_objectsGroup;
@property (nonatomic, retain) CCLabelTTF *_scoreLabel;

@property (nonatomic, assign) int _bubbleLimit;
@property (nonatomic, assign) int _bubbleToUse;
@property (nonatomic, retain) CCSprite *_bubbleLife1;
@property (nonatomic, retain) CCSprite *_bubbleLife2;
@property (nonatomic, retain) CCSprite *_bubbleLife3;

@property (nonatomic, retain) Character *_character;
@property (nonatomic, retain) CCButton *_buttonPause, *_buttonBubble;
@property (nonatomic, retain) CCNode *_walls;

- (void)resume;

@end
