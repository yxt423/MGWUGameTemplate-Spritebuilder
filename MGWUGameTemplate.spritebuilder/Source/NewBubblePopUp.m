//
//  NewBubblePopUp.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/15/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "NewBubblePopUp.h"

@implementation NewBubblePopUp {
    CCNode *_newBubblePopUp;
}

- (void)ok {
    CCAnimationManager* animationManager = _newBubblePopUp.userObject;
    [animationManager runAnimationsForSequenceNamed:@"Disappear"];
    
    // remove the popUp from mainScene after finish.
    [animationManager setCompletedAnimationCallbackBlock:^(id sender) {
        [_newBubblePopUp removeFromParentAndCleanup:YES];
    }];
}

@end
