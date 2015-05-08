//
//  InfoScene.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 4/9/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "InfoScene.h"
#import "GameManager.h"

@implementation InfoScene

- (void)backToMainScene {
    [GameManager popSceneWithFadeTransition];
//    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

@end
