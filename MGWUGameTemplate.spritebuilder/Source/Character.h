//
//  Character.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 2/20/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "CCSprite.h"

@interface Character : CCSprite

- (void)jump;
- (void)jumpHigh;
- (void)moveLeft;
- (void)moveRight;
- (void)bubbleUp;
- (void)stop;

- (void)tapGestureCharacterMove: (CGPoint)point;

@end
