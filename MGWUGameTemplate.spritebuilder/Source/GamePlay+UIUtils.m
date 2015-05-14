//
//  GamePlay+UIUtils.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay+UIUtils.h"
#import "GameManager.h"

@implementation GamePlay (UIUtils)


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
            CCLOG(@"_bubbleToUse out of range!!!");
            break;
    }
    CCLOG(@"_bubbleToUse %d", _bubbleToUse);
}

@end
