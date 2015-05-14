//
//  GamePlay+UIUtils.h
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 5/13/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "GamePlay.h"

@interface GamePlay (UIUtils)

- (void)loadNewContent;
/* load game content - cloud related */
- (void)addClouds: (int)num;
- (void)addAdditionalCloudWith: (int)x;
- (void)addSymmetricCloudWith: (int)x;
- (float)getRandomXAtSameLineWith: (float)x;

/* get game parameters */
- (int)getObjectIntervalAt: (int)height;
- (float)getCloudScaleAt: (int)height;

- (void)updateScore;
- (void)updateBubbleNum;

@end
