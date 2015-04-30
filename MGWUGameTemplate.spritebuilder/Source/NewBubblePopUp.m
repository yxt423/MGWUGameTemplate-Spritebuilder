//
//  NewBubblePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewBubblePopUp.h"
#import "GameManager.h"

@implementation NewBubblePopUp {
    CCNode *_newBubblePopUp;
}

- (void)ok {
    [GameManager replaceSceneWithFadeTransition:@"GamePlay"];
}

@end
