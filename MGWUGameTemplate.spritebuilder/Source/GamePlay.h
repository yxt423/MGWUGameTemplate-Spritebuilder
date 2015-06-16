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
    // stats
    int _score;
    int _starHit;
    int _contentHeight;
    int _objectInterval;
    float _cloudScale;
    
    // elements of game
    Character *_character;
    CCButton *_buttonPause, *_buttonBubble;
    CCNode *_walls;
    CCNode *_objectsGroup;
    CCLabelTTF *_scoreLabel;

    // bubble life
    int _bubbleLimit;
    int _bubbleToUse;
    CCSprite *_bubbleLife1, *_bubbleLife2, *_bubbleLife3;
    
    // update about bubble
    CCNode *_bubble;
    bool _inBubble;
    float _timeInBubble;
}

@property (nonatomic, assign) int _score;
@property (nonatomic, assign) int _starHit;
@property (nonatomic, assign) int _contentHeight;
@property (nonatomic, assign) int _objectInterval;
@property (nonatomic, assign) float _cloudScale;

@property (nonatomic, retain) Character *_character;
@property (nonatomic, retain) CCButton *_buttonPause, *_buttonBubble;
@property (nonatomic, retain) CCNode *_walls;
@property (nonatomic, retain) CCNode *_objectsGroup;
@property (nonatomic, retain) CCLabelTTF *_scoreLabel;

@property (nonatomic, assign) int _bubbleLimit;
@property (nonatomic, assign) int _bubbleToUse;
@property (nonatomic, retain) CCSprite *_bubbleLife1;
@property (nonatomic, retain) CCSprite *_bubbleLife2;
@property (nonatomic, retain) CCSprite *_bubbleLife3;

@property (nonatomic, retain) CCNode *_bubble;
@property (nonatomic, assign) bool _inBubble;
@property (nonatomic, assign) float _timeInBubble;


- (void)update:(CCTime)delta;
- (void)updateAboutLoadNewContent:(CCTime)delta;
- (void)updateAboutBubble:(CCTime)delta;
- (void)swipeUpGesture:(UISwipeGestureRecognizer *)recognizer;
- (void)resume;

@end
