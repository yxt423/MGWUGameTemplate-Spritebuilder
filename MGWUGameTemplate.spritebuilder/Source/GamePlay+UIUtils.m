//
//  GamePlay+UIUtils.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay+UIUtils.h"
#import "GameManager.h"
#import "BubbleObject.h"

@implementation GamePlay (UIUtils)

// loadNewContent by ramdomly generate game content.
- (void)loadNewContent {
    _objectInterval = [self getObjectIntervalAt:_contentHeight];
    _cloudScale = [self getCloudScaleAt:_contentHeight];
    
    [self addClouds:arc4random_uniform(10) + 15];
    
    int randomNum = arc4random_uniform(100);
    if (randomNum < 10) {
        // add bubble.
        BubbleObject *bubbleObject = (BubbleObject *)[CCBReader load:@"Objects/BubbleObject"];
        _contentHeight += _objectInterval;
        bubbleObject.position = ccp(arc4random_uniform(_gameManager.screenWidth - 80) + 40, _contentHeight);
        bubbleObject.zOrder = -1;
        [_objectsGroup addChild:bubbleObject];
        
    } else if (randomNum < 50) {
        // add cloudBlack.
        CCNode *cloudBlack = [CCBReader load:@"Objects/CloudBlack"];
        _contentHeight += _objectInterval;
        cloudBlack.position = ccp(arc4random_uniform(_gameManager.screenWidth - 40) + 20, _contentHeight);
        cloudBlack.zOrder = -1;
        [_objectsGroup addChild:cloudBlack];
        [self addAdditionalCloudWith:cloudBlack.position.x];
        
    } else {
        // add star.
        CCNode *star;
        if (_starHit < 2) {
            star = [CCBReader load:@"Objects/StarStatic"];
        } else if (_starHit < 5) {
            star = [CCBReader load:@"Objects/StarSpining40"];
        } else {
            star = [CCBReader load:@"Objects/StarSpining80"];
        }
        _contentHeight += _objectInterval;
        star.position = ccp(arc4random_uniform(_gameManager.screenWidth - 80) + 40, _contentHeight);
        star.zOrder = -1;
        [_objectsGroup addChild:star];
    }
    
    //    CCLOG(@"interval %d, scale, %f", _objectInterval, _cloudScale);
}

/* load game content - cloud related */

- (void)addClouds: (int)num {
    for (int i = 0; i < num; i++) {
        CCNode *cloud = [CCBReader load:@"Objects/Cloud"];
        _contentHeight += _objectInterval;
        float ramdon = arc4random_uniform(_gameManager.screenWidth - 40);
        cloud.position = ccp(ramdon + 20, _contentHeight);
        cloud.zOrder = -1;
        cloud.scale = _cloudScale;
        [_objectsGroup addChild:cloud];
        // if this cloud is too close to the left/right screen edge, add another one.
        if (ramdon / (_gameManager.screenWidth - 40) < 0.07 || ramdon / (_gameManager.screenWidth - 40) > 0.93) {
            [self addSymmetricCloudWith:ramdon + 20];
        }
    }
}

- (void)addAdditionalCloudWith: (int)x {
    CCNode *cloud = [CCBReader load:@"Objects/Cloud"];
    cloud.position = ccp([self getRandomXAtSameLineWith:x], _contentHeight);
    cloud.zOrder = -1;
    cloud.scale = _cloudScale;
    [_objectsGroup addChild:cloud];
}

- (void)addSymmetricCloudWith: (int)x {
    CCNode *cloud = [CCBReader load:@"Objects/Cloud"];
    cloud.position = ccp(_gameManager.screenWidth - x, _contentHeight);
    cloud.zOrder = -1;
    cloud.scale = _cloudScale;
    [_objectsGroup addChild:cloud];
}

- (float)getRandomXAtSameLineWith: (float)x {
    int screenWidth = _gameManager.screenWidth;
    if (x < screenWidth / 2) {
        return arc4random_uniform(screenWidth / 2 - 40) + screenWidth / 2 + 20;
    } else {
        return arc4random_uniform(screenWidth / 2 - 40) + 20;
    }
}

/* get game parameters */

- (int)getObjectIntervalAt: (int)height {
    int _interval;
    
    if (height > 8000) {
        _interval = 42;
    } else if (height > 5000) {
        _interval = 39;
    } else if (height > 3000) {
        _interval = 36;
    } else if (height > 1000) {
        _interval = 33;
    } else {
        _interval = 30;
    }
    
    return _interval;
}

- (float)getCloudScaleAt: (int)height {
    float _scale;
    
    if (height < 5000) {
        _scale = 1.f;
    } else if (height < 10000) {
        _scale = 0.9f;
    } else if (height < 18000) {
        _scale = 0.8f;
    } else if (height < 26000) {
        _scale = 0.7f;
    } else {
        _scale = 0.6f;
    }
    
    return _scale;
}

- (void)updateScore {
    _scoreLabel.string = [GameManager scoreWithComma:score];
}

/* Bubble num related */

- (void)updateBubbleNum {
    CCSpriteFrame* bubbleLifeFrame = [CCSpriteFrame frameWithImageNamed:@"Assets/Gadgets/bubbleLife_100.png"];
    CCSpriteFrame* bubbleUsedFrame = [CCSpriteFrame frameWithImageNamed:@"Assets/Gadgets/bubbleUsed_100.png"];
    switch (_bubbleToUse) {
        case 0:
            _bubbleLife1.spriteFrame = bubbleUsedFrame;
            _bubbleLife2.spriteFrame = bubbleUsedFrame;
            _bubbleLife3.spriteFrame = bubbleUsedFrame;
            break;
        case 1:
            _bubbleLife1.spriteFrame = bubbleLifeFrame;
            _bubbleLife2.spriteFrame = bubbleUsedFrame;
            _bubbleLife3.spriteFrame = bubbleUsedFrame;
            break;
        case 2:
            _bubbleLife1.spriteFrame = bubbleLifeFrame;
            _bubbleLife2.spriteFrame = bubbleLifeFrame;
            _bubbleLife3.spriteFrame = bubbleUsedFrame;
            break;
        case 3:
            _bubbleLife1.spriteFrame = bubbleLifeFrame;
            _bubbleLife2.spriteFrame = bubbleLifeFrame;
            _bubbleLife3.spriteFrame = bubbleLifeFrame;
            break;
        default:
            CCLOG(@"ERROR, _bubbleToUse out of range!!!");
            break;
    }
}

@end
