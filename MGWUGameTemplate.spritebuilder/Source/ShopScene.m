//
//  ShopScene.m
//  MGWUGameTemplate
//
//  Created by Xintong Yu on 7/12/15.
//  Copyright (c) 2015 Apportable. All rights reserved.
//

#import "ShopScene.h"
#import "GameManager.h"

@implementation ShopScene

- (void)backToMainScene {
    [GameManager replaceSceneWithFadeTransition:@"MainScene"];
}

@end
